import SwiftUI

struct GISProductDetail: Equatable, Identifiable {
    let id: String
    let sku: String
    let metaTag: String
    let location: String
    let status: String
    let collection: String
    let metal: String
    let stone: String
    let size: String
    let color: String
    let grossWeight: String
    let netWeight: String
    let price: String
    let imageURL: URL?
    let imageURLs: [URL]
    let stones: [GISStoneDetail]

    init(data: NSDictionary) {
        func value(_ key: String) -> String {
            let raw = data[key]
            let string = raw.map { "\($0)" } ?? ""
            return string.isEmpty || string == "<null>" ? "--" : string
        }

        id = value("stock_id")
        sku = value("SKU")
        metaTag = value("Matatag")
        location = value("location_name")
        status = value("type")
        collection = value("Collection_name")
        metal = value("metal_name")
        stone = value("stoneName")
        size = value("size_name")
        color = value("color_name")
        grossWeight = value("grossWt")
        netWeight = value("netWt")
        price = value("price")
        let imagePath = value("main_image")
        imageURL = imagePath == "--" ? nil : URL(string: imagePath)
        imageURLs = (data["allImage"] as? [String] ?? [])
            .compactMap(URL.init(string:))
        stones = (data["stone_arr"] as? [NSDictionary] ?? []).map(GISStoneDetail.init)
    }
}

struct GISStoneDetail: Identifiable, Equatable {
    let id: String
    let stone: String
    let shape: String
    let cut: String
    let clarity: String
    let size: String
    let weight: String
    let pieces: String
    let certificateType: String
    let certificateNumber: String
    let certificateURL: URL?

    init(data: NSDictionary) {
        func value(_ key: String) -> String {
            let raw = data[key]
            let string = raw.map { "\($0)" } ?? ""
            return string.isEmpty || string == "<null>" ? "--" : string
        }

        stone = value("stone")
        shape = value("shape")
        cut = value("cut")
        clarity = value("clarity")
        size = value("stone_size")
        weight = value("weight")
        pieces = value("pcs")
        certificateType = value("certificate_type")
        certificateNumber = value("certificate_no")
        let certificatePath = value("certificate_url")
        certificateURL = certificatePath == "--" ? nil : URL(string: certificatePath)
        id = [stone, shape, certificateNumber].joined(separator: "-")
    }
}

struct GISProductDetailView: View {
    let product: GISProductDetail
    let onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                productImage
                titleSection
                statusSection
                detailsSection
                if !product.stones.isEmpty {
                    stonesSection
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Product Detail")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }

    private var productImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
            if !product.imageURLs.isEmpty {
                TabView {
                    ForEach(product.imageURLs, id: \.self) { url in
                        remoteImage(url)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
            } else if let imageURL = product.imageURL {
                remoteImage(imageURL)
            } else {
                Image(systemName: "shippingbox")
                    .font(.system(size: 52))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(product.sku)
                .font(.title2.weight(.semibold))
            Text(product.metaTag)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(product.price)
                .font(.title3.weight(.bold))
                .foregroundColor(Color.gisProductTeal)
        }
    }

    private var statusSection: some View {
        HStack(spacing: 8) {
            Circle().fill(statusColor).frame(width: 10, height: 10)
            Text(product.status)
                .font(.subheadline.weight(.medium))
            Spacer()
            Text(product.location)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var detailsSection: some View {
        VStack(spacing: 0) {
            detailRow("Stock ID", product.id)
            detailRow("Collection", product.collection)
            detailRow("Metal", product.metal)
            detailRow("Stone", product.stone)
            detailRow("Size", product.size)
            detailRow("Color", product.color)
            detailRow("Gross weight", product.grossWeight)
            detailRow("Net weight", product.netWeight, showsDivider: false)
        }
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var stonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stone Details")
                .font(.headline)
            ForEach(product.stones) { stone in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(stone.stone).font(.headline)
                        Spacer()
                        Text(stone.weight).foregroundColor(.secondary)
                    }
                    detailGrid(stone)
                    if let url = stone.certificateURL {
                        Link("Open Certificate", destination: url)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(Color.gisProductTeal)
                    }
                }
                .padding(14)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private func remoteImage(_ url: URL) -> some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image.resizable().scaledToFit().padding(16)
            } else if phase.error != nil {
                Image(systemName: "photo")
                    .font(.system(size: 42))
                    .foregroundColor(.secondary)
            } else {
                ProgressView()
            }
        }
    }

    private func detailGrid(_ stone: GISStoneDetail) -> some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            alignment: .leading,
            spacing: 10
        ) {
            stoneValue("Shape", stone.shape)
            stoneValue("Cut", stone.cut)
            stoneValue("Clarity", stone.clarity)
            stoneValue("Size", stone.size)
            stoneValue("Pieces", stone.pieces)
            stoneValue("Certificate", stone.certificateNumber)
        }
    }

    private func stoneValue(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(value).font(.subheadline)
        }
    }

    private func detailRow(_ title: String, _ value: String, showsDivider: Bool = true) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title).foregroundColor(.secondary)
                Spacer()
                Text(value).multilineTextAlignment(.trailing)
            }
            .font(.subheadline)
            .padding(.vertical, 14)
            if showsDivider { Divider() }
        }
    }

    private var statusColor: Color {
        switch product.status.lowercased() {
        case "reserved": return .orange
        case "sales order": return .red
        case "repair order", "repair order inventory": return .purple
        default: return Color.gisProductTeal
        }
    }
}

private extension Color {
    static let gisProductTeal = Color(red: 0.0, green: 0.66, blue: 0.66)
}
