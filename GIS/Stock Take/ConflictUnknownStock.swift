//
//  ConflictUnknownStock.swift
//  GIS
//
//  Created by Apple Hawkscode on 17/12/20.
//

import UIKit


class ConflictUnknownStockCell: UITableViewCell {

    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mSno: UILabel!
    @IBOutlet weak var mUknownView: UIView!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mQuantity: UILabel!
    @IBOutlet weak var mIcon: UIImageView?

    // Manual icon is created programmatically because the storyboard
    // does not need another IBOutlet for this new icon.
    private var mManualIconView: UIImageView?
//    private var mStockIDDisplayLabel: UILabel?
    @IBOutlet weak var mStockIDDisplayLabel: UILabel!

    // Fallback conflict icon.
    // This prevents the cell from crashing if the storyboard's mIcon
    // outlet is not connected.
    private var mConflictIconView: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()

        // The original conflict icon is connected from Storyboard.
        // Hide it and use one programmatic icon instead so we never
        // render two conflict icons on top of each other.
        mIcon?.isHidden = true

        _ = conflictIconView()
        setupManualIconView()
        setupStockIDDisplayLabel()
    }

    private func setupStockIDDisplayLabel() {
        guard mStockIDDisplayLabel == nil else { return }

        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.isHidden = true

        contentView.addSubview(label)
        mStockIDDisplayLabel = label
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let label = mStockIDDisplayLabel else { return }

        // # | Stock ID | SKU | icon | quantity
        let x = contentView.bounds.width * 0.333

        // เหลือพื้นที่ให้ SKU ก่อนถึง icon
        let rightReserved: CGFloat = 125

        let width = max(
            160,
            contentView.bounds.width - x - rightReserved
        )

        label.frame = CGRect(
            x: x,
            y: (contentView.bounds.height - 30) / 2,
            width: width,
            height: 30
        )
    }

    /// Creates/returns the single conflict icon used by this cell.
    /// We intentionally do NOT reuse the storyboard mIcon because
    /// its old constraints can overlap the new manual icon.
    private func conflictIconView() -> UIImageView? {

        if let icon = mConflictIconView {
            return icon
        }

        let container = contentView

        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(named: "stocktake_ic_conflict")
        icon.contentMode = .scaleAspectFit
        icon.isUserInteractionEnabled = false
        icon.isHidden = false

        container.addSubview(icon)
        mConflictIconView = icon

        NSLayoutConstraint.activate([
            // Keep the conflict icon immediately before the quantity area.
            icon.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -98),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 16),
            icon.heightAnchor.constraint(equalToConstant: 16)
        ])

        return icon
    }

    private func setupManualIconView() {
        guard mManualIconView == nil,
              let conflictIcon = conflictIconView(),
              let superview = conflictIcon.superview else {
            return
        }

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "stocktake_ic_manualadd")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.isHidden = true

        superview.addSubview(imageView)
        mManualIconView = imageView

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: conflictIcon.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: conflictIcon.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 16),
            imageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    func configureIcons(isManual: Bool, showConflict: Bool = true) {
        guard let conflictIcon = conflictIconView() else {
            return
        }

        // The red conflict icon is no longer used on this screen.
        // Keep the storyboard image view hidden.
        conflictIcon.isHidden = true

        // Only a manually-added item gets an icon.
        // The manual-add icon is placed exactly where the old conflict icon was.
        if mManualIconView == nil {
            setupManualIconView()
        }

        mManualIconView?.image = UIImage(named: "stocktake_ic_manualadd")
        mManualIconView?.isHidden = !isManual
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        mManualIconView?.isHidden = true
        mStockIDDisplayLabel?.text = nil
        mStockIDDisplayLabel?.isHidden = true

        // The red conflict icon is intentionally hidden on this screen.
        conflictIconView()?.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

class ConflictUnknownStock: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum DisplayMode {
        case conflict
        case unknown
    }

    var displayMode: DisplayMode = .conflict

    @IBOutlet weak var mUknownLine: UILabel?
    @IBOutlet weak var mConflictLine: UILabel?
    @IBOutlet weak var mAllLine: UILabel?
    @IBOutlet weak var mUnknownCounts: UILabel?
    @IBOutlet weak var mAllCounts: UILabel?
    @IBOutlet weak var mConflictCounts: UILabel?

    @IBOutlet weak var mBottomView: UIView?
    @IBOutlet weak var mConflictUnknownStockable: UITableView?

    @IBOutlet weak var mHeadingConflictUnknownLABEL: UILabel?
    var mConflictData = [String]()
    var mMasterData = [String]()

    // Display-only data for Conflict rows.
    // The conflict key may contain a suffix such as |DUPLICATE,
    // but the UI must show SKU and Stock ID separately.
    var mConflictDisplayData: [[String: String]] = []

    @IBOutlet weak var mTotalCount: UILabel?
    var mCount = ""

    // Safe fallback for storyboard variants where the title outlet is not connected.
    private var fallbackHeadingLabel: UILabel?

    private func ensureHeadingLabel() -> UILabel {
        if let label = mHeadingConflictUnknownLABEL {
            return label
        }
        if let label = fallbackHeadingLabel {
            return label
        }

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(named: "theme6A") ?? .darkText
        label.numberOfLines = 1

        view.addSubview(label)
        fallbackHeadingLabel = label

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.heightAnchor.constraint(equalToConstant: 28)
        ])

        return label
    }

    @IBOutlet weak var mConflictLABEL: UILabel!
    @IBOutlet weak var mShareLABEL: UILabel!
    @IBOutlet weak var mPrintLABEL: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let title = displayMode == .conflict
            ? "Conflict".localizedString
            : "Unknown".localizedString
        ensureHeadingLabel().text = title
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mMasterData = mConflictData

        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false

        mBottomView?.isHidden = true
        hideLegacyModeTabs()

        if let table = mConflictUnknownStockable {
            table.delegate = self
            table.dataSource = self
            table.separatorStyle = .none
            table.showsVerticalScrollIndicator = false
            table.showsHorizontalScrollIndicator = false
            table.backgroundColor = .clear
        }

        applyDisplayModeData()
        mConflictUnknownStockable?.reloadData()
    }

    private func hideLegacyModeTabs() {
        [
            mAllCounts,
            mConflictCounts,
            mUnknownCounts,
            mAllLine,
            mConflictLine,
            mUknownLine
        ].forEach { $0?.isHidden = true }

        // Hide the smallest common storyboard container that owns the tab strip.
        let views = [
            mAllCounts?.superview,
            mConflictCounts?.superview,
            mUnknownCounts?.superview,
            mAllLine?.superview,
            mConflictLine?.superview,
            mUknownLine?.superview
        ].compactMap { $0 }

        for candidate in views {
            let containsAllTabs =
                views.allSatisfy { candidate === $0 || $0.isDescendant(of: candidate) }

            if containsAllTabs {
                candidate.isHidden = true
                break
            }
        }
    }

    private func applyDisplayModeData() {
        let title: String

        switch displayMode {
        case .conflict:
            mConflictData = mMasterData.filter {
                !$0.uppercased().contains("UKN")
            }
            title = "Conflict".localizedString

        case .unknown:
            mConflictData = mMasterData.filter {
                $0.uppercased().contains("UKN")
            }
            title = "Unknown".localizedString
        }

        // Never force-unwrap storyboard outlets here.
        ensureHeadingLabel().text = title.replacingOccurrences(of: "UKN", with: "")
        mTotalCount?.text = "\(mConflictData.count)"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let table = mConflictUnknownStockable else {
            return
        }

        // IMPORTANT:
        // The UITableView is a storyboard view with Auto Layout constraints.
        // Setting table.frame here was allowing it to cover the header/back/title
        // area. Keep it below the navigation/header area instead.
        //
        // The screen reference has:
        //   Safe Area
        //      Back / Conflict title
        //      small gap
        //      Conflict rows
        //
        // Use Auto Layout for the table so it cannot expand over the header.
        table.translatesAutoresizingMaskIntoConstraints = false

        // Remove only constraints owned directly by the table. The storyboard
        // may already contain constraints involving the table, so deactivate
        // those before installing the reference constraints.
        let ownConstraints = table.constraints
        NSLayoutConstraint.deactivate(ownConstraints)

        // Remove constraints from the superview that directly reference table.
        if let superview = table.superview {
            let relatedConstraints = superview.constraints.filter {
                $0.firstItem === table || $0.secondItem === table
            }
            NSLayoutConstraint.deactivate(relatedConstraints)

            let topOffset: CGFloat = 56

            NSLayoutConstraint.activate([
                table.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                table.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                           constant: topOffset),
                table.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }

    @IBAction func mBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func mShare(_ sender: Any) {
    }

    // Kept for storyboard compatibility. These controls are hidden in the UI.
    @IBAction func mFilterAll(_ sender: Any) {
        applyDisplayModeData()
        mConflictUnknownStockable?.reloadData()
    }

    @IBAction func mFilterConflict(_ sender: Any) {
        displayMode = .conflict
        applyDisplayModeData()
        mConflictUnknownStockable?.reloadData()
    }

    @IBAction func mFilterUknown(_ sender: Any) {
        displayMode = .unknown
        applyDisplayModeData()
        mConflictUnknownStockable?.reloadData()
    }

    @IBAction func mPrint(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        if let mPrint = storyBoard.instantiateViewController(withIdentifier: "PrintItem") as? PrintItem {
            navigationController?.pushViewController(mPrint, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mConflictData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        guard let cells = tableView.dequeueReusableCell(
            withIdentifier: "ConflictUnknownStockCell"
        ) as? ConflictUnknownStockCell else {
            return UITableViewCell()
        }

        let rawValue = mConflictData[indexPath.row]
        let upperValue = rawValue.uppercased()

        // DUPLICATE / MANUAL are internal conflict markers only.
        // Never show them in the Conflict list.
        var isManual =
            upperValue.contains("|MANUAL") ||
            upperValue.hasSuffix("MANUAL") ||
            upperValue.contains("|DUPLICATE") ||
            upperValue.hasSuffix("DUPLICATE")

        let isConflictScreen = displayMode == .conflict

        cells.mUknownView.isHidden = true

        if isConflictScreen,
           indexPath.row < mConflictDisplayData.count {

            let displayItem = mConflictDisplayData[indexPath.row]

            // Sold conflicts use the internal key "|SOLD", so the key alone
            // cannot tell us whether the user typed the search. Preserve the
            // actual scan source added by StockTakePage instead.
            let scanSource = (displayItem["scan_source"] ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
            isManual = isManual || scanSource == "manual"

            let sku = displayItem["SKU"]?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            let stockID = displayItem["stock_id"]?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            // Stock ID — ตัวหนา
            cells.mStockId.text = stockID
            cells.mStockId.font = UIFont(name:"SegoeUI-Bold", size: 12.0)//UIFont(name: "segoe_bold", size: 12)
            

            // SKU — ตัวปกติ
            cells.mStockIDDisplayLabel?.text = sku
            cells.mStockIDDisplayLabel?.isHidden = sku.isEmpty
            cells.mStockIDDisplayLabel?.font = UIFont(name:"SegoeUI", size: 12.0)//UIFont(name: "segoe_regular", size: 12)
            cells.mStockIDDisplayLabel?.lineBreakMode = .byClipping
            cells.mStockIDDisplayLabel?.adjustsFontSizeToFitWidth = true
            cells.mStockIDDisplayLabel?.minimumScaleFactor = 0.7

        } else {

            let displayValue = rawValue
                .replacingOccurrences(
                    of: "|MANUAL",
                    with: "",
                    options: .caseInsensitive
                )
                .replacingOccurrences(
                    of: "MANUAL",
                    with: "",
                    options: .caseInsensitive
                )
                .replacingOccurrences(
                    of: "|UKN",
                    with: "",
                    options: .caseInsensitive
                )
                .replacingOccurrences(
                    of: "|DUPLICATE",
                    with: "",
                    options: .caseInsensitive
                )
                .replacingOccurrences(
                    of: "DUPLICATE",
                    with: "",
                    options: .caseInsensitive
                )
                .trimmingCharacters(in: .whitespacesAndNewlines)

            cells.mStockId.text = displayValue
            cells.mStockId.font = UIFont(name:"SegoeUI", size: 12.0)
//            UIFont.systemFont(
//                ofSize: 14,
//                weight: .regular
//            )

            cells.mStockIDDisplayLabel?.text = nil
            cells.mStockIDDisplayLabel?.isHidden = true
        }
//        if isConflictScreen,
//           indexPath.row < mConflictDisplayData.count {
//
//            let displayItem = mConflictDisplayData[indexPath.row]
//            let sku = displayItem["SKU"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//            let stockID = displayItem["stock_id"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//
//            // Reference UI:
//            //   #1    2210149    RG025RGDD-54    icon    1 Pcs
//            //
//            // SKU and Stock ID are separate fields.
//            // Internal markers such as |DUPLICATE / |MANUAL are never shown.
//            cells.mStockId.text = sku
//            cells.mStockId.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//            cells.mStockIDDisplayLabel?.text = stockID
//            cells.mStockIDDisplayLabel?.isHidden = stockID.isEmpty
//        } else {
//            let displayValue = rawValue
//                .replacingOccurrences(of: "|MANUAL", with: "", options: .caseInsensitive)
//                .replacingOccurrences(of: "MANUAL", with: "", options: .caseInsensitive)
//                .replacingOccurrences(of: "UKN", with: "", options: .caseInsensitive)
//                .replacingOccurrences(of: "|DUPLICATE", with: "", options: .caseInsensitive)
//                .replacingOccurrences(of: "DUPLICATE", with: "", options: .caseInsensitive)
//
//            cells.mStockId.text = displayValue
//            cells.mStockId.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//            cells.mStockIDDisplayLabel?.text = nil
//            cells.mStockIDDisplayLabel?.isHidden = true
//        }

        cells.mSno.text = "#\(indexPath.row + 1)"
        cells.mSno.font = UIFont(name: "SegoeUI", size: 12.0)
        cells.mQuantity.text = "1 Pcs"
        cells.mQuantity.font = UIFont(name:"SegoeUI-Semibold", size: 12.0)//UIFont(name: "segoe_regular", size: 12)

        // Conflict screen:
        //   - normal conflict/RFID item = conflict icon
        //   - manual-added item = conflict icon + stocktake_ic_manualadd
        //
        // Unknown screen:
        //   - no icons
        //
        // This matches the reference design where a manual-added Conflict
        // row has BOTH icons.
        cells.configureIcons(
            isManual: isConflictScreen && isManual,
            showConflict: isConflictScreen
        )

        cells.mView.backgroundColor =
            indexPath.row % 2 == 0
            ? UIColor(named: "themeBackground")
            : UIColor(
                red: 0.9568627451,
                green: 0.9568627451,
                blue: 0.9568627451,
                alpha: 1
            )

        return cells
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
}
