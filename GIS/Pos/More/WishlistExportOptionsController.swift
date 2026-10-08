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
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad

        // Tap outside to dismiss
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dismissModal))
        dimTap.delegate = self
        view.addGestureRecognizer(dimTap)

        // Card — iPhone: 295 × Hug (r12), iPad: 443 × Hug (r28) (Figma)
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = isIPad ? 28 : 12
        card.layer.shadowColor = UIColor(red: 16/255, green: 24/255, blue: 40/255, alpha: 1).cgColor
        card.layer.shadowOpacity = 0.03
        card.layer.shadowOffset = CGSize(width: 0, height: 8)
        card.layer.shadowRadius = 24
        view.addSubview(card)
        cardView = card

        // Title — iPhone: Semibold 14, iPad: Semibold 18, #101828
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Export Option".localizedString
        let titleSize: CGFloat = isIPad ? 18 : 14
        titleLabel.font = UIFont(name: "SegoeUI-Semibold", size: titleSize) ?? .systemFont(ofSize: titleSize, weight: .semibold)
        titleLabel.textColor = UIColor(red: 16/255, green: 24/255, blue: 40/255, alpha: 1)
        titleLabel.textAlignment = .center
        card.addSubview(titleLabel)

        // Subtitle — iPhone: Regular 12, iPad: Regular 14, #667085
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "select your template option to export".localizedString
        let subtitleSize: CGFloat = isIPad ? 14 : 12
        subtitleLabel.font = UIFont(name: "SegoeUI", size: subtitleSize) ?? .systemFont(ofSize: subtitleSize, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 102/255, green: 112/255, blue: 133/255, alpha: 1)
        subtitleLabel.textAlignment = .center
        card.addSubview(subtitleLabel)

        // Template options stack — Figma iPad: 403 Fill, gap 16 between cards
        let optionsStack = UIStackView()
        optionsStack.axis = .horizontal
        optionsStack.spacing = isIPad ? 16 : 7
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

        // Export button — Figma: 403 Fill × 40, radius 8
        let exportBtn = UIButton(type: .system)
        exportBtn.translatesAutoresizingMaskIntoConstraints = false
        exportBtn.backgroundColor = UIColor.separator
        exportBtn.setTitle("Export".localizedString, for: .normal)
        exportBtn.setTitleColor(.white, for: .normal)
        let btnFontSize: CGFloat = isIPad ? 17 : 15
        exportBtn.titleLabel?.font = UIFont(name: "SegoeUI-Semibold", size: btnFontSize) ?? .systemFont(ofSize: btnFontSize, weight: .semibold)
        exportBtn.layer.cornerRadius = isIPad ? 8 : 10
        exportBtn.isEnabled = false
        exportBtn.addTarget(self, action: #selector(exportTapped), for: .touchUpInside)
        card.addSubview(exportBtn)
        exportButton = exportBtn

        // Figma exact values: iPhone 295 × Hug pad 20, iPad 443 × Hug pad 20
        let cardWidth: CGFloat = isIPad ? 443 : 295
        let pad: CGFloat = 20
        let titleToSubtitle: CGFloat = isIPad ? 6 : 4
        let subtitleToOptions: CGFloat = isIPad ? 24 : 24
        let optionsToButton: CGFloat = isIPad ? 24 : 24
        let optionsHeight: CGFloat = isIPad ? 212 : -1  // iPad fixed height from Figma
        let btnHeight: CGFloat = isIPad ? 40 : 40
        let bottomPad: CGFloat = 20

        var constraints = [
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: cardWidth),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: pad),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: pad),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -pad),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: titleToSubtitle),
            subtitleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: pad),
            subtitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -pad),

            optionsStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: subtitleToOptions),
            optionsStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: pad),
            optionsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -pad),

            exportBtn.topAnchor.constraint(equalTo: optionsStack.bottomAnchor, constant: optionsToButton),
            exportBtn.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: pad),
            exportBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -pad),
            exportBtn.heightAnchor.constraint(equalToConstant: btnHeight),
            exportBtn.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -bottomPad)
        ]

        // iPad: fixed options height from Figma (212)
        if optionsHeight > 0 {
            constraints.append(optionsStack.heightAnchor.constraint(equalToConstant: optionsHeight))
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func createTemplateOption(
        title: String,
        imageName: String,
        isSelected: Bool,
        action: Selector
    ) -> (container: UIView, titleLabel: UILabel) {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad

        // Figma: card 193.5 Fill × 212 Hug, radius 4, padding 10, gap 10, bg #F9F9F9
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
        container.layer.cornerRadius = 4
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.clear.cgColor

        // Title label — Figma: Segoe UI Semibold 12px, #6A6A6A (unselected)
        let titleLbl = UILabel()
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.text = title.localizedString
        let cardTitleSize: CGFloat = isIPad ? 12 : 12
        titleLbl.font = UIFont(name: "SegoeUI-Semibold", size: cardTitleSize) ?? .systemFont(ofSize: cardTitleSize, weight: .semibold)
        titleLbl.textColor = UIColor(red: 106/255, green: 106/255, blue: 106/255, alpha: 1)
        container.addSubview(titleLbl)

        // Template preview image — Figma: 173.5 Fill × 166
        let previewImageView = UIImageView()
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.clipsToBounds = true
        previewImageView.image = UIImage(named: imageName)
        container.addSubview(previewImageView)

        // Full-area tap button
        let tapButton = UIButton(type: .system)
        tapButton.translatesAutoresizingMaskIntoConstraints = false
        tapButton.addTarget(self, action: action, for: .touchUpInside)
        container.addSubview(tapButton)

        let inset: CGFloat = 10
        let imgHeight: CGFloat = isIPad ? 166 : -1  // iPad: fixed 166 from Figma

        var cardConstraints = [
            titleLbl.topAnchor.constraint(equalTo: container.topAnchor, constant: inset),
            titleLbl.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: inset),

            previewImageView.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: inset),
            previewImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: inset),
            previewImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -inset),
            previewImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -inset),

            tapButton.topAnchor.constraint(equalTo: container.topAnchor),
            tapButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tapButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tapButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ]

        // iPad: fixed image height from Figma (166)
        if imgHeight > 0 {
            cardConstraints.append(previewImageView.heightAnchor.constraint(equalToConstant: imgHeight))
        }

        NSLayoutConstraint.activate(cardConstraints)

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
        let clearColor = UIColor.clear.cgColor
        // Figma selected: #00CAC2
        let selectedTextColor = UIColor(named: "themeColor") ?? UIColor(red: 0/255, green: 202/255, blue: 194/255, alpha: 1)
        // Figma unselected: #6A6A6A
        let defaultTextColor = UIColor(red: 106/255, green: 106/255, blue: 106/255, alpha: 1)
        // Figma: always Semibold 12
        let fontSize: CGFloat = 12
        let semiboldFont = UIFont(name: "SegoeUI-Semibold", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: .semibold)

        let isCatalog = selectedType == "catalog"
        let isDetail = selectedType == "detail"

        catalogCard?.layer.borderWidth = isCatalog ? 1 : 1
        catalogCard?.layer.borderColor = isCatalog ? tealColor : clearColor
        catalogTitleLabel?.textColor = isCatalog ? selectedTextColor : defaultTextColor
        catalogTitleLabel?.font = semiboldFont

        detailCard?.layer.borderWidth = isDetail ? 1 : 1
        detailCard?.layer.borderColor = isDetail ? tealColor : clearColor
        detailTitleLabel?.textColor = isDetail ? selectedTextColor : defaultTextColor
        detailTitleLabel?.font = semiboldFont

        let hasSelection = selectedType != nil
        exportButton?.isEnabled = hasSelection
        exportButton?.backgroundColor = hasSelection ? selectedTextColor : UIColor.separator
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
