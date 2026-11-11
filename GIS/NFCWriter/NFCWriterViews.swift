//
//  NFCWriterViews.swift
//  GIS
//
//  NFC Writer flow: select a purchased product -> enter Text / URL -> write to an NFC tag.
//  Compiled only when the `NFC_WRITER` build flag is set (see NFCWriterManager.swift).
//

#if NFC_WRITER
import SwiftUI
import UIKit
import Alamofire

// MARK: - Model

struct NFCWriterProduct: Identifiable, Equatable {
    let id: String
    let name: String
    let sku: String
    let stockId: String
    let metal: String
    let size: String
    let quantity: String
    let price: String
    let date: String
    let imageURL: URL?
    /// 24-character product id used in the product page link (empty when the order line has none).
    let productId: String

    init(item: NSDictionary, date: String, id: String) {
        func value(_ key: String) -> String {
            let string = item[key].map { "\($0)" } ?? ""
            return string == "<null>" ? "" : string
        }
        self.id = id
        name = value("name")
        sku = value("SKU")
        stockId = value("stock_id")
        metal = value("metal")
        size = value("size")
        quantity = value("qty").isEmpty ? "1" : value("qty")
        price = value("price")
        self.date = date
        imageURL = URL(string: value("main_image"))
        func isObjectId(_ string: String) -> Bool {
            string.count == 24 && string.allSatisfy { $0.isHexDigit }
        }
        let preferred = ["po_product_id", "product_id", "parentproduct_id", "productId", "_id", "id"]
            .map { value($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .first(where: isObjectId)
        // Fall back to any 24-character hex value on the order line (the API field name is not fixed).
        let anyId = item.allKeys.compactMap { key -> String? in
            guard let key = key as? String, key.lowercased() != "cart_id" else { return nil }
            let candidate = value(key).trimmingCharacters(in: .whitespacesAndNewlines)
            return isObjectId(candidate) ? candidate : nil
        }.first
        productId = preferred ?? anyId ?? ""
        if productId.isEmpty { print("NFCWriter: no product id on order line, keys = \(item.allKeys)") }
    }

    /// Flattens every cart line of the purchase-history orders into one product list.
    static func products(fromOrders orders: NSArray) -> [NFCWriterProduct] {
        var result = [NFCWriterProduct]()
        for (orderIndex, order) in orders.enumerated() {
            guard let order = order as? NSDictionary,
                  let cart = order["cart"] as? NSArray else { continue }
            let date = "\(order["date"] ?? "")"
            for (itemIndex, item) in cart.enumerated() {
                guard let item = item as? NSDictionary else { continue }
                result.append(NFCWriterProduct(item: item, date: date, id: "\(orderIndex)-\(itemIndex)"))
            }
        }
        return result
    }
}

// MARK: - Product share link

enum NFCProductLink {
    /// The same link the Product Detail "share" button produces (Mobile/catalog/getProductDetailPdf).
    /// Order lines of the purchase history carry no product id, so it is looked up from the stock id first.
    static func resolveURL(for product: NFCWriterProduct, completion: @escaping (String) -> Void) {
        if !product.productId.isEmpty {
            tryShareLink(candidates: [(product.productId, "inventory")], fallbackPoProductId: nil, completion: completion)
            return
        }
        guard !product.stockId.isEmpty else {
            print("NFCWriter: order line has no product id and no stock id")
            completion("")
            return
        }

        let params: [String: Any] = ["search": product.stockId, "type": "stock_id"]
        AF.request(mSearchItems, method: .post, parameters: params, headers: sGisHeaders2).responseJSON { response in
            print("NFCWriter: search stock \(product.stockId) response = \(String(describing: response.value))")
            guard let json = response.value, let id = findProductId(in: json) else {
                DispatchQueue.main.async { completion("") }
                return
            }
            // The inventory share uses the stock's po_product_id; if that finds nothing, fall back to the
            // product id from the detail endpoint (inventory, then catalog).
            tryShareLink(candidates: [(id, "inventory")], fallbackPoProductId: id, completion: completion)
        }
    }

    private static func tryShareLink(candidates: [(String, String)], fallbackPoProductId: String?, completion: @escaping (String) -> Void) {
        guard let (productId, type) = candidates.first else {
            if let poId = fallbackPoProductId {
                resolveShareProductId(for: poId) { shareId in
                    tryShareLink(candidates: [(shareId, "inventory"), (shareId, "catalog")], fallbackPoProductId: nil, completion: completion)
                }
            } else {
                DispatchQueue.main.async { completion("") }
            }
            return
        }
        requestShareLink(productId: productId, type: type) { link in
            if link.isEmpty {
                tryShareLink(candidates: Array(candidates.dropFirst()), fallbackPoProductId: fallbackPoProductId, completion: completion)
            } else {
                completion(link)
            }
        }
    }

    /// The search returns the stock's po_product_id; the Product Detail screen then asks the detail endpoint for
    /// the real product id that the share (PDF) API needs, so do the same here.
    private static func resolveShareProductId(for poProductId: String, completion: @escaping (String) -> Void) {
        mGetData(url: BaseUrl + "Mobile/pos/customOrder/productDetail", headers: sGisHeaders, params: ["id": poProductId]) { response, _ in
            var detail: NSDictionary?
            if let data = response["data"] as? NSDictionary {
                detail = data
            } else if let rows = response["data"] as? NSArray {
                detail = rows.firstObject as? NSDictionary
            }
            let keys = ["product_id", "parentproduct_id", "main_po_product_id", "baseVariant_id", "id", "_id"]
            let id = keys
                .map { "\(detail?[$0] ?? "")".trimmingCharacters(in: .whitespacesAndNewlines) }
                .first { !$0.isEmpty && $0 != "<null>" } ?? poProductId
            print("NFCWriter: detail \(poProductId) -> share product id \(id)")
            completion(id)
        }
    }

    private static func requestShareLink(productId: String, type: String, usingLegacyProductID: Bool = false, completion: @escaping (String) -> Void) {
        let website = (UserDefaults.standard.string(forKey: "website_url") ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let params: [String: Any] = [
            "product_id": usingLegacyProductID ? productId : [productId],
            "type": type,
            "website_url": website.isEmpty ? "ios.gis247.net" : website
        ]
        mGetData(url: BaseUrl + "Mobile/catalog/getProductDetailPdf", headers: sGisHeaders, params: params) { response, _ in
            // Older (UAT) servers still expect a single product id string instead of an array.
            if !usingLegacyProductID,
               "\(response.value(forKey: "code") ?? "")" == "400",
               "\(response.value(forKey: "message") ?? "")" == "product_id is required" {
                requestShareLink(productId: productId, type: type, usingLegacyProductID: true, completion: completion)
                return
            }
            let link = shareURL(from: response)
            print("NFCWriter: share link for \(productId) = '\(link)' response = \(response)")
            DispatchQueue.main.async { completion(link) }
        }
    }

    private static func shareURL(from response: NSDictionary) -> String {
        func clean(_ value: Any?) -> String {
            "\(value ?? "")".trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "<null>", with: "")
        }
        // Prefer the direct (shorter) PDF address over the encoded ios.gis247.net/reports/... link.
        func pick(_ dictionary: NSDictionary) -> String {
            [dictionary["printURLdecode"], dictionary["url"], dictionary["pdf_url"], dictionary["link"]].map(clean).first { !$0.isEmpty } ?? ""
        }
        let root = pick(response)
        if !root.isEmpty { return root }
        if let data = response["data"] as? NSDictionary { return pick(data) }
        if let first = (response["data"] as? NSArray)?.firstObject as? NSDictionary { return pick(first) }
        return ""
    }

    private static func findProductId(in value: Any) -> String? {
        func isObjectId(_ string: String) -> Bool { string.count == 24 && string.allSatisfy { $0.isHexDigit } }
        if let dictionary = value as? [String: Any] {
            for key in ["product_id", "po_product_id"] {
                if let id = dictionary[key] as? String, isObjectId(id) { return id }
            }
            if let ids = dictionary["ids"] as? [Any],
               let id = ids.compactMap({ $0 as? String }).first(where: isObjectId) { return id }
            for child in dictionary.values {
                if let id = findProductId(in: child) { return id }
            }
        } else if let array = value as? [Any] {
            for child in array {
                if let id = findProductId(in: child) { return id }
            }
        }
        return nil
    }
}

// MARK: - Flow container

struct NFCWriterFlowView: View {
    let customerName: String
    let products: [NFCWriterProduct]
    let onClose: () -> Void

    @State private var selected: NFCWriterProduct?

    var body: some View {
        if let product = selected {
            NFCWriterFormView(
                product: product,
                customerName: customerName,
                onBack: { selected = nil }
            )
        } else {
            NFCWriterProductListView(
                products: products,
                onBack: onClose,
                onSelect: { selected = $0 }
            )
        }
    }
}

// MARK: - Shared pieces

private enum NFCStyle {
    static let teal = Color("themeColor")
    static let background = Color(red: 0.98, green: 0.98, blue: 0.98)
}

private struct NFCWriterHeader: View {
    let onBack: () -> Void
    var onEdit: (() -> Void)?

    var body: some View {
        ZStack {
            Text("NFC Writer")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(white: 0.2))
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(white: 0.35))
                        .frame(width: 44, height: 44)
                }
                Spacer()
                if let onEdit = onEdit {
                    Button(action: onEdit) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18))
                            .foregroundColor(Color(white: 0.35))
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 52)
        .background(Color.white)
    }
}

private struct NFCWriterProductRow: View {
    enum Style { case list, form }

    let product: NFCWriterProduct
    var style: Style = .list

    /// Prices from the API already carry the currency symbol; only add one when it is missing.
    private var priceText: String {
        let price = product.price.trimmingCharacters(in: .whitespaces)
        guard let first = price.first, first.isNumber else { return price }
        return (UserDefaults.standard.string(forKey: "currencySymbol") ?? "$") + price
    }

    private var variantText: String {
        [product.metal, product.size].filter { !$0.isEmpty }.joined(separator: " ")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: product.imageURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFit()
                } else {
                    Color(white: 0.96)
                }
            }
            .frame(width: style == .form ? 104 : 72, height: style == .form ? 104 : 72)
            .background(Color.white)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(product.name)
                        .font(.system(size: 15))
                        .foregroundColor(Color(white: 0.1))
                        .lineLimit(2)
                    Spacer(minLength: 4)
                    if style == .list {
                        Text(product.date)
                            .font(.system(size: 11))
                            .foregroundColor(Color(white: 0.65))
                    }
                }
                HStack(spacing: 8) {
                    Text(product.sku)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(NFCStyle.teal)
                        .underline()
                    Text(variantText)
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.15))
                    if style == .list { Spacer(minLength: 0) }
                }
                HStack(alignment: .top) {
                    Text(product.stockId)
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.15))
                    Spacer(minLength: 4)
                    quantity
                }
                if style == .form {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 0.3))
                        Text(product.date)
                            .font(.system(size: 13))
                            .foregroundColor(Color(white: 0.15))
                        Spacer(minLength: 4)
                        Text(priceText)
                            .font(.system(size: 13))
                            .foregroundColor(Color(white: 0.15))
                    }
                    .padding(.top, 2)
                } else {
                    HStack {
                        Spacer()
                        Text(priceText)
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 0.15))
                    }
                }
            }
        }
    }

    private var quantity: some View {
        HStack(spacing: 3) {
            Text(product.quantity)
                .font(.system(size: 12, weight: .bold))
            Text("pcs")
                .font(.system(size: 12))
        }
        .foregroundColor(Color(white: 0.15))
    }
}

// MARK: - Product list

struct NFCWriterProductListView: View {
    let products: [NFCWriterProduct]
    let onBack: () -> Void
    let onSelect: (NFCWriterProduct) -> Void

    var body: some View {
        VStack(spacing: 0) {
            NFCWriterHeader(onBack: onBack)
            Text("Select product to write.")
                .font(.system(size: 14))
                .foregroundColor(Color(white: 0.35))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(NFCStyle.background)

            if products.isEmpty {
                Spacer()
                Text("No Data Found!")
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.5))
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(products) { product in
                            Button(action: { onSelect(product) }) {
                                NFCWriterProductRow(product: product)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            Divider().padding(.leading, 16)
                        }
                    }
                }
            }
        }
        .background(NFCStyle.background.edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Form

struct NFCWriterFormView: View {
    let product: NFCWriterProduct
    let customerName: String
    let onBack: () -> Void

    @State private var text = ""
    @State private var url: String
    /// After a successful write the fields are locked until the edit (pencil) button is tapped.
    @State private var isWritten = false
    @State private var errorMessage: String?
    @State private var isLoadingLink = false
    @State private var manager = NFCWriterManager()

    init(product: NFCWriterProduct, customerName: String, onBack: @escaping () -> Void) {
        self.product = product
        self.customerName = customerName
        self.onBack = onBack
        _url = State(initialValue: "")
        // Show the loading state from the very first frame when a link will be fetched.
        _isLoadingLink = State(initialValue: !product.productId.isEmpty || !product.stockId.isEmpty)
    }

    private var canWrite: Bool {
        // The text is optional; only the URL is required.
        !url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            NFCWriterHeader(onBack: onBack, onEdit: isWritten ? { isWritten = false } : nil)

            HStack(spacing: 10) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color(white: 0.8))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Customer")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.55))
                    Text(customerName.isEmpty ? "--" : customerName)
                        .font(.system(size: 15))
                        .foregroundColor(Color(white: 0.1))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)

            ScrollView {
                VStack(spacing: 16) {
                    NFCWriterProductRow(product: product, style: .form)
                        .padding(8)
                        .background(Color.white)

                    field(title: "Text (optional)", placeholder: "Enter your text", text: $text, isURL: false)
                    field(title: "URL", placeholder: isLoadingLink ? "Loading link..." : "Enter your url", text: $url, isURL: true, isLoading: isLoadingLink)
                }
                .padding(16)
            }

            Button(action: write) {
                Text("NEXT")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(canWrite && !isWritten ? NFCStyle.teal : Color(white: 0.82))
                    .cornerRadius(10)
            }
            .disabled(!canWrite || isWritten)
            .padding(16)
            .background(Color.white)
        }
        .background(NFCStyle.background.edgesIgnoringSafeArea(.all))
        .overlay(loadingOverlay)
        .onAppear {
            guard url.isEmpty else { isLoadingLink = false; return }
            isLoadingLink = true
            NFCProductLink.resolveURL(for: product) { link in
                isLoadingLink = false
                // Never overwrite something the user already typed.
                if url.isEmpty { url = link }
            }
        }
        .alert(isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
            Alert(title: Text("NFC Writer"), message: Text(errorMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }

    /// Full-screen loading indicator shown while the product link is being fetched.
    @ViewBuilder
    private var loadingOverlay: some View {
        if isLoadingLink {
            ZStack {
                Color.black.opacity(0.25).edgesIgnoringSafeArea(.all)
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.4)
                    Text("Loading link...")
                        .font(.system(size: 14))
                        .foregroundColor(Color(white: 0.3))
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 22)
                .background(Color.white)
                .cornerRadius(14)
            }
        }
    }

    private func field(title: String, placeholder: String, text: Binding<String>, isURL: Bool, isLoading: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(Color(white: 0.6))
            HStack {
            TextField(placeholder, text: text)
                .font(.system(size: 15))
                .foregroundColor(isWritten ? Color(white: 0.5) : Color(white: 0.1))
                .keyboardType(isURL ? .URL : .default)
                .autocapitalization(isURL ? .none : .sentences)
                .disableAutocorrection(isURL)
                .disabled(isWritten || isLoading)
                if isLoading { ProgressView() }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(white: 0.8), lineWidth: 1))
    }

    private func write() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        manager.write(text: text, url: url, imageURL: product.imageURL) { result in
            switch result {
            case .success:
                isWritten = true
            case .failure(let message):
                errorMessage = message
            case .cancelled:
                break
            }
        }
    }
}

// MARK: - UIKit entry point

enum NFCWriterRouter {
    /// Presents the NFC Writer flow over `viewController` for the given purchase-history orders.
    static func present(from viewController: UIViewController, customerName: String, orders: NSArray) {
        var host: UIHostingController<NFCWriterFlowView>?
        let flow = NFCWriterFlowView(
            customerName: customerName,
            products: NFCWriterProduct.products(fromOrders: orders),
            onClose: { host?.dismiss(animated: true) }
        )
        let hosting = UIHostingController(rootView: flow)
        hosting.modalPresentationStyle = .fullScreen
        host = hosting
        viewController.present(hosting, animated: true)
    }
}

// MARK: - Scan entry point (Home)

enum NFCScanRouter {
    private static let reader = NFCReaderManager()

    /// Starts an NFC read and shows the app's own popup with the tag's text and an "Open Link" button.
    static func scan(from viewController: UIViewController) {
        reader.read { result in
            switch result {
            case .cancelled:
                break
            case .failure(let message):
                present(title: "NFC", message: message, url: nil, from: viewController)
            case .success(let content):
                present(title: "NFC Tag", message: content.text ?? "", url: content.url, from: viewController)
            }
        }
    }

    private static func present(title: String, message: String, url: URL?, from viewController: UIViewController) {
        // Let the system "Ready to Scan" sheet finish dismissing before showing ours.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            var host: UIHostingController<NFCTagPopupView>?
            let popup = NFCTagPopupView(
                title: title,
                message: message,
                showsCheck: url != nil || !message.isEmpty,
                hasLink: url != nil,
                onOpen: {
                    host?.dismiss(animated: true) { if let url = url { UIApplication.shared.open(url) } }
                },
                onClose: { host?.dismiss(animated: true) }
            )
            let hosting = UIHostingController(rootView: popup)
            hosting.modalPresentationStyle = .overFullScreen
            hosting.modalTransitionStyle = .crossDissolve
            hosting.view.backgroundColor = .clear
            host = hosting
            (viewController.presentedViewController ?? viewController).present(hosting, animated: true)
        }
    }
}

/// Bottom sheet shown after an NFC tag is read: title, the tag's text, a check mark and an "Open Link" button.
struct NFCTagPopupView: View {
    let title: String
    let message: String
    let showsCheck: Bool
    let hasLink: Bool
    let onOpen: () -> Void
    let onClose: () -> Void

    private let blue = Color(red: 0, green: 0.48, blue: 1)

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture(perform: onClose)

            VStack(spacing: 14) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(white: 0.75))
                            .frame(width: 32, height: 32)
                            .background(Color(white: 0.25))
                            .clipShape(Circle())
                    }
                }
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                if !message.isEmpty {
                    Text(message)
                        .font(.system(size: 17))
                        .foregroundColor(Color(white: 0.9))
                        .multilineTextAlignment(.center)
                }
                if showsCheck {
                    ZStack {
                        Circle().stroke(blue, lineWidth: 8).frame(width: 128, height: 128)
                        Image(systemName: "checkmark")
                            .font(.system(size: 58, weight: .regular))
                            .foregroundColor(blue)
                    }
                    .padding(.vertical, 20)
                }
                if hasLink {
                    Button(action: onOpen) {
                        Text("Open Link")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(blue)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 22)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.11, green: 0.11, blue: 0.12))
            .cornerRadius(40, corners: [.topLeft, .topRight])
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

private struct NFCRoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}

private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(NFCRoundedCorner(radius: radius, corners: corners))
    }
}
#endif
