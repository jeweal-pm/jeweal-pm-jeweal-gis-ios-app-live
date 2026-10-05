//
//  WishlistExportOptionsController.swift
//  GIS
//

import UIKit

protocol WishlistExportDelegate: AnyObject {
    func didSelectExportType(_ type: String)
}

class WishlistExportOptionsController: UIViewController, UIGestureRecognizerDelegate {

    weak var delegate: WishlistExportDelegate?
    private var selectedType: String? = nil

    private var catalogCard: UIView?
    private var detailCard: UIView?
    private var catalogTitleLabel: UILabel?
    private var detailTitleLabel: UILabel?
    private var exportButton: UIButton?
    private var cardView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        setupUI()
    }

    // MARK: - UI Setup

    private func setupUI() {
        // Tap outside to dismiss
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        dimTap.delegate = self
        view.addGestureRecognizer(dimTap)

        // Center card container
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.15
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 12
        view.addSubview(card)
        cardView = card

        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Export Option".localizedString
        titleLabel.font = UIFont(name: "SegoeUI-Bold", size: 18) ?? .boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor(named: "themeText") ?? .label
        titleLabel.textAlignment = .center
        card.addSubview(titleLabel)

        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "select your template option to export".localizedString
        subtitleLabel.font = UIFont(name: "SegoeUI", size: 13) ?? .systemFont(ofSize: 13)
        subtitleLabel.textColor = UIColor(named: "themeExtraLightText") ?? .secondaryLabel
        subtitleLabel.textAlignment = .center
        card.addSubview(subtitleLabel)

        // Template options stack
        let optionsStack = UIStackView()
        optionsStack.axis = .horizontal
        optionsStack.spacing = 12
        optionsStack.distribution = .fillEqually
        optionsStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(optionsStack)

        // Catalog option
        let catCard = createTemplateOption(
            title: "Catalog",
            imageName: "export_option_catalog",
            isSelected: false,
            action: #selector(selectCatalog)
        )
        catalogCard = catCard.container
        catalogTitleLabel = catCard.titleLabel
        optionsStack.addArrangedSubview(catCard.container)

        // Detail option
        let detCard = createTemplateOption(
            title: "Detail",
            imageName: "export_option_detail",
            isSelected: false,
            action: #selector(selectDetail)
        )
        detailCard = detCard.container
        detailTitleLabel = detCard.titleLabel
        optionsStack.addArrangedSubview(detCard.container)

        // Export button - starts disabled
        let exportBtn = UIButton(type: .system)
        exportBtn.translatesAutoresizingMaskIntoConstraints = false
        exportBtn.backgroundColor = UIColor.separator
        exportBtn.setTitle("Export".localizedString, for: .normal)
        exportBtn.setTitleColor(.white, for: .normal)
        exportBtn.titleLabel?.font = UIFont(name: "SegoeUI-Semibold", size: 17) ?? .systemFont(ofSize: 17, weight: .semibold)
        exportBtn.layer.cornerRadius = 12
        exportBtn.isEnabled = false
        exportBtn.addTarget(self, action: #selector(exportTapped), for: .touchUpInside)
        card.addSubview(exportBtn)
        exportButton = exportBtn

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            optionsStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            optionsStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            optionsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            optionsStack.heightAnchor.constraint(equalToConstant: 160),

            exportBtn.topAnchor.constraint(equalTo: optionsStack.bottomAnchor, constant: 20),
            exportBtn.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            exportBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            exportBtn.heightAnchor.constraint(equalToConstant: 48),
            exportBtn.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24)
        ])
    }

    private func createTemplateOption(
        title: String,
        imageName: String,
        isSelected: Bool,
        action: Selector
    ) -> (container: UIView, titleLabel: UILabel) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.systemGroupedBackground
        container.layer.cornerRadius = 10
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.separator.cgColor

        // Title label at top-left
        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.text = title.localizedString
        titleLbl.font = UIFont(name: "SegoeUI", size: 13) ?? .systemFont(ofSize: 13)
        titleLbl.textColor = UIColor(named: "themeText") ?? .label
        container.addSubview(titleLbl)

        // Template preview image
        let previewImageView = UIImageView()
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.clipsToBounds = true
        previewImageView.layer.cornerRadius = 6
        previewImageView.image = UIImage(named: imageName)
        container.addSubview(previewImageView)

        // Full-area tap button
        let tapButton = UIButton(type: .system)
        tapButton.translatesAutoresizingMaskIntoConstraints = false
        tapButton.addTarget(self, action: action, for: .touchUpInside)
        container.addSubview(tapButton)

        NSLayoutConstraint.activate([
            titleLbl.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            titleLbl.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),

            previewImageView.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 8),
            previewImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            previewImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            previewImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),

            tapButton.topAnchor.constraint(equalTo: container.topAnchor),
            tapButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tapButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tapButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return (container, titleLbl)
    }

    // MARK: - Actions

    @objc private func selectCatalog() {
        if selectedType == "catalog" {
            selectedType = nil
        } else {
            selectedType = "catalog"
        }
        updateSelection()
    }

    @objc private func selectDetail() {
        if selectedType == "detail" {
            selectedType = nil
        } else {
            selectedType = "detail"
        }
        updateSelection()
    }

    private func updateSelection() {
        let tealColor = (UIColor(named: "themeColor") ?? .systemTeal).cgColor
        let separatorColor = UIColor.separator.cgColor
        let themeColor = UIColor(named: "themeColor") ?? UIColor(red: 0.36, green: 0.78, blue: 0.76, alpha: 1)

        let isCatalog = selectedType == "catalog"
        let isDetail = selectedType == "detail"

        catalogCard?.layer.borderWidth = isCatalog ? 2 : 1
        catalogCard?.layer.borderColor = isCatalog ? tealColor : separatorColor
        catalogTitleLabel?.textColor = isCatalog ? themeColor : (UIColor(named: "themeText") ?? .label)
        catalogTitleLabel?.font = isCatalog
            ? (UIFont(name: "SegoeUI-Semibold", size: 13) ?? .systemFont(ofSize: 13, weight: .semibold))
            : (UIFont(name: "SegoeUI", size: 13) ?? .systemFont(ofSize: 13))

        detailCard?.layer.borderWidth = isDetail ? 2 : 1
        detailCard?.layer.borderColor = isDetail ? tealColor : separatorColor
        detailTitleLabel?.textColor = isDetail ? themeColor : (UIColor(named: "themeText") ?? .label)
        detailTitleLabel?.font = isDetail
            ? (UIFont(name: "SegoeUI-Semibold", size: 13) ?? .systemFont(ofSize: 13, weight: .semibold))
            : (UIFont(name: "SegoeUI", size: 13) ?? .systemFont(ofSize: 13))

        let hasSelection = selectedType != nil
        exportButton?.isEnabled = hasSelection
        exportButton?.backgroundColor = hasSelection ? themeColor : UIColor.separator
    }

    @objc private func exportTapped() {
        guard let type = selectedType else { return }
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didSelectExportType(type)
        }
    }

    @objc private func dismissModal() {
        dismiss(animated: true)
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let card = cardView else { return true }
        let location = touch.location(in: card)
        // Only allow dismiss tap if touch is outside the card
        return !card.bounds.contains(location)
    }
}
