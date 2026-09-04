//
//  SoldStock.swift
//  GIS
//
//  Sold stock list for Stock Take.
//

import UIKit

final class SoldStock: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIViewControllerTransitioningDelegate {

    var mSoldData: [NSDictionary] = []
    var mCount: String = "0"

    private let contentView = UIView()
    private let searchField = UITextField()
    private let productCard = UIView()
    private let productImage = UIImageView()
    private let skuLabel = UILabel()
    private let productNameLabel = UILabel()
    private let storeLabel = UILabel()
    private let metalTitleLabel = UILabel()
    private let metalLabel = UILabel()
    private let stoneTitleLabel = UILabel()
    private let stoneLabel = UILabel()
    private let sizeTitleLabel = UILabel()
    private let sizeLabel = UILabel()
    private let collectionTitleLabel = UILabel()
    private let collectionLabel = UILabel()
    private let productArrow = UIButton(type: .system)
    private let productArrowBackground = UIView()
    private let tableView = UITableView(frame: .zero, style: .plain)

    private var filteredData: [NSDictionary] = []
    private var selectedProductItem: NSDictionary?
    // Mirrors TotalStock: this holds the full SKU-detail response for the
    // selected Sold item, while mSoldData remains the list response.
    private var loadedItemDetails: NSDictionary?
    private var loadedItemID = ""
    private var productCardHeightConstraint: NSLayoutConstraint!
    private var productSummaryView: UIView?
    private var productSummaryLabels: [UILabel] = []
    private var isProductSummaryExpanded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: "#FAFAFA")
        view.isUserInteractionEnabled = true
        navigationController?.setNavigationBarHidden(true, animated: false)

        filteredData = mSoldData
        selectedProductItem = filteredData.first
        buildUI()
        configureProductCard()
        if let item = selectedProductItem {
            getItemDetails(for: item)
        }
        tableView.reloadData()
    }

    private func makeLabel(fontSize: CGFloat, weight: UIFont.Weight = .regular, color: UIColor = UIColor(hex: "#222222")) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        label.textColor = color
        label.numberOfLines = 1
        return label
    }

    private func buildUI() {
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .white
        view.addSubview(header)

        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor(hex: "#777777")
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        header.addSubview(backButton)

        let titleLabel = makeLabel(fontSize: 20, weight: .semibold, color: UIColor(hex: "#F46565"))
        titleLabel.text = "Sold (\(mCount))"
        titleLabel.textAlignment = .center
        header.addSubview(titleLabel)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)

        // Search
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.backgroundColor = .white
        searchField.layer.cornerRadius = 20
        searchField.layer.borderWidth = 1
        searchField.layer.borderColor = UIColor(hex: "#DDDDDD").cgColor
        searchField.placeholder = "Search by SKU / Stock ID"
        searchField.attributedPlaceholder = NSAttributedString(
            string: "Search by SKU / Stock ID",
            attributes: [.foregroundColor: UIColor(hex: "#C8C8C8")]
        )
        searchField.font = UIFont.systemFont(ofSize: 14)
        searchField.textColor = UIColor(hex: "#222222")
        searchField.tintColor = UIColor(hex: "#AAAAAA")
        searchField.leftView = makeSearchIcon()
        searchField.leftViewMode = .always
        searchField.clearButtonMode = .whileEditing
        searchField.delegate = self
        searchField.isUserInteractionEnabled = true
        searchField.isEnabled = true
        searchField.returnKeyType = .search
        searchField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
        searchField.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(searchFieldTapped))
        )
        if let tap = searchField.gestureRecognizers?.last {
            tap.cancelsTouchesInView = false
        }
        contentView.addSubview(searchField)

        // Product card
        productCard.translatesAutoresizingMaskIntoConstraints = false
        productCard.backgroundColor = .white
        productCard.layer.cornerRadius = 8
        productCard.clipsToBounds = true
        contentView.addSubview(productCard)

        productImage.translatesAutoresizingMaskIntoConstraints = false
        productImage.contentMode = .scaleAspectFit
        productImage.backgroundColor = UIColor(hex: "#FCFCFC")
        productCard.addSubview(productImage)

        skuLabel.translatesAutoresizingMaskIntoConstraints = false
        skuLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        skuLabel.textColor = UIColor(hex: "#3DB7A7")
        skuLabel.isUserInteractionEnabled = true
        skuLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(skuLabelTapped))
        )
        productCard.addSubview(skuLabel)

        productNameLabel.translatesAutoresizingMaskIntoConstraints = false
        productNameLabel.font = UIFont.systemFont(ofSize: 13)
        productNameLabel.textColor = UIColor(hex: "#444444")
        productNameLabel.lineBreakMode = .byTruncatingTail
        productCard.addSubview(productNameLabel)

        storeLabel.translatesAutoresizingMaskIntoConstraints = false
        storeLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        storeLabel.textColor = UIColor(hex: "#444444")
        productCard.addSubview(storeLabel)

        metalTitleLabel.text = "Metal"
        stoneTitleLabel.text = "Stone"
        sizeTitleLabel.text = "Size"
        collectionTitleLabel.text = "Collection"

        for label in [metalTitleLabel, stoneTitleLabel, sizeTitleLabel, collectionTitleLabel] {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor(hex: "#AAAAAA")
            productCard.addSubview(label)
        }
        for label in [metalLabel, stoneLabel, sizeLabel, collectionLabel] {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor(hex: "#444444")
            productCard.addSubview(label)
        }

        // The Metal column can use the open space before Stone, keeping values
        // such as "White Gold" on one complete line.
        metalLabel.numberOfLines = 1
        metalLabel.lineBreakMode = .byClipping

        productArrowBackground.translatesAutoresizingMaskIntoConstraints = false
        productArrowBackground.backgroundColor = UIColor(hex: "#F4F4F4")
        productCard.addSubview(productArrowBackground)

        productArrow.translatesAutoresizingMaskIntoConstraints = false
        productArrow.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        productArrow.tintColor = UIColor(hex: "#777777")
        productArrow.addTarget(self, action: #selector(productArrowTapped), for: .touchUpInside)
        productArrow.isUserInteractionEnabled = true
        productCard.addSubview(productArrow)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 48
        tableView.showsVerticalScrollIndicator = false
        tableView.register(SoldStockCell.self, forCellReuseIdentifier: SoldStockCell.reuseID)
        contentView.addSubview(tableView)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Same header/search rhythm as TotalStock.
            header.heightAnchor.constraint(equalToConstant: 106),

            backButton.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 18),
            backButton.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -18),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),

            titleLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            contentView.topAnchor.constraint(equalTo: header.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            searchField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            searchField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 40),

            productCard.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 8),
            productCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            productCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            productCard.heightAnchor.constraint(equalToConstant: 195),

            productImage.leadingAnchor.constraint(equalTo: productCard.leadingAnchor, constant: 10),
            productImage.topAnchor.constraint(equalTo: productCard.topAnchor, constant: 20),
            productImage.widthAnchor.constraint(equalToConstant: 120),
            productImage.heightAnchor.constraint(equalToConstant: 120),

            skuLabel.leadingAnchor.constraint(equalTo: productImage.trailingAnchor, constant: 10),
            skuLabel.topAnchor.constraint(equalTo: productCard.topAnchor, constant: 8),
            skuLabel.trailingAnchor.constraint(equalTo: productCard.trailingAnchor, constant: -12),

            productNameLabel.leadingAnchor.constraint(equalTo: skuLabel.leadingAnchor),
            productNameLabel.topAnchor.constraint(equalTo: skuLabel.bottomAnchor, constant: 5),
            productNameLabel.trailingAnchor.constraint(equalTo: skuLabel.trailingAnchor),

            storeLabel.leadingAnchor.constraint(equalTo: skuLabel.leadingAnchor),
            storeLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 8),

            metalTitleLabel.leadingAnchor.constraint(equalTo: skuLabel.leadingAnchor),
            metalTitleLabel.topAnchor.constraint(equalTo: storeLabel.bottomAnchor, constant: 8),
            metalTitleLabel.widthAnchor.constraint(equalToConstant: 105),
            metalLabel.leadingAnchor.constraint(equalTo: metalTitleLabel.leadingAnchor),
            metalLabel.topAnchor.constraint(equalTo: metalTitleLabel.bottomAnchor, constant: 1),
            metalLabel.trailingAnchor.constraint(lessThanOrEqualTo: stoneTitleLabel.leadingAnchor, constant: -16),

            stoneTitleLabel.leadingAnchor.constraint(equalTo: productCard.leadingAnchor, constant: 265),
            stoneTitleLabel.topAnchor.constraint(equalTo: metalTitleLabel.topAnchor),
            stoneTitleLabel.trailingAnchor.constraint(equalTo: productCard.trailingAnchor, constant: -12),
            stoneLabel.leadingAnchor.constraint(equalTo: stoneTitleLabel.leadingAnchor),
            stoneLabel.topAnchor.constraint(equalTo: stoneTitleLabel.bottomAnchor, constant: 1),
            stoneLabel.trailingAnchor.constraint(equalTo: stoneTitleLabel.trailingAnchor),

            sizeTitleLabel.leadingAnchor.constraint(equalTo: metalTitleLabel.leadingAnchor),
            sizeTitleLabel.topAnchor.constraint(equalTo: metalLabel.bottomAnchor, constant: 5),
            sizeTitleLabel.widthAnchor.constraint(equalToConstant: 105),
            sizeLabel.leadingAnchor.constraint(equalTo: sizeTitleLabel.leadingAnchor),
            sizeLabel.topAnchor.constraint(equalTo: sizeTitleLabel.bottomAnchor, constant: 1),
            sizeLabel.trailingAnchor.constraint(lessThanOrEqualTo: productCard.centerXAnchor, constant: -10),

            collectionTitleLabel.leadingAnchor.constraint(equalTo: stoneTitleLabel.leadingAnchor),
            collectionTitleLabel.topAnchor.constraint(equalTo: stoneLabel.bottomAnchor, constant: 5),
            collectionLabel.leadingAnchor.constraint(equalTo: collectionTitleLabel.leadingAnchor),
            collectionLabel.topAnchor.constraint(equalTo: collectionTitleLabel.bottomAnchor, constant: 1),
            collectionLabel.trailingAnchor.constraint(equalTo: collectionTitleLabel.trailingAnchor),

            productArrowBackground.leadingAnchor.constraint(equalTo: productCard.leadingAnchor),
            productArrowBackground.trailingAnchor.constraint(equalTo: productCard.trailingAnchor),
            productArrowBackground.bottomAnchor.constraint(equalTo: productCard.bottomAnchor),
            productArrowBackground.heightAnchor.constraint(equalToConstant: 27),

            productArrow.leadingAnchor.constraint(equalTo: productCard.leadingAnchor),
            productArrow.trailingAnchor.constraint(equalTo: productCard.trailingAnchor),
            productArrow.bottomAnchor.constraint(equalTo: productCard.bottomAnchor),
            productArrow.heightAnchor.constraint(equalToConstant: 27),

            tableView.topAnchor.constraint(equalTo: productCard.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        productCardHeightConstraint = productCard.constraints.first {
            $0.firstAttribute == .height && $0.relation == .equal
        }
    }

    private func makeSearchIcon() -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 43))
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor(hex: "#CCCCCC")
        imageView.contentMode = .scaleAspectFit
        container.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 17),
            imageView.heightAnchor.constraint(equalToConstant: 17)
        ])
        return container
    }

    private func configureProductCard() {
        guard let item = selectedProductItem ?? filteredData.first else {
            skuLabel.text = ""
            productNameLabel.text = ""
            storeLabel.text = "STORE"
            metalLabel.text = ""
            stoneLabel.text = ""
            sizeLabel.text = ""
            collectionLabel.text = ""
            productImage.image = nil
            removeProductSummary()
            return
        }

        skuLabel.text = stringValue(item, keys: ["SKU", "sku"])
        productNameLabel.text = stringValue(item, keys: ["name", "item_name", "product_name"])
        storeLabel.text = "STORE"
        metalLabel.text = stringValue(item, keys: ["metal", "metal_name"])
        stoneLabel.text = stringValue(item, keys: ["stone_name", "stone"])
        sizeLabel.text = stringValue(item, keys: ["size", "size_name"])
        collectionLabel.text = stringValue(item, keys: ["collection", "collection_name"])

        // Sold items use the image returned by the API; there is no mock fallback.
        let imageName = stringValue(item, keys: ["main_image", "image_name"])
        if imageName.isEmpty {
            productImage.image = nil
        } else if let localImage = UIImage(named: imageName) {
            productImage.image = localImage
        } else {
            productImage.downlaodImageFromUrl(urlString: imageName)
        }

        if isProductSummaryExpanded {
            buildOrUpdateProductSummary(for: item)
        }
    }

    private func removeProductSummary() {
        productSummaryView?.removeFromSuperview()
        productSummaryView = nil
        productSummaryLabels.removeAll()
        isProductSummaryExpanded = false
        productCardHeightConstraint?.constant = 195
        productArrow.setImage(UIImage(systemName: "chevron.down"), for: .normal)
    }

    @objc private func productArrowTapped() {
        isProductSummaryExpanded.toggle()

        if isProductSummaryExpanded {
            let item = selectedProductItem ?? filteredData.first ?? mSoldData.first
            guard let item else {
                isProductSummaryExpanded = false
                return
            }

            buildOrUpdateProductSummary(for: item)
            // Match Total: the new Summary must not be visible while the
            // product card is still collapsed, otherwise its labels overlap
            // the Product Detail section.
            productSummaryView?.isHidden = true
            // Resolve the newly-created labels at their fixed top position
            // before changing the card height. Without this pre-layout pass,
            // Auto Layout animates them down from the card's origin.
            view.layoutIfNeeded()
            productCardHeightConstraint?.constant = 390
            productArrow.setImage(UIImage(systemName: "chevron.up"), for: .normal)

            // The labels stay fixed; only the summary area and table position animate.
            UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut]) {
                self.productSummaryView?.isHidden = false
                self.view.layoutIfNeeded()
            }
        } else {
            let summary = productSummaryView
            productArrow.setImage(UIImage(systemName: "chevron.down"), for: .normal)

            // Keep text visible until the collapsing layout has finished.
            productCardHeightConstraint?.constant = 195
            UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut]) {
                self.view.layoutIfNeeded()
            } completion: { _ in
                summary?.removeFromSuperview()
                self.removeProductSummary()
            }
        }
    }

    private func buildOrUpdateProductSummary(for item: NSDictionary) {
        productSummaryView?.removeFromSuperview()
        productSummaryLabels.removeAll()

        let summary = UIView()
        summary.translatesAutoresizingMaskIntoConstraints = false
        // TotalStock presents Product Summary as a separate light-gray section,
        // not as an extension of the white product-detail card.
        summary.backgroundColor = UIColor(hex: "#FAFAFA")
        productCard.addSubview(summary)
        productSummaryView = summary

        let title = makeLabel(fontSize: 16, weight: .semibold, color: UIColor(hex: "#222222"))
        title.text = "Product Summary"
        summary.addSubview(title)
        productSummaryLabels.append(title)

        let materialTitle = makeLabel(fontSize: 13, color: UIColor(hex: "#333333"))
        materialTitle.text = "Material"
        let materialValue = makeLabel(fontSize: 13, color: UIColor(hex: "#999999"))
        materialValue.text = stringValue(item, keys: ["metal", "metal_name"])
        let materialWeight = makeLabel(fontSize: 13, color: UIColor(hex: "#999999"))
        materialWeight.text = stringValue(item, keys: ["weight", "gross_weight"])
        summary.addSubview(materialTitle)
        summary.addSubview(materialValue)
        summary.addSubview(materialWeight)

        let stoneTitle = makeLabel(fontSize: 13, color: UIColor(hex: "#333333"))
        stoneTitle.text = "Stone"
        let stones = stoneDetails(for: item)
        let firstStone = stones.first
        let secondStone = stones.dropFirst().first

        let stoneValue = makeLabel(fontSize: 13, color: UIColor(hex: "#999999"))
        stoneValue.text = firstStone?.name ?? stringValue(item, keys: ["stone_name", "stone"])
        let stonePcs = makeLabel(fontSize: 13, color: UIColor(hex: "#999999"))
        stonePcs.text = firstStone?.pcs ?? ""
        stonePcs.textAlignment = .right
        let stoneCts = makeLabel(fontSize: 13, color: UIColor(hex: "#999999"))
        stoneCts.text = firstStone.map { "\($0.cts) c" } ?? ""
        stoneCts.textAlignment = .right

        let secondStoneValue = makeLabel(fontSize: 13, color: UIColor(hex: "#999999"))
        secondStoneValue.text = secondStone?.name ?? ""
        let secondStonePcs = makeLabel(fontSize: 13, color: UIColor(hex: "#999999"))
        secondStonePcs.text = secondStone?.pcs ?? ""
        secondStonePcs.textAlignment = .right
        let secondStoneCts = makeLabel(fontSize: 13, color: UIColor(hex: "#999999"))
        secondStoneCts.text = secondStone.map { "\($0.cts) c" } ?? ""
        secondStoneCts.textAlignment = .right

        summary.addSubview(stoneTitle)
        summary.addSubview(stoneValue)
        summary.addSubview(stonePcs)
        summary.addSubview(stoneCts)
        summary.addSubview(secondStoneValue)
        summary.addSubview(secondStonePcs)
        summary.addSubview(secondStoneCts)

        let referenceTitle = makeLabel(fontSize: 13, color: UIColor(hex: "#333333"))
        referenceTitle.text = "Reference No."
        let referenceValue = makeLabel(fontSize: 13, color: UIColor(hex: "#999999"))
        referenceValue.text = stringValue(item, keys: ["SKU", "sku"])
        referenceValue.textAlignment = .right
        summary.addSubview(referenceTitle)
        summary.addSubview(referenceValue)

        let certificateTitle = makeLabel(fontSize: 13, color: UIColor(hex: "#333333"))
        certificateTitle.text = "Certificate"
        let certificateValue = makeLabel(fontSize: 13, color: UIColor(hex: "#999999"))
        certificateValue.text = "EFCO"
        certificateValue.textAlignment = .right
        summary.addSubview(certificateTitle)
        summary.addSubview(certificateValue)

        NSLayoutConstraint.activate([
            summary.leadingAnchor.constraint(equalTo: productCard.leadingAnchor),
            summary.trailingAnchor.constraint(equalTo: productCard.trailingAnchor),
            // Product Summary begins below the closed Product Detail section.
            // Because productCard clips its subviews, its labels are revealed
            // only as the card grows, rather than overlapping the detail above.
            summary.topAnchor.constraint(equalTo: productCard.topAnchor, constant: 195),
            // Keep a fixed Summary body height. It sits outside the collapsed
            // card and is clipped there; once expanded, it ends just above the
            // bottom arrow without producing collapsed-state constraints.
            summary.heightAnchor.constraint(equalToConstant: 164),

            title.leadingAnchor.constraint(equalTo: summary.leadingAnchor),
            title.topAnchor.constraint(equalTo: summary.topAnchor),

            materialTitle.leadingAnchor.constraint(equalTo: summary.leadingAnchor),
            materialTitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            materialValue.leadingAnchor.constraint(equalTo: summary.leadingAnchor, constant: 144),
            materialValue.centerYAnchor.constraint(equalTo: materialTitle.centerYAnchor),
            materialWeight.trailingAnchor.constraint(equalTo: summary.trailingAnchor),
            materialWeight.centerYAnchor.constraint(equalTo: materialTitle.centerYAnchor),

            stoneTitle.leadingAnchor.constraint(equalTo: summary.leadingAnchor),
            stoneTitle.topAnchor.constraint(equalTo: materialTitle.bottomAnchor, constant: 7),
            stoneValue.leadingAnchor.constraint(equalTo: materialValue.leadingAnchor),
            stoneValue.centerYAnchor.constraint(equalTo: stoneTitle.centerYAnchor),
            stoneValue.trailingAnchor.constraint(lessThanOrEqualTo: stonePcs.leadingAnchor, constant: -8),
            stonePcs.trailingAnchor.constraint(equalTo: stoneCts.leadingAnchor, constant: -16),
            stonePcs.centerYAnchor.constraint(equalTo: stoneTitle.centerYAnchor),
            stonePcs.widthAnchor.constraint(equalToConstant: 28),
            stoneCts.trailingAnchor.constraint(equalTo: summary.trailingAnchor),
            stoneCts.centerYAnchor.constraint(equalTo: stoneTitle.centerYAnchor),
            stoneCts.widthAnchor.constraint(equalToConstant: 64),

            secondStoneValue.leadingAnchor.constraint(equalTo: materialValue.leadingAnchor),
            secondStoneValue.topAnchor.constraint(equalTo: stoneValue.bottomAnchor, constant: 7),
            secondStoneValue.trailingAnchor.constraint(lessThanOrEqualTo: secondStonePcs.leadingAnchor, constant: -8),
            secondStonePcs.trailingAnchor.constraint(equalTo: secondStoneCts.leadingAnchor, constant: -16),
            secondStonePcs.centerYAnchor.constraint(equalTo: secondStoneValue.centerYAnchor),
            secondStonePcs.widthAnchor.constraint(equalToConstant: 28),
            secondStoneCts.trailingAnchor.constraint(equalTo: summary.trailingAnchor),
            secondStoneCts.centerYAnchor.constraint(equalTo: secondStoneValue.centerYAnchor),
            secondStoneCts.widthAnchor.constraint(equalToConstant: 64),

            referenceTitle.leadingAnchor.constraint(equalTo: summary.leadingAnchor),
            referenceTitle.topAnchor.constraint(equalTo: secondStoneValue.bottomAnchor, constant: 7),
            referenceValue.trailingAnchor.constraint(equalTo: summary.trailingAnchor),
            referenceValue.centerYAnchor.constraint(equalTo: referenceTitle.centerYAnchor),

            certificateTitle.leadingAnchor.constraint(equalTo: summary.leadingAnchor),
            certificateTitle.topAnchor.constraint(equalTo: referenceTitle.bottomAnchor, constant: 7),
            certificateValue.trailingAnchor.constraint(equalTo: summary.trailingAnchor),
            certificateValue.centerYAnchor.constraint(equalTo: certificateTitle.centerYAnchor)
        ])
    }

    private func stringValue(_ item: NSDictionary, keys: [String]) -> String {
        // Prefer the full item-detail response, just as TotalStock does.
        if let details = loadedItemDetails {
            for key in keys {
                if let value = details[key], !"\(value)".trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return "\(value)"
                }
            }
        }

        for key in keys {
            if let value = item[key], !"\(value)".trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "\(value)"
            }
        }
        if let details = item["product_details"] as? NSDictionary {
            for key in keys {
                if let value = details[key], !"\(value)".trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return "\(value)"
                }
            }
        }
        return ""
    }

    private func stoneDetails(for item: NSDictionary) -> [(name: String, pcs: String, cts: String)] {
        let rawStones = (loadedItemDetails?["stones"] as? [NSDictionary])
            ?? (item["stones"] as? [NSDictionary])
            ?? []

        return rawStones.map { stone in
            (
                name: "\(stone["stone_name"] ?? "")",
                pcs: "\(stone["pcs"] ?? stone["Pcs"] ?? "")",
                cts: "\(stone["cts"] ?? stone["Cts"] ?? "")"
            )
        }
    }

    private func getItemDetails(for item: NSDictionary) {
        let id = stringValue(item, keys: ["_id", "product_id", "productId"])
        guard !id.isEmpty else { return }

        loadedItemID = id
        loadedItemDetails = nil

        let params: [String: Any] = ["id": id]
        mGetData(url: sSkuDetail, headers: sGisHeaders, params: params) { [weak self] response, status in
            guard let self, status,
                  self.loadedItemID == id,
                  let code = response.value(forKey: "code") as? Int,
                  code == 200,
                  let details = response.value(forKey: "data") as? NSDictionary else {
                return
            }

            self.loadedItemDetails = details
            self.configureProductCard()
            self.view.setNeedsLayout()
        }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func searchFieldTapped() {
        searchField.becomeFirstResponder()
    }

    @objc private func skuLabelTapped() {
        guard let item = selectedProductItem ?? filteredData.first ?? mSoldData.first else { return }

        let productID = stringValue(item, keys: ["_id", "product_id", "productId"])
        guard !productID.isEmpty else {
            print("⚠️ SoldStock: Product ID is empty")
            return
        }

        let storyBoard = UIStoryboard(name: "common", bundle: nil)
        guard let summary = storyBoard.instantiateViewController(
            withIdentifier: "SKUProductSummary"
        ) as? SKUProductSummary else {
            print("⚠️ SoldStock: SKUProductSummary storyboard ID not found")
            return
        }

        summary.mKey = productID
        summary.mType = "Inventory"
        summary.modalPresentationStyle = .automatic
        summary.transitioningDelegate = self
        present(summary, animated: true)
    }

    @objc private func searchChanged() {
        let query = (searchField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty {
            filteredData = mSoldData
        } else {
            filteredData = mSoldData.filter {
                let sku = stringValue($0, keys: ["SKU", "sku"]).lowercased()
                let stockID = stringValue($0, keys: ["stock_id", "stockId"]).lowercased()
                return sku.contains(query) || stockID.contains(query)
            }
        }

        selectedProductItem = filteredData.first
        loadedItemDetails = nil
        loadedItemID = ""
        isProductSummaryExpanded = false
        productSummaryView?.removeFromSuperview()
        productSummaryView = nil
        productSummaryLabels.removeAll()
        productCardHeightConstraint?.constant = 195
        productArrow.setImage(UIImage(systemName: "chevron.down"), for: .normal)

        configureProductCard()
        if let item = selectedProductItem {
            getItemDetails(for: item)
        }
        tableView.reloadData()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard filteredData.indices.contains(indexPath.row) else { return }

        selectedProductItem = filteredData[indexPath.row]
        loadedItemDetails = nil
        loadedItemID = ""
        isProductSummaryExpanded = false
        productSummaryView?.removeFromSuperview()
        productSummaryView = nil
        productSummaryLabels.removeAll()
        productCardHeightConstraint?.constant = 195
        productArrow.setImage(UIImage(systemName: "chevron.down"), for: .normal)

        UIView.performWithoutAnimation {
            configureProductCard()
            view.layoutIfNeeded()
        }

        getItemDetails(for: filteredData[indexPath.row])

        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SoldStockCell.reuseID, for: indexPath) as! SoldStockCell
        cell.configure(
            index: indexPath.row + 1,
            item: filteredData[indexPath.row],
            valueProvider: { [weak self] item, keys in
                self?.stringValue(item, keys: keys) ?? ""
            }
        )
        return cell
    }
}

final class SoldStockCell: UITableViewCell {
    static let reuseID = "SoldStockCell"

    private let numberLabel = UILabel()
    private let stockLabel = UILabel()
    private let skuLabel = UILabel()
    private let iconView = UIImageView()
    private let quantityLabel = UILabel()
    private let rowBackground = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }

    private func buildUI() {
        backgroundColor = .clear
        selectionStyle = .none

        rowBackground.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rowBackground)

        for label in [numberLabel, stockLabel, skuLabel, quantityLabel] {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            label.textColor = UIColor(hex: "#333333")
            label.numberOfLines = 1
            contentView.addSubview(label)
        }

        stockLabel.textColor = UIColor(hex: "#F46565")
        skuLabel.textColor = UIColor(hex: "#333333")
        quantityLabel.textAlignment = .right

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = nil
        iconView.contentMode = .scaleAspectFit
        contentView.addSubview(iconView)

        NSLayoutConstraint.activate([
            rowBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rowBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rowBackground.topAnchor.constraint(equalTo: contentView.topAnchor),
            rowBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            numberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 13),
            numberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            numberLabel.widthAnchor.constraint(equalToConstant: 30),

            stockLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 52),
            stockLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stockLabel.widthAnchor.constraint(equalToConstant: 68),

            skuLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 148),
            skuLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            skuLabel.trailingAnchor.constraint(lessThanOrEqualTo: iconView.leadingAnchor, constant: -8),

            iconView.trailingAnchor.constraint(equalTo: quantityLabel.leadingAnchor, constant: -16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            quantityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            quantityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            quantityLabel.widthAnchor.constraint(equalToConstant: 48)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        rowBackground.backgroundColor = indexPathRowIsEven ? UIColor(hex: "#FFFFFF") : UIColor(hex: "#F4F4F4")
    }

    private var indexPathRowIsEven = true

    private func imageForVariantType(_ value: String) -> UIImage? {
        let raw = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }

        // Support the existing variant codes already used in SKUProductSummary.
        switch raw.lowercased() {
        case "1", "variant", "variants":
            return UIImage(named: "variantic")
        case "2", "3", "design", "diamond", "ring":
            return UIImage(named: "diamond_ic")
        default:
            break
        }

        // If API variantType is already the asset name, use it directly.
        if let image = UIImage(named: raw) {
            return image
        }

        // Also support values such as "ring", "earring", etc. when the
        // corresponding asset is named "<variantType>_ic".
        if let image = UIImage(named: "\(raw.lowercased())_ic") {
            return image
        }

        return nil
    }

    func configure(index: Int, item: NSDictionary, valueProvider: (NSDictionary, [String]) -> String) {
        indexPathRowIsEven = index % 2 == 1
        numberLabel.text = "#\(index)"
        stockLabel.text = valueProvider(item, ["stock_id", "stockId"])
        skuLabel.text = valueProvider(item, ["SKU", "sku"])

        let variantType = valueProvider(item, ["variantType", "variant_type"])
        // The Sold API does not provide variantType yet.  Keep this column
        // empty instead of showing a misleading default diamond icon.
        iconView.image = imageForVariantType(variantType)
        iconView.isHidden = variantType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        // Sold quantity is normally not po_QTY (po_QTY can be 0 for sold stock).
        // Prefer an explicit sold quantity when the API provides one.
        let sold = valueProvider(item, ["sold_qty", "sold", "sold_quantity", "soldQty", "quantity", "qty"])
        quantityLabel.text = sold.isEmpty ? "0 Pcs" : "\(sold) Pcs"
        setNeedsLayout()
    }
}
