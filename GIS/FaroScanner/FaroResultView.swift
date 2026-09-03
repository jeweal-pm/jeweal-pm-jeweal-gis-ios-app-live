//
//  FaroResultView.swift
//  GIS
//
//  Created by Jeweal on 9/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI
import UIKit

struct FaroResultView: View {

    //-----------------------------------------
    // MARK: - Input
    //-----------------------------------------

    @Binding var searchText: String

    /// Image selected for image-search. Kept visible on the result screen.
    let selectedImage: UIImage?

    @Binding var products: [NSMutableDictionary]

    @Binding var isLoading: Bool
    
    // In Stock Only state comes from FaroScannerView
    // because the API request must use this value.
    @Binding var inStockOnly: Bool

    // Called when the small image X is tapped.
    // The parent Scanner removes the image and returns to the full search card.
    let onRemoveImage: () -> Void
    let onSearchChanged: (String) -> Void

    let onContinue: ([NSMutableDictionary]) -> Void
    
    let onInStockChanged: (Bool) -> Void

    /// Return to Faro first page without dismissing Faro itself.
    let onReturnToFaroHome: () -> Void
    
    @Environment(\.dismiss)
    private var dismiss
    init(
        searchText: Binding<String>,
        selectedImage: UIImage?,
        products: Binding<[NSMutableDictionary]>,
        isLoading: Binding<Bool>,
        inStockOnly: Binding<Bool>,
        onRemoveImage: @escaping () -> Void,
        onSearchChanged: @escaping (String) -> Void,
        onInStockChanged: @escaping (Bool) -> Void,
        onReturnToFaroHome: @escaping () -> Void,
        onContinue: @escaping ([NSMutableDictionary]) -> Void
    ) {
        
        self._searchText = searchText
        self.selectedImage = selectedImage
        self._products = products
        self._isLoading = isLoading
        self._inStockOnly = inStockOnly
        self.onRemoveImage = onRemoveImage
        self.onSearchChanged = onSearchChanged
        self.onInStockChanged = onInStockChanged
        self.onReturnToFaroHome = onReturnToFaroHome
        self.onContinue = onContinue
    }

    //-----------------------------------------
    // MARK: - State
    //-----------------------------------------

    // Image result card state:
    // true  = large selected image is visible
    // false = only thumbnail + X remains in the search row
    @State
    private var imagePreviewExpanded = true

//    @State
//    private var inStockOnly = false
    
//    @State
//    private var showOnlyInStock = false
    
    @State
    private var selectedProducts: [NSMutableDictionary] = []

    private var cartCount: Int {

        selectedProducts.reduce(0) { result, item in

            result + (item["quantity"] as? Int ?? 1)

        }

    }
    
    
    @State
    private var confirmProducts: [NSMutableDictionary] = []
    
//    private var confirmProducts: [NSMutableDictionary] {
//
//        var items: [NSMutableDictionary] = []
//
//        for product in selectedProducts {
//
//            let qty = product["quantity"] as? Int ?? 1
//
//            for _ in 0..<qty {
//
//                let item = NSMutableDictionary(dictionary: product)
//
//                item.removeObject(forKey: "quantity")
//
//                items.append(item)
//
//            }
//        }
//
//        return items
//    }
    
    private var totalPrice: Double {

        selectedProducts.reduce(0) { result, product in

            let priceString =
                product["price"] as? String ?? "0"

            let value = Double(
                priceString
                    .replacingOccurrences(of: ",", with: "")
                    .replacingOccurrences(of: "฿", with: "")
                    .trimmingCharacters(in: .whitespaces)
            ) ?? 0

            return result + value

        }

    }
    
    @FocusState
    private var resultSearchFocused: Bool

    @State
    private var showToast = false

    @State
    private var showConfirmOrder = false

    @State
    private var showImageGallery = false

    @State
    private var galleryImageURLs: [String] = []
    
    @State
    private var galleryProductName = ""

    @State
    private var editingOrderIndex: Int?
    
    //-----------------------------------------
    // MARK: - Body
    //-----------------------------------------


    //-----------------------------------------
    // MARK: - Body
    //-----------------------------------------

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            resultContentView
            resultCartOverlay
            resultToastOverlay
        }
        .fullScreenCover(isPresented: $showConfirmOrder) {
            FaroConfirmOrderView(
                // Use the expanded cart here. selectedProducts stores one
                // dictionary per unique product and keeps the quantity in
                // the `quantity` field. The Order screen, however, displays
                // one row per item.
                products: $confirmProducts,
                onConfirm: {
                    showConfirmOrder = false
                    onContinue(confirmProducts)
                }
            )
        }
        .fullScreenCover(isPresented: $showImageGallery) {
            FaroImageGalleryView(
                imageURLs: galleryImageURLs,
                productName: galleryProductName
            )
        }
        .onChange(of: isLoading) { value in
            print("ResultView isLoading =", value)
        }
    }

    // MARK: - Result content

    private var resultContentView: some View {
        VStack(spacing: 0) {
            FaroHeader {
                dismiss()
            }
            .padding(.bottom, 8)

            resultSearchView
            resultFilterView
            resultProductsView
        }
        .background(Color.white)
        .background(KeyboardDismissView())
    }

    @ViewBuilder
    private var resultSearchView: some View {
        if let image = selectedImage {
            ImageSearchResultCard(
                image: image,
                searchText: $searchText,
                isExpanded: $imagePreviewExpanded,
                onRemoveImage: {
                    onRemoveImage()
                },
                onSubmit: {
                    submitResultSearch()
                }
            )
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 8)
        } else {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("Search", text: $searchText)
                    .focused($resultSearchFocused)
                    .font(FaroFont.regular(16))
                    .foregroundColor(.black)
                    .submitLabel(.search)
                    .onSubmit {
                        submitResultSearch()
                    }

                Spacer(minLength: 4)

                if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button {
                        searchText = ""
                        resultSearchFocused = true
                    } label: {
                        Image(systemName: "xmark")
                            .font(FaroFont.semibold(16))
                            .foregroundColor(.gray)
                            .frame(width: 30, height: 30)
                    }

                    Button {
                        submitResultSearch()
                    } label: {
                        Image("faro_enter")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34, height: 34)
                    }
                } else {
                    Button {
                        resultSearchFocused = false
                        hideKeyboard()
                        onReturnToFaroHome()
                    } label: {
                        Image(systemName: "xmark")
                            .font(FaroFont.semibold(16))
                            .foregroundColor(.gray)
                            .frame(width: 34, height: 34)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 58)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 29)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.36, green: 0.54, blue: 1.0),
                                Color(red: 0.24, green: 0.92, blue: 0.95)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 8)
        }
    }

    private var resultFilterView: some View {
        HStack {
            Text(
                isLoading
                    ? "Searching..."
                    : "Showing (\(products.count))"
            )
            .font(FaroFont.regular(15))
            .foregroundColor(Color(white: 0.36))
            .animation(.easeInOut(duration: 0.2), value: isLoading)

            Spacer()

            Button {
                let newValue = !inStockOnly

                withAnimation(.easeInOut) {
                    inStockOnly = newValue
                }

                print("""
                ==========================
                IN STOCK BUTTON
                ==========================
                InStockOnly : \(newValue)
                ==========================
                """)

                onInStockChanged(newValue)
            } label: {
                Text("In stock only")
                    .foregroundColor(inStockOnly ? .white : .gray)
                    .font(FaroFont.regular(14))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(
                                inStockOnly
                                ? Color(
                                    red: 82 / 255,
                                    green: 203 / 255,
                                    blue: 196 / 255
                                )
                                : .white
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.gray.opacity(0.25))
                    )
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            resultSearchFocused = false
            hideKeyboard()
        }
    }

    private var resultProductsView: some View {
        ScrollView {
            Group {
                if isLoading {
                    resultLoadingGrid
                } else {
                    resultLoadedGrid
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)
            .padding(.bottom, 24)
            // IMPORTANT: measure the actual scrolling content.
            // Measuring a zero-height GeometryReader at the top of the
            // ScrollView can stay at 0 on some iOS versions, so the
            // selected image never receives the collapse event.
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: FaroProductsScrollOffsetKey.self,
                            value: proxy.frame(in: .named("FaroProductsScroll")).minY
                        )
                }
            )
            .animation(.easeInOut(duration: 0.25), value: isLoading)
            .simultaneousGesture(
                TapGesture().onEnded {
                    resultSearchFocused = false
                    hideKeyboard()
                }
            )
        }
        .coordinateSpace(name: "FaroProductsScroll")
        // Collapse the large image from the actual upward drag gesture.
        // This is more reliable than depending on a GeometryReader offset,
        // especially when LazyVGrid is still laying out its cells.
        .simultaneousGesture(
            DragGesture(minimumDistance: 6)
                .onChanged { value in
                    guard !isLoading,
                          !products.isEmpty,
                          selectedImage != nil,
                          imagePreviewExpanded,
                          value.translation.height < -8 else { return }

                    withAnimation(
                        .spring(
                            response: 0.35,
                            dampingFraction: 0.86
                        )
                    ) {
                        imagePreviewExpanded = false
                    }
                }
        )
//        .scrollDisabled(parentScrollDisabled)
    }


    private var resultLoadingGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 12
        ) {
            ForEach(0..<6, id: \.self) { _ in
                FaroProductSkeletonCard()
            }
        }
        .opacity(isLoading ? 1 : 0)
        .frame(maxWidth: .infinity)
    }

    private var resultLoadedGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 12
        ) {
            ForEach(Array(products.enumerated()), id: \.offset) { item in
                resultProductCell(item.element)
            }
        }
        .opacity(isLoading ? 0 : 1)
        .frame(maxWidth: .infinity)
    }

    private func resultProductCell(_ product: NSMutableDictionary) -> some View {
        let sku = product["SKU"] as? String ?? ""
        let selectedIndex = selectedProducts.firstIndex {
            ($0["SKU"] as? String ?? "") == sku
        }

        let quantity: Int
        if let selectedIndex {
            quantity = selectedProducts[selectedIndex]["quantity"] as? Int ?? 1
        } else {
            quantity = 0
        }

        return FaroProductCard(
            product: product,
            quantity: quantity,
            onImageTap: {
                galleryImageURLs = imageURLs(for: product)
                galleryProductName = product["name"] as? String ?? ""
                showImageGallery = true
            }
        ) { product, metal, stone, size in
            addSelectedProduct(
                product,
                metal: metal,
                stone: stone,
                size: size
            )
        }
    }

    private func addSelectedProduct(
        _ product: NSDictionary,
        metal: String,
        stone: String,
        size: String
    ) {
        let newProduct = NSMutableDictionary(dictionary: product)
        newProduct["selected_metal"] = metal
        newProduct["selected_stone"] = stone
        newProduct["selected_size"] = size

        let sku = newProduct["SKU"] as? String ?? ""

        if let index = selectedProducts.firstIndex(where: {
            ($0["SKU"] as? String ?? "") == sku &&
            ($0["selected_metal"] as? String ?? "") == metal &&
            ($0["selected_stone"] as? String ?? "") == stone &&
            ($0["selected_size"] as? String ?? "") == size
        }) {
            let quantity = selectedProducts[index]["quantity"] as? Int ?? 1
            selectedProducts[index]["quantity"] = quantity + 1
        } else {
            newProduct["quantity"] = 1
            selectedProducts.append(newProduct)
        }

        showToast = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation {
                showToast = false
            }
        }
    }

    @ViewBuilder
    private var resultCartOverlay: some View {
        if !selectedProducts.isEmpty {
            FaroResultCartButton(count: cartCount) {
                confirmProducts.removeAll()

                for product in selectedProducts {
                    let quantity = max(product["quantity"] as? Int ?? 1, 1)

                    for _ in 0..<quantity {
                        let item = NSMutableDictionary(dictionary: product)
                        item.removeObject(forKey: "quantity")
                        confirmProducts.append(item)
                    }
                }

                print("[FARO CART] Unique products: \(selectedProducts.count)")
                print("[FARO CART] Expanded items: \(confirmProducts.count)")

                showConfirmOrder = true
            }
            .padding(.trailing, 24)
            .padding(.bottom, 28)
        }
    }

    @ViewBuilder
    private var resultToastOverlay: some View {
        if showToast {
            VStack {
                ToastView()
                Spacer()
            }
            .transition(.move(edge: .top))
        }
    }

    
//    private func compressProducts(
//        _ products: [NSMutableDictionary]
//    ) -> [NSMutableDictionary] {
//
//        var result: [NSMutableDictionary] = []
//
//        for item in products {
//
//            if let index = result.firstIndex(where: {
//
//                ($0["SKU"] as? String ?? "") ==
//                (item["SKU"] as? String ?? "")
//
//                &&
//
//                ($0["selected_metal"] as? String ?? "") ==
//                (item["selected_metal"] as? String ?? "")
//
//                &&
//
//                ($0["selected_stone"] as? String ?? "") ==
//                (item["selected_stone"] as? String ?? "")
//
//                &&
//
//                ($0["selected_size"] as? String ?? "") ==
//                (item["selected_size"] as? String ?? "")
//
//            }) {
//
//                let qty = result[index]["quantity"] as? Int ?? 1
//
//                result[index]["quantity"] = qty + 1
//
//            } else {
//
//                let copy = NSMutableDictionary(dictionary: item)
//
//                copy["quantity"] = 1
//
//                result.append(copy)
//
//            }
//
//        }
//
//        return result
//
//    }
    
//    private func expandedProducts(
//        from products: [NSMutableDictionary]
//    ) -> [NSMutableDictionary] {
//
//        var result: [NSMutableDictionary] = []
//
//        for product in products {
//
//            let qty = product["quantity"] as? Int ?? 1
//
//            for _ in 0..<qty {
//
//                result.append(
//                    NSMutableDictionary(dictionary: product)
//                )
//
//            }
//
//        }
//
//        return result
//
//    }
    
//    private var filteredProducts: [NSMutableDictionary] {
//
//        guard showOnlyInStock else {
//            return products
//        }
//
//        return products.filter {
//
//            let qty = $0["qty"] as? Int ?? 0
//
//            return qty > 0
//
//        }
//
//    }

    private func submitResultSearch() {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return }

        resultSearchFocused = false
        hideKeyboard()
        onSearchChanged(keyword)
    }

    private func imageURLs(for product: NSDictionary) -> [String] {

        var urls: [String] = []

        // main image
        if let image = product["main_image"] as? String,
           !image.isEmpty {

            urls.append(image)

        }

        // images
        if let images = product["images"] as? [String] {

            urls.append(contentsOf: images)

        }

        // image objects
        if let images = product["images"] as? [NSDictionary] {

            urls.append(
                contentsOf: images.compactMap {
                    $0["image"] as? String
                }
            )

            urls.append(
                contentsOf: images.compactMap {
                    $0["url"] as? String
                }
            )

        }

        // variants
        if let variants = product["variants"] as? [NSDictionary] {

            urls.append(
                contentsOf: variants.compactMap {
                    $0["imageUrl"] as? String
                }
            )

            urls.append(
                contentsOf: variants.compactMap {
                    $0["image"] as? String
                }
            )

        }

        return Array(
            Set(
                urls.filter {
                    !$0.isEmpty
                }
            )
        )

    }

}


//-------------------------------------------------------------

//-------------------------------------------------------------
// MARK: - Floating Cart Button
//-------------------------------------------------------------

private struct FaroResultCartButton: View {
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                Circle()
                    .fill(Color.black)
                    .frame(width: 64, height: 64)
                    .shadow(
                        color: .black.opacity(0.18),
                        radius: 10,
                        y: 5
                    )
                    .overlay {
                        Image("faro_bag")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }

                Text("\(count)")
                    .font(FaroFont.semibold(11))
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: -2, y: -4)
            }
        }
        .buttonStyle(.plain)
    }
}


private struct FaroProductsScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Dismiss keyboard when tapping outside a text field

private struct KeyboardDismissView: UIViewRepresentable {

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.installIfNeeded(on: uiView)
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.remove()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {

        private weak var window: UIWindow?
        private var tapGesture: UITapGestureRecognizer?

        func installIfNeeded(on view: UIView) {
            guard tapGesture == nil else { return }

            DispatchQueue.main.async { [weak self, weak view] in
                guard let self,
                      let window = view?.window,
                      self.tapGesture == nil else { return }

                let tap = UITapGestureRecognizer(
                    target: self,
                    action: #selector(self.handleTap)
                )
                tap.cancelsTouchesInView = false
                tap.delegate = self

                window.addGestureRecognizer(tap)
                self.window = window
                self.tapGesture = tap
            }
        }

        func remove() {
            if let tapGesture {
                window?.removeGestureRecognizer(tapGesture)
            }

            tapGesture = nil
            window = nil
        }

        @objc func handleTap() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldReceive touch: UITouch
        ) -> Bool {
            var view = touch.view

            while let current = view {
                if current is UITextField || current is UITextView {
                    return false
                }
                view = current.superview
            }

            return true
        }
    }
}

// MARK: - Image Search Result Card
//-------------------------------------------------------------

private struct ImageSearchResultCard: View {

    let image: UIImage

    @Binding var searchText: String

    @Binding var isExpanded: Bool

    let onRemoveImage: () -> Void
    let onSubmit: () -> Void

    var body: some View {

        VStack(spacing: 0) {

            //---------------------------------------------
            // Search row
            //---------------------------------------------

            HStack(spacing: 8) {

                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 22, height: 22)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 5)
                    )

                // X beside the small image.
                // This is the ONLY action that removes the image.
                Button {

                    onRemoveImage()

                } label: {

                    Image(systemName: "xmark")
                        .font(
                            .system(
                                size: 10,
                                weight: .semibold
                            )
                        )
                        .foregroundColor(.gray)
                        .frame(width: 22, height: 22)

                }

                TextField(
                    "Add to your search",
                    text: $searchText
                )
                .font(FaroFont.regular(15))
                .foregroundColor(.black)
                .tint(.gray.opacity(0.55))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(.search)
                .onSubmit {
                    onSubmit()
                }

                Spacer(minLength: 0)

                // ^ ONLY closes/opens the large image.
                // It does NOT dismiss the result and does NOT remove the image.
                Button {

                    withAnimation(
                        .spring(
                            response: 0.45,
                            dampingFraction: 0.82
                        )
                    ) {

                        isExpanded.toggle()

                    }

                } label: {

                    Image(
                        systemName:
                            isExpanded
                            ? "chevron.up"
                            : "chevron.down"
                    )
                    .font(
                        .system(
                            size: 13,
                            weight: .medium
                        )
                    )
                    .foregroundColor(.gray)
                    .frame(width: 28, height: 28)

                }

            }
            .frame(height: 34)
            .padding(.horizontal, 16)
            .padding(.top, 12)

            //---------------------------------------------
            // Large image
            //---------------------------------------------

            if isExpanded {

                ZStack {

                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            Color(
                                red: 248 / 255,
                                green: 248 / 255,
                                blue: 250 / 255
                            )
                        )

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            maxWidth: 188,
                            maxHeight: 124
                        )

                }
                .frame(height: 142)
                .padding(.horizontal, 14)
                .padding(.top, 7)
                .padding(.bottom, 14)
                .transition(
                    .opacity.combined(
                        with: .scale(scale: 0.98)
                    )
                )

            }

        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 28)
        )
        .shadow(
            color: .black.opacity(0.055),
            radius: 14,
            x: 0,
            y: 6
        )
        .animation(
            .spring(
                response: 0.45,
                dampingFraction: 0.82
            ),
            value: isExpanded
        )

    }
}

private struct FaroProductSkeletonCard: View {

    @State private var shimmer = false
    var body: some View {

        VStack(alignment: .leading, spacing: 10) {

            skeletonBox(height: 150, corner: 10)

            skeletonBox(width: 120, height: 16, corner: 5)

            skeletonBox(width: 72, height: 13, corner: 5)

            skeletonBox(width: 92, height: 18, corner: 5)

        }
        .padding(.bottom, 2)
        .onAppear {

            withAnimation(
                .linear(duration: 1.1)
                .repeatForever(autoreverses: false)
            ) {

                shimmer = true

            }

        }

    }
    
    private func skeletonBox(
        width: CGFloat? = nil,
        height: CGFloat,
        corner: CGFloat
    ) -> some View {

        RoundedRectangle(cornerRadius: corner)
            .fill(Color.gray.opacity(0.18))
            .frame(width: width, height: height)
            .overlay {

                GeometryReader { geo in

                    LinearGradient(

                        colors: [

                            .clear,
                            Color.white.opacity(0.65),
                            .clear

                        ],

                        startPoint: .top,
                        endPoint: .bottom

                    )
                    .rotationEffect(.degrees(20))
                    .offset(
                        x: shimmer
                        ? geo.size.width * 2
                        : -geo.size.width * 2
                    )

                }
                .clipped()

            }

    }

}

private struct FaroImageGalleryView: View {

    let imageURLs: [String]
    

    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex = 0

    let productName: String
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                //--------------------------------
                // Product Title
                //--------------------------------
                
                Text(productName)
                    .font(FaroFont.semibold(18))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 26)
                    .padding(.top, 58)
                    .padding(.bottom, 24)
                
                //--------------------------------
                // Image
                //--------------------------------
                
                ZStack {
                    
                    TabView(selection: $currentIndex) {
                        
                        ForEach(imageURLs.indices, id:\.self) { index in
                            
                            AsyncImage(
                                url: URL(string: imageURLs[index])
                            ) { image in
                                
                                image
                                    .resizable()
                                    .scaledToFit()
                                
                            } placeholder: {
                                
                                ProgressView()
                                
                            }
                            .tag(index)
                            
                        }
                        
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 420)
                    
                    HStack {
                        
                        Button {
                            
                            if currentIndex > 0 {
                                
                                withAnimation {
                                    
                                    currentIndex -= 1
                                    
                                }
                                
                            }
                            
                        } label: {
                            
                            Circle()
                                .fill(.white)
                                .frame(width: 52,height:52)
                                .shadow(radius:6)
                                .overlay {
                                    
                                    Image(systemName:"chevron.left")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                    
                                }
                            
                        }
                        .padding(.leading,20)
                        
                        Spacer()
                        
                        Button {
                            
                            if currentIndex < imageURLs.count-1 {
                                
                                withAnimation {
                                    
                                    currentIndex += 1
                                    
                                }
                                
                            }
                            
                        } label: {
                            
                            Circle()
                                .fill(.white)
                                .frame(width:52,height:52)
                                .shadow(radius:6)
                                .overlay {
                                    
                                    Image(systemName:"chevron.right")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                    
                                }
                            
                        }
                        .padding(.trailing,20)
                        
                    }
                    
                }
                
                //--------------------------------
                // Thumbnail
                //--------------------------------
                
                ScrollView(.horizontal,showsIndicators:false){
                    
                    HStack(spacing:18){
                        
                        ForEach(imageURLs.indices,id:\.self){ index in
                            
                            AsyncImage(
                                url:URL(string:imageURLs[index])
                            ){ image in
                                
                                image
                                    .resizable()
                                    .scaledToFit()
                                
                            } placeholder:{
                                
                                Color.gray.opacity(0.15)
                                
                            }
                            .frame(width:92,height:92)
                            .background(Color.white)
                            .overlay(
                                
                                RoundedRectangle(cornerRadius:2)
                                
                                    .stroke(
                                        
                                        currentIndex == index
                                        ? Color(
                                            red:86/255,
                                            green:201/255,
                                            blue:200/255
                                        )
                                        : Color.clear,
                                        
                                        lineWidth:3
                                        
                                    )
                                
                            )
                            .onTapGesture{
                                
                                withAnimation{
                                    
                                    currentIndex = index
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    .padding(.horizontal,26)
                    
                }
                
                Spacer()
                
            }
            
            Button{
                
                dismiss()
                
            }label:{
                
                Image(systemName:"xmark")
                    .font(FaroFont.regular(26))
                    .foregroundColor(.gray)
                
            }
            .padding(.top,24)
            .padding(.trailing,24)
            
        }
        
    }

}

private struct FaroConfirmOrderView: View {
    @Binding var products: [NSMutableDictionary]
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isManaging = false
    @State private var selectedIndexes: Set<Int> = []
    @State private var editingIndex: Int?
    @State private var swipedIndex: Int?

    private let pageBackground = Color(red: 249/255, green: 249/255, blue: 251/255)
    private let teal = Color(red: 82/255, green: 203/255, blue: 196/255)

    var body: some View {
        ZStack(alignment: .bottom) {
            pageBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(products.enumerated()), id: \.offset) { index, _ in
                            orderRow(
                                product: products[index],
                                index: index,
                                isManaging: isManaging,
                                isSelected: selectedIndexes.contains(index),
                                swipedIndex: $swipedIndex,
                                onToggleSelection: {
                                    toggleSelection(index)
                                },
                                onEdit: {
                                    editingIndex = index
                                },
                                onDelete: {
                                    deleteProduct(at: index)
                                }
                            )
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)
            }

            bottomConfirmBar
        }
        .fullScreenCover(item: Binding<FaroEditTarget?>(
            get: { editingIndex.map(FaroEditTarget.init) },
            set: { editingIndex = $0?.id }
        )) { target in
            if target.id < products.count {
                FaroEditOrderView(
                    product: products[target.id],
                    onSave: { editingIndex = nil },
                    onCancel: { editingIndex = nil },
                    onDelete: {
                        deleteProduct(at: target.id)
                        editingIndex = nil
                    }
                )
            }
        }
    }

    private var headerView: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(FaroFont.regular(19))
                    .foregroundColor(.black)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Order")
                .font(FaroFont.semibold(18))
                .foregroundColor(.black)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isManaging.toggle()
                    selectedIndexes.removeAll()
                    swipedIndex = nil
                }
            } label: {
                Text(isManaging ? "Cancel" : "Manage")
                    .font(FaroFont.regular(16))
                    .foregroundColor(teal)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
        .frame(height: 56)
        .background(Color.white)
    }

    private var bottomConfirmBar: some View {
        VStack(spacing: 0) {
            if isManaging {
                managementBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            HStack {
                Text("\(products.count) Item")
                    .font(FaroFont.regular(17))
                    .foregroundColor(.black)

                Spacer()

                Button { onConfirm() } label: {
                    Text("Confirm")
                        .font(FaroFont.semibold(18))
                        .foregroundColor(.white)
                        .frame(width: 196, height: 53)
                        .background(teal)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.white)
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.10), radius: 12, y: -5)
        .animation(.easeInOut(duration: 0.25), value: isManaging)
    }

    private var managementBar: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    if selectedIndexes.count == products.count && !products.isEmpty {
                        selectedIndexes.removeAll()
                    } else {
                        selectedIndexes = Set(products.indices)
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName:
                        selectedIndexes.count == products.count && !products.isEmpty
                        ? "checkmark.circle.fill"
                        : "circle"
                    )
                    .font(FaroFont.regular(24))
                    .foregroundColor(
                        selectedIndexes.count == products.count && !products.isEmpty
                        ? teal
                        : Color(white: 0.88)
                    )

                    Text("Select All")
                        .font(FaroFont.regular(17))
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                let indexes = selectedIndexes.sorted(by: >)
                for index in indexes where index < products.count {
                    products.remove(at: index)
                }
                selectedIndexes.removeAll()
                swipedIndex = nil
                isManaging = false
            } label: {
                Text(selectedIndexes.isEmpty ? "Delete" : "Delete (\(selectedIndexes.count))")
                    .font(FaroFont.semibold(18))
                    .foregroundColor(.white)
                    .frame(width: 196, height: 52)
                    .background(
                        selectedIndexes.isEmpty
                        ? Color(white: 0.90)
                        : Color(red: 1, green: 0.33, blue: 0.33)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(selectedIndexes.isEmpty)
        }
        .padding(.horizontal, 24)
        .frame(height: 82)
        .background(Color.white)
    }

    private func toggleSelection(_ index: Int) {
        guard index >= 0, index < products.count else { return }
        withAnimation(.easeInOut(duration: 0.12)) {
            if selectedIndexes.contains(index) {
                selectedIndexes.remove(index)
            } else {
                selectedIndexes.insert(index)
            }
        }
    }

    private func deleteProduct(at index: Int) {
        guard index >= 0, index < products.count else { return }

        products.remove(at: index)

        // Rebuild selection indexes because removing an item shifts every
        // following row by one position.
        selectedIndexes = Set(
            selectedIndexes.compactMap { selectedIndex in
                if selectedIndex == index { return nil }
                return selectedIndex > index ? selectedIndex - 1 : selectedIndex
            }
        )

        swipedIndex = nil
    }

    @ViewBuilder
    private func orderRow(
        product: NSDictionary,
        index: Int,
        isManaging: Bool,
        isSelected: Bool,
        swipedIndex: Binding<Int?>,
        onToggleSelection: @escaping () -> Void,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) -> some View {
        ZStack(alignment: .trailing) {
            if !isManaging {
                Button(action: onDelete) {
                    VStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .medium))
                        Text("Delete")
                            .font(FaroFont.regular(12))
                    }
                    .foregroundColor(.white)
                    .frame(width: 82, height: 148)
                    .background(Color(red: 1, green: 0.28, blue: 0.28))
                }
                .buttonStyle(.plain)
            }

            HStack(alignment: .top, spacing: 11) {
                if isManaging {
                    Button(action: onToggleSelection) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(FaroFont.regular(24))
                            .foregroundColor(isSelected ? teal : Color(white: 0.90))
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }

                FaroRemoteImage(urlString: product["main_image"] as? String ?? "")
                    .id(product["main_image"] as? String ?? "")
                    .frame(width: 103, height: 132)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))

                VStack(alignment: .leading, spacing: 0) {
                    Text(product["name"] as? String ?? "")
                        .font(FaroFont.semibold(14))
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(product["SKU"] as? String ?? "")
                        .font(FaroFont.regular(13))
                        .foregroundColor(Color(white: 0.63))
                        .padding(.top, 7)

                    Text(
                        "\(product["selected_metal"] as? String ?? "") · " +
                        "\(product["selected_stone"] as? String ?? "") · " +
                        "\(product["selected_size"] as? String ?? "")"
                    )
                    .font(FaroFont.regular(12))
                    .foregroundColor(Color(white: 0.63))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.top, 7)

                    Spacer(minLength: 0)

                    HStack(alignment: .center, spacing: 0) {
                        Text("\(product["price"] as? String ?? "")")
                            .font(FaroFont.semibold(16))
                            .foregroundColor(teal)
                            .lineLimit(1)

                        Spacer(minLength: 8)

                        if !isManaging {
                            Button(action: onEdit) {
                                Image("faro_edit")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 132, maxHeight: 132, alignment: .topLeading)
            }
            .padding(.horizontal, 8)
            .frame(minHeight: 148, maxHeight: 148, alignment: .top)
            .overlay(Divider().opacity(0.55), alignment: .bottom)
            .background(pageBackground)
            .contentShape(Rectangle())
            .onTapGesture {
                if isManaging {
                    onToggleSelection()
                } else {
                    swipedIndex.wrappedValue = nil
                }
            }
            .offset(x: (!isManaging && swipedIndex.wrappedValue == index) ? -82 : 0)
            .gesture(
                DragGesture(minimumDistance: 12)
                    .onEnded { value in
                        guard !isManaging else { return }

                        if value.translation.width < -35 {
                            withAnimation(.easeOut(duration: 0.18)) {
                                swipedIndex.wrappedValue = index
                            }
                        } else if value.translation.width > 20 {
                            withAnimation(.easeOut(duration: 0.18)) {
                                swipedIndex.wrappedValue = nil
                            }
                        }
                    }
            )
        }
    }
}

private struct FaroRemoteImage: View {
    let urlString: String
    @StateObject private var loader: FaroRemoteImageLoader

    init(urlString: String) {
        self.urlString = urlString
        _loader = StateObject(wrappedValue: FaroRemoteImageLoader(urlString: urlString))
    }

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Color.white
            }
        }
        .task(id: urlString) {
            loader.load()
        }
    }
}

private final class FaroRemoteImageLoader: ObservableObject {
    @Published var image: UIImage?

    private static let cache = NSCache<NSString, UIImage>()
    private let urlString: String
    private var isLoading = false

    init(urlString: String) {
        self.urlString = urlString
        if let cached = Self.cache.object(forKey: urlString as NSString) {
            self.image = cached
        }
    }

    func load() {
        guard image == nil, !isLoading, let url = URL(string: urlString), !urlString.isEmpty else {
            return
        }

        isLoading = true

        if let cached = Self.cache.object(forKey: urlString as NSString) {
            image = cached
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { self?.isLoading = false }
                return
            }

            Self.cache.setObject(image, forKey: self.urlString as NSString)

            DispatchQueue.main.async {
                self.image = image
                self.isLoading = false
            }
        }.resume()
    }
}

private struct FaroEditTarget: Identifiable {
    let id: Int
}

private struct FaroEditOrderView: View {
    let product: NSMutableDictionary
    let onSave: () -> Void
    let onCancel: () -> Void
    let onDelete: () -> Void

    @State private var selectedMetal = ""
    @State private var selectedStone = ""
    @State private var selectedSize = ""
    @Environment(\.dismiss) private var dismiss
    @State private var openDropdown: String?

    private let teal = Color(
        red: 82 / 255,
        green: 203 / 255,
        blue: 196 / 255
    )

    private let background = Color(
        red: 247 / 255,
        green: 247 / 255,
        blue: 249 / 255
    )

    private var metals: [String] {
        ((product["metals"] as? [NSDictionary]) ?? [])
            .compactMap { $0["label"] as? String }
    }

    private var stones: [String] {
        ((product["stones"] as? [NSDictionary]) ?? [])
            .compactMap { $0["label"] as? String }
    }

    private var sizes: [String] {
        ((product["sizes"] as? [NSDictionary]) ?? [])
            .compactMap { $0["label"] as? String }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                // Fixed edit screen. The page itself does not scroll.
                VStack(alignment: .leading, spacing: 0) {
                    AsyncImage(
                        url: URL(
                            string: product["main_image"] as? String ?? ""
                        )
                    ) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                    } placeholder: {
                        Color.white
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 296)
                    .background(Color.white)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 28,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 28
                        )
                    )

                    VStack(alignment: .leading, spacing: 0) {
                        Text(product["name"] as? String ?? "")
                            .font(FaroFont.semibold(14))
                            .foregroundColor(.black)
                            .lineLimit(2)

                        Text(product["SKU"] as? String ?? "")
                            .font(FaroFont.regular(13))
                            .foregroundColor(Color(white: 0.63))
                            .padding(.top, 8)

                        Text("฿ \(product["price"] as? String ?? "")")
                            .font(FaroFont.regular(17))
                            .foregroundColor(teal)
                            .padding(.top, 4)

                        Divider()
                            .padding(.top, 30)

                        VStack(spacing: 10) {
                            FaroEditDropdown(
                                title: "Metal",
                                options: metals,
                                selection: $selectedMetal,
                                isOpen: Binding(
                                    get: { openDropdown == "Metal" },
                                    set: {
                                        openDropdown = $0 ? "Metal" : nil
                                    }
                                ),
                                onOpen: {
                                    openDropdown = "Metal"
                                }
                            )

                            FaroEditDropdown(
                                title: "Stone",
                                options: stones,
                                selection: $selectedStone,
                                isOpen: Binding(
                                    get: { openDropdown == "Stone" },
                                    set: {
                                        openDropdown = $0 ? "Stone" : nil
                                    }
                                ),
                                onOpen: {
                                    openDropdown = "Stone"
                                }
                            )

                            FaroEditDropdown(
                                title: "Size",
                                options: sizes,
                                selection: $selectedSize,
                                isOpen: Binding(
                                    get: { openDropdown == "Size" },
                                    set: {
                                        openDropdown = $0 ? "Size" : nil
                                    }
                                ),
                                onOpen: {
                                    openDropdown = "Size"
                                }
                            )
                        }
                        .padding(.top, 7)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 13)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }

            editBottomBar
        }
        .onAppear {
            selectedMetal =
                product["selected_metal"] as? String
                ?? metals.first
                ?? "--"

            selectedStone =
                product["selected_stone"] as? String
                ?? stones.first
                ?? "--"

            selectedSize =
                product["selected_size"] as? String
                ?? sizes.first
                ?? "--"
        }
    }

    private var header: some View {
        HStack {
            Button {
                openDropdown = nil
                onCancel()
            } label: {
                Image(systemName: "xmark")
                    .font(FaroFont.regular(20))
                    .foregroundColor(.gray)
                    .frame(width: 34, height: 34)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Edit Order")
                .font(FaroFont.semibold(18))
                .foregroundColor(.black)

            Spacer()

            Button {
                // Dismiss the edit sheet first, then mutate the parent
                // product array on the next main-run-loop cycle. This makes
                // the delete reliable when the edit screen is presented
                // with fullScreenCover.
                openDropdown = nil
                dismiss()
                DispatchQueue.main.async {
                    onDelete()
                }
            } label: {
                Image(systemName: "trash")
                    .font(FaroFont.regular(19))
                    .foregroundColor(.red)
                    .frame(width: 34, height: 34)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .frame(height: 56)
        .background(Color.white)
    }

    private var editBottomBar: some View {
        HStack {
            Button {
                save()
            } label: {
                Text("Update Product")
                    .font(FaroFont.semibold(17))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 53)
                    .background(teal)
                    .cornerRadius(9)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(
            color: .black.opacity(0.08),
            radius: 10,
            y: -4
        )
    }

    private func save() {
        product["selected_metal"] = selectedMetal
        product["selected_stone"] = selectedStone
        product["selected_size"] = selectedSize
        onSave()
    }
}

private struct FaroEditDropdown: View {
    let title: String
    let options: [String]
    @Binding var selection: String
    @Binding var isOpen: Bool
    let onOpen: () -> Void

    private let teal = Color(
        red: 82 / 255,
        green: 203 / 255,
        blue: 196 / 255
    )

    private let cornerRadius: CGFloat = 7
    private let rowHeight: CGFloat = 36

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(FaroFont.regular(11))
                .foregroundColor(.black)

            ZStack(alignment: .topLeading) {
                Button {
                    guard !options.isEmpty else { return }
                    if isOpen {
                        isOpen = false
                    } else {
                        onOpen()
                    }
                } label: {
                    HStack {
                        Text(selection.isEmpty ? "Select \(title)" : selection)
                            .font(FaroFont.regular(14))
                            .foregroundColor(Color(white: 0.40))
                            .lineLimit(1)

                        Spacer()

                        Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                            .font(FaroFont.semibold(10))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .frame(height: rowHeight)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )
                    .contentShape(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    )
                }
                .buttonStyle(.plain)

                if isOpen && !options.isEmpty {
                    let dropdownHeight = min(CGFloat(options.count) * rowHeight, 180)

                    ScrollView(.vertical, showsIndicators: options.count * Int(rowHeight) > 180) {
                        LazyVStack(spacing: 0) {
                            ForEach(options, id: \.self) { option in
                                Button {
                                    selection = option
                                    isOpen = false
                                } label: {
                                    HStack {
                                        Text(option)
                                            .font(FaroFont.regular(14))
                                            .foregroundColor(.black)
                                        Spacer()
                                        if selection == option {
                                            Image(systemName: "checkmark")
                                                .font(FaroFont.semibold(11))
                                                .foregroundColor(teal)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .frame(height: rowHeight)
                                    .background(Color.white)
                                }
                                .buttonStyle(.plain)

                                if option != options.last {
                                    Divider()
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: dropdownHeight)
                    .background(Color.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.gray.opacity(0.22), lineWidth: 1)
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    )
                    .shadow(color: .black.opacity(0.12), radius: 7, y: 3)
                    .offset(y: rowHeight + 4)
                    .zIndex(10000)
                }
            }
            .zIndex(isOpen ? 10000 : 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .zIndex(isOpen ? 10000 : 0)
    }
}
