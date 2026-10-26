//
//  TraceabilityView.swift
//  GIS
//
//  "Traceability" tab of the Trace screen (TrackStocks).
//  UI only — currently driven by TraceabilityData.mock until the API is ready.
//

import UIKit
import SDWebImage

// MARK: - Model

/// Visual style of one stop on the traceability timeline.
/// The API should send the `group` key (see TraceStep.init(dictionary:)); the colors/icons are owned by the app.
enum TraceStepGroup: String {
    case design        // navy
    case chain         // blue
    case diamond       // black
    case metal         // light blue
    case handcrafting  // gray
    case shipping      // green

    var color: UIColor {
        switch self {
        case .design:       return UIColor(red: 0.24, green: 0.35, blue: 0.60, alpha: 1)
        case .chain:        return UIColor(red: 0.22, green: 0.55, blue: 0.85, alpha: 1)
        case .diamond:      return UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1)
        case .metal:        return UIColor(red: 0.42, green: 0.65, blue: 0.88, alpha: 1)
        case .handcrafting: return UIColor(red: 0.50, green: 0.50, blue: 0.52, alpha: 1)
        case .shipping:     return UIColor(red: 0.42, green: 0.69, blue: 0.55, alpha: 1)
        }
    }

    /// SF Symbol shown inside a large node.
    var symbolName: String {
        switch self {
        case .design:       return "pencil.and.ruler"
        case .chain:        return "link"
        case .diamond:      return "diamond"
        case .metal:        return "mountain.2"
        case .handcrafting: return "hammer"
        case .shipping:     return "shippingbox"
        }
    }
}

struct TraceStep {
    let title: String
    let location: String
    /// Already formatted as dd/MM/yy HH:mm; nil = no date shown.
    let date: String?
    let group: TraceStepGroup
    /// true = big icon node, false = small dot node (sub-step).
    let isMajor: Bool
    /// Draw the vertical connector between this node and the next one.
    let lineBelow: Bool

    init(title: String, location: String, date: String?, group: TraceStepGroup, isMajor: Bool, lineBelow: Bool) {
        self.title = title
        self.location = location
        self.date = date
        self.group = group
        self.isMajor = isMajor
        self.lineBelow = lineBelow
    }

    init?(dictionary: [String: Any]) {
        guard let title = dictionary["title"] as? String,
              let group = TraceStepGroup(rawValue: "\(dictionary["group"] ?? "")") else { return nil }
        self.init(title: title,
                  location: "\(dictionary["location"] ?? "")",
                  date: dictionary["date"] as? String,
                  group: group,
                  isMajor: (dictionary["is_major"] as? Bool) ?? true,
                  lineBelow: (dictionary["line_below"] as? Bool) ?? false)
    }
}

struct TraceabilityData {
    let imageUrl: String?
    let productName: String
    let sku: String
    let stockId: String
    let transactionId: String
    let quantity: String
    let steps: [TraceStep]

    static let mock = TraceabilityData(
        imageUrl: nil,
        productName: "#1 CT. Round Diamond Solitaire V Bale Necklace",
        sku: "BL0007",
        stockId: "1234",
        transactionId: "0x019cddac4815ee68426785621d0e4423d25f9445954c8e83fe77cd62eb77239f",
        quantity: "1",
        steps: [
            TraceStep(title: "Product Design", location: "UK", date: nil, group: .design, isMajor: true, lineBelow: true),
            TraceStep(title: "Chain Origin", location: "Italy", date: "04/05/25 11:30", group: .chain, isMajor: true, lineBelow: false),
            TraceStep(title: "Chain Making", location: "Italy", date: "14/05/25 11:30", group: .chain, isMajor: false, lineBelow: false),
            TraceStep(title: "Component Supplier", location: "Italy", date: "14/05/25 11:30", group: .chain, isMajor: false, lineBelow: true),
            TraceStep(title: "Diamond Mine", location: "Zimbabwe", date: "20/04/25 11:30", group: .diamond, isMajor: true, lineBelow: false),
            TraceStep(title: "Diamond Cutter", location: "India", date: "30/04/25 11:30", group: .diamond, isMajor: false, lineBelow: true),
            TraceStep(title: "Metal Origin", location: "USA", date: "02/05/25 11:30", group: .metal, isMajor: true, lineBelow: false),
            TraceStep(title: "Handcrafting", location: "India", date: "16/06/25 11:30", group: .handcrafting, isMajor: true, lineBelow: false),
            TraceStep(title: "QC & Shipping", location: "UK", date: "22/06/25 11:30", group: .shipping, isMajor: true, lineBelow: false)
        ]
    )
}

// MARK: - Views

/// One timeline row: node + connector on the left, title/location in the middle, date on the right.
private final class TraceStepRow: UIView {

    static let nodeRegionHeight: CGFloat = 34
    private static let majorSize: CGFloat = 34
    private static let minorSize: CGFloat = 14
    private static let nodeCenterX: CGFloat = 29

    /// `height` is the distance from this node's top to the next node's top.
    init(step: TraceStep, height: CGFloat) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true

        let color = step.group.color

        // Node
        let nodeSize = step.isMajor ? Self.majorSize : Self.minorSize
        let node = UIView()
        node.translatesAutoresizingMaskIntoConstraints = false
        node.backgroundColor = color
        node.layer.cornerRadius = nodeSize / 2
        addSubview(node)
        NSLayoutConstraint.activate([
            node.widthAnchor.constraint(equalToConstant: nodeSize),
            node.heightAnchor.constraint(equalToConstant: nodeSize),
            node.centerXAnchor.constraint(equalTo: leadingAnchor, constant: Self.nodeCenterX),
            node.centerYAnchor.constraint(equalTo: topAnchor, constant: Self.nodeRegionHeight / 2)
        ])

        if step.isMajor {
            let icon = UIImageView(image: UIImage(systemName: step.group.symbolName))
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.tintColor = .white
            icon.contentMode = .scaleAspectFit
            node.addSubview(icon)
            NSLayoutConstraint.activate([
                icon.centerXAnchor.constraint(equalTo: node.centerXAnchor),
                icon.centerYAnchor.constraint(equalTo: node.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 16),
                icon.heightAnchor.constraint(equalToConstant: 16)
            ])
        } else {
            // Ring: colored disc with a white core.
            let core = UIView()
            core.translatesAutoresizingMaskIntoConstraints = false
            core.backgroundColor = .white
            core.layer.cornerRadius = 3
            node.addSubview(core)
            NSLayoutConstraint.activate([
                core.centerXAnchor.constraint(equalTo: node.centerXAnchor),
                core.centerYAnchor.constraint(equalTo: node.centerYAnchor),
                core.widthAnchor.constraint(equalToConstant: 6),
                core.heightAnchor.constraint(equalToConstant: 6)
            ])
        }

        // Connector
        if step.lineBelow {
            let line = UIView()
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = UIColor(white: 0.82, alpha: 1)
            addSubview(line)
            NSLayoutConstraint.activate([
                line.widthAnchor.constraint(equalToConstant: 2),
                line.centerXAnchor.constraint(equalTo: node.centerXAnchor),
                line.topAnchor.constraint(equalTo: topAnchor, constant: Self.nodeRegionHeight + 6),
                line.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
            ])
        }

        // Texts
        let title = UILabel()
        title.text = step.title
        title.font = UIFont(name: "SegoeUI-Semibold", size: 13) ?? .systemFont(ofSize: 13, weight: .semibold)
        title.textColor = color

        let location = UILabel()
        location.text = step.location
        location.font = UIFont(name: "SegoeUI", size: 12) ?? .systemFont(ofSize: 12)
        location.textColor = color

        let texts = UIStackView(arrangedSubviews: [title, location])
        texts.axis = .vertical
        texts.spacing = 0
        texts.translatesAutoresizingMaskIntoConstraints = false
        addSubview(texts)
        NSLayoutConstraint.activate([
            texts.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 64),
            texts.centerYAnchor.constraint(equalTo: topAnchor, constant: Self.nodeRegionHeight / 2)
        ])

        // Date
        if let date = step.date {
            let dateLabel = UILabel()
            dateLabel.text = date
            dateLabel.font = UIFont(name: "SegoeUI", size: 12) ?? .systemFont(ofSize: 12)
            dateLabel.textColor = UIColor(white: 0.62, alpha: 1)
            dateLabel.textAlignment = .right
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            addSubview(dateLabel)
            NSLayoutConstraint.activate([
                dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: texts.trailingAnchor, constant: 8),
                dateLabel.centerYAnchor.constraint(equalTo: texts.centerYAnchor, constant: 8)
            ])
            dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// Content of the "Traceability" tab: product header card + vertical timeline.
final class TraceabilityView: UIView {

    private let scrollView = UIScrollView()
    private let card = UIView()
    private let productImageView = UIImageView()
    private let nameLabel = UILabel()
    private let skuLabel = UILabel()
    private let stockLabel = UILabel()
    private let transactionTitleLabel = UILabel()
    private let transactionLabel = UILabel()
    private let quantityLabel = UILabel()
    private let timelineStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    // MARK: Public

    func configure(with data: TraceabilityData) {
        nameLabel.text = data.productName
        skuLabel.text = data.sku
        stockLabel.text = "\("Stock Id".localizedString): \(data.stockId)"
        transactionTitleLabel.text = "Transaction ID".localizedString
        transactionLabel.text = data.transactionId
        quantityLabel.attributedText = Self.quantityText(title: "Quantity".localizedString, value: data.quantity)

        productImageView.image = UIImage(systemName: "circle.hexagongrid")
        if let urlString = data.imageUrl, let url = URL(string: urlString) {
            productImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "circle.hexagongrid"))
        }

        timelineStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, step) in data.steps.enumerated() {
            let isLast = index == data.steps.count - 1
            timelineStack.addArrangedSubview(TraceStepRow(step: step, height: Self.rowHeight(at: index, in: data.steps, isLast: isLast)))
        }
    }

    // MARK: Layout helpers

    /// Distance from this node's top to the next node's top.
    /// Rows followed by a connector are taller so the line has room (matches the design spacing).
    static func rowHeight(at index: Int, in steps: [TraceStep], isLast: Bool) -> CGFloat {
        let step = steps[index]
        if isLast { return TraceStepRow.nodeRegionHeight }
        if step.lineBelow { return step.isMajor ? 68 : 79 }
        return step.isMajor && steps[index + 1].isMajor ? 68 : 45
    }

    private static func quantityText(title: String, value: String) -> NSAttributedString {
        let font = UIFont(name: "SegoeUI", size: 12) ?? .systemFont(ofSize: 12)
        let result = NSMutableAttributedString(string: "\(title)  ", attributes: [
            .font: font, .foregroundColor: UIColor(white: 0.55, alpha: 1)
        ])
        result.append(NSAttributedString(string: value, attributes: [
            .font: font, .foregroundColor: UIColor.black
        ]))
        return result
    }

    private func setUp() {
        backgroundColor = UIColor(named: "themeBackground") ?? UIColor(white: 0.98, alpha: 1)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        scrollView.addSubview(card)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            card.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            card.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            card.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])

        // Product image
        let imageBox = UIView()
        imageBox.translatesAutoresizingMaskIntoConstraints = false
        imageBox.backgroundColor = UIColor(white: 0.95, alpha: 1)
        imageBox.layer.cornerRadius = 12
        imageBox.clipsToBounds = true
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        productImageView.contentMode = .scaleAspectFit
        productImageView.tintColor = UIColor(white: 0.75, alpha: 1)
        imageBox.addSubview(productImageView)
        card.addSubview(imageBox)

        let regular = UIFont(name: "SegoeUI", size: 12) ?? .systemFont(ofSize: 12)
        let teal = UIColor(named: "themeColor") ?? UIColor(red: 0.36, green: 0.78, blue: 0.76, alpha: 1)

        nameLabel.font = UIFont(name: "SegoeUI", size: 13) ?? .systemFont(ofSize: 13)
        nameLabel.textColor = UIColor(white: 0.15, alpha: 1)
        nameLabel.numberOfLines = 0
        skuLabel.font = regular
        skuLabel.textColor = teal
        stockLabel.font = regular
        stockLabel.textColor = teal
        transactionTitleLabel.font = regular
        transactionTitleLabel.textColor = UIColor(white: 0.55, alpha: 1)
        transactionLabel.font = regular
        transactionLabel.textColor = .black
        transactionLabel.numberOfLines = 0
        transactionLabel.lineBreakMode = .byCharWrapping

        let info = UIStackView(arrangedSubviews: [nameLabel, skuLabel, stockLabel, transactionTitleLabel, transactionLabel, quantityLabel])
        info.axis = .vertical
        info.spacing = 2
        info.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(info)

        timelineStack.axis = .vertical
        timelineStack.spacing = 0
        timelineStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(timelineStack)

        NSLayoutConstraint.activate([
            imageBox.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            imageBox.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            imageBox.widthAnchor.constraint(equalToConstant: 150),
            imageBox.heightAnchor.constraint(equalToConstant: 131),
            productImageView.centerXAnchor.constraint(equalTo: imageBox.centerXAnchor),
            productImageView.centerYAnchor.constraint(equalTo: imageBox.centerYAnchor),
            productImageView.widthAnchor.constraint(equalTo: imageBox.widthAnchor),
            productImageView.heightAnchor.constraint(equalTo: imageBox.heightAnchor),

            info.topAnchor.constraint(equalTo: imageBox.topAnchor),
            info.leadingAnchor.constraint(equalTo: imageBox.trailingAnchor, constant: 12),
            info.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            timelineStack.topAnchor.constraint(equalTo: imageBox.bottomAnchor, constant: 38),
            timelineStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            timelineStack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            timelineStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            info.bottomAnchor.constraint(lessThanOrEqualTo: timelineStack.topAnchor, constant: -8)
        ])
    }
}
