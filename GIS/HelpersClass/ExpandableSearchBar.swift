//
//  ExpandableSearchBar.swift
//  GIS
//
//  Created by Claude on 07/10/26.
//

import UIKit

// MARK: - Protocol
protocol ExpandableSearchBarDelegate: AnyObject {
    func searchBarDidSubmit(_ searchBar: ExpandableSearchBar, text: String)
    func searchBarDidClear(_ searchBar: ExpandableSearchBar)
    func searchBarMicTapped(_ searchBar: ExpandableSearchBar)
    func searchBarScanTapped(_ searchBar: ExpandableSearchBar)
    func searchBarFilterTapped(_ searchBar: ExpandableSearchBar)
}

// MARK: - Configuration
struct ExpandableSearchBarConfig {
    var idlePlaceholder: String = "Search By SKU/Product Name"
    var expandedPlaceholder: String = "SKU, product name, description"
    var showMic: Bool = true
    var showScan: Bool = false
    var showFilter: Bool = true
    /// Asset name for the voice-search control. Some screens use the
    /// stock-take microphone artwork rather than the legacy search artwork.
    var microphoneImage: String = "search_mic_ic"
    /// Optional second action displayed after the microphone. Catalog uses
    /// this slot for its Master/Stock switch rather than a scanner.
    var secondaryActionImage: String = "search_scan_ic"
    var secondaryActionTintColor: UIColor? = nil
    /// Catalog's Master/Stock control is aligned to the trailing edge when
    /// typing; Inventory keeps its scanner adjacent to the microphone.
    var secondaryActionAtTrailingEdge: Bool = false
    var collapsedHeight: CGFloat = 44
    var expandedHeight: CGFloat = 104
}

// MARK: - ExpandableSearchBar
class ExpandableSearchBar: UIView, UITextViewDelegate {

    enum SearchState {
        case idle
        case focused
        case typing
        case filled
    }

    weak var delegate: ExpandableSearchBarDelegate?
    var config: ExpandableSearchBarConfig = ExpandableSearchBarConfig()
    var onStateChange: ((SearchState) -> Void)?
    /// Called whenever the bar's height changes. Hosts that place the bar in a
    /// fixed-height header can use this to move content below it instead of
    /// allowing the search UI to overlap that content.
    var onExpandedHeightChange: ((CGFloat) -> Void)?

    private(set) var searchState: SearchState = .idle
    private(set) var searchText: String = ""
    private var keepsExpandedAfterClear = false

    // MARK: - Subviews

    // Idle row — full-width rounded bar with magnifying glass
    private let idleContainer = UIView()
    private let searchIcon = UIImageView()
    private let idleLabel = UILabel()
    private let micButtonIdle = UIButton(type: .system)
    private let scanButtonIdle = UIButton(type: .system)
    private let filterButtonIdle = UIButton(type: .system)
    private let idleSecondaryDivider = UIView()

    // Expanded (focused / typing) — X | [card with textview + mic/scan] | filter
    private let expandedContainer = UIView()
    private let closeButton = UIButton(type: .system)
    private let searchCard = UIView()
    private let searchTextView = UITextView()
    private let placeholderLabel = UILabel()
    private let clearButtonExpanded = UIButton(type: .system)
    private let micButtonExpanded = UIButton(type: .system)
    private let scanButtonExpanded = UIButton(type: .system)
    private let filterButtonExpanded = UIButton(type: .system)

    // Filled row — X | [card with text... clearX mic scan] | filter
    private let filledContainer = UIView()
    private let closeButtonFilled = UIButton(type: .system)
    private let filledCard = UIView()
    private let filledLabel = UILabel()
    private let clearButtonFilled = UIButton(type: .system)
    private let micButtonFilled = UIButton(type: .system)
    private let scanButtonFilled = UIButton(type: .system)
    private let filterButtonFilled = UIButton(type: .system)

    // Height constraint
    private var heightConstraint: NSLayoutConstraint!
    // Text view max height (3 lines)
    private var textViewHeightConstraint: NSLayoutConstraint!
    private var expandedSecondaryLeadingConstraint: NSLayoutConstraint!
    private var expandedSecondaryTrailingConstraint: NSLayoutConstraint!
    private var idleFilterTrailingConstraint: NSLayoutConstraint!
    private var idleFilterBeforeSecondaryConstraint: NSLayoutConstraint!
    private var idleSecondaryBeforeFilterConstraint: NSLayoutConstraint!
    private var idleSecondaryTrailingConstraint: NSLayoutConstraint!
    private var idleMicBeforeSecondaryConstraint: NSLayoutConstraint!
    private var idleMicBeforeFilterConstraint: NSLayoutConstraint!
    private var idleSecondaryDividerTrailingConstraint: NSLayoutConstraint!

    // Theme colors
    private let tealColor = UIColor(named: "themeColor") ?? UIColor(red: 0/255, green: 202/255, blue: 194/255, alpha: 1)
    private let grayBorder = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
    private let d9Border = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1)
    private let placeholderColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)
    private let textColor = UIColor(red: 42/255, green: 42/255, blue: 42/255, alpha: 1)
    private let iconColor = UIColor(red: 106/255, green: 106/255, blue: 106/255, alpha: 1) // #6A6A6A
    private let clearXColor = UIColor(red: 96/255, green: 96/255, blue: 96/255, alpha: 1) // #606060

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    convenience init(config: ExpandableSearchBarConfig) {
        self.init(frame: .zero)
        self.config = config
        applyConfig()
    }

    // MARK: - Setup
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false
        backgroundColor = .clear

        heightConstraint = heightAnchor.constraint(equalToConstant: config.collapsedHeight)
        heightConstraint.isActive = true

        setupIdleContainer()
        setupExpandedContainer()
        setupFilledContainer()

        idleContainer.isHidden = false
        expandedContainer.isHidden = true
        filledContainer.isHidden = true
    }

    private func applyConfig() {
        idleLabel.text = config.idlePlaceholder
        idleLabel.textColor = placeholderColor
        placeholderLabel.text = config.expandedPlaceholder
        micButtonIdle.isHidden = !config.showMic
        scanButtonIdle.isHidden = !config.showScan
        micButtonExpanded.isHidden = !config.showMic
        scanButtonExpanded.isHidden = !config.showScan
        micButtonFilled.isHidden = !config.showMic
        scanButtonFilled.isHidden = !config.showScan
        updateMicrophoneAppearance()
        updateSecondaryActionAppearance()
        let secondaryAtTrailingEdge = config.secondaryActionAtTrailingEdge
        idleFilterTrailingConstraint.isActive = !secondaryAtTrailingEdge
        idleSecondaryBeforeFilterConstraint.isActive = !secondaryAtTrailingEdge
        idleFilterBeforeSecondaryConstraint.isActive = secondaryAtTrailingEdge
        idleSecondaryTrailingConstraint.isActive = secondaryAtTrailingEdge
        // In Catalog, the visual order is Mic → Filter → divider → Crown.
        // The older Mic → Crown relation made the mic and filter share the
        // same trailing anchor and overlap each other.
        idleMicBeforeSecondaryConstraint.isActive = config.showScan && !secondaryAtTrailingEdge
        idleMicBeforeFilterConstraint.isActive = !config.showScan || secondaryAtTrailingEdge
        idleSecondaryDivider.isHidden = !secondaryAtTrailingEdge || !config.showScan
        idleSecondaryDividerTrailingConstraint.isActive = secondaryAtTrailingEdge && config.showScan
        expandedSecondaryLeadingConstraint.isActive = !config.secondaryActionAtTrailingEdge
        expandedSecondaryTrailingConstraint.isActive = config.secondaryActionAtTrailingEdge
        heightConstraint.constant = config.collapsedHeight
        updateState(.idle, animated: false)
    }

    private func updateSecondaryActionAppearance() {
        let image = UIImage(named: config.secondaryActionImage)?.withRenderingMode(.alwaysTemplate)
        let tint = config.secondaryActionTintColor ?? iconColor
        [scanButtonIdle, scanButtonExpanded, scanButtonFilled].forEach { button in
            button.setImage(image, for: .normal)
            button.tintColor = tint
        }
    }

    private func updateMicrophoneAppearance() {
        let image = UIImage(named: config.microphoneImage)?.withRenderingMode(.alwaysTemplate)
        [micButtonIdle, micButtonExpanded, micButtonFilled].forEach { button in
            button.setImage(image, for: .normal)
            button.tintColor = iconColor
        }
    }

    // MARK: - Idle Container (magnifying glass + placeholder + icons)
    private func setupIdleContainer() {
        idleContainer.translatesAutoresizingMaskIntoConstraints = false
        idleContainer.backgroundColor = .white
        // The compact search control is a full pill in the approved Catalog
        // layout: 44pt high with matching 22pt curves on both ends.
        idleContainer.layer.cornerRadius = 22
        idleContainer.layer.borderWidth = 1
        idleContainer.layer.borderColor = grayBorder.cgColor
        idleContainer.clipsToBounds = true
        addSubview(idleContainer)

        NSLayoutConstraint.activate([
            idleContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            idleContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            idleContainer.topAnchor.constraint(equalTo: topAnchor),
            idleContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        searchIcon.image = UIImage(systemName: "magnifyingglass")
        searchIcon.tintColor = placeholderColor
        searchIcon.contentMode = .scaleAspectFit
        idleContainer.addSubview(searchIcon)

        idleLabel.translatesAutoresizingMaskIntoConstraints = false
        idleLabel.font = UIFont(name: "SegoeUI", size: 14) ?? .systemFont(ofSize: 14)
        idleLabel.textColor = placeholderColor
        idleLabel.lineBreakMode = .byTruncatingTail
        idleContainer.addSubview(idleLabel)

        setupIconButton(micButtonIdle, image: config.microphoneImage, in: idleContainer)
        setupIconButton(scanButtonIdle, image: "search_scan_ic", in: idleContainer)
        setupFilterButton(filterButtonIdle, in: idleContainer)

        idleSecondaryDivider.translatesAutoresizingMaskIntoConstraints = false
        idleSecondaryDivider.backgroundColor = d9Border
        idleSecondaryDivider.isHidden = true
        idleContainer.addSubview(idleSecondaryDivider)

        let tap = UITapGestureRecognizer(target: self, action: #selector(idleTapped))
        idleContainer.addGestureRecognizer(tap)

        let p: CGFloat = 12
        NSLayoutConstraint.activate([
            searchIcon.leadingAnchor.constraint(equalTo: idleContainer.leadingAnchor, constant: p),
            searchIcon.centerYAnchor.constraint(equalTo: idleContainer.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 24),
            searchIcon.heightAnchor.constraint(equalToConstant: 24),

            filterButtonIdle.centerYAnchor.constraint(equalTo: idleContainer.centerYAnchor),
            filterButtonIdle.widthAnchor.constraint(equalToConstant: 32),
            filterButtonIdle.heightAnchor.constraint(equalToConstant: 32),

            scanButtonIdle.centerYAnchor.constraint(equalTo: idleContainer.centerYAnchor),
            scanButtonIdle.widthAnchor.constraint(equalToConstant: 20),
            scanButtonIdle.heightAnchor.constraint(equalToConstant: 20),

            micButtonIdle.centerYAnchor.constraint(equalTo: idleContainer.centerYAnchor),
            micButtonIdle.widthAnchor.constraint(equalToConstant: 20),
            micButtonIdle.heightAnchor.constraint(equalToConstant: 20),

            idleSecondaryDivider.centerYAnchor.constraint(equalTo: idleContainer.centerYAnchor),
            idleSecondaryDivider.widthAnchor.constraint(equalToConstant: 1),
            idleSecondaryDivider.heightAnchor.constraint(equalToConstant: 28),

            idleLabel.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 8),
            idleLabel.centerYAnchor.constraint(equalTo: idleContainer.centerYAnchor),
            idleLabel.trailingAnchor.constraint(lessThanOrEqualTo: micButtonIdle.leadingAnchor, constant: -8),
        ])
        idleFilterTrailingConstraint = filterButtonIdle.trailingAnchor.constraint(
            equalTo: idleContainer.trailingAnchor,
            constant: -p
        )
        idleFilterBeforeSecondaryConstraint = filterButtonIdle.trailingAnchor.constraint(
            equalTo: idleSecondaryDivider.leadingAnchor,
            constant: -8
        )
        idleSecondaryBeforeFilterConstraint = scanButtonIdle.trailingAnchor.constraint(
            equalTo: filterButtonIdle.leadingAnchor,
            constant: -4
        )
        idleSecondaryTrailingConstraint = scanButtonIdle.trailingAnchor.constraint(
            equalTo: idleContainer.trailingAnchor,
            constant: -p
        )
        idleMicBeforeSecondaryConstraint = micButtonIdle.trailingAnchor.constraint(
            equalTo: scanButtonIdle.leadingAnchor,
            constant: -4
        )
        idleMicBeforeFilterConstraint = micButtonIdle.trailingAnchor.constraint(
            equalTo: filterButtonIdle.leadingAnchor,
            constant: -4
        )
        idleSecondaryDividerTrailingConstraint = idleSecondaryDivider.trailingAnchor.constraint(
            equalTo: scanButtonIdle.leadingAnchor,
            constant: -8
        )
        idleFilterTrailingConstraint.isActive = true
        idleSecondaryBeforeFilterConstraint.isActive = true
        idleMicBeforeFilterConstraint.isActive = true
    }

    // MARK: - Expanded Container (focused / typing)
    private func setupExpandedContainer() {
        expandedContainer.translatesAutoresizingMaskIntoConstraints = false
        expandedContainer.backgroundColor = .white
        addSubview(expandedContainer)

        NSLayoutConstraint.activate([
            expandedContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            expandedContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            expandedContainer.topAnchor.constraint(equalTo: topAnchor),
            expandedContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let btnSize: CGFloat = 48

        // Close button (X)
        setupCloseButton(closeButton, in: expandedContainer)

        // Filter button
        filterButtonExpanded.translatesAutoresizingMaskIntoConstraints = false
        filterButtonExpanded.setImage(UIImage(named: "stocktake_ic_filter")?.withRenderingMode(.alwaysTemplate), for: .normal)
        filterButtonExpanded.tintColor = textColor
        filterButtonExpanded.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        expandedContainer.addSubview(filterButtonExpanded)

        // Search card (r20, 0.5px border)
        searchCard.translatesAutoresizingMaskIntoConstraints = false
        searchCard.backgroundColor = .white
        searchCard.layer.cornerRadius = 20
        searchCard.layer.borderWidth = 0.5
        searchCard.layer.borderColor = d9Border.cgColor
        searchCard.clipsToBounds = true
        expandedContainer.addSubview(searchCard)

        // UITextView — multi-line, max 3 lines then scroll
        searchTextView.translatesAutoresizingMaskIntoConstraints = false
        searchTextView.font = UIFont(name: "SegoeUI", size: 14) ?? .systemFont(ofSize: 14)
        searchTextView.textColor = textColor
        searchTextView.backgroundColor = .clear
        searchTextView.isScrollEnabled = false
        searchTextView.textContainerInset = .zero
        searchTextView.textContainer.lineFragmentPadding = 0
        searchTextView.delegate = self
        searchTextView.returnKeyType = .search
        searchTextView.autocorrectionType = .no
        searchCard.addSubview(searchTextView)

        // Placeholder
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.font = UIFont(name: "SegoeUI", size: 14) ?? .systemFont(ofSize: 14)
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.numberOfLines = 1
        placeholderLabel.isUserInteractionEnabled = false
        searchCard.addSubview(placeholderLabel)

        // Clear X inside card
        clearButtonExpanded.translatesAutoresizingMaskIntoConstraints = false
        clearButtonExpanded.setImage(UIImage(systemName: "xmark")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 8, weight: .bold)
        ), for: .normal)
        clearButtonExpanded.tintColor = clearXColor
        clearButtonExpanded.addTarget(self, action: #selector(clearExpandedTapped), for: .touchUpInside)
        clearButtonExpanded.isHidden = true
        searchCard.addSubview(clearButtonExpanded)

        // Mic inside card
        setupIconButton(micButtonExpanded, image: config.microphoneImage, in: searchCard)
        // Scan inside card
        setupIconButton(scanButtonExpanded, image: "search_scan_ic", in: searchCard)

        // Calculate max height for 3 lines of text
        let lineHeight = (UIFont(name: "SegoeUI", size: 14) ?? .systemFont(ofSize: 14)).lineHeight
        let maxTextHeight = ceil(lineHeight * 3)

        // Use an equality constraint and update its value as text grows. A
        // less-than-or-equal constraint lets UITextView's fitting size win,
        // which makes a fourth line grow the card beyond its 3-line maximum.
        textViewHeightConstraint = searchTextView.heightAnchor.constraint(equalToConstant: min(20, maxTextHeight))
        textViewHeightConstraint.isActive = true

        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: expandedContainer.leadingAnchor),
            closeButton.topAnchor.constraint(equalTo: searchCard.topAnchor, constant: -4),
            closeButton.widthAnchor.constraint(equalToConstant: btnSize),
            closeButton.heightAnchor.constraint(equalToConstant: btnSize),

            filterButtonExpanded.trailingAnchor.constraint(equalTo: expandedContainer.trailingAnchor),
            filterButtonExpanded.topAnchor.constraint(equalTo: searchCard.topAnchor, constant: -4),
            filterButtonExpanded.widthAnchor.constraint(equalToConstant: btnSize),
            filterButtonExpanded.heightAnchor.constraint(equalToConstant: btnSize),

            searchCard.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 0),
            searchCard.trailingAnchor.constraint(equalTo: filterButtonExpanded.leadingAnchor, constant: 0),
            searchCard.topAnchor.constraint(equalTo: expandedContainer.topAnchor, constant: 8),

            // Text view — leave room for clear X on the right
            searchTextView.leadingAnchor.constraint(equalTo: searchCard.leadingAnchor, constant: 16),
            searchTextView.trailingAnchor.constraint(equalTo: clearButtonExpanded.leadingAnchor, constant: -4),
            searchTextView.topAnchor.constraint(equalTo: searchCard.topAnchor, constant: 8),
            searchTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),

            placeholderLabel.leadingAnchor.constraint(equalTo: searchTextView.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: searchTextView.trailingAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: searchTextView.topAnchor),

            // Keep the X glyph in the same visual position, but provide the
            // standard 44×44 pt hit target so a tap always clears the field.
            clearButtonExpanded.trailingAnchor.constraint(equalTo: searchCard.trailingAnchor, constant: -6),
            clearButtonExpanded.topAnchor.constraint(equalTo: searchCard.topAnchor),
            clearButtonExpanded.widthAnchor.constraint(equalToConstant: 44),
            clearButtonExpanded.heightAnchor.constraint(equalToConstant: 44),

            micButtonExpanded.leadingAnchor.constraint(equalTo: searchCard.leadingAnchor, constant: 16),
            micButtonExpanded.topAnchor.constraint(equalTo: searchTextView.bottomAnchor, constant: 12),
            micButtonExpanded.widthAnchor.constraint(equalToConstant: 20),
            micButtonExpanded.heightAnchor.constraint(equalToConstant: 20),
            micButtonExpanded.bottomAnchor.constraint(equalTo: searchCard.bottomAnchor, constant: -12),

            scanButtonExpanded.centerYAnchor.constraint(equalTo: micButtonExpanded.centerYAnchor),
            scanButtonExpanded.widthAnchor.constraint(equalToConstant: 20),
            scanButtonExpanded.heightAnchor.constraint(equalToConstant: 20),
        ])
        expandedSecondaryLeadingConstraint = scanButtonExpanded.leadingAnchor.constraint(
            equalTo: micButtonExpanded.trailingAnchor,
            constant: 10
        )
        expandedSecondaryTrailingConstraint = scanButtonExpanded.trailingAnchor.constraint(
            equalTo: searchCard.trailingAnchor,
            constant: -16
        )
        expandedSecondaryLeadingConstraint.isActive = true
    }

    // MARK: - Filled Container — X | [card: text... x mic scan] | filter
    // Figma: card width Fill(279), height Hug(40), r20, border 0.5px
    private func setupFilledContainer() {
        filledContainer.translatesAutoresizingMaskIntoConstraints = false
        filledContainer.backgroundColor = .white
        addSubview(filledContainer)

        NSLayoutConstraint.activate([
            filledContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            filledContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            filledContainer.topAnchor.constraint(equalTo: topAnchor),
            filledContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let btnSize: CGFloat = 48

        // Close button (X)
        setupCloseButton(closeButtonFilled, in: filledContainer)

        // Filter button
        filterButtonFilled.translatesAutoresizingMaskIntoConstraints = false
        filterButtonFilled.setImage(UIImage(named: "stocktake_ic_filter")?.withRenderingMode(.alwaysTemplate), for: .normal)
        filterButtonFilled.tintColor = textColor
        filterButtonFilled.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        filledContainer.addSubview(filterButtonFilled)

        // Filled card (r20, 0.5px border)
        filledCard.translatesAutoresizingMaskIntoConstraints = false
        filledCard.backgroundColor = .white
        filledCard.layer.cornerRadius = 20
        filledCard.layer.borderWidth = 0.5
        filledCard.layer.borderColor = d9Border.cgColor
        filledCard.clipsToBounds = true
        filledContainer.addSubview(filledCard)

        // Label inside card — single line, truncating
        filledLabel.translatesAutoresizingMaskIntoConstraints = false
        filledLabel.font = UIFont(name: "SegoeUI", size: 14) ?? .systemFont(ofSize: 14)
        filledLabel.textColor = textColor
        filledLabel.lineBreakMode = .byTruncatingTail
        filledLabel.numberOfLines = 1
        filledCard.addSubview(filledLabel)

        // Clear X inside card (8×8 icon, #606060)
        clearButtonFilled.translatesAutoresizingMaskIntoConstraints = false
        clearButtonFilled.setImage(UIImage(systemName: "xmark")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 8, weight: .bold)
        ), for: .normal)
        clearButtonFilled.tintColor = clearXColor
        clearButtonFilled.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        filledCard.addSubview(clearButtonFilled)

        // Mic inside card
        setupIconButton(micButtonFilled, image: config.microphoneImage, in: filledCard)
        // Scan inside card
        setupIconButton(scanButtonFilled, image: "search_scan_ic", in: filledCard)

        // Tap on the card to re-expand
        let tap = UITapGestureRecognizer(target: self, action: #selector(filledCardTapped))
        filledCard.addGestureRecognizer(tap)

        NSLayoutConstraint.activate([
            closeButtonFilled.leadingAnchor.constraint(equalTo: filledContainer.leadingAnchor),
            closeButtonFilled.centerYAnchor.constraint(equalTo: filledCard.centerYAnchor),
            closeButtonFilled.widthAnchor.constraint(equalToConstant: btnSize),
            closeButtonFilled.heightAnchor.constraint(equalToConstant: btnSize),

            filterButtonFilled.trailingAnchor.constraint(equalTo: filledContainer.trailingAnchor),
            filterButtonFilled.centerYAnchor.constraint(equalTo: filledCard.centerYAnchor),
            filterButtonFilled.widthAnchor.constraint(equalToConstant: btnSize),
            filterButtonFilled.heightAnchor.constraint(equalToConstant: btnSize),

            // Card between X and filter
            filledCard.leadingAnchor.constraint(equalTo: closeButtonFilled.trailingAnchor, constant: 0),
            filledCard.trailingAnchor.constraint(equalTo: filterButtonFilled.leadingAnchor, constant: 0),
            filledCard.topAnchor.constraint(equalTo: filledContainer.topAnchor, constant: 8),
            filledCard.heightAnchor.constraint(equalToConstant: 40),

            // Filter icon on right inside card
            filterButtonFilled.widthAnchor.constraint(equalToConstant: btnSize),

            // Scan on right edge inside card
            scanButtonFilled.trailingAnchor.constraint(equalTo: filledCard.trailingAnchor, constant: -16),
            scanButtonFilled.centerYAnchor.constraint(equalTo: filledCard.centerYAnchor),
            scanButtonFilled.widthAnchor.constraint(equalToConstant: 20),
            scanButtonFilled.heightAnchor.constraint(equalToConstant: 20),

            // Mic before scan
            micButtonFilled.trailingAnchor.constraint(equalTo: scanButtonFilled.leadingAnchor, constant: -10),
            micButtonFilled.centerYAnchor.constraint(equalTo: filledCard.centerYAnchor),
            micButtonFilled.widthAnchor.constraint(equalToConstant: 20),
            micButtonFilled.heightAnchor.constraint(equalToConstant: 20),

            // Clear X before mic
            clearButtonFilled.trailingAnchor.constraint(equalTo: micButtonFilled.leadingAnchor, constant: -6),
            clearButtonFilled.centerYAnchor.constraint(equalTo: filledCard.centerYAnchor),
            clearButtonFilled.widthAnchor.constraint(equalToConstant: 24),
            clearButtonFilled.heightAnchor.constraint(equalToConstant: 24),

            // Label: from left padding to clear button
            filledLabel.leadingAnchor.constraint(equalTo: filledCard.leadingAnchor, constant: 16),
            filledLabel.centerYAnchor.constraint(equalTo: filledCard.centerYAnchor),
            filledLabel.trailingAnchor.constraint(lessThanOrEqualTo: clearButtonFilled.leadingAnchor, constant: -4),
        ])
    }

    // MARK: - Helper: setup icon button
    private func setupIconButton(_ button: UIButton, image: String, in parent: UIView) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: image)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = iconColor
        button.imageView?.contentMode = .scaleAspectFit
        if button === micButtonIdle || button === micButtonExpanded || button === micButtonFilled {
            button.addTarget(self, action: #selector(micTapped), for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(scanTapped), for: .touchUpInside)
        }
        parent.addSubview(button)
    }

    private func setupFilterButton(_ button: UIButton, in parent: UIView) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "stocktake_ic_filter")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = placeholderColor
        button.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        parent.addSubview(button)
    }

    private func setupCloseButton(_ button: UIButton, in parent: UIView) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        ), for: .normal)
        button.tintColor = textColor
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        parent.addSubview(button)
    }

    // MARK: - State Management
    func updateState(_ newState: SearchState, animated: Bool = true) {
        searchState = newState
        onStateChange?(newState)

        let changes: () -> Void = {
            switch newState {
            case .idle:
                self.heightConstraint.constant = self.config.collapsedHeight
                self.onExpandedHeightChange?(self.config.collapsedHeight)
                self.idleContainer.isHidden = false
                self.expandedContainer.isHidden = true
                self.filledContainer.isHidden = true
                self.idleLabel.text = self.config.idlePlaceholder
                self.idleLabel.textColor = self.placeholderColor

            case .focused, .typing:
                self.idleContainer.isHidden = true
                self.expandedContainer.isHidden = false
                self.filledContainer.isHidden = true
                self.filterButtonExpanded.isHidden = !self.config.showFilter
                self.micButtonExpanded.isHidden = !self.config.showMic
                self.scanButtonExpanded.isHidden = !self.config.showScan
                self.placeholderLabel.isHidden = !self.searchTextView.text.isEmpty
                self.clearButtonExpanded.isHidden = self.searchTextView.text.isEmpty
                self.superview?.bringSubviewToFront(self)
                // Recalculate height based on content
                self.updateExpandedHeight()

            case .filled:
                // A completed search uses the same compact pill as the
                // reference design. The previous separate filled container
                // left an X and filter outside the field, unlike the approved
                // one-row layout.
                self.heightConstraint.constant = self.config.collapsedHeight
                self.onExpandedHeightChange?(self.config.collapsedHeight)
                self.idleContainer.isHidden = false
                self.expandedContainer.isHidden = true
                self.filledContainer.isHidden = true
                self.idleLabel.text = self.searchText
                self.idleLabel.textColor = self.textColor
            }
            self.superview?.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: changes)
        } else {
            changes()
        }
    }

    /// Recalculate the height of the bar based on text content in expanded state
    private func updateExpandedHeight() {
        searchCard.layoutIfNeeded()
        let cardHeight = searchCard.systemLayoutSizeFitting(
            CGSize(width: searchCard.bounds.width > 0 ? searchCard.bounds.width : 250, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        let newHeight = max(self.config.expandedHeight, 8 + cardHeight + 4) // top padding + card + bottom
        self.heightConstraint.constant = newHeight
        onExpandedHeightChange?(newHeight)
    }

    // MARK: - Public
    func setText(_ text: String) {
        searchText = text
        searchTextView.text = text
        if text.isEmpty {
            updateState(.idle)
        } else {
            updateState(.filled)
        }
    }

    func setSecondaryAction(imageName: String, tintColor: UIColor?) {
        config.secondaryActionImage = imageName
        config.secondaryActionTintColor = tintColor
        updateSecondaryActionAppearance()
    }

    func expand() {
        if searchState == .filled {
            searchTextView.text = searchText
        } else {
            searchTextView.text = ""
        }
        placeholderLabel.isHidden = !searchTextView.text.isEmpty
        clearButtonExpanded.isHidden = searchTextView.text.isEmpty
        updateState(.focused)
        searchTextView.becomeFirstResponder()
    }

    func collapse() {
        searchTextView.resignFirstResponder()
        let text = searchTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if text.isEmpty {
            searchText = ""
            updateState(.idle)
        } else {
            searchText = text
            updateState(.filled)
        }
    }

    // MARK: - Actions
    @objc private func idleTapped() {
        keepsExpandedAfterClear = false
        if searchState == .filled {
            // Re-open a completed query for editing without discarding it.
            searchTextView.text = searchText
            searchTextView.selectedRange = NSRange(location: searchText.count, length: 0)
            placeholderLabel.isHidden = true
            clearButtonExpanded.isHidden = false
        } else {
            searchTextView.text = ""
            placeholderLabel.isHidden = false
            clearButtonExpanded.isHidden = true
        }
        updateState(.focused)
        searchTextView.becomeFirstResponder()
    }

    @objc private func filledCardTapped() {
        searchTextView.text = searchText
        placeholderLabel.isHidden = true
        clearButtonExpanded.isHidden = false
        updateState(.focused)
        searchTextView.becomeFirstResponder()
    }

    @objc private func closeTapped() {
        keepsExpandedAfterClear = false
        searchTextView.resignFirstResponder()
        searchTextView.text = ""
        searchText = ""
        updateState(.idle)
        delegate?.searchBarDidClear(self)
    }

    @objc private func clearTapped() {
        clearTextAndRemainFocused()
    }

    @objc private func clearExpandedTapped() {
        clearTextAndRemainFocused()
    }

    /// The X inside either search card clears only the query. It deliberately
    /// stays in the expanded, empty search state; the separate leading X is
    /// the control that closes the search UI.
    private func clearTextAndRemainFocused() {
        keepsExpandedAfterClear = true
        searchTextView.text = ""
        searchTextView.selectedRange = NSRange(location: 0, length: 0)
        searchText = ""
        placeholderLabel.isHidden = false
        clearButtonExpanded.isHidden = true
        searchState = .focused
        searchTextView.isScrollEnabled = false
        textViewHeightConstraint.constant = 20
        updateState(.focused, animated: false)
        searchCard.setNeedsLayout()
        searchCard.layoutIfNeeded()
        superview?.setNeedsLayout()
        superview?.layoutIfNeeded()
        DispatchQueue.main.async { [weak self] in
            self?.searchTextView.becomeFirstResponder()
        }
    }

    @objc private func micTapped() {
        delegate?.searchBarMicTapped(self)
    }

    @objc private func scanTapped() {
        // A scanner is presented full-screen. Resign the text view first so
        // the keyboard never remains visible over its camera preview.
        window?.endEditing(true)
        delegate?.searchBarScanTapped(self)
    }

    @objc private func filterTapped() {
        delegate?.searchBarFilterTapped(self)
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        clearButtonExpanded.isHidden = textView.text.isEmpty
        if textView.text.isEmpty {
            searchState = .focused
        } else {
            searchState = .typing
        }

        // Check if text exceeds 3 lines — enable scrolling
        let lineHeight = textView.font?.lineHeight ?? 17
        let maxTextHeight = ceil(lineHeight * 3)
        let textSize = textView.sizeThatFits(
            CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
        )
        let fittedHeight = ceil(textSize.height)
        textView.isScrollEnabled = fittedHeight > maxTextHeight
        textViewHeightConstraint.constant = min(maxTextHeight, max(20, fittedHeight))

        // Update height to push content down, capped at exactly three lines.
        updateExpandedHeight()
        // Notify parent to relayout
        if let headerView = self.superview {
            UIView.animate(withDuration: 0.15) {
                headerView.superview?.layoutIfNeeded()
            }
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            let query = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            searchText = query
            textView.resignFirstResponder()
            if query.isEmpty {
                updateState(.idle)
            } else {
                updateState(.filled)
            }
            delegate?.searchBarDidSubmit(self, text: query)
            return false
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        searchText = text
        if text.isEmpty {
            if keepsExpandedAfterClear {
                updateState(.focused, animated: false)
                DispatchQueue.main.async { [weak self] in
                    self?.searchTextView.becomeFirstResponder()
                }
                return
            }
            updateState(.idle)
        } else {
            updateState(.filled)
        }
    }
}
