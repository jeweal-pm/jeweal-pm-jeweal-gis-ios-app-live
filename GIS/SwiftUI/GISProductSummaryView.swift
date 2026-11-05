import Foundation
import SwiftUI

final class GISProductSummaryViewModel: ObservableObject {
    @Published private(set) var product: GISProductSummary?
    @Published var isLoading = true
    @Published var errorMessage: String?

    func load(_ data: NSDictionary, fallbackStockID: String = "") {
        product = GISProductSummary(data: data, fallbackStockID: fallbackStockID)
        isLoading = false
    }

    func fail(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.isLoading = false
        }
    }
}

struct GISProductSummary: Equatable {
    let name: String
    let metaTag: String
    let productID: String
    let sku: String
    let stockID: String
    let price: String
    let location: String
    let metal: String
    let color: String
    let size: String
    let grossWeight: String
    let netWeight: String
    let imageURL: URL?
    let stones: [GISProductSummaryStone]
    let shareID: String
    let variantIconName: String?

    init(data: NSDictionary, fallbackStockID: String) {
        func value(_ keys: [String]) -> String {
            for key in keys {
                let text = "\(data[key] ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty, text != "<null>" {
                    return text
                }
            }
            return "--"
        }

        name = value(["name", "item_name", "product_name"])
        metaTag = value(["Matatag", "metatag", "category_name", "category"])
        productID = value(["ID", "display_id", "product_code", "product_id"])
        sku = value(["SKU", "sku"])
        let loadedStockID = value(["stock_id", "stockId", "StockId", "stock_no", "stock_number"])
        stockID = loadedStockID == "--" && !fallbackStockID.isEmpty ? fallbackStockID : loadedStockID
        price = GISProductSummary.formatPrice(value(["price", "retailprice", "retail_price"]))
        location = value(["location_name", "location"])
        metal = value(["metal_name", "metal"])
        color = value(["color_name", "Color_name", "color"])
        size = value(["size_name", "Size", "size"])
        grossWeight = value(["GrossWt", "gross_weight", "grossWt"])
        netWeight = value(["NetWt", "net_weight", "netWt"])

        let imageText = value(["main_image", "images", "image"])
        imageURL = imageText == "--" ? nil : URL(string: imageText)

        let stones = GISProductSummary.stones(from: data)
        self.stones = stones.map(GISProductSummaryStone.init)

        shareID = value(["product_id", "parentproduct_id", "main_po_product_id", "baseVariant_id", "id", "_id"])

        let variantType = value(["product_variants_enable"])
        if variantType == "1" {
            variantIconName = "variantic"
        } else if variantType == "2" || variantType == "3" {
            variantIconName = "diamond_ic"
        } else {
            let isVariant = value(["is_variant", "isVariant"]) == "1"
            let isDesign = value(["is_design", "isDesign"]) == "1"
            if isVariant && !isDesign {
                variantIconName = "variantic"
            } else if isVariant || isDesign {
                variantIconName = "diamond_ic"
            } else {
                variantIconName = nil
            }
        }
    }

    private static func stones(from data: NSDictionary) -> [NSDictionary] {
        let directKeys = ["stones", "stoneData", "Stones", "stone_arr", "stone_data"]
        for key in directKeys {
            if let rows = data[key] as? [NSDictionary], !rows.isEmpty { return rows }
            if let rows = data[key] as? NSArray {
                return rows.compactMap { $0 as? NSDictionary }
            }
        }
        if let details = data["product_details"] as? NSDictionary {
            return stones(from: details)
        }
        return []
    }

    private static func formatPrice(_ rawValue: String) -> String {
        guard rawValue != "--" else { return rawValue }
        guard !rawValue.contains(where: { !$0.isNumber && $0 != "." && $0 != "," }) else {
            return rawValue
        }
        guard let value = Double(rawValue.replacingOccurrences(of: ",", with: "")) else {
            return rawValue
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? rawValue
    }
}

struct GISProductSummaryStone: Identifiable, Equatable {
    let id: String
    let stone: String
    let shape: String
    let cut: String
    let clarity: String
    let color: String
    let size: String
    let pieces: String
    let weight: String
    let setting: String
    let certificateType: String
    let certificateNumber: String
    let certificateURL: URL?

    init(data: NSDictionary) {
        func value(_ keys: [String]) -> String {
            for key in keys {
                let text = "\(data[key] ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty, text != "<null>" { return text }
            }
            return "--"
        }

        stone = value(["stone_name", "stone"])
        shape = value(["Shape_name", "shape_name", "shape"])
        cut = value(["Cut_name", "cut"])
        clarity = value(["Clarity_name", "clarity_name", "clarity"])
        color = value(["Color_name", "color"])
        size = value(["size_name", "Size_name", "Size", "stone_size", "size"])
        pieces = value(["Pcs", "pcs", "piece"])
        weight = GISProductSummaryStone.formatWeight(value(["Cts", "totalStoneWt", "weight"]))
        setting = value(["Setting_type_name", "setting_type", "setting"])

        let certificate = data["certificate"] as? NSDictionary
        certificateType = "\(certificate?["type"] ?? data["certificate_type"] ?? data["certificateName"] ?? "--")"
        certificateNumber = value(["certificate_number", "certificateNo", "certificate_no"])
        let urlText = "\(certificate?["url"] ?? data["certificateLink"] ?? data["certificate_link"] ?? "")"
        certificateURL = URL(string: urlText)
        id = [stone, shape, certificateNumber, weight].joined(separator: "-")
    }

    private static func formatWeight(_ rawValue: String) -> String {
        guard rawValue != "--", let value = Double(rawValue) else { return rawValue }
        return String(format: "%.2f", value)
    }
}

struct GISProductSummaryView: View {
    @ObservedObject var viewModel: GISProductSummaryViewModel
    let onClose: () -> Void
    let onShare: () -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            if let product = viewModel.product {
                productBody(product)
            } else if viewModel.isLoading {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .alert("Product Detail", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func productBody(_ product: GISProductSummary) -> some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 14) {
                    overview(product)
                    specifications(product)
                    ForEach(product.stones) { stone in
                        stoneCard(stone)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
        }
    }

    private var header: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .regular))
                    .frame(width: 44, height: 44)
            }
            Spacer()
            Text("Product Detail")
                .font(.system(size: 17, weight: .semibold))
            Spacer()
            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20, weight: .regular))
                    .frame(width: 44, height: 44)
            }
        }
        .foregroundColor(Color.gisSummaryText)
        .padding(.horizontal, 10)
        .frame(height: 56)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.45)
        }
    }

    private func overview(_ product: GISProductSummary) -> some View {
        GeometryReader { proxy in
            HStack(alignment: .bottom, spacing: 0) {
                productImage(product.imageURL)
                    .frame(width: proxy.size.width * 0.34, alignment: .center)
                VStack(alignment: .leading, spacing: 7) {
                    Text(product.metaTag == "--" ? product.name : product.metaTag)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.gisSummaryText)
                        .lineLimit(1)
                    Text(product.metaTag == "--" ? "" : product.name)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Divider()
                    HStack(alignment: .top, spacing: 0) {
                        identifier(title: "Product ID", value: product.productID)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        identifier(title: "SKU", value: product.sku)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack(alignment: .bottom, spacing: 0) {
                        identifier(title: "Stock ID", value: product.stockID)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if let icon = product.variantIconName {
                            Image(icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 27, height: 27, alignment: .leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(width: proxy.size.width * 0.66, alignment: .leading)
            }
        }
        .frame(height: 172)
        .padding(.horizontal, 4)
    }

    private func productImage(_ url: URL?) -> some View {
        ZStack {
            Color.white
            if let url {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit().padding(4)
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    } else {
                        ProgressView()
                    }
                }
            } else {
                Image(systemName: "shippingbox")
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 154, height: 154)
    }

    private func identifier(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.system(size: 13)).foregroundColor(.secondary)
            Text(value).font(.system(size: 14, weight: .medium)).foregroundColor(Color.gisSummaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }

    private func specifications(_ product: GISProductSummary) -> some View {
        VStack(spacing: 14) {
            summaryCard {
                summaryRow("Price", product.price)
                summaryRow("Location", product.location)
            }
            summaryCard {
                summaryRow("Metal", product.metal)
                summaryRow("Color", product.color)
                summaryRow("Size", product.size)
                summaryRow("Gross Wt", product.grossWeight, highlighted: true)
                summaryRow("Net Wt", product.netWeight, highlighted: true)
            }
        }
    }

    private func stoneCard(_ stone: GISProductSummaryStone) -> some View {
        summaryCard {
            summaryRow("Stone", stone.stone)
            summaryRow("Shape", stone.shape)
            summaryRow("Cut", stone.cut)
            summaryRow("Clarity", stone.clarity)
            summaryRow("Color", stone.color)
            summaryRow("Size", stone.size, highlighted: true)
            summaryRow("Pcs", stone.pieces, highlighted: true)
            summaryRow("Weight", stone.weight, highlighted: true)
            summaryRow("Setting", stone.setting)
            HStack(alignment: .firstTextBaseline) {
                Text("Certificate")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 8) {
                    Text(stone.certificateType)
                        .font(.system(size: 15))
                    if let url = stone.certificateURL {
                        Link(destination: url) {
                            HStack(spacing: 4) {
                                Image("arr_ic")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14, height: 14)
                                Text(stone.certificateNumber)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.gisSummaryText)
                            }
                        }
                    } else {
                        Text(stone.certificateNumber)
                            .font(.system(size: 15))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func summaryCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 10, content: content)
            .padding(14)
            .background(Color(.systemGray6).opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func summaryRow(_ title: String, _ value: String, highlighted: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(highlighted ? Color.gisSummaryTeal : Color.gisSummaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(highlighted ? Color.gisSummaryTeal : Color.gisSummaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private extension Color {
    static let gisSummaryText = Color(red: 0.22, green: 0.22, blue: 0.23)
    static let gisSummaryTeal = Color(red: 0.10, green: 0.79, blue: 0.77)
}
