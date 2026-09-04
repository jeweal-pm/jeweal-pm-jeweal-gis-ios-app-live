//
//  PosCart.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 06/02/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
import DropDown


protocol GetParkItems {
    func mGetParkItems(parkId:String)
}

protocol SalesPersonTransactionDelegate {
    func mSelectedCustomer(customerId:String)
    
}


let mAddParkPopUp = UINib(nibName:"confirmpark",bundle:.main).instantiate(withOwner: nil, options: nil).first as? AddParkPopUp ?? AddParkPopUp()

class AddParkPopUp: UIView {
    var mType = ""
    var mCustomerId = ""
    var mCartId = ""
    var index = Int()
    var delegate:ProceedToPay? = nil
    @IBOutlet weak var mAddNoteLABEL: UILabel!
    
    @IBOutlet weak var mNoteForLABEL: UILabel!
    @IBOutlet weak var mMessage: UITextField!
    @IBOutlet weak var mConfirmButton: UIButton!
    @IBOutlet weak var mCancelButton: UIButton!
    
    var mNavigation = UINavigationController()
    static func instantiate(message: String) -> AddParkPopUp {
        let view: AddParkPopUp = initFromNib()
        return view
    }

    @IBAction func mCancel(_ sender: Any) {
        self.removeFromSuperview()

    }
    
    @IBAction func mConfirm(_ sender: Any) {
        self.removeFromSuperview()
        if mMessage.text != "" {
            self.delegate?.isProceedWithStatus(status: true, message: self.mMessage.text ?? "")
        }else{
            CommonClass.showSnackBar(message: "Please write a note!")
        }
    }

}


struct POSSalesPersonRow {
    let id: String
    let name: String
    let image: String
    let country: String
    let phone: String
}

final class POSSalesPersonPickerView: UIView, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {

    private let rows: [POSSalesPersonRow]
    private var filteredRows: [POSSalesPersonRow]
    private let onSelect: (POSSalesPersonRow) -> Void
    private let onProfileTap: (POSSalesPersonRow) -> Void

    private let dimView = UIView()
    private let card = UIView()
    private let handleView = UIView()
    private let titleLabel = UILabel()
    private let searchField = UITextField()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var dismissPanGesture: UIPanGestureRecognizer!

    init(rows: [POSSalesPersonRow], onSelect: @escaping (POSSalesPersonRow) -> Void, onProfileTap: @escaping (POSSalesPersonRow) -> Void) {
        self.rows = rows
        self.filteredRows = rows
        self.onSelect = onSelect
        self.onProfileTap = onProfileTap
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.42)
        addSubview(dimView)

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 28
        card.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        card.clipsToBounds = true
        addSubview(card)

        // Allow the bottom sheet to be dismissed by swiping it downward.
        // Keep the gesture directional so normal vertical scrolling inside
        // the Sales Person list is not interrupted unless the list is already
        // at the top and the user is dragging downward.
        dismissPanGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleDismissPan(_:))
        )
        dismissPanGesture.delegate = self
        card.addGestureRecognizer(dismissPanGesture)

        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.backgroundColor = UIColor.systemGray3
        handleView.layer.cornerRadius = 2.5
        card.addSubview(handleView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Choose Sale Person"
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        card.addSubview(titleLabel)

        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholder = "Search customer by Name & Phone no."
        searchField.font = UIFont.systemFont(ofSize: 12)
        searchField.textColor = .black
        searchField.tintColor = UIColor.systemTeal
        searchField.backgroundColor = .white
        searchField.layer.cornerRadius = 18
        searchField.layer.borderWidth = 1
        searchField.layer.borderColor = UIColor.systemGray4.cgColor
        searchField.leftView = makeSearchIcon()
        searchField.leftViewMode = .always
        searchField.clearButtonMode = .whileEditing
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(searchChanged(_:)), for: .editingChanged)
        card.addSubview(searchField)

        let micButton = UIButton(type: .system)
        micButton.translatesAutoresizingMaskIntoConstraints = false
        micButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        micButton.tintColor = UIColor.systemTeal
        micButton.isUserInteractionEnabled = false
        card.addSubview(micButton)

        let filterButton = UIButton(type: .system)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.setImage(UIImage(systemName: "line.3.horizontal.decrease"), for: .normal)
        filterButton.tintColor = UIColor.systemTeal
        filterButton.isUserInteractionEnabled = false
        card.addSubview(filterButton)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 58
        tableView.register(POSSalesPersonCell.self, forCellReuseIdentifier: POSSalesPersonCell.reuseIdentifier)
        card.addSubview(tableView)

        NSLayoutConstraint.activate([
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Full-screen bottom sheet: the card must cover the entire app width
            // and extend behind the bottom navigation area.
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 52),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),

            handleView.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            handleView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 58),
            handleView.heightAnchor.constraint(equalToConstant: 5),

            titleLabel.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),

            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            searchField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            searchField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            searchField.heightAnchor.constraint(equalToConstant: 36),

            micButton.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
            micButton.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -12),
            micButton.widthAnchor.constraint(equalToConstant: 24),
            micButton.heightAnchor.constraint(equalToConstant: 24),

            filterButton.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
            filterButton.trailingAnchor.constraint(equalTo: searchField.trailingAnchor, constant: -8),
            filterButton.widthAnchor.constraint(equalToConstant: 24),
            filterButton.heightAnchor.constraint(equalToConstant: 24),

            tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
    }

    private func makeSearchIcon() -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 38, height: 36))
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = UIColor.systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            imageView.widthAnchor.constraint(equalToConstant: 16),
            imageView.heightAnchor.constraint(equalToConstant: 16)
        ])
        return container
    }

    @objc private func searchChanged(_ sender: UITextField) {
        let query = (sender.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if query.isEmpty {
            filteredRows = rows
        } else {
            filteredRows = rows.filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                $0.country.localizedCaseInsensitiveContains(query) ||
                $0.phone.localizedCaseInsensitiveContains(query)
            }
        }

        tableView.reloadData()
    }

    func dismissPicker() {
        removeFromSuperview()
    }

    @objc private func handleDismissPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)

        switch gesture.state {
        case .changed:
            // Only allow the sheet to move downward.
            let y = max(0, translation.y)
            card.transform = CGAffineTransform(translationX: 0, y: y)
            dimView.alpha = max(0, 1 - (y / 280.0))

        case .ended, .cancelled:
            let velocity = gesture.velocity(in: self).y
            let currentY = max(0, translation.y)

            // Dismiss with either a sufficiently long drag or a fast downward swipe.
            let shouldDismiss = currentY > 120 || velocity > 900

            if shouldDismiss {
                let remainingDistance = max(0, self.bounds.height - currentY)
                let duration = min(0.28, max(0.16, TimeInterval(remainingDistance / 1400.0)))

                UIView.animate(withDuration: duration, animations: {
                    self.card.transform = CGAffineTransform(
                        translationX: 0,
                        y: self.bounds.height
                    )
                    self.dimView.alpha = 0
                }, completion: { _ in
                    self.removeFromSuperview()
                })
            } else {
                UIView.animate(withDuration: 0.20) {
                    self.card.transform = .identity
                    self.dimView.alpha = 1
                }
            }

        default:
            break
        }
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === dismissPanGesture,
              let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }

        let velocity = pan.velocity(in: self)
        guard velocity.y > 0, abs(velocity.y) > abs(velocity.x) else {
            return false
        }

        // If the list can still scroll upward/downward, let UITableView handle it.
        // A downward swipe dismisses the sheet only when the list is already at top.
        let topInset = tableView.adjustedContentInset.top
        let atTop = tableView.contentOffset.y <= -topInset + 1
        return atTop
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    func showAnimated() {
        card.transform = CGAffineTransform(translationX: 0, y: 30)
        dimView.alpha = 0
        UIView.animate(withDuration: 0.22) {
            self.card.transform = .identity
            self.dimView.alpha = 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: POSSalesPersonCell.reuseIdentifier,
            for: indexPath
        ) as! POSSalesPersonCell

        cell.configure(with: filteredRows[indexPath.row], onProfileTap: onProfileTap)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelect(filteredRows[indexPath.row])
    }
}

final class POSSalesPersonCell: UITableViewCell {

    static let reuseIdentifier = "POSSalesPersonCell"

    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let detailLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private var profileTap: ((POSSalesPersonRow) -> Void)?
     private var profilePerson: POSSalesPersonRow?

    private var imageTask: URLSessionDataTask?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        profileTap = nil
        profilePerson = nil
        setDefaultUserIcon()
        nameLabel.text = nil
        detailLabel.text = nil
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .white

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.backgroundColor = .clear
        avatarImageView.contentMode = .center
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 21
        contentView.addSubview(avatarImageView)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        nameLabel.textColor = .darkText
        contentView.addSubview(nameLabel)

        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        detailLabel.textColor = .systemGray
        contentView.addSubview(detailLabel)

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setImage(UIImage(named: "pos_salehistory")?.withRenderingMode(.alwaysOriginal), for: .normal)
        actionButton.imageView?.contentMode = .scaleAspectFit
        actionButton.contentHorizontalAlignment = .center
        actionButton.contentVerticalAlignment = .center
        actionButton.backgroundColor = .clear
        actionButton.tintColor = nil
        actionButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        contentView.addSubview(actionButton)

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 42),
            avatarImageView.heightAnchor.constraint(equalToConstant: 42),

            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
            nameLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -8),
            nameLabel.heightAnchor.constraint(equalToConstant: 20),

            detailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            detailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0),
            detailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            detailLabel.heightAnchor.constraint(equalToConstant: 17),

            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 32),
            actionButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    private func setDefaultUserIcon() {
        guard let image = UIImage(named: "usericon") else {
            avatarImageView.image = nil
            return
        }

        // Keep the default user icon visually inside the circular avatar.
        let targetSize = CGSize(width: 32, height: 32)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        avatarImageView.image = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        avatarImageView.contentMode = .center
    }

    @objc private func profileButtonTapped() {
        guard let person = profilePerson else { return }
        profileTap?(person)
    }

    func configure(with person: POSSalesPersonRow, onProfileTap: @escaping (POSSalesPersonRow) -> Void) {
        profilePerson = person
        profileTap = onProfileTap
        imageTask?.cancel()
        imageTask = nil

        setDefaultUserIcon()
        nameLabel.text = person.name

        let country = person.country.isEmpty ? "Country" : person.country
        let phone = person.phone.isEmpty ? "" : person.phone
        detailLabel.text = phone.isEmpty ? country : "\(country)  \(phone)"

        let imageString = person.image.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !imageString.isEmpty, let url = URL(string: imageString) else {
            return
        }

        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                return
            }

            DispatchQueue.main.async {
                guard self.nameLabel.text == person.name else { return }
                // Real profile images should fill the circular avatar.
                // The default usericon remains smaller/centered.
                self.avatarImageView.contentMode = .scaleAspectFill
                self.avatarImageView.image = image
            }
        }
        imageTask?.resume()
    }
}

class PosCart:UIViewController, UIViewControllerTransitioningDelegate ,GetCustomerDataDelegate , UITableViewDataSource, UITextFieldDelegate, UITableViewDelegate, GetInventoryDataItemsDelegate , DeleteCustomCartItems , ProceedToPay,GetParkItems , SalesPersonTransactionDelegate, SearchDelegate, ServiceLabourDelegate, GetAddressDataDelegate {
    
    func isProceed(status: Bool) {
        
    }
   
    
    @IBOutlet weak var mParkCount: UILabel!
    @IBOutlet weak var mAvailableParkView: UIView!
    //TAX VIEWS
    
    
    @IBOutlet weak var mTaxView: UIView!
    @IBOutlet weak var mTaxSubTotal: UILabel!
    @IBOutlet weak var mTaxTotal: UILabel!
    
    @IBOutlet weak var mTaxAmount: UITextField!
    @IBOutlet weak var mTaxValue: UITextField!

    @IBOutlet weak var mTaxLabourCharge: UITextField!
    @IBOutlet weak var mTaxShippingCharge: UITextField!
    @IBOutlet weak var mTaxLoyaltyPoint: UITextField!

    @IBOutlet weak var mTaxDiscountPercents: UITextField!
    @IBOutlet weak var mTaxDiscountAmounts: UITextField!
    
    @IBOutlet weak var mSearchField: UITextField!

    @IBOutlet weak var mTotalItems: UILabel!
    @IBOutlet weak var mGrandTotal: UILabel!
    @IBOutlet weak var mDepositAmount: UILabel!
    @IBOutlet weak var mOutstandingAmount: UILabel!
    @IBOutlet weak var mSelectedCustomerIcon: UIImageView!
    var mCustomerId = ""
    
    // Selected Salesperson for the current POS sale.
    // The value is persisted using the existing SALESPERSONID key
    // so POSCheckout can include it in the payment payload.
    private var mSalesPersonId = ""
    private let mSalesPersonIDKey = "SALESPERSONID"

    // Sales Person picker data/UI
    private var mSalesPersons: [POSSalesPersonRow] = []
    private var mSalesPersonPicker: POSSalesPersonPickerView?
    
    @IBOutlet weak var mNotes: UITextField!
    
    @IBOutlet weak var mAddressPickerIcon: UIImageView!
    @IBOutlet weak var mAddressAlertIcon: UIImageView!
    
    var mDepositPercentData = ["25%","50%","75%","100%"]
    var mDepositPercentValue = ["25","50","75","100"]
    var mCurrency = ""
    var mGrandTotalCart = "0.00"

    @IBOutlet weak var mDepositePercent: UILabel!
    var mDepositPercents = "100"
    var mGrandTotalAmounts = "0.00"
    var mTotalDepositAmounts = "0.00"
    var mOutStandingAmounts = "0.00"
    @IBOutlet weak var mCartTable: UITableView!
    var mCartData = NSMutableArray()
    var mCartDataMaster = NSArray()
    private var linkedCartContext: LinkedCartContext?


    var mQuantityData = [Int]()
    var mCartAmount = [Double]()
    var mCurrentIndex = -1
    let mDatePicker:UIDatePicker = UIDatePicker()
    var isItemsAvailable =  false
    var isDeleted = false
    @IBOutlet weak var mSalesPersonimag: UIImageView!
    @IBOutlet weak var mUpForwardIcon: UIImageView!
    
    @IBOutlet weak var mTaxAmountLABEL: UILabel!
    
    @IBOutlet weak var mTaxPercentLABEL: UILabel!
    @IBOutlet weak var mTaxSubTotalLABEL: UILabel!
    @IBOutlet weak var mDiscountAmountLABEL: UILabel!
    @IBOutlet weak var mDiscountPercentLABEL: UILabel!
    @IBOutlet weak var mTaxShippingLABEL: UILabel!
    @IBOutlet weak var mTaxLoyaltyPointLABEL: UILabel!
    
    @IBOutlet weak var mTaxLabourLABEL: UILabel!
    @IBOutlet weak var mTaxTotalLABEL: UILabel!
    @IBOutlet weak var mCheckOutBUTTON: UIButton!
   
    @IBOutlet weak var mParkBUTTON: UIButton!
    @IBOutlet weak var mHeadingLABEL: UILabel!
    
    @IBOutlet weak var mParkButtonView: UIView!
    // MARK: - Park Suggestions
    // Same interaction pattern as MixMatchCart / CustomCart.
    private let parkSuggestions = [
        "Hold for 30 minutes",
        "Parked until customer is ready",
        "Resume after customer confirmation",
        "Manager approval"
    ]

    private var parkSuggestionsView: UIView?
    private var parkSuggestionsStack: UIStackView?
    private var parkSuggestionsTargetsInstalled = false
    private var parkSuggestionsSuppressedAfterSelection = false
    private var parkDismissTapGesture: UITapGestureRecognizer?

    private func parkFont(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        if weight == .bold {
            return UIFont(name: "segoe_bold", size: size)
                ?? UIFont.systemFont(ofSize: size, weight: weight)
        }
        return UIFont(name: "segoe_regular", size: size)
            ?? UIFont.systemFont(ofSize: size, weight: weight)
    }

    private func setupParkSuggestions() {
        guard let textField = mAddParkPopUp.mMessage else { return }

        textField.clearButtonMode = .whileEditing
        textField.delegate = self

        if !parkSuggestionsTargetsInstalled {
            textField.addTarget(
                self,
                action: #selector(parkNoteEditingChanged(_:)),
                for: .editingChanged
            )
            textField.addTarget(
                self,
                action: #selector(parkNoteEditingBegan(_:)),
                for: .editingDidBegin
            )
            textField.addTarget(
                self,
                action: #selector(parkNoteEditingEnded(_:)),
                for: .editingDidEnd
            )
            parkSuggestionsTargetsInstalled = true
        }

        if parkSuggestionsView == nil {
            let popup = UIView()
            popup.backgroundColor = .white
            popup.layer.cornerRadius = 8
            popup.layer.masksToBounds = false
            popup.layer.shadowColor = UIColor.black.cgColor
            popup.layer.shadowOpacity = 0.12
            popup.layer.shadowRadius = 8
            popup.layer.shadowOffset = CGSize(width: 0, height: 2)
            popup.translatesAutoresizingMaskIntoConstraints = false
            popup.isHidden = true

            let title = UILabel()
            title.text = "Suggestions"
            title.textColor = .black
            title.font = parkFont(13, weight: .bold)
            title.translatesAutoresizingMaskIntoConstraints = false

            let stack = UIStackView()
            stack.axis = .vertical
            stack.alignment = .fill
            stack.distribution = .fill
            stack.spacing = 0
            stack.translatesAutoresizingMaskIntoConstraints = false

            popup.addSubview(title)
            popup.addSubview(stack)
            mAddParkPopUp.addSubview(popup)

            NSLayoutConstraint.activate([
                popup.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
                popup.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
                popup.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -8),

                title.topAnchor.constraint(equalTo: popup.topAnchor, constant: 12),
                title.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: 16),
                title.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -16),
                title.heightAnchor.constraint(equalToConstant: 18),

                stack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
                stack.leadingAnchor.constraint(equalTo: popup.leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: popup.trailingAnchor),
                stack.bottomAnchor.constraint(equalTo: popup.bottomAnchor, constant: -8)
            ])

            parkSuggestionsView = popup
            parkSuggestionsStack = stack
        }

        parkSuggestionsView?.isHidden = true
    }

    private func showParkSuggestions() {
        guard let textField = mAddParkPopUp.mMessage else { return }

        guard !parkSuggestionsSuppressedAfterSelection else {
            parkSuggestionsView?.isHidden = true
            return
        }

        updateParkSuggestions(for: textField.text ?? "")
    }

    private func updateParkSuggestions(for text: String) {
        guard let popup = parkSuggestionsView,
              let stack = parkSuggestionsStack else { return }

        if parkSuggestionsSuppressedAfterSelection {
            popup.isHidden = true
            return
        }

        stack.arrangedSubviews.forEach {
            stack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = query.isEmpty
            ? parkSuggestions
            : parkSuggestions.filter {
                $0.localizedCaseInsensitiveContains(query)
            }

        guard !filtered.isEmpty else {
            popup.isHidden = true
            return
        }

        for suggestion in filtered {
            let button = UIButton(type: .system)

            button.setTitle(suggestion, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = parkFont(13)

            // IMPORTANT:
            // Do not truncate long suggestion text with "..."
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.85

            button.contentHorizontalAlignment = .left
            button.contentVerticalAlignment = .center

            button.contentEdgeInsets = UIEdgeInsets(
                top: 0,
                left: 16,
                bottom: 0,
                right: 8
            )

            button.backgroundColor = .white

            button.heightAnchor.constraint(equalToConstant: 40).isActive = true

            button.addTarget(
                self,
                action: #selector(parkSuggestionTapped(_:)),
                for: .touchUpInside
            )

            stack.addArrangedSubview(button)
        }
//        for suggestion in filtered {
//            let button = UIButton(type: .system)
//            button.setTitle(suggestion, for: .normal)
//            button.setTitleColor(.black, for: .normal)
//            button.titleLabel?.font = parkFont(13)
//            button.contentHorizontalAlignment = .left
//            button.contentEdgeInsets = UIEdgeInsets(
//                top: 0,
//                left: 16,
//                bottom: 0,
//                right: 16
//            )
//            button.backgroundColor = .white
//            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
//            button.addTarget(
//                self,
//                action: #selector(parkSuggestionTapped(_:)),
//                for: .touchUpInside
//            )
//            stack.addArrangedSubview(button)
//        }

        popup.isHidden = false
        mAddParkPopUp.layoutIfNeeded()
        mAddParkPopUp.bringSubviewToFront(popup)
    }

    private func hideParkSuggestions() {
        parkSuggestionsView?.isHidden = true
    }

    @objc private func parkNoteEditingBegan(_ textField: UITextField) {
        showParkSuggestions()
    }

    @objc private func parkNoteEditingChanged(_ textField: UITextField) {
        let text = textField.text ?? ""

        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parkSuggestionsSuppressedAfterSelection = false
            hideParkSuggestions()
            textField.resignFirstResponder()
            mAddParkPopUp.endEditing(true)
            return
        }

        if parkSuggestionsSuppressedAfterSelection {
            hideParkSuggestions()
            return
        }

        updateParkSuggestions(for: text)
    }

    @objc private func parkSuggestionTapped(_ sender: UIButton) {
        guard let textField = mAddParkPopUp.mMessage else { return }

        textField.text = sender.currentTitle ?? ""
        parkSuggestionsSuppressedAfterSelection = true
        hideParkSuggestions()
        textField.becomeFirstResponder()
    }

    @objc private func parkNoteEditingEnded(_ textField: UITextField) {
        hideParkSuggestions()
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        guard textField === mAddParkPopUp.mMessage else {
            return true
        }

        textField.text = ""
        parkSuggestionsSuppressedAfterSelection = false
        hideParkSuggestions()
        textField.resignFirstResponder()
        mAddParkPopUp.endEditing(true)
        return false
    }

    @objc private func parkPopupTapped(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: mAddParkPopUp)

        if let noteField = mAddParkPopUp.mMessage,
           noteField.frame.contains(point) {
            return
        }

        if let suggestionsView = parkSuggestionsView,
           !suggestionsView.isHidden,
           suggestionsView.frame.contains(point) {
            return
        }

        mAddParkPopUp.endEditing(true)
        hideParkSuggestions()
    }

    private func installParkPopupDismissGesture() {
        guard parkDismissTapGesture == nil else { return }

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(parkPopupTapped(_:))
        )
        tap.cancelsTouchesInView = false
        mAddParkPopUp.addGestureRecognizer(tap)
        parkDismissTapGesture = tap
    }

    @IBOutlet weak var mNoteLABEL: UILabel!
    
    @IBOutlet weak var mGrandTotalLABEL: UILabel!
    
    var mParkedStockIds = Set<String>()
    
    var mCalculatedSubTotal: Double = 0.0
    var mCalculatedTaxAmount: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mCustomerId = UserDefaults.standard.string(forKey: "DEFAULTCUSTOMER") ?? ""

        // New POS sale: no Salesperson has been selected yet.
        mSalesPersonId = ""
        UserDefaults.standard.removeObject(forKey: mSalesPersonIDKey)
        UserDefaults.standard.removeObject(forKey: "sales_person_id")
        UserDefaults.standard.removeObject(forKey: "SALESPERSON_IMAGE")
        UserDefaults.standard.removeObject(forKey: "SALESPERSONNAME")
        UserDefaults.standard.removeObject(forKey: "sales_person_name")
        updateSalesPersonImage()
        self.mNotes.keyboardType = .default
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")

        self.mCartTable.delegate = self
        self.mCartTable.dataSource = self
        self.mCartTable.reloadData()
        mGrandTotal.text = "\(UserDefaults.standard.value(forKey: "currencySymbol") ?? "$") 0.00"
        print("GrandTotal =", mGrandTotal.text ?? "")
        UserDefaults.standard.setValue(nil, forKey: "CustomerBillingAddressUDID")
        UserDefaults.standard.setValue(nil, forKey: "CustomerShippingAddressUDID")
        
        mTaxDiscountPercents.keyboardType = .decimalPad
        mTaxDiscountAmounts.keyboardType = .decimalPad
        
        mTaxShippingCharge.delegate = self
        mTaxLoyaltyPoint.delegate = self
//        mTaxLabourCharge.delegate = self
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Sales Person UI

    private func applySalesPersonImage(_ image: UIImage?) {
        // Header Sales Person icon.
        // Keep the storyboard's existing tap area, but render the icon smaller
        // so it matches the reference design instead of filling the whole view.
        mSalesPersonimag.layoutIfNeeded()

        // The design does not have a white circular background around the
        // Sales Person icon. Clear both the image view and its immediate
        // container because the circle may come from the storyboard view.
        mSalesPersonimag.backgroundColor = .clear
        mSalesPersonimag.clipsToBounds = false
        mSalesPersonimag.layer.masksToBounds = false
        mSalesPersonimag.layer.cornerRadius = 0
        mSalesPersonimag.layer.borderWidth = 0
        mSalesPersonimag.layer.borderColor = UIColor.clear.cgColor
        mSalesPersonimag.contentMode = .center
        mSalesPersonimag.tintColor = nil

        if let container = mSalesPersonimag.superview {
            container.backgroundColor = .clear
            container.clipsToBounds = false
            container.layer.masksToBounds = false
            container.layer.cornerRadius = 0
            container.layer.borderWidth = 0
            container.layer.borderColor = UIColor.clear.cgColor
        }

        mSalesPersonimag.image = resizeSalesPersonHeaderIcon(image, maxSide: 28)
    }

    private func resizeSalesPersonHeaderIcon(_ image: UIImage?, maxSide: CGFloat) -> UIImage? {
        guard let image = image else { return nil }
        guard image.size.width > 0, image.size.height > 0 else { return image }

        let scale = min(maxSide / image.size.width, maxSide / image.size.height)
        let targetSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    private func updateSalesPersonImage() {
        let salesPersonId = UserDefaults.standard.string(forKey: mSalesPersonIDKey) ?? ""
        let imageURL = UserDefaults.standard.string(forKey: "SALESPERSON_IMAGE") ?? ""

        // No Sales Person selected yet -> keep the original POS contact icon.
        if salesPersonId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            applySalesPersonImage(UIImage(named: "pos_contact"))
            return
        }

        // Selected Sales Person but no image -> use usericon.
        let trimmedURL = imageURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURL.isEmpty, let url = URL(string: trimmedURL) else {
            applySalesPersonImage(UIImage(named: "usericon"))
            return
        }

        // Always show fallback first. If the URL succeeds, replace it.
        applySalesPersonImage(UIImage(named: "usericon"))

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                return
            }

            DispatchQueue.main.async {
                self.applySalesPersonImage(image)
            }
        }.resume()
    }

    func mSelectedCustomer(customerId: String) {
        // Keep the existing delegate for compatibility with the rest of the project.
        let selectedId = customerId.trimmingCharacters(in: .whitespacesAndNewlines)
        mSalesPersonId = selectedId

        if selectedId.isEmpty {
            UserDefaults.standard.removeObject(forKey: mSalesPersonIDKey)
            UserDefaults.standard.removeObject(forKey: "sales_person_id")
            UserDefaults.standard.removeObject(forKey: "SALESPERSONNAME")
            UserDefaults.standard.removeObject(forKey: "sales_person_name")
            UserDefaults.standard.removeObject(forKey: "SALESPERSON_IMAGE")
        } else {
            UserDefaults.standard.set(selectedId, forKey: mSalesPersonIDKey)
            UserDefaults.standard.set(selectedId, forKey: "sales_person_id")
        }

        updateSalesPersonImage()
        print("DEBUG_POS_SELECTED_SALESPERSON_ID =", mSalesPersonId)
    }

    @IBAction func mOpenSalesPerson(_ sender: Any) {
        fetchSalesPersonsAndShowPicker()
    }

    private func fetchSalesPersonsAndShowPicker() {
        // Backend needs to expose these fields.
        let query = "{salespersons{id name image country phone}}"
        let params: [String: Any] = ["query": query]

        print("========== SALES PERSON GRAPHQL ==========")
        print("URL =", mInventoryGrapQlUrl)
        print("QUERY =", query)
        print("==========================================")

        CommonClass.showFullLoader(view: self.view)

        AF.request(
            mInventoryGrapQlUrl,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: sGisHeaders
        ).responseJSON { [weak self] response in
            guard let self = self else { return }
            CommonClass.stopLoader()

            guard response.error == nil,
                  let data = response.data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let root = json["data"] as? [String: Any],
                  let rows = root["salespersons"] as? [[String: Any]] else {
                print("❌ SALES PERSON GRAPHQL ERROR =",
                      response.error?.localizedDescription ?? "Invalid response")
                CommonClass.showSnackBar(message: "Unable to load Sales Person list")
                return
            }

            let salesPersons: [POSSalesPersonRow] = rows.compactMap { row in
                guard let id = row["id"] as? String, !id.isEmpty else {
                    return nil
                }

                let name = (row["name"] as? String ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                let image = self.salesPersonString(row["image"])
                let country = self.salesPersonString(row["country"])
                let phone = self.salesPersonString(row["phone"])

                return POSSalesPersonRow(
                    id: id,
                    name: name.isEmpty ? id : name,
                    image: image,
                    country: country,
                    phone: phone
                )
            }

            print("SALES PERSON COUNT =", salesPersons.count)
            print("SALES PERSON DATA =", salesPersons)

            guard !salesPersons.isEmpty else {
                CommonClass.showSnackBar(message: "No Sales Person found")
                return
            }

            self.mSalesPersons = salesPersons
            self.showSalesPersonPicker()
        }
    }

    private func salesPersonString(_ value: Any?) -> String {
        if let value = value as? String {
            return value.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let value = value as? NSNumber {
            return value.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }

    private func openSalesPersonProfile(for person: POSSalesPersonRow) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "posBoard", bundle: nil)

        if let mSalesPerson = storyBoard.instantiateViewController(withIdentifier: "SalesPerson") as? SalesPerson {
            // Pass the exact Sales Person selected from the list.
            mSalesPerson.mSalesPersonId = person.id
            mSalesPerson.modalPresentationStyle = .overFullScreen
            mSalesPerson.delegate = self
            mSalesPerson.transitioningDelegate = self
            self.present(mSalesPerson, animated: true)
        }
    }

    private func showSalesPersonPicker() {
        mSalesPersonPicker?.removeFromSuperview()

        let picker = POSSalesPersonPickerView(rows: mSalesPersons, onSelect: { [weak self] person in
            guard let self = self else { return }

            self.mSalesPersonId = person.id

            UserDefaults.standard.set(person.id, forKey: self.mSalesPersonIDKey)
            UserDefaults.standard.set(person.id, forKey: "sales_person_id")
            UserDefaults.standard.set(person.name, forKey: "SALESPERSONNAME")
            UserDefaults.standard.set(person.name, forKey: "sales_person_name")

            if person.image.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                UserDefaults.standard.removeObject(forKey: "SALESPERSON_IMAGE")
            } else {
                UserDefaults.standard.set(person.image, forKey: "SALESPERSON_IMAGE")
            }

            self.updateSalesPersonImage()

            print("DEBUG_SELECTED_SALESPERSON_NAME =", person.name)
            print("DEBUG_SELECTED_SALESPERSON_ID =", person.id)
            print("DEBUG_SELECTED_SALESPERSON_IMAGE =", person.image)

            self.mSalesPersonPicker?.dismissPicker()
            self.mSalesPersonPicker = nil
        }, onProfileTap: { [weak self] person in
            self?.openSalesPersonProfile(for: person)
        })

        picker.translatesAutoresizingMaskIntoConstraints = false

        // Add the picker to the key window instead of self.view so the sheet
        // covers the complete screen, including the bottom tab bar.
        guard let window = self.view.window ??
                UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first(where: { $0.activationState == .foregroundActive })?
                    .windows.first(where: { $0.isKeyWindow }) else {
            print("❌ Cannot find key window for Sales Person picker")
            return
        }

        window.addSubview(picker)

        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            picker.topAnchor.constraint(equalTo: window.topAnchor),
            picker.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        ])

        mSalesPersonPicker = picker
        picker.showAnimated()
    }

    func isProceedWithStatus(status: Bool, message : String) {
        if status {
            
            let mParkCarData = NSMutableArray()
        
            for i in self.mCartData {
                let mParkObjects = NSMutableDictionary()
                if let mData = i as? NSDictionary {
                    mParkObjects.setValue("\(mData.value(forKey: "Qty") ?? "" )", forKey: "Qty")
                    mParkObjects.setValue("pos_order", forKey: "type")
                    mParkObjects.setValue("\(mData.value(forKey: "retailprice_Inc") ?? "0")", forKey: "retailprice_Inc")
                    
                    mParkObjects.setValue("\(mData.value(forKey: "price") ?? "0" )", forKey: "price")
                    mParkObjects.setValue("pos_order", forKey: "order_type")
                    mParkObjects.setValue("\(mData.value(forKey: "Discount_Amount") ?? "0" )", forKey: "Discount_Amount")
                    mParkObjects.setValue("\(mData.value(forKey: "discount_percent") ?? "0" )", forKey: "discount_percent")
                    mParkObjects.setValue("\(mData.value(forKey: "custom_cart_id") ?? "" )", forKey: "custom_cart_id")
                    mParkObjects.setValue("\(mData.value(forKey: "name") ?? "" )", forKey: "name")
                    mParkObjects.setValue("\(mData.value(forKey: "main_image") ?? "" )", forKey: "main_image")
                    mParkObjects.setValue("\(mData.value(forKey: "currency") ?? "" )", forKey: "currency")
                    mParkObjects.setValue("\(mData.value(forKey: "stock_id") ?? "" )", forKey: "stock_id")
                }
                mParkCarData.add(mParkObjects)
                
            }
            let mSummaryOrder = NSMutableDictionary()
            let mSellInfo = NSMutableDictionary()
            let mCustomerData = NSMutableDictionary()
            mCustomerData.setValue(self.mCustomerId, forKey: "id")
            mCustomerData.setValue(UserDefaults.standard.string(forKey:"DEFAULTCUSTOMERNAME") ?? "User", forKey: "name")

            mSummaryOrder.setValue(0, forKey: "labour")
            mSummaryOrder.setValue(0, forKey: "shipping")
            mSummaryOrder.setValue(0, forKey: "loyalty_points")
            mSummaryOrder.setValue(0, forKey: "tax_amount")
            mSummaryOrder.setValue(0, forKey: "tax_amount_int")
            mSummaryOrder.setValue(0, forKey: "tax_prect")
            mSummaryOrder.setValue("", forKey: "tax_type")
            mSummaryOrder.setValue(0, forKey: "discount")
            mSummaryOrder.setValue(0, forKey: "discount_percent")
            mSummaryOrder.setValue(mCustomerData, forKey: "customer_id")
            mSummaryOrder.setValue(self.mSalesPersonId, forKey: "sales_person_id")
            mSummaryOrder.setValue(0, forKey: "deposit")
            mSummaryOrder.setValue(Double(self.mGrandTotalAmounts), forKey: "deposit_amount")
        
            mSellInfo.setValue(mParkCarData, forKey: "cart")
            mSellInfo.setValue(mSummaryOrder, forKey: "summary_order")
            mSellInfo.setValue("pos_order", forKey: "status_type")
            mSellInfo.setValue(Double(self.mGrandTotalAmounts), forKey: "totalamount")
            let  mFinalData = ["sell_info": mSellInfo, "totalamount":self.mGrandTotalAmounts,"order_type":"pos_order", "parktime": message] as [String : Any]
            
            
            
            mUserLoginToken = UserDefaults.standard.string(forKey: "token")
            mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
            mGetData(url: mAddToPark,headers: sGisHeaders,  params: mFinalData) { response , status in
                if status {
                    var parkedIds = UserDefaults.standard.stringArray(forKey: "ParkedStockIds") ?? []

                    for item in self.mCartData {

                        if let dict = item as? NSDictionary {

                            let stockId = "\(dict["stock_id"] ?? "")"

                            if !parkedIds.contains(stockId) {
                                parkedIds.append(stockId)
                            }
                        }
                    }

                    UserDefaults.standard.set(parkedIds, forKey: "ParkedStockIds")
                    
                    
                    
                    // ===== Clear Cart =====
                    self.mClearCart()
                    self.mCartData.removeAllObjects()
                    self.mCartTable.reloadData()

                    // ถ้ามีฟังก์ชันคำนวณยอด
                    self.mTaxShippingCharge.text = "0.00"
                    self.mTaxLoyaltyPoint.text = "0.00"
                    self.calculateItemsWithAmount()
                    
                    self.mGetParkStatus()

                    
                }
        }
            
        }
    }
    
    
    @IBAction func mParkNow(_ sender: UIButton) {

        if mCartData.count > 0 {

            // Suggestions extend above the Note field, so don't clip the popup.
            mAddParkPopUp.clipsToBounds = false
            mAddParkPopUp.frame = self.view.bounds

            mAddParkPopUp.mMessage.text = ""
            mAddParkPopUp.mMessage.placeholder =
                "Ex: Customer will back in 10 mins".localizedString
            mAddParkPopUp.delegate = self

            mAddParkPopUp.mAddNoteLABEL.text = "Add Note".localizedString
            mAddParkPopUp.mNoteForLABEL.text =
                "Not for the sale you want to park".localizedString
            mAddParkPopUp.mCancelButton.setTitle(
                "CANCEL".localizedString,
                for: .normal
            )
            mAddParkPopUp.mConfirmButton.setTitle(
                "PARK SALE".localizedString,
                for: .normal
            )

            parkSuggestionsSuppressedAfterSelection = false

            self.view.addSubview(mAddParkPopUp)

            // Prepare Suggestions but don't show them until Note is tapped.
            setupParkSuggestions()
            hideParkSuggestions()
            installParkPopupDismissGesture()

            // Do not open the keyboard automatically.
            mAddParkPopUp.mMessage.resignFirstResponder()
            mAddParkPopUp.endEditing(true)

        } else {
            CommonClass.showSnackBar(message: "No Items in Cart")
        }
    }

    func mGetParkItems(parkId: String) {
        
        if parkId != "" {
            
            let mParams = [ "park_id":parkId] as [String : Any]
            
            mUserLoginToken = UserDefaults.standard.string(forKey: "token")
            mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
            
            mGetData(url: mFetchCustomProduct,headers: sGisHeaders,  params: mParams) { response , status in
                CommonClass.stopLoader()
                if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    if let mData = response.value(forKey: "data") as? NSArray, mData.count > 0 {
                        self.mCartDataMaster = mData
                        self.mCartData = NSMutableArray(array: mData)
                        self.mCartTable.delegate = self
                        self.mCartTable.dataSource = self
                        self.mQuantityData = [Int]()
                        self.mCartAmount = [Double]()
                        self.mGetParkStatus()
                        self.mCartTable.reloadData()
                        for i in self.mCartData {
                            if let mData = i as? NSDictionary {
                                self.mQuantityData.append(Int("\(mData.value(forKey: "Qty") ?? "0")") ?? 0)
                                
                                let priceString = "\(mData.value(forKey: "cart_price") ?? "0")"
                                print("priceStringpriceStringpriceString = \(priceString)")
                                let filtered = priceString.filter {
                                    "0123456789.-".contains($0)
                                }
                                print("filteredfilteredfilteredfiltered = \(filtered)")
                                let price = Double(filtered) ?? 0.0
                                print("pricepricepricepriceprice = \(price)")
                                self.mCartAmount.append(price)
                                print("mCartAmount =", self.mCartAmount)
                                print("sum =", self.mCartAmount.reduce(0, +))
//                                self.calculateItemsWithAmount()
                                
//                                self.mCartAmount.append(Double("\(mData.value(forKey: "cart_price") ?? "0")") ?? 0.0)
                            }
                        }
                        DispatchQueue.main.async {
                            self.mCartTable.reloadData()
                            self.calculateItemsWithAmount()
                        }
                    }
                    
                    
                }else{
              
                }
            }
        }
        }else{
            mGetParkStatus()
        }
        
    }
    @IBAction func mViewPark(_ sender: UIButton) {
      
        let storyBoard: UIStoryboard = UIStoryboard(name: "posBoard", bundle: nil)
        if let mPOSPark = storyBoard.instantiateViewController(withIdentifier: "POSPark") as? POSPark {
            mPOSPark.modalPresentationStyle = .overFullScreen
            mPOSPark.delegate = self
            mPOSPark.transitioningDelegate = self
            self.present(mPOSPark,animated: true)
        }
    }
    
    
    @IBAction func mEditLabour(_ sender: UITextField) {
//        if sender.text == "" {
//            sender.text = "0"
//            calculateItemsWithAmount()
//        }else{
//            calculateItemsWithAmount()
//
//        }
        calculateItemsWithAmount()
    }
    @IBAction func mEditShipping(_ sender: UITextField) {
//        if sender.text == "" {
//            sender.text = ""
//            calculateItemsWithAmount()
//        }else{
            calculateItemsWithAmount()
//        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.mTaxShippingCharge,
           (textField.text ?? "").isEmpty {
            textField.text = "0"
        }
    }
    
    @IBAction func mEditLoyaltyPoints(_ sender: UITextField) {
//        if sender.text == "" {
//            sender.text = "0"
//            calculateItemsWithAmount()
//        }else{
            calculateItemsWithAmount()
            
//        }
    }
    @IBAction func mEditTaxDiscount(_ sender: UITextField) {

        let shipping = Double(self.mTaxShippingCharge.text ?? "") ?? 0.0
        let loyalty = Double(self.mTaxLoyaltyPoint.text ?? "") ?? 0.0

        let orderTotal = (Double(self.mGrandTotalAmounts) ?? 0.0) + shipping + loyalty
        var percent = Double(sender.text ?? "") ?? 0.0

        // จำกัดช่วง 0 - 100%
        if percent < 0 {
            percent = 0
        } else if percent > 100 {
            percent = 100
        }

        // อัปเดตค่าที่แสดงใน TextField
        sender.text = String(format: "%.0f", percent)

        let discountAmount = calculatePercentage(
            value: orderTotal,
            percent: percent
        )

        self.mTaxDiscountAmounts.text = String(format: "%.2f", discountAmount)

        calculateItemsWithAmount()
    }
    
    @IBAction func mEditTaxDiscountAmount(_ sender: UITextField) {
//        print("mEditTaxDiscountAmount")
//        let grandTotal = Double(self.mGrandTotalAmounts) ?? 0
        let shipping = Double(self.mTaxShippingCharge.text ?? "") ?? 0
        let grandTotal = (Double(self.mGrandTotalAmounts) ?? 0) + shipping
//        print("mEditTaxDiscountAmount grandTotal = \(grandTotal)")
        var discount = Double(sender.text ?? "") ?? 0
//        print("mEditTaxDiscountAmount discount = \(discount)")
        if discount < 0 {
            discount = 0
        }

        if discount > grandTotal {
            discount = grandTotal
        }

//        sender.text = String(format: "%.2f", discount)
//        print("mEditTaxDiscountAmount sender.text = \(String(describing: sender.text))")

        let percent = grandTotal == 0
            ? 0
            : (discount / grandTotal) * 100

        self.mTaxDiscountPercents.text = String(format: "%.2f", percent)
//        print("mEditTaxDiscountAmount self.mTaxDiscountPercents.text = \(String(describing: self.mTaxDiscountPercents.text))")

        calculateItemsWithAmount()
    }
    
    private func updateProductPrice(_ cell: CustomCartItems, price: Double) {

        let currency = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        let priceText = formatter.string(from: NSNumber(value: price)) ?? "0.00"

        let attr = NSMutableAttributedString()

        attr.append(
            NSAttributedString(
                string: "\(currency) ",
                attributes: [
                    .foregroundColor: UIColor.black,
                    .font: UIFont(name: "SegoeUI", size: 14)!
                ]
            )
        )

        attr.append(
            NSAttributedString(
                string: priceText,
                attributes: [
                    .foregroundColor: UIColor(named: "themeColor") ?? .systemTeal,
                    .font: UIFont(name: "SegoeUI", size: 14)!
                ]
            )
        )

        cell.mProductPrice.attributedText = attr
    }
    
    private func updateCartData(
        at index:Int,
        price:Double,
        discountPercent:Double,
        discountAmount:Double
    ){

        guard let oldData = mCartData[index] as? NSDictionary,
              let data = oldData.mutableCopy() as? NSMutableDictionary else {
            return
        }

        data["price"] = price
        data["discount_percent"] = String(format:"%.2f",discountPercent)
        data["Discount_Amount"] = String(format:"%.2f",discountAmount)

        if let exist = oldData["Service_labour_exsist"] as? Bool{

            data["Service_labour_exsist"] = exist

            if exist,
               let labour = oldData["Service_labour"] as? NSDictionary{

                data["Service_labour"] = labour
            }

        }else{

            data["Service_labour_exsist"] = false
        }

        if oldData["stock_id_options"] == nil{
            data["stock_id_options"] = []
        }

        mCartData[index] = data
        
        print("========== UPDATE CART ==========")
        print("price =", data["price"] ?? "")
        print("cart_price =", data["cart_price"] ?? "")
        print("Discount_Amount =", data["Discount_Amount"] ?? "")
        print("discount_percent =", data["discount_percent"] ?? "")
        print("=================================")
    }
    
    private func resetDiscount(
        cell:CustomCartItems,
        index:Int
    ){

        let price = mCartAmount[index]

        cell.mDiscountPercent.text = ""
        cell.mDiscountAmount.text = ""

        updateProductPrice(cell, price: price)

        updateCartData(
            at: index,
            price: price,
            discountPercent: 0,
            discountAmount: 0
        )

        calculateItemsWithAmount()
    }
    
    private func clearTaxFields() {
        mTaxLabourCharge.text = ""
        mTaxShippingCharge.text = ""
        mTaxLoyaltyPoint.text = ""
        mTaxDiscountAmounts.text = ""
        mTaxDiscountPercents.text = ""
    }
    
    @IBAction func mEditDiscount(_ sender: UITextField) {
        
        clearTaxFields()
        let mIndexPath = IndexPath(row:sender.tag,section: 0)
        
        print("sender.tag =", sender.tag)
        print("mCartAmount =", mCartAmount)
        print("mCartData.count =", mCartData.count)
        
        if sender.text == "" {

            guard let cell = self.mCartTable.cellForRow(at: mIndexPath) as? CustomCartItems else {
                return
            }

            sender.placeholder = "0.00"

            resetDiscount(
                cell: cell,
                index: sender.tag
            )

            return
        }else{
            guard let cell = self.mCartTable.cellForRow(at: mIndexPath) as? CustomCartItems else {
                return
            }
            
            let price = self.mCartAmount[sender.tag]
            print("Original Price =", price)
            var percent = Double(sender.text ?? "") ?? 0
            
            // จำกัด 0...100
            percent = min(max(percent, 0), 100)
            
            // ถ้าผู้ใช้พิมพ์เกิน 100 ให้แก้ textbox กลับ
            if percent != (Double(sender.text ?? "") ?? 0) {
                sender.text = String(format: "%.0f", percent)
            }
            
            // ถ้าเป็น 0 ให้รีเซ็ต
            if percent == 0 {
                
                resetDiscount(cell: cell, index: sender.tag)
                
                return
            }
            
//            let discountAmount = price * percent / 100
//
//            let finalPrice = price - discountAmount
//
//            print("Percent =", percent)
//            print("Discount =", discountAmount)
//            print("Final =", finalPrice)
//
//            updateProductPrice(cell, price: finalPrice)

//            cell.mDiscountAmount.text = String(format: "%.2f", discountAmount)
            
            let discountAmount = price * percent / 100
            let finalPrice = price - discountAmount

            // Sync Discount Amount
            if cell.mDiscountAmount.isEditing == false {
                cell.mDiscountAmount.text = String(format: "%.2f", discountAmount)
            }

            updateProductPrice(cell, price: finalPrice)

            updateCartData(
                at: sender.tag,
                price: finalPrice,
                discountPercent: percent,
                discountAmount: discountAmount
            )

            calculateItemsWithAmount()

            updateCartData(
                at: sender.tag,
                price: finalPrice,
                discountPercent: percent,
                discountAmount: discountAmount
            )

            calculateItemsWithAmount()
            
        }
       
    }
    
    @IBAction func mEditDiscountAmount(_ sender: UITextField) {
        clearTaxFields()
    
        let mIndexPath = IndexPath(row:sender.tag,section: 0)

        if sender.text == "" {

            guard let cell = self.mCartTable.cellForRow(at: mIndexPath) as? CustomCartItems else {
                return
            }

            sender.placeholder = "0.00"

            resetDiscount(
                cell: cell,
                index: sender.tag
            )

            return
        }
        
        if sender.text == "0" {
            sender.text = ""
        }
        
            
            guard let cell = self.mCartTable.cellForRow(at: mIndexPath) as? CustomCartItems else {
                return
            }

            let originalPrice = self.mCartAmount[sender.tag]

            var discount = Double(sender.text ?? "") ?? 0

            // ไม่ให้ติดลบ
            discount = max(0, discount)

            // ไม่ให้เกินราคาสินค้า
            if discount > originalPrice {

                discount = originalPrice

//                sender.text = String(format: "%.2f", originalPrice)
                
                cell.mDiscountAmount.text = sender.text
            }
//            cell.mDiscountAmount.text =
//                String(format: "%.2f", discount)
            // ถ้าเป็น 0 ให้รีเซ็ต
            if discount == 0 {

                resetDiscount(cell: cell, index: sender.tag)

                return
            }

//            let percent = originalPrice == 0
//                ? 0
//                : (discount / originalPrice) * 100
//
//            let finalPrice = originalPrice - discount

//            cell.mDiscountPercent.text =
//                String(format: "%.2f", percent)
        let percent = originalPrice == 0
            ? 0
            : (discount / originalPrice) * 100

        let finalPrice = originalPrice - discount

        // Sync Discount %
        if cell.mDiscountPercent.isEditing == false {
            cell.mDiscountPercent.text = String(format: "%.2f", percent)
        }

        updateProductPrice(
            cell,
            price: finalPrice
        )

        updateCartData(
            at: sender.tag,
            price: finalPrice,
            discountPercent: percent,
            discountAmount: discount
        )

        calculateItemsWithAmount()
            updateProductPrice(
                cell,
                price: finalPrice
            )

            updateCartData(
                at: sender.tag,
                price: finalPrice,
                discountPercent: percent,
                discountAmount: discount
            )

            calculateItemsWithAmount()
        
    
    }
    
    
    @IBAction func mShowTax(_ sender: UIButton) {
         sender.isSelected = !sender.isSelected
         if sender.isSelected {
            mUpForwardIcon.image = UIImage(named: "top_ic")
            UIView.animate(withDuration: 1.0) {
                self.mTaxView.isHidden = false
                self.view.layoutIfNeeded() }
        }else{
            mUpForwardIcon.image = UIImage(named: "forward_ic")
             UIView.animate(withDuration: 1.0) {
                self.mTaxView.isHidden = true
                self.view.layoutIfNeeded()
            }
        }

        
    }
   
    @IBAction func mOpenProductStoneDetails(_ sender: UIButton) {
        let mIndex = sender.tag
        let mData = mCartData[mIndex] as? NSDictionary
        if let mPoProductId = mData?.value(forKey: "po_product_id") as? String {
            if mPoProductId != "" {
                print("mData = \(mData ?? [:])")
                let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
                if let home = storyBoard.instantiateViewController(withIdentifier: "SKUProductSummary") as? SKUProductSummary{
                    home.mKey = mPoProductId
                    home.modalPresentationStyle = .automatic
                    home.transitioningDelegate = self
                    self.present(home,animated: true)
                }
            }
        }

      
    }
    
    

    override func viewWillDisappear(_ animated: Bool) {

    }
    
    func mClearCart() {
        print("🔥 POSCart.swift mClearCart called")
        mGetData(
            url: mClearDataApi,
            headers: sGisHeaders,
            params: [:]
        ) { response, status in

            if status,
               "\(response["code"] ?? "")" == "200" {

                self.mFetchCartItems()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

        // Restore the selected Salesperson whenever returning from
        // the Choose Sale Person screen.
        mSalesPersonId = UserDefaults.standard.string(forKey: mSalesPersonIDKey) ?? ""
        updateSalesPersonImage()

        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mTaxAmountLABEL.text = "TAX (Amount)".localizedString
        mTaxPercentLABEL.text = "TAX (%)".localizedString
        mTaxSubTotalLABEL.text = "Sub Total".localizedString
        mDiscountAmountLABEL.text = "Discount (Amount)".localizedString
        mDiscountPercentLABEL.text = "Discount (%)".localizedString
        mTaxShippingLABEL.text = "Shipping".localizedString
        mTaxLoyaltyPointLABEL.text = "Loyalty point".localizedString
        mTaxLabourLABEL.text = "Labour".localizedString
        mTaxTotalLABEL.text = "Total".localizedString
        mCheckOutBUTTON.setTitle("CHECK OUT".localizedString, for: .normal)
        mParkBUTTON.setTitle("PARK".localizedString, for: .normal)
        mHeadingLABEL.text = "POS".localizedString
        mNoteLABEL.text = "Note".localizedString
        mGrandTotalLABEL.text = "Grand Total".localizedString
 
        mTotalItems.text = "0 " + "Item".localizedString
        mSearchField.placeholder = "Search by SKU / Stock ID".localizedString
        mNotes.placeholder = "EX. Urgent Order".localizedString
        
        
        
        if UserDefaults.standard.string(forKey: "cRemark") != nil {
            self.mNotes.text = "\(UserDefaults.standard.string(forKey: "cRemark") ?? "")"
        }
        
        mCustomerId  = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""
        if mCustomerId == "" {
            mOpenCustomerSheet()
        }else{
            if let clearCart = UserDefaults.standard.string(forKey: "mClearCart"),
               clearCart == "mClearCart" {

                UserDefaults.standard.setValue("", forKey: "mClearCart")
                mClearCart()
                self.mCheckAddresse()
                self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")

            } else {

                self.mCheckAddresse()
                self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
                mFetchCartItems()
            }
//            if(UserDefaults.standard.value(forKey: "mClearCart") ?? "$" == "mClearCart"){
//                UserDefaults.standard.setValue("", forKey: "mClearCart")
//                mClearCart()
//                self.mCheckAddresse()
//                self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
//            }
//            else {
//                self.mCheckAddresse()
//                self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
//                mFetchCartItems()
//            }
            
            
        }
        
        let mParams = ["query":"{stones{id name}colors{id name}metals{id name}shapes{id name}claritys{id name}cuts{id name}sizes{id name}settingType{id name}stonecolors{id name}}"]
        AF.request(mGrapQlUrl, method:.post,parameters: mParams, encoding:JSONEncoding.default, headers: sGisHeaders).responseJSON
        {response in
     
            if(response.error != nil) {
                UserDefaults.standard.set(nil, forKey: "GRAPHQL")
            }else{
                if let jsonData = response.data {
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let jsonResult = json as? NSDictionary {
                        UserDefaults.standard.set(jsonResult, forKey: "GRAPHQL")
                    }
                }
            }
        }
        
        
        AF.request(mGetShapes, method:.post,parameters: nil, headers: sGisHeaders).responseJSON { response in

            if(response.error != nil) {
                UserDefaults.standard.set(nil, forKey: "SHAPES")

            }else{
                if let jsonData = response.data {
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let jsonResult = json as? NSDictionary {
                        
                        UserDefaults.standard.set(jsonResult, forKey: "SHAPES")
                    }
                }
            }
        }
        
        let isPark = UserDefaults.standard.bool(forKey: "isPark")
        if isPark {
            self.mParkButtonView.isHidden = false
            mGetParkStatus()
        }else{
            self.mAvailableParkView.isHidden = true
            self.mParkButtonView.isHidden = true
        }
   
    }
    
    func mGetParkStatus(){
        print("mGetParkStatus ")
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mGetData(url: mGetPark,headers: sGisHeaders,  params: ["":""]) { response , status in
                if status {
                    print("mGetParkStatus response = ",response)
                    if let mData = response.value(forKey: "data") as? NSArray {
                        print("mGetParkStatus mData = ",mData)
                        
                        self.mParkedStockIds.removeAll()

                        for item in mData {

                            guard let park = item as? NSDictionary else { continue }

                            if let status = park["status"] as? NSDictionary,
                               "\(status["is_park"] ?? "0")" == "1",
                               let cart = park["cart"] as? NSArray {

                                for obj in cart {

                                    if let product = obj as? NSDictionary {

                                        let stockId = "\(product["stock_id"] ?? "")"

                                        self.mParkedStockIds.insert(stockId)

                                    }

                                }

                            }

                        }
                        
                        UserDefaults.standard.set(
                            Array(self.mParkedStockIds),
                            forKey: "ParkedStockIds"
                        )

                        print("DEBUG_PARKED_STOCK =", self.mParkedStockIds)
//                        self.calculateItemsWithAmount()
                        if mData.count > 0 {
                            self.mAvailableParkView.isHidden = false
                            self.mParkCount.text = "\(mData.count)"
                        }else{
                            self.mAvailableParkView.isHidden = true

                        }
                    }
                }else{
                    self.mAvailableParkView.isHidden = true

                }
        }
    }
//    func mGetSearchItems(id: String) {
//    func mGetSearchItems(id: String, locationId: String) {
    func mGetSearchItems(
        id: String,
        locationId: String,
        type: String
    ) {
        var mParams = [String : Any]()
        

            mParams = ["product_id":[id], "customer_id":mCustomerId, "sales_person_id":self.mSalesPersonId, "type":"inventory", "order_type":"pos_order"]
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
//        let stockId = "\(product["stock_id"] ?? "")"
//        if mParkedStockIds.contains(stockId) {
//
//            CommonClass.showSnackBar(message: "This stock is already parked")
//            return
//
//        }
        
        CommonClass.showFullLoader(view: self.view)
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        mGetData(url: mAddCustomProduct,headers: sGisHeaders,  params: mParams) { response , status in
//            CommonClass.stopLoader()
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    
                    self.mFetchCartItems()

                }else{
                    CommonClass.stopLoader()
                    self.tabBarController?.tabBar.isUserInteractionEnabled = true
                }
            }
            else{
                CommonClass.stopLoader()
                self.tabBarController?.tabBar.isUserInteractionEnabled = true
            }
    }

    }
    
    @IBAction func mSearchnow(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        if let mCommonSearch = storyBoard.instantiateViewController(withIdentifier: "CommonSearch") as? CommonSearch {
            mCommonSearch.modalPresentationStyle = .overFullScreen
            mCommonSearch.delegate = self
            mCommonSearch.mType = "inventory"
            mCommonSearch.mFrom = "pos"
            
            mCommonSearch.transitioningDelegate = self
            self.present(mCommonSearch,animated: false)
        }
    }
    
    @IBAction func mSearchCart(_ sender: Any) {
                
           
    }
    
    
    @IBAction func mOpenCustomer(_ sender: Any) {
      
         mOpenCustomerSheet()
    }
    
    
    @IBAction func mOpenAddressPicker(_ sender: Any) {
        mOpenAddressPicker()
    }
    
    private func restoreLinkedCartStatus(cartIds: [String]) {

        let params: [String: Any] = [

            "cart_id": cartIds

        ]

        print("========== RESTORE LINKED CART ==========")
        print("restore cartIds =", cartIds)
        print(params)

        CommonClass.showFullLoader(view: self.view)

        mGetData(

            url: mRestoreLinkedCartStatus,

            headers: sGisHeaders,

            params: params

        ) { response, status in

            CommonClass.stopLoader()

            print("========== RESTORE RESPONSE ==========")
            print(response)

            if status,
               "\(response["code"] ?? "")" == "200" {

//                self.dismiss(animated: true)
//
//                self.delegate?.mGetInventoryItems(
//                    items: self.mProductId
//                )
//                UserDefaults.standard.set("0", forKey: "reserve_show_popup")
                UserDefaults.standard.removeObject(forKey: "reserve_show_popup")
                UserDefaults.standard.removeObject(forKey: "reserve_linked_cart_id")
                UserDefaults.standard.removeObject(forKey: "reserve_linked_order_type")
                UserDefaults.standard.removeObject(forKey: "reserve_can_create_new_cart")
                LinkedCartContextStore.shared.clear(
                    orderType: "reserve",
                    customerId: self.mCustomerId
                )

                LinkedCartContextStore.shared.clear(
                    orderType: "pos_order",
                    customerId: self.mCustomerId
                )

                self.navigationController?.popViewController(animated: true)
                

            } else {

                CommonClass.showSnackBar(

                    message: "\(response["message"] ?? "Something went wrong")"

                )
            }
        }
    }
    
    
    private func sshowReserveConfirmation(cartIds: [String]) {

        DispatchQueue.main.async { [weak self] in

            guard let self = self else { return }

            // หา Key Window
            guard let windowScene = self.view.window?.windowScene ??
                    UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first(where: { $0.activationState == .foregroundActive })
            else {
                print("❌ Cannot find window scene")
                return
            }

            guard let window = windowScene.windows.first(where: {
                $0.isKeyWindow
            }) else {
                print("❌ Cannot find key window")
                return
            }

            // ป้องกัน popup ซ้ำ
            if window.viewWithTag(98765) != nil {
                return
            }

            // =========================================================
            // OVERLAY
            // =========================================================

            let overlay = UIView()
            overlay.tag = 98765
            overlay.translatesAutoresizingMaskIntoConstraints = false
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.55)
            overlay.alpha = 0

            window.addSubview(overlay)

            NSLayoutConstraint.activate([
                overlay.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                overlay.topAnchor.constraint(equalTo: window.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])

            // =========================================================
            // POPUP
            // =========================================================

            let popup = UIView()
            popup.translatesAutoresizingMaskIntoConstraints = false
            popup.backgroundColor = .white
            popup.layer.cornerRadius = 8
            popup.clipsToBounds = true

            overlay.addSubview(popup)

            // =========================================================
            // TITLE
            // =========================================================
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false

            label.text = "!"
            label.textAlignment = .center
            label.font = .boldSystemFont(ofSize: 24)

            let warningColor = UIColor(
                red: 0.93,
                green: 0.63,
                blue: 0.13,
                alpha: 1
            )

            label.textColor = warningColor
            label.layer.borderColor = warningColor.cgColor
            label.layer.borderWidth = 2
            label.layer.cornerRadius = 20
            label.clipsToBounds = true

            popup.addSubview(label)
//            let titleLabel = UILabel()
//            titleLabel.translatesAutoresizingMaskIntoConstraints = false
//            titleLabel.text = ""
//            titleLabel.textAlignment = .center
//            titleLabel.textColor = UIColor(
//                red: 0.08,
//                green: 0.12,
//                blue: 0.20,
//                alpha: 1
//            )
//            titleLabel.font = UIFont.systemFont(
//                ofSize: 14,
//                weight: .medium
//            )

            popup.addSubview(label)
            
            popup.layer.cornerRadius = 14
            popup.layer.shadowColor = UIColor.black.cgColor
            popup.layer.shadowOpacity = 0.18
            popup.layer.shadowRadius = 20
            popup.layer.shadowOffset = CGSize(width: 0, height: 10)
            popup.clipsToBounds = false

            // =========================================================
            // MESSAGE
            // =========================================================

            let messageLabel = UILabel()
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.text =
            "Do you want to quit this page?"

            messageLabel.numberOfLines = 0
            messageLabel.font = .systemFont(ofSize: 17, weight: .medium)
            messageLabel.textAlignment = .center
            
            messageLabel.textColor = UIColor(
                red: 0.38,
                green: 0.42,
                blue: 0.50,
                alpha: 1
            )
            messageLabel.font = UIFont.systemFont(
                ofSize: 18,
                weight: .regular
            )

            popup.addSubview(messageLabel)

            // =========================================================
            // CANCEL BUTTON
            // =========================================================

            let cancelButton = UIButton(type: .system)
            cancelButton.translatesAutoresizingMaskIntoConstraints = false

            cancelButton.setTitle("No", for: .normal)
            cancelButton.setTitleColor(
                UIColor(
                    red: 0.15,
                    green: 0.20,
                    blue: 0.28,
                    alpha: 1
                ),
                for: .normal
            )

            cancelButton.titleLabel?.font =
                UIFont.systemFont(ofSize: 14)

            cancelButton.backgroundColor = .white
            cancelButton.layer.cornerRadius = 7
            cancelButton.layer.borderWidth = 1
            cancelButton.layer.borderColor =
                UIColor(
                    red: 0.78,
                    green: 0.81,
                    blue: 0.87,
                    alpha: 1
                ).cgColor

            popup.addSubview(cancelButton)

            // =========================================================
            // CLEAR BUTTON
            // =========================================================

            let clearButton = UIButton(type: .system)
            clearButton.translatesAutoresizingMaskIntoConstraints = false

            clearButton.setTitle("Quit", for: .normal)
            clearButton.setTitleColor(.white, for: .normal)

            clearButton.titleLabel?.font =
                UIFont.systemFont(
                    ofSize: 14,
                    weight: .medium
                )

            clearButton.backgroundColor = UIColor(
                red: 1.0,
                green: 0.31,
                blue: 0.34,
                alpha: 1
            )

            clearButton.layer.cornerRadius = 7

            popup.addSubview(clearButton)

            // =========================================================
            // CONSTRAINTS
            // =========================================================

            NSLayoutConstraint.activate([

                popup.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
                popup.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
                popup.widthAnchor.constraint(equalToConstant: 330),
                popup.heightAnchor.constraint(equalToConstant: 210),

                //------------------------------------------------
                // Warning Icon
                //------------------------------------------------

                label.topAnchor.constraint(equalTo: popup.topAnchor, constant: 22),
                label.centerXAnchor.constraint(equalTo: popup.centerXAnchor),
                label.widthAnchor.constraint(equalToConstant: 40),
                label.heightAnchor.constraint(equalToConstant: 40),

                //------------------------------------------------
                // Message
                //------------------------------------------------

                messageLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 18),
                messageLabel.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: 20),
                messageLabel.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -20),

                //------------------------------------------------
                // No Button
                //------------------------------------------------

                cancelButton.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: 20),
                cancelButton.bottomAnchor.constraint(equalTo: popup.bottomAnchor, constant: -22),
                cancelButton.widthAnchor.constraint(equalToConstant: 136),
                cancelButton.heightAnchor.constraint(equalToConstant: 44),

                //------------------------------------------------
                // Quit Button
                //------------------------------------------------

                clearButton.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -20),
                clearButton.bottomAnchor.constraint(equalTo: popup.bottomAnchor, constant: -22),
                clearButton.widthAnchor.constraint(equalToConstant: 136),
                clearButton.heightAnchor.constraint(equalToConstant: 44)
            ])

            // =========================================================
            // CANCEL
            // =========================================================

            cancelButton.addAction(
                UIAction { _ in

                    UIView.animate(
                        withDuration: 0.15,
                        animations: {
                            overlay.alpha = 0
                        },
                        completion: { _ in
                            overlay.removeFromSuperview()
                        }
                    )
                },
                for: .touchUpInside
            )

            // =========================================================
            // CLEAR
            // =========================================================

            clearButton.addAction(
                UIAction { [weak self] _ in

                    guard let self = self else {
                        overlay.removeFromSuperview()
                        return
                    }

                    UIView.animate(
                        withDuration: 0.15,
                        animations: {
                            overlay.alpha = 0
                        },
                        completion: { _ in

                            overlay.removeFromSuperview()

//                            self.clearStockTakeResults()
                            self.restoreLinkedCartStatus(cartIds: cartIds)
                            self.navigationController?.popViewController(animated: true)
                        }
                    )
                },
                for: .touchUpInside
            )

            // =========================================================
            // SHOW
            // =========================================================

            window.bringSubviewToFront(overlay)

            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .curveEaseOut
            ) {
                overlay.alpha = 1
            }
        }
    }
    
    private func showReserveConfirmation(cartIds: [String]) {

        DispatchQueue.main.async {

            let alert = UIAlertController(

                title: nil,

                message: "Do you want to quit the page or proceed?",

                preferredStyle: .alert
            )

            //--------------------------------------------------

            alert.addAction(

                UIAlertAction(

                    title: "Yes",

                    style: .default

                ) { _ in

                    self.restoreLinkedCartStatus(cartIds: cartIds)

                }
            )

            //--------------------------------------------------
            alert.addAction(
                UIAlertAction(
                    title: "No",
                    style: .cancel
                ) { _ in

//                    self.navigationController?.popViewController(animated: true)

                }
            )

            //--------------------------------------------------

            self.present(alert, animated: true)
        }
    }
    
    @IBAction func mBack(_ sender: Any) {

        let showPopup =
            UserDefaults.standard.string(
                forKey: "reserve_show_popup"
            ) ?? "0"

        print("mBack showPopup = \(showPopup)")
//        //=========== mockInventory ==========//
//        let mockInventory = NSMutableDictionary()
//
//        mockInventory["linked_cart_id"] = "6a8d666d54c728d45a778961"
//        mockInventory["linked_order_id"] = "TEST_ORDER"
//        mockInventory["existing_cart_status"] = "linked"
//        mockInventory["linked_order_type"] = "reserve"
//        mockInventory["can_create_new_cart"] = false
//        let context = LinkedCartContext(inventoryItem: mockInventory)
//        LinkedCartContextStore.shared.save(
//            LinkedCartContext(inventoryItem: mockInventory),
//            orderType: "pos_order",
//            customerId: mCustomerId
//        )
//        linkedCartContext = LinkedCartContextStore.shared.context(
//            orderType: "pos_order",
//            customerId: mCustomerId
//        )
        // Existing Reserve flow should normally be stored under "reserve".
        // Keep a fallback to the POS cart key because older/previous flows
        // may already have stored the same linked cart there.
        linkedCartContext = LinkedCartContextStore.shared.context(
            orderType: "reserve",
            customerId: mCustomerId
        )

        if linkedCartContext?.linkedCartId.isEmpty ?? true {
            print("⚠️ reserve context has no linkedCartId, fallback to pos_order")

            linkedCartContext = LinkedCartContextStore.shared.context(
                orderType: "pos_order",
                customerId: mCustomerId
            )
        }

        // The linked cart id can come from the context store, but that store
        // is not guaranteed to be readable after the Cart Details screen has
        // been restored. Keep the id saved by CommonInventory as a fallback.
        let storedLinkedCartId =
            UserDefaults.standard.string(forKey: "reserve_linked_cart_id") ?? ""

        let storedLinkedOrderType =
            UserDefaults.standard.string(forKey: "reserve_linked_order_type") ?? ""
        let storedCanCreateNewCart = UserDefaults.standard.object(
            forKey: "reserve_can_create_new_cart"
        ) as? Bool

        let resolvedLinkedCartId: String = {
            // Restore the original Reserve cart supplied by Inventory. The
            // addItemToCart response may contain a newly-created POS cart.
            if let context = linkedCartContext, !context.linkedCartId.isEmpty {
                return context.linkedCartId.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return storedLinkedCartId.trimmingCharacters(in: .whitespacesAndNewlines)
        }()

        print("mBack context.linkedCartId = \(String(describing: linkedCartContext?.linkedCartId))")
        print("mBack storedLinkedCartId = \(storedLinkedCartId)")
        print("mBack resolvedLinkedCartId = \(resolvedLinkedCartId)")

        let linkedOrderType = (
            linkedCartContext?.linkedOrderType.isEmpty == false
                ? linkedCartContext?.linkedOrderType
                : storedLinkedOrderType
        ) ?? ""
        let isExistingReserveCart =
            (linkedCartContext?.canCreateNewCart == false || storedCanCreateNewCart == false) &&
            linkedOrderType.lowercased() == "reserve"
        let shouldShowLeaveConfirmation =
            !resolvedLinkedCartId.isEmpty && (showPopup == "1" || isExistingReserveCart)

        if shouldShowLeaveConfirmation {
            // IMPORTANT: Do not pop or clear the cart here.
            // The popup must be shown first.
            sshowReserveConfirmation(
                cartIds: [resolvedLinkedCartId]
            )
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func mCatalog(_ sender: Any) {
        if mCustomerId == "" {
            CommonClass.showSnackBar(message: "Please choose customer first!")
            mOpenCustomerSheet()
            return
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let mFilters = storyBoard.instantiateViewController(withIdentifier: "CommonCatalog") as? CommonCatalog {
            mFilters.mOrderType = "pos_order"
            
            print("PosCart.swift withIdentifier: CommonCatalog")
            mFilters.modalPresentationStyle = .overFullScreen
            mFilters.transitioningDelegate = self
            self.present(mFilters,animated: true)
        }
    }
    
//    func mGetInventoryItems(items: [String]) {
//
//        mFetchCartItems()
//    }
//
//
//
//    func mFetchCartItems(){
//
//        let mParams = [ "customer_id":mCustomerId ] as [String : Any]
//
//
//        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
//        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
//
//        mGetData(url: mFetchCustomProduct, headers:sGisHeaders ,params: mParams) { response , status in
//            CommonClass.stopLoader()
//            if status {
//            if "\(response.value(forKey: "code") ?? "")" == "200" {
//                if let mData = response.value(forKey: "data") as? NSArray, mData.count > 0 {
//                    print("DEBUG_CART_RESPONSE PosCart.swift = \(mData)")
//                        self.mCartDataMaster = mData
//                        self.mCartData = NSMutableArray(array: mData)
//                        self.mCartTable.delegate = self
//                        self.mCartTable.dataSource = self
//                        self.mQuantityData = [Int]()
//                        self.mCartAmount = [Double]()
//
//                        self.mCartTable.reloadData()
//                        for i in self.mCartData {
//                            if let mData = i as? NSDictionary {
//                                self.mQuantityData.append(Int("\(mData.value(forKey: "Qty") ?? "0")") ?? 0)
//                                self.mCartAmount.append(Double("\(mData.value(forKey: "price") ?? "0")") ?? 0.0)
//                            }
//                        }
//
//                }
//            }else{
//
//            }
//        }
//    }
//    }
    
    func mGetInventoryItems(items: [String]) {

        print("========== DELEGATE CALLBACK ==========")
        print("mGetInventoryItems CALLED")
        print("ITEMS =", items)
        print("CUSTOMER ID =", mCustomerId)
        print("=======================================")

        self.linkedCartContext = LinkedCartContextStore.shared.context(
            orderType: "pos_order",
            customerId: mCustomerId
        )
        print("READ LINKED CONTEXT")
        print("orderType = pos_order")
        print("customerId =", mCustomerId)
        print("context =", self.linkedCartContext as Any)
        mFetchCartItems()
    }


    func mFetchCartItems() {

        let mParams = [
            "customer_id": mCustomerId
        ] as [String : Any]

        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")

        print("========== FETCH CART REQUEST ==========")
        print("URL =", mFetchCustomProduct)
        print("PARAMS =", mParams)
        print("CUSTOMER ID =", mCustomerId)
        print("========================================")
        
        mGetData(
            url: mFetchCustomProduct,
            headers: sGisHeaders,
            params: mParams
        ) { response, status in

//            CommonClass.stopLoader()
            DispatchQueue.main.async {
                self.mCartTable.reloadData()
                self.calculateItemsWithAmount()
                CommonClass.stopLoader()
                self.tabBarController?.tabBar.isUserInteractionEnabled = true
            }

            print("========== FETCH CART RESPONSE ==========")
            print("STATUS =", status)
            print("FULL RESPONSE =", response)
            print("=========================================")

            if status {

                let code = "\(response.value(forKey: "code") ?? "")"

                print("FETCH CART CODE =", code)

                if code == "200" {

                    if let mData = response.value(forKey: "data") as? NSArray {

                        print("CART ITEM COUNT =", mData.count)
                        print("CART DATA =", mData)
                        
                        

                        if mData.count > 0 {

                            self.mCartDataMaster = mData
                            self.mCartData = NSMutableArray(array: mData)

                            self.mCartTable.delegate = self
                            self.mCartTable.dataSource = self

                            self.mQuantityData = [Int]()
                            self.mCartAmount = [Double]()

                            for item in self.mCartData {

                                if let data = item as? NSDictionary {

                                    print("price =", data["price"] ?? "")
                                    print("cart_price =", data["cart_price"] ?? "")
                                    print("discount =", data["discount"] ?? "")
                                    print("discount_amount =", data["discount_amount"] ?? "")
                                    print("discount_price =", data["discount_price"] ?? "")
                                    print("final_price =", data["final_price"] ?? "")
                                    print("delivery_date", data["delivery_date"] ?? "")
                                    
                                    let sku =
                                        "\(data.value(forKey: "SKU") ?? data.value(forKey: "sku") ?? "")"

                                    let productId =
                                        "\(data.value(forKey: "product_id") ?? "")"

                                    let poProductId =
                                        "\(data.value(forKey: "po_product_id") ?? "")"

                                    let qty =
                                        Int("\(data.value(forKey: "Qty") ?? "0")") ?? 0

//                                    let price =
//                                        Double("\(data.value(forKey: "price") ?? "0")") ?? 0.0
                                    
                                    let price =
                                        Double("\(data.value(forKey: "cart_price") ?? "0")") ?? 0.0

                                    print("---------- CART ITEM ----------")
                                    print("SKU =", sku)
                                    print("product_id =", productId)
                                    print("po_product_id =", poProductId)
                                    print("Qty =", qty)
                                    print("price =", price)
                                    print("-------------------------------")
                                    let rawPrice = data.value(forKey: "cart_price")

                                    print("RAW PRICE =", rawPrice ?? "nil")
                                    print("RAW TYPE =", type(of: rawPrice))

                                    let pricee =
                                        Double("\(rawPrice ?? "0")") ?? 0.0
                                    print("-------------------------------")
                                    print("PARSED PRICE =", pricee)
                                    self.mQuantityData.append(qty)
                                    self.mCartAmount.append(price)
                                }
                            }

                            DispatchQueue.main.async {
                                self.mCartTable.reloadData()
                                self.calculateItemsWithAmount()
                            }

                        } else {

                            print("🚨 FETCH CART SUCCESS BUT DATA IS EMPTY")
                        }

                    } else {

                        print("🚨 FETCH CART DATA IS NOT NSArray")
                        print("DATA TYPE =", type(of: response.value(forKey: "data")))
                    }

                } else {

                    print("🚨 FETCH CART CODE IS NOT 200")
                }

            } else {

                print("🚨 FETCH CART REQUEST FAILED")
            }
        }
    }
    
    func uniqueElementsFrom(array:[String]) -> [String] {
        
        var set = Set<String>()
        
        let result = array.filter {
            guard !set.contains($0)  else {
                return false
            }
            set.insert($0)
            return true
        }
        
        return result
    }
    @IBAction func mInventory(_ sender: Any) {

        if mCustomerId == "" {
            CommonClass.showSnackBar(
                message: "Please choose customer first!"
            )
            mOpenCustomerSheet()
            return
        }

        let storyBoard = UIStoryboard(
            name: "common",
            bundle: nil
        )

        if let mInv = storyBoard.instantiateViewController(
            withIdentifier: "CommonInventory"
        ) as? CommonInventory {

            mInv.modalPresentationStyle = .overFullScreen

            mInv.delegate = self
            mInv.mCustomerId = mCustomerId

            // สำคัญ
            mInv.mOrderType = "pos_order"

            mInv.transitioningDelegate = self

            self.present(
                mInv,
                animated: true
            )
        }
    }
    
    @IBAction func mCustomer(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerSearch") as? CustomerSearch {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    func mCreateNewCustomer() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let mCreateCustomer = storyBoard.instantiateViewController(withIdentifier: "CreateCustomer") as? CreateCustomer {
            self.navigationController?.pushViewController(mCreateCustomer, animated:true)
        }
    }
    func mGetCustomerData(data: NSMutableDictionary) {
       
        UserDefaults.standard.set(data.value(forKey: "id") ?? "", forKey: "DEFAULTCUSTOMER")
        UserDefaults.standard.set(data.value(forKey: "profile") ?? "", forKey: "DEFAULTCUSTOMERPICTURE")
        UserDefaults.standard.set(data.value(forKey: "name") ?? "", forKey: "DEFAULTCUSTOMERNAME")

        self.mCustomerId = data.value(forKey: "id") as? String ?? ""
        self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")
        
        UserDefaults.standard.setValue(nil, forKey: "CustomerBillingAddressUDID")
        UserDefaults.standard.setValue(nil, forKey: "CustomerShippingAddressUDID")
        
        if let haveAddresses = data.value(forKey: "haveAddresses") as? Bool, haveAddresses {
            mAddressPickerIcon.image = UIImage(named: "address_pick_ic_green")
            mAddressAlertIcon.isHidden = true
        } else {
            mAddressPickerIcon.image = UIImage(named: "address_pick_ic_green")
            mAddressAlertIcon.isHidden = false
        }
        
        mFetchCartItems()

    }
    
    func mCheckAddresse() {
        
        guard Reachability.isConnectedToNetwork() == true else {
            return
        }
        
        let params = ["id": mCustomerId] as [String : Any]
        
        AF.request(mCheckAddress, method:.post,parameters: params,encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
            
            guard let jsonData = response.data else {
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                   let code = json["code"] as? Int {
                    switch code {
                    case 200:
                        if let haveAddress = json["AddressExists"] as? Bool, haveAddress {
                            self.mAddressPickerIcon.image = UIImage(named: "address_pick_ic_green")
                            self.mAddressAlertIcon.isHidden = true
                        } else {
                            self.mAddressPickerIcon.image = UIImage(named: "address_pick_ic_green")
                            self.mAddressAlertIcon.isHidden = false
                        }
                    case 403:
                        CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                    default:
                        break
                    }
                }
            } catch {
            }
        }
        
    }
    
    func mOpenCustomerSheet(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
            home.delegate = self
            home.modalPresentationStyle = .automatic
            home.transitioningDelegate = self
            self.present(home,animated: true)
        }
    }
    
    func mOpenAddressPicker(){
        if !mCustomerId.isEmpty {
            let storyBoard: UIStoryboard = UIStoryboard(name: "AddressPicker", bundle: nil)
            if let addressPicker = storyBoard.instantiateViewController(withIdentifier: "AddressPicker") as? AddressPicker {
                addressPicker.delegate = self
                addressPicker.mCustomerId = mCustomerId
                self.navigationController?.pushViewController(addressPicker, animated: true)
            }
        }
    }
    
    func mGetAddress(data: NSMutableDictionary) {
        
    }
    
    @IBAction func mDepositeDropdown(_ sender: Any) {
        let dropdown = DropDown()
               dropdown.anchorView = self.mDepositePercent
               dropdown.direction = .any
               dropdown.bottomOffset = CGPoint(x: 0, y: self.mDepositePercent.frame.size.height)
               dropdown.width = 120
               dropdown.dataSource = mDepositPercentData
               dropdown.selectionAction = {
               [unowned self](index:Int, item: String) in
               self.mDepositePercent.text  = item
                self.mDepositPercents = self.mDepositPercentValue[index]
                   if self.mCartData.count > 0{
                   self.calculateItemsWithAmount()
                   }
                   
              }
               dropdown.show()
    }
    
    
    @IBAction func mCheckOut(_ sender: UIButton) {
            sender.showAnimation{
                
                if self.mCartData.count == 0 {
                    CommonClass.showSnackBar(message: "No items in cart!")
                    return
                }

                if Double(self.mTotalDepositAmounts) ?? 0.00 == 0.0 {
                    CommonClass.showSnackBar(message: "Please fill valid amount!")
                    return
                }
                
                guard self.mAddressAlertIcon.isHidden else {
                    CommonClass.showSnackBar(message: "Add Billing and Shipping address")
                    return
                }
                
                // ✨ แนบ Quotation ID ลง UserDefaults ✨
                // ใน PosCart บางทีไม่มีตัวแปร mQuotationId ให้ส่งค่าว่างเพื่อเคลียร์ของเก่า
                UserDefaults.standard.setValue("", forKey: "quotationId")
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
                guard let mCheckOut = storyBoard.instantiateViewController(withIdentifier: "POSCheckout") as? POSCheckout else { return }
                mCheckOut.mTotalP = self.mTotalDepositAmounts
                
                // ... (โค้ดเดิมด้านล่าง) ...
                mCheckOut.mSubTotalP = String(format: "%.2f", self.mCalculatedSubTotal)
                mCheckOut.mTaxAm = String(format: "%.2f", self.mCalculatedTaxAmount)
//                mCheckOut.mSubTotalP = ""
                mCheckOut.mTaxP = ""
//                mCheckOut.mTaxAm = ""
                mCheckOut.mStoreCurrency =  self.mCurrency
                mCheckOut.mOrderType = "pos_order"
                mCheckOut.mNote = self.mNotes.text ?? ""
                print("DEBUG_cRemark = \(UserDefaults.standard.string(forKey: "cRemark") ?? "nil")")
                print("DEBUG_mNotes = \(self.mNotes.text ?? "nil")")
                mCheckOut.mRemark = UserDefaults.standard.string(forKey: "cRemark") ?? ""
//                mCheckOut.mRemark = self.mNotes.text ?? ""
                mCheckOut.mTotalOutstandingAm = self.mOutStandingAmounts
                mCheckOut.mCurrencySymbol = self.mCurrency
//                mCheckOut.mCartTotalAmount = self.mGrandTotalCart
                print("mGrandTotalCart =", self.mGrandTotalCart)
                print("mTotalDepositAmounts =", self.mTotalDepositAmounts)
                mCheckOut.mCartTotalAmount = self.mTotalDepositAmounts
//                mCheckOut.mCartTotalAmount = self.mGrandTotalCart

                mCheckOut.mDepositPercents = self.mDepositPercents
                mCheckOut.mTotalWithDiscount =  self.mTotalDepositAmounts
                
                mCheckOut.mLabourPoints = Double(self.mTaxLabourCharge.text ?? "") ?? 0.00
                mCheckOut.mShippingPoints = Double(self.mTaxShippingCharge.text ?? "") ?? 0.00
                mCheckOut.mLoyaltyPoints = Double(self.mTaxLoyaltyPoint.text ?? "") ?? 0.00
                mCheckOut.mTaxAmount = Double(self.mTaxAmount.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
                mCheckOut.mTaxAmountInt = Double(self.mTaxAmount.text?.replacingOccurrences(of: ",", with: "") ?? "") ?? 0.0
                mCheckOut.mTaxInPercent = Double(self.mTaxValue.text ?? "") ?? 0.0
                mCheckOut.mTaxDiscountAmount = Double(self.mTaxDiscountAmounts.text ?? "") ?? 0.0
                mCheckOut.mTaxDiscountPercent = Double(self.mTaxDiscountPercents.text ?? "") ?? 0.0
                
                mCheckOut.mTaxTypeIE = UserDefaults.standard.string(forKey: "taxType") ?? ""
                mCheckOut.mCustomerId = self.mCustomerId
                mCheckOut.mCartTableData =  self.mCartData
                mCheckOut.applyLinkedCartContext(self.linkedCartContext)
                
                self.navigationController?.pushViewController( mCheckOut, animated:true)
            }
        }

    func mUpdateCartProduct(newStockId: String,qty: Int , index: Int){
        
        guard let mData = mCartData[index] as? NSDictionary,
        let cartId = mData.value(forKey: "custom_cart_id") as? String,
        let oldStockId = mData.value(forKey: "stock_id") as? String else { return }
        
        let mParams = [ "cart_id": cartId, "old_stockId": oldStockId, "new_stockId": newStockId, "qty": qty ] as [String : Any]
    
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mGetData(url: mStockIdManage, headers:sGisHeaders ,params: mParams) { response , status in
            CommonClass.stopLoader()
            if status {
            if "\(response.value(forKey: "code") ?? "")" == "200" {
                self.mFetchCartItems()
            }else{
                CommonClass.showSnackBar(message: "Oop! Something went wrong!")
            }
        }
        }
    }
    
    @IBAction func mPickStockId(_ sender: UIButton) {
        guard let mCartDatas = mCartData[sender.tag] as? NSDictionary else { return }
        if let mCartItems = mCartDatas.value(forKey: "stock_id_options") as? NSArray {
            if mCartItems.count < 1 {
                return
            }
            
            var mStockIds = [String]()
            for i in mCartItems {
                if let data = i as? NSDictionary {
                    mStockIds.append("\(data.value(forKey: "value") ?? "")")
                }
            }

            let dropdown = DropDown()
            dropdown.anchorView = sender
            dropdown.direction = .any
            dropdown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)
            dropdown.width = 200
            dropdown.dataSource = mStockIds
            dropdown.selectionAction = {
                [unowned self](index:Int, item: String) in
                let cell1 = mCartTable.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? CustomCartItems
               
                mUpdateCartProduct(newStockId: item, qty: mCartDatas.value(forKey: "Qty") as? Int ?? 0 , index: sender.tag)
                cell1?.mStockId.text = item
                
                guard let mInvData = self.mCartData[sender.tag] as? NSDictionary,
                      let mData = mInvData.mutableCopy() as? NSMutableDictionary else { return }

                mData.setValue(item, forKey: "stock_id")

                if let mServiceLabourStatus =  mInvData.value(forKey: "Service_labour_exsist") as? Bool {
                    mData.setValue(mServiceLabourStatus, forKey: "Service_labour_exsist")
                    if mServiceLabourStatus, let mServiceLabour = mInvData.value(forKey: "Service_labour") as? NSDictionary {
                        mData.setValue(mServiceLabour, forKey: "Service_labour")
                    }
                } else {
                    mData.setValue(false, forKey: "Service_labour_exsist")
                }

                if mInvData.value(forKey: "stock_id_options") == nil {
                    mData.setValue([], forKey: "stock_id_options")
                }

                self.mCartData.removeObject(at: sender.tag)
                self.mCartData.insert(mData, at: sender.tag)
                self.calculateItemsWithAmount()
            }
            dropdown.show()
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mCartData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCartItems") as? CustomCartItems else {
            return UITableViewCell()
        }
        
        cell.mSNo.text = "\(indexPath.row + 1)"
        cell.mOpenProductDetailsButton.tag = indexPath.row
        cell.mRemoveButton.tag = indexPath.row
        
        cell.mPickStockId.tag = indexPath.row
        cell.mProductPrice.tag = indexPath.row
        cell.mPlusButton.tag = indexPath.row
        cell.mMinusButton.tag = indexPath.row
        cell.mDiscountAmount.tag = indexPath.row
        cell.mDiscountPercent.tag = indexPath.row
        cell.mEditServiceLabourButton.tag = indexPath.row
        cell.mShowServiceLabourButton.tag = indexPath.row

        guard let mData = mCartData[indexPath.row] as? NSDictionary else { return UITableViewCell() }
        
        let isServiceLabour = UserDefaults.standard.bool(forKey: "isServiceLabour")
        if isServiceLabour {
            if let mServiceLabourStatus =  mData.value(forKey: "Service_labour_exsist") as? Bool {
                mServiceLabourStatus ? (cell.mEditServiceLabourIcon.tintColor = UIColor(named:"themeColor")) : (cell.mEditServiceLabourIcon.tintColor = UIColor(named:"theme6A"))
                
                cell.mServiceLabourView.isHidden = false
                
                if mServiceLabourStatus {
                    
                    self.mTaxLabourCharge.isEnabled = false
                    if let mServiceLabour = mData.value(forKey: "Service_labour") as? NSDictionary {
                        if let mServiceItem = mServiceLabour.value(forKey: "service_laburelist") as? NSArray {
                            if mServiceItem.count > 0 {
                                cell.mServiceLabourCount.text = "Service Labour".localizedString + " (\(mServiceItem.count))"
                                var mAmounts = [Double]()
                                for i in mServiceItem {
                                    if let items = i as? NSDictionary {
                                        mAmounts.append(Double("\(items.value(forKey: "scrviceamount") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
                                    }
                                }
                                cell.mServiceLabourCharges.text = self.mCurrency + " " + String(format:"%.02f",locale:Locale.current,mAmounts.reduce(0, {$0 + $1}))
                            }else{
                                self.mTaxLabourCharge.isEnabled = true
                                cell.mServiceLabourCharges.text = self.mCurrency + " 0.00"
                                cell.mServiceLabourCount.text = "Service Labour".localizedString + " (0)"
                            }
                        }
                    }
                    
                }else{
                    cell.mServiceLabourCharges.text = self.mCurrency + " 0.00"
                    cell.mServiceLabourCount.text = "Service Labour".localizedString + " (0)"
                }
            }else{
                cell.mServiceLabourView.isHidden = true
                self.mTaxLabourCharge.isEnabled = true
            }
        } else {
            cell.mServiceLabourView.isHidden = true
        }
        
        cell.mCurrency.text = "\(mData.value(forKey: "currency") ?? "$")"
        self.mCurrency = "\(mData.value(forKey: "currency") ?? "$") "
 
        cell.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "")"
        cell.mDiscountAmount.text = "\(mData.value(forKey: "Discount_Amount") ?? "")"
        cell.mDiscountPercent.text = "\(mData.value(forKey: "discount_percent") ?? "")"
        cell.mProductName.text = "\(mData.value(forKey: "name") ?? "")"
        cell.mMetalColorSize.text = "\(mData.value(forKey: "color_name") ?? "") " + "\(mData.value(forKey: "metal_name") ?? "") " + "\(mData.value(forKey: "size_name") ?? "")"
        
        let priceValue = PriceHelper.unformatPrice(
            "\(mData.value(forKey: "price") ?? "0")"
        )

        let displayPrice = priceValue > 0
            ? priceValue
            : PriceHelper.unformatPrice(
                "\(mData.value(forKey: "cart_price") ?? "0")"
              )
        updateProductPrice(cell, price: displayPrice)
//        cell.mProductPrice.text = "\(mData.value(forKey: "price") ?? "")"
        
        cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
        
        cell.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
        cell.mProductImage.tag = indexPath.row
        cell.imageTapGesture(target: self, action: #selector(handleImageTap(_:)))
        
//        calculateItemsWithAmount()
        
        return cell
    }
    
    @objc func handleImageTap(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else {
            return
        }
        let index = imageView.tag
        if let mData = mCartData[index] as? NSDictionary {
            let productId = "\(mData.value(forKey: "id") ?? "")"
            let sku = "\(mData.value(forKey: "SKU") ?? "")"
       
            mOpenGlobalImageViewer(mProductIdForImage: productId, mSKUForImage: sku)
        }
    }
    
    func mOpenGlobalImageViewer(mProductIdForImage: String , mSKUForImage: String){
        if mProductIdForImage != "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
            if let mGlobalImageViewer = storyBoard.instantiateViewController(withIdentifier: "GlobalImageViewer") as? GlobalImageViewer {
                mGlobalImageViewer.modalPresentationStyle = .overFullScreen
                mGlobalImageViewer.mProductId = mProductIdForImage
                mGlobalImageViewer.mSKUName = mSKUForImage
                mGlobalImageViewer.transitioningDelegate = self
                self.present(mGlobalImageViewer,animated: false)
            }
        }
    }
    

    func mRemoveServiceLabour() {
        mFetchCartItems()
    }
    func mConfirmServiceLabour(data: NSDictionary) {
        mFetchCartItems()
    }
   
    
    @IBAction func mShowServiceLabour(_ sender: UIButton) {
        if let mData = self.mCartData[sender.tag] as? NSDictionary {
            
            if let mServiceData = mData.value(forKey: "Service_labour") as? NSDictionary {
                let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
                if let mSelectedServiceLabour = storyBoard.instantiateViewController(withIdentifier: "SelectedServiceLabour") as? SelectedServiceLabour {
                    mSelectedServiceLabour.modalPresentationStyle = .automatic
                    mSelectedServiceLabour.mProductData = mServiceData
                    mSelectedServiceLabour.transitioningDelegate = self
                    self.present(mSelectedServiceLabour,animated: true)
                }
            }
        }
    }

    @IBAction func mEditServiceLabour(_ sender: UIButton) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
        if let mCommonServiceLabour = storyBoard.instantiateViewController(withIdentifier: "CommonServiceLabour") as? CommonServiceLabour {
            mCommonServiceLabour.modalPresentationStyle = .overFullScreen
            mCommonServiceLabour.delegate = self
            mCommonServiceLabour.mProductData = self.mCartData[sender.tag] as? NSDictionary ?? NSDictionary()
            mCommonServiceLabour.transitioningDelegate = self
            self.present(mCommonServiceLabour,animated: true)
        }
    }
    
    @IBAction func mMinusButton(_ sender: UIButton) {
        let index = sender.tag
        guard let mInvData = mCartData[index] as? NSDictionary,
              let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems else {
            return
        }
        let mOrgData = mCartDataMaster[sender.tag] as? NSDictionary
        let mMinQty = 1
        var mCurrentQty = Int(cells.mQuantityUnit.text ?? "") ?? 0
        if mCurrentQty == mMinQty {
            return
        } else {
            mCurrentQty -= 1
            cells.mQuantityUnit.text = "\(mCurrentQty)"

            cells.mProductPrice.text = "\((Double("\(mInvData.value(forKey: "price") ?? "0")") ?? 0.0))"
        }

        guard let mData = mInvData.mutableCopy() as? NSMutableDictionary else { return }
        
        let finalQTY = Int(cells.mQuantityUnit.text ?? "") ?? 0
        let finalPrice = Double((cells.mProductPrice.text ?? "0").replace(string: ",", replacement: "")) ?? 0
        mData.setValue(finalQTY, forKey: "Qty")
        mData.setValue(finalPrice, forKey: "price")

        if let mServiceLabourStatus = mInvData.value(forKey: "Service_labour_exsist") as? Bool {
            mData.setValue(mServiceLabourStatus, forKey: "Service_labour_exsist")
            if mServiceLabourStatus, let mServiceLabour = mInvData.value(forKey: "Service_labour") as? NSDictionary {
                mData.setValue(mServiceLabour, forKey: "Service_labour")
            }
        } else {
            mData.setValue(false, forKey: "Service_labour_exsist")
        }

        if mInvData.value(forKey: "stock_id_options") == nil {
            mData.setValue([], forKey: "stock_id_options")
        }

        mCartData.removeObject(at: index)
        mCartData.insert(mData, at: index)
        mCartTable.reloadData()
        calculateItemsWithAmount()
    }

    @IBAction func mPlusButton(_ sender: UIButton) {
        let index = sender.tag

        let mOrgData = mCartDataMaster[sender.tag] as? NSDictionary
        guard let mInvData = mCartData[index] as? NSDictionary,
              let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems else {
            return
        }
        
        let mMaxQty =  Int("\(mInvData.value(forKey: "po_QTY") ?? "1")") ?? 1
        var mCurrentQty = Int(cells.mQuantityUnit.text ?? "") ?? 0
        print("Current Qty =", mCurrentQty)
        print("Max Qty =", mMaxQty)
        print("Inventory Data =", mInvData)
        if mCurrentQty >= mMaxQty {
            return
        }
        mCurrentQty += 1
        cells.mQuantityUnit.text = "\(mCurrentQty)"

        cells.mProductPrice.text = "\((Double("\(mInvData.value(forKey: "price") ?? "0")") ?? 0.0))"

        guard let mData = mInvData.mutableCopy() as? NSMutableDictionary else { return }

        let finalQTY = Int(cells.mQuantityUnit.text ?? "") ?? 0
        let finalPrice = Double((cells.mProductPrice.text ?? "0").replace(string: ",", replacement: "")) ?? 0
        mData.setValue(finalQTY, forKey: "Qty")
        mData.setValue(finalPrice, forKey: "price")

        if let mServiceLabourStatus = mInvData.value(forKey: "Service_labour_exsist") as? Bool {
            mData.setValue(mServiceLabourStatus, forKey: "Service_labour_exsist")
            if mServiceLabourStatus, let mServiceLabour = mInvData.value(forKey: "Service_labour") as? NSDictionary {
                mData.setValue(mServiceLabour, forKey: "Service_labour")
            }
        } else {
            mData.setValue(false, forKey: "Service_labour_exsist")
        }

        if mInvData.value(forKey: "stock_id_options") == nil {
            mData.setValue([], forKey: "stock_id_options")
        }

        mCartData.removeObject(at: index)
        mCartData.insert(mData, at: index)
        mCartTable.reloadData()
        calculateItemsWithAmount()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       
       if editingStyle == .delete {
 
           guard let mData = mCartData[indexPath.row] as? NSDictionary else {
               return
           }
           CommonClass.showFullLoader(view: self.view)
           let mParams = [ "customer_id":mCustomerId , "custom_cart_id":mData.value(forKey: "custom_cart_id") as? String ?? ""] as [String : Any]
           
           mUserLoginToken = UserDefaults.standard.string(forKey: "token")
           mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
           
           mGetData(url: mDeleteCartItem,headers: sGisHeaders,  params: mParams) { response , status in
               CommonClass.stopLoader()
               if status {
               if "\(response.value(forKey: "code") ?? "")" == "200" {
                   CommonClass.stopLoader()
                   self.mDeleteRow(index: indexPath.row)
               }else{
             
               }
           }
       }
           
       }
   }
    func mDeleteRow(index : Int)
    {
        self.mCartData.removeObject(at: index)
        self.mCartTable.reloadData()
        calculateItemsWithAmount()

    }
    
//    func mDeleteCartItems(index: Int) {
//        self.mCartData.removeObject(at: index)
//        self.mCartTable.reloadData()
//        calculateItemsWithAmount()
//
//    }
    func mDeleteCartItems(index: Int) {

        print("========== DELETE CART DEBUG ==========")
        print("🔥 DELETE INDEX =", index)
        print("🔥 CART COUNT =", self.mCartData.count)
        print("🔥 CART DATA =", self.mCartData)
        print("=======================================")


        guard index >= 0,
              index < self.mCartData.count else {

            print("❌ INVALID DELETE INDEX")
            return
        }


        self.mCartData.removeObject(at: index)

        self.mCartTable.reloadData()

        calculateItemsWithAmount()
    }
    @IBAction func mRemoveCartItems(_ sender: UIButton) {
        
        mRemovePopUp.frame = self.view.bounds
        mRemovePopUp.mCustomerId = mCustomerId
        mRemovePopUp.delegate = self
        mRemovePopUp.index = sender.tag
        mRemovePopUp.mType = ""
        if let mData = mCartData[sender.tag] as? NSDictionary {
            mRemovePopUp.mCartId = mData.value(forKey: "custom_cart_id") as? String ?? ""
        }
        mRemovePopUp.mMessage.text = "Are you sure want to remove ?".localizedString
        mRemovePopUp.mCancelButton.setTitle("CANCEL".localizedString, for: .normal)
        mRemovePopUp.mConfirmButton.setTitle("CONFIRM".localizedString, for: .normal)
        self.view.addSubview(mRemovePopUp)
    }

    @IBAction func mEditAmount(_ sender: UITextField) {
        
        self.mTaxLabourCharge.text = ""
        self.mTaxShippingCharge.text = ""
        self.mTaxLoyaltyPoint.text = ""
        self.mTaxDiscountAmounts.text = ""
        self.mTaxDiscountPercents.text = ""
        
        if let mInvData = mCartData[sender.tag] as? NSDictionary,
        let mOrgData = mCartDataMaster[sender.tag] as? NSDictionary,
           let cells = mCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? CustomCartItems {
            cells.mQuantityUnit.text = "1"
            cells.mDiscountAmount.text = "0"
            cells.mDiscountPercent.text = "0"
            if sender.text == "" || sender.text == "0" {
                cells.mProductPrice.text = ""
                
                guard var mData = mInvData.mutableCopy() as? NSMutableDictionary else { return }
                mData.setValue(0, forKey: "price")
                self.mCartAmount[sender.tag] = 0.0
                
                mData.setValue("0", forKey: "discount_percent")
                mData.setValue("0", forKey: "Discount_Amount")
                
                if let mServiceLabourStatus = mInvData.value(forKey: "Service_labour_exsist") as? Bool {
                    mData.setValue(mServiceLabourStatus, forKey: "Service_labour_exsist")
                    if mServiceLabourStatus, let mServiceLabour = mInvData.value(forKey: "Service_labour") as? NSDictionary {
                        mData.setValue(mServiceLabour, forKey: "Service_labour")
                    }
                } else {
                    mData.setValue(false, forKey: "Service_labour_exsist")
                }
                
                if let mStockData = mInvData.value(forKey: "stock_id_options") as? NSArray {
                    mData.setValue(mStockData, forKey: "stock_id_options")
                } else {
                    mData.setValue([], forKey: "stock_id_options")
                }
                
                mCartData[sender.tag] = mData
                calculateItemsWithAmount()
                return
            }
            
            guard var mData = mInvData.mutableCopy() as? NSMutableDictionary else { return }
            self.mCartAmount.remove(at: sender.tag)
            self.mCartAmount.insert(Double("\(cells.mProductPrice.text ?? "")") ?? 0.0, at: sender.tag)
            
            let finalPrice = Double((cells.mProductPrice.text ?? "0").replace(string: ",", replacement: "")) ?? 0
            mData.setValue(finalPrice, forKey: "price")
            
            mData.setValue("0", forKey: "discount_percent")
            mData.setValue("0", forKey: "Discount_Amount")
            if let mServiceLabourStatus =  mInvData.value(forKey: "Service_labour_exsist") as? Bool {
                if mServiceLabourStatus {
                    mData.setValue(mServiceLabourStatus, forKey: "Service_labour_exsist")
                    if let mServiceLabour = mInvData.value(forKey: "Service_labour") as? NSDictionary {
                        mData.setValue(mServiceLabour, forKey: "Service_labour")
                    }
                }else{
                    mData.setValue(false, forKey: "Service_labour_exsist")
                }
            }
            
            if let mStockData = mInvData.value(forKey: "stock_id_options") as? NSArray {
                mData.setValue(mStockData, forKey: "stock_id_options")
            }else{
                mData.setValue([], forKey: "stock_id_options")
                
            }
            mCartData.removeObject(at: sender.tag)
            mCartData.insert(mData, at: sender.tag)
            calculateItemsWithAmount()
        }
    }
    
    @IBAction func mEditremarks(_ sender: UITextField) {
        

    }
    
    
    
//    func calculateItemsWithAmount(){
//        var mAmounts = [Double]()
//        var mQuantities = [Int]()
//
//        var mServiceAmounts = [Double]()
//
//        for i in mCartData {
//            if let mData = i as? NSDictionary {
//                let qty = Int("\(mData.value(forKey: "Qty") ?? "0")") ?? 0
//                let amount = Double("\(mData.value(forKey: "price") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00
//                mQuantities.append(qty)
//                mAmounts.append(amount * Double(qty))
//
//                if let mServiceLabourStatus = mData.value(forKey: "Service_labour_exsist") as? Bool {
//
//                    if mServiceLabourStatus {
//                        if let mServiceLabour = mData.value(forKey: "Service_labour") as? NSDictionary {
//                            if let mServiceItem = mServiceLabour.value(forKey: "service_laburelist") as? NSArray,
//                               mServiceItem.count > 0 {
//                                var mAmounts = [Double]()
//                                for i in mServiceItem {
//                                    if let items = i as? NSDictionary {
//                                        mAmounts.append(Double("\(items.value(forKey: "scrviceamount") ?? "0.0")".replacingOccurrences(of: ",", with: "")) ?? 0.00)
//                                    }
//                                }
//
//                                mServiceAmounts.append(mAmounts.reduce(0, {$0 + $1}))
//                            }
//                        }
//
//                    }
//                }
//            }
//        }
//
//        self.mTaxLabourCharge.text = "\(mServiceAmounts.reduce(0, {$0 + $1}))"
//        mTotalItems.text = "\(mCartData.count) items"
//        mGrandTotal.text = self.mCurrency + String(format:"%.02f",locale:Locale.current,mAmounts.reduce(0, {$0 + $1}))
//        self.mTaxTotal.text = self.mCurrency + String(format:"%.02f",locale:Locale.current,mAmounts.reduce(0, {$0 + $1}))
//
//        mGrandTotalCart = "\(mAmounts.reduce(0, {$0 + $1}))"
//        self.mGrandTotalAmounts = "\(mAmounts.reduce(0, {$0 + $1}))"
//        self.mTaxValue.text = "\((Double("\(UserDefaults.standard.string(forKey: "taxValue") ?? "0")") ?? 0.00))"
//        self.mTaxTotal.text =  self.mCurrency + " " + self.mGrandTotalAmounts.formatPrice()
//        if mDepositPercents == "100" {
//            var mAdditionalAmount =  Double()
//            let mDiscountA = Double(self.mTaxDiscountAmounts.text ?? "") ?? 0.0
//            let mLabour = Double(self.mTaxLabourCharge.text ?? "") ?? 0.0
//            let mShipping = Double(self.mTaxShippingCharge.text ?? "") ?? 0.0
//            let mLoyalty = Double(self.mTaxLoyaltyPoint.text ?? "") ?? 0.0
//            mAdditionalAmount = mLabour + mShipping + mLoyalty
//
//            mDepositAmount.text =  mGrandTotal.text
//            mOutstandingAmount.text = self.mCurrency + "0.00"
//            self.mOutStandingAmounts = "0.00"
//            self.mTotalDepositAmounts = self.mGrandTotalAmounts
//
//             let mTaxType = UserDefaults.standard.string(forKey: "taxType") ?? ""
//                if mTaxType.lowercased() == "inclusive" {
//                    let grandTotal = Double(self.mGrandTotalAmounts.replacingOccurrences(of: ",", with: "")) ?? 0.0
//                    let taxPercent = Double(UserDefaults.standard.string(forKey: "taxValue") ?? "0.0") ?? 0.0
//
//                    let taxAmount = calculateInclusiveTax(value: grandTotal, percent: taxPercent)
//
//                    mTaxAmount.text = String(format: "%.02f", locale: Locale.current, taxAmount)
//
//                    let subTotal = grandTotal - taxAmount
//                    mTaxSubTotal.text = "\(self.mCurrency) \(String(format: "%.02f", locale: Locale.current, subTotal))"
//
//                    var includingDiscount = (Double(self.mGrandTotalAmounts) ?? 0.00) - (mDiscountA)
//                    includingDiscount = includingDiscount + mAdditionalAmount
//
//                    mGrandTotal.text = self.mCurrency + "\(includingDiscount)".formatPrice()
//                self.mTotalDepositAmounts  = String(format: "%.2f", includingDiscount)
//
//                }
//            if mTaxType.lowercased() == "exclusive" {
//
//                let grandTotal = Double(self.mGrandTotalAmounts.replacingOccurrences(of: ",", with: "")) ?? 0.0
//                let taxPercent = Double(UserDefaults.standard.string(forKey: "taxValue") ?? "0.0") ?? 0.0
//                let taxAmount = calculateExclusiveTax(value: grandTotal, percent: taxPercent)
//                mTaxAmount.text = String(format: "%.02f", locale: Locale.current, taxAmount)
//
//                let taxSubTotal = grandTotal + taxAmount + mAdditionalAmount - mDiscountA
//                mTaxSubTotal.text = self.mCurrency + " " + String(format: "%.02f", locale: Locale.current, taxSubTotal)
//
//                var includingDiscount = (Double(self.mGrandTotalAmounts) ?? 0.00) - (mDiscountA)
//                includingDiscount = includingDiscount + mAdditionalAmount + calculateExclusiveTax(value: (Double(self.mGrandTotalAmounts.replacingOccurrences(of: ",", with: "")) ?? 0.0), percent: (Double("\(UserDefaults.standard.string(forKey: "taxValue") ?? "0")") ?? 0.0))
//
//
//                mGrandTotal.text = self.mCurrency + "\(includingDiscount)".formatPrice()
//            self.mTotalDepositAmounts  = String(format: "%.2f", includingDiscount)
//            }
//
//            }else{
//              let mTotalValue = mAmounts.reduce(0, {$0 + $1})
//            mDepositAmount.text = self.mCurrency + String(format:"%.02f",locale:Locale.current,calculatePercentage(value: mTotalValue, percent: Double(mDepositPercents) ?? 0.00))
//            self.mTotalDepositAmounts = "\(calculatePercentage(value: mTotalValue, percent: Double(mDepositPercents) ?? 0.00))"
//            let mOutstandingBal = mTotalValue - calculatePercentage(value: mTotalValue, percent: Double(mDepositPercents) ?? 0.00)
//            self.mOutStandingAmounts = "\(mOutstandingBal)"
//            self.mOutstandingAmount.text = self.mCurrency + String(format:"%.02f",locale:Locale.current,mOutstandingBal)
//        }
//
//
//
//
//    }
    
    func calculateItemsWithAmount() {

        var mAmounts = [Double]()
        var mQuantities = [Int]()
        var mServiceAmounts = [Double]()

        // =====================================================
        // 1. PRODUCT TOTAL + SERVICE LABOUR TOTAL
        // =====================================================

        for item in mCartData {

            guard let mData = item as? NSDictionary else {
                continue
            }
            
            print("========== CALCULATE ==========")
            print("price =", mData["price"] ?? "")
            print("cart_price =", mData["cart_price"] ?? "")
            print("Discount_Amount =", mData["Discount_Amount"] ?? "")
            print("discount_percent =", mData["discount_percent"] ?? "")

            let qty =
                Int("\(mData.value(forKey: "Qty") ?? "0")") ?? 0

//            let amount =
//                Double(
//                    "\(mData.value(forKey: "price") ?? "0.0")"
//                        .replacingOccurrences(of: ",", with: "")
//                ) ?? 0.0
//            let amount = PriceHelper.unformatPrice(
//                "\(mData.value(forKey: "price") ?? "0")"
//            )
            
//            let rawAmount =
//                mData.value(forKey: "cart_price")
//                ?? mData.value(forKey: "price")
//                ?? "0"
            let rawAmount =
                mData.value(forKey: "price")
                ?? mData.value(forKey: "cart_price")
                ?? "0"
            print("RAW AMOUNT =", rawAmount)
            let amount = PriceHelper.unformatPrice("\(rawAmount)")
            
            print("---------------------")
            print("price =", mData["price"] ?? "")
            print("cart_price =", mData["cart_price"] ?? "")
            print("amount =", amount)

            mQuantities.append(qty)

            // Product amount
            mAmounts.append(amount * Double(qty))


            // =================================================
            // SERVICE LABOUR
            // =================================================

            let serviceLabourStatus =
                mData.value(forKey: "Service_labour_exsist") as? Bool
                ?? false

            if serviceLabourStatus {

                if let mServiceLabour =
                    mData.value(forKey: "Service_labour")
                        as? NSDictionary {

                    /*
                     รองรับทั้ง key เดิมของ project:
                     service_laburelist
                     scrviceamount

                     และ key ใหม่ ถ้า API เปลี่ยน:
                     service_labour_list
                     serviceAmount
                     */

                    let serviceItems =
                        (mServiceLabour.value(
                            forKey: "service_laburelist"
                        ) as? NSArray)
                        ??
                        (mServiceLabour.value(
                            forKey: "service_labour_list"
                        ) as? NSArray)

                    if let serviceItems = serviceItems {

                        var itemServiceTotal = 0.0

                        for serviceItem in serviceItems {

                            guard let service =
                                serviceItem as? NSDictionary else {
                                continue
                            }

                            let rawAmount =
                                service.value(forKey: "scrviceamount")
                                ??
                                service.value(forKey: "serviceAmount")
                                ??
                                "0"

                            let serviceAmount =
                                Double(
                                    "\(rawAmount)"
                                        .replacingOccurrences(
                                            of: ",",
                                            with: ""
                                        )
                                ) ?? 0.0

                            itemServiceTotal += serviceAmount
                        }

                        mServiceAmounts.append(itemServiceTotal)
                    }
                }
            }
        }


        // =====================================================
        // 2. CALCULATE BASE TOTALS
        // =====================================================

        let productTotal =
            mAmounts.reduce(0, +)

        let serviceLabourTotal =
            mServiceAmounts.reduce(0, +)

        // Service Labour included here
        let baseGrandTotal =
            productTotal + serviceLabourTotal


        print("========== POS TOTAL DEBUG ==========")
        print("PRODUCT TOTAL =", productTotal)
        print("SERVICE LABOUR TOTAL =", serviceLabourTotal)
        print("BASE GRAND TOTAL =", baseGrandTotal)
        print("=====================================")


        // =====================================================
        // 3. UPDATE BASIC UI
        // =====================================================

        self.mTaxLabourCharge.text =
            String(format: "%.2f", serviceLabourTotal)

        mTotalItems.text =
            "\(mCartData.count) items"

//        mGrandTotal.text =
//            self.mCurrency +
//            String(
//                format: "%.02f",
//                locale: Locale.current,
//                baseGrandTotal
//            )
        let currency = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"

        mGrandTotal.text = PriceHelper.formatPrice(
            baseGrandTotal,
            currency: currency
        )
        print("GrandTotal =", mGrandTotal.text ?? "")
        mTaxTotal.text =
            self.mCurrency +
            String(
                format: "%.02f",
                locale: Locale.current,
                baseGrandTotal
            )

        mGrandTotalCart =
            "\(baseGrandTotal)"

        self.mGrandTotalAmounts =
            "\(baseGrandTotal)"

        self.mTaxValue.text = "\(Double(UserDefaults.standard.string(forKey: "taxValue") ?? "0") ?? 0.0)"

        self.mTaxTotal.text =
            self.mCurrency +
            " " +
            self.mGrandTotalAmounts.formatPrice()


        // =====================================================
        // 4. DISCOUNT / SHIPPING / LOYALTY
        // =====================================================

//        let mDiscountA =
//            Double(
//                self.mTaxDiscountAmounts.text ?? ""
//            ) ?? 0.0
        
        var mDiscountA =
            Double(
                self.mTaxDiscountAmounts.text ?? ""
            ) ?? 0.0

        // Discount cannot exceed product total
//        if mDiscountA > baseGrandTotal {
//            mDiscountA = baseGrandTotal
//            self.mTaxDiscountAmounts.text = String(format: "%.2f", mDiscountA)
//        }

        let mShipping =
            Double(
                self.mTaxShippingCharge.text ?? ""
            ) ?? 0.0

        let mLoyalty =
            Double(
                self.mTaxLoyaltyPoint.text ?? ""
            ) ?? 0.0
        
        let discountBase = baseGrandTotal + mShipping

        if mDiscountA > discountBase {
            mDiscountA = discountBase
            self.mTaxDiscountAmounts.text = String(format: "%.2f", mDiscountA)
        }

        /*
         IMPORTANT

         Service Labour ถูกบวกเข้า baseGrandTotal แล้ว

         เพราะฉะนั้นห้ามเอา mTaxLabourCharge
         มาบวกใน mAdditionalAmount อีก
         ไม่อย่างนั้น Labour จะโดนบวก 2 รอบ
         */

        let mAdditionalAmount =
            mShipping + mLoyalty


        // =====================================================
        // 5. TAX TYPE
        // =====================================================

        let mTaxType =
            UserDefaults.standard.string(
                forKey: "taxType"
            ) ?? ""

        let taxPercent =
            Double(
                UserDefaults.standard.string(
                    forKey: "taxValue"
                ) ?? "0.0"
            ) ?? 0.0


        // =====================================================
        // 6. CALCULATE FINAL TOTAL
        // =====================================================

        var finalGrandTotal = baseGrandTotal


        if mTaxType.lowercased() == "inclusive" {

//            let taxAmount =
//                calculateInclusiveTax(
//                    value: baseGrandTotal,
//                    percent: taxPercent
//                )
            
            let taxAmount = calculateInclusiveTax(
                value: baseGrandTotal,
                percent: taxPercent
            )

            mTaxAmount.text =
                String(
                    format: "%.02f",
                    locale: Locale.current,
                    taxAmount
                )

//            let subTotal =
//                baseGrandTotal - taxAmount
            
            let subTotal = baseGrandTotal - taxAmount
            
            mCalculatedTaxAmount = taxAmount
            mCalculatedSubTotal = subTotal

            mTaxSubTotal.text =
                "\(self.mCurrency) " +
                String(
                    format: "%.02f",
                    locale: Locale.current,
                    subTotal
                )

            finalGrandTotal =
                baseGrandTotal
                - mDiscountA
                + mAdditionalAmount

            if finalGrandTotal < 0 {
                finalGrandTotal = 0
            }

        } else if mTaxType.lowercased() == "exclusive" {

//            let taxAmount =
//                calculateExclusiveTax(
//                    value: baseGrandTotal,
//                    percent: taxPercent
//                )
            let subTotalBeforeTax =
                baseGrandTotal
                + mShipping
                - mDiscountA

            let taxAmount =
                calculateExclusiveTax(
                    value: max(subTotalBeforeTax, 0),
                    percent: taxPercent
                )

            mTaxAmount.text =
                String(
                    format: "%.02f",
                    locale: Locale.current,
                    taxAmount
                )
            
            mCalculatedTaxAmount = taxAmount
            mCalculatedSubTotal = subTotalBeforeTax

            let taxSubTotal =
                baseGrandTotal
                + taxAmount
                + mAdditionalAmount
                - mDiscountA

            mTaxSubTotal.text =
                self.mCurrency +
                " " +
                String(
                    format: "%.02f",
                    locale: Locale.current,
                    taxSubTotal
                )

//            finalGrandTotal =
//                baseGrandTotal
//                - mDiscountA
//                + mAdditionalAmount
//                + taxAmount
            
            finalGrandTotal =
                max(subTotalBeforeTax, 0)
                + taxAmount

            if finalGrandTotal < 0 {
                finalGrandTotal = 0
            }

        } else {

            // No tax type
//            finalGrandTotal =
//                baseGrandTotal
//                - mDiscountA
//                + mAdditionalAmount
            
            let subTotalBeforeTax =
                baseGrandTotal
                + mShipping
                - mDiscountA

            finalGrandTotal = max(subTotalBeforeTax, 0)
            
            
            if finalGrandTotal < 0 {
                finalGrandTotal = 0
            }

            mTaxAmount.text = "0.00"

            mTaxSubTotal.text =
                self.mCurrency +
                " " +
                String(
                    format: "%.02f",
                    locale: Locale.current,
                    finalGrandTotal
                )
        }

        
        // ===== DEBUG =====
        print("========== POS FINAL DEBUG ==========")
        print("BASE =", baseGrandTotal)
        print("DISCOUNT =", mDiscountA)
        print("SHIPPING =", mShipping)
        print("ADDITIONAL =", mAdditionalAmount)
        print("TAX TYPE =", mTaxType)
        print("TAX =", taxPercent)
        print("FINAL =", finalGrandTotal)
        print("UserDefaults taxType = ")
        print(UserDefaults.standard.string(forKey: "taxType") ?? "")
        print("=====================================")

        // =====================================================
        // 7. UPDATE GRAND TOTAL
        // =====================================================

//        mGrandTotal.text =
//            self.mCurrency +
//            "\(finalGrandTotal)".formatPrice()
        print("baseGrandTotal =", baseGrandTotal)
        print("formatted =", PriceHelper.formatPrice(baseGrandTotal, currency: currency))

        mGrandTotal.text = PriceHelper.formatPrice(
            finalGrandTotal,
            currency: currency
        )
        print("GrandTotal =", mGrandTotal.text ?? "")
        self.mTotalDepositAmounts =
            String(
                format: "%.2f",
                finalGrandTotal
            )


        print("FINAL GRAND TOTAL =", finalGrandTotal)


        // =====================================================
        // 8. DEPOSIT / OUTSTANDING
        // =====================================================

        if mDepositPercents == "100" {

//            mDepositAmount.text =
//                self.mCurrency +
//                String(
//                    format: "%.02f",
//                    locale: Locale.current,
//                    finalGrandTotal
//                )
            mDepositAmount.text = PriceHelper.formatPrice(
                finalGrandTotal,
                currency: currency
            )

            mOutstandingAmount.text =
                self.mCurrency + "0.00"

            self.mOutStandingAmounts =
                "0.00"

            self.mTotalDepositAmounts =
                String(
                    format: "%.2f",
                    finalGrandTotal
                )


        } else {

            let depositPercent =
                Double(mDepositPercents) ?? 0.0

            let depositAmount =
                calculatePercentage(
                    value: finalGrandTotal,
                    percent: depositPercent
                )

            let outstandingAmount =
                finalGrandTotal - depositAmount


//            mDepositAmount.text =
//                self.mCurrency +
//                String(
//                    format: "%.02f",
//                    locale: Locale.current,
//                    depositAmount
//                )
            mDepositAmount.text = PriceHelper.formatPrice(
                depositAmount,
                currency: currency
            )

            self.mTotalDepositAmounts =
                String(
                    format: "%.2f",
                    depositAmount
                )

            self.mOutStandingAmounts =
                String(
                    format: "%.2f",
                    outstandingAmount
                )

//            self.mOutstandingAmount.text =
//                self.mCurrency +
//                String(
//                    format: "%.02f",
//                    locale: Locale.current,
//                    outstandingAmount
//                )
            
            self.mOutstandingAmount.text = PriceHelper.formatPrice(
                outstandingAmount,
                currency: currency
            )
        }


        print("========== POS FINAL DEBUG ==========")
        print("PRODUCT =", productTotal)
        print("SERVICE =", serviceLabourTotal)
        print("DISCOUNT =", mDiscountA)
        print("SHIPPING =", mShipping)
        print("LOYALTY =", mLoyalty)
        print("TAX TYPE =", mTaxType)
        print("TAX % =", taxPercent)
        print("FINAL TOTAL =", finalGrandTotal)
        print("DEPOSIT =", self.mTotalDepositAmounts)
        print("OUTSTANDING =", self.mOutStandingAmounts)
        print("=====================================")
    }
    
    func calculatePercentage(value:Double,percent: Double) -> Double {
        let val = value * percent
        return val/100.00
    }
    func calculateInclusiveTax(value:Double,percent: Double) -> Double {
            let val = value * percent
        return val/(100.00 + (Double("\(UserDefaults.standard.string(forKey: "taxValue") ?? "0")") ?? 0.00))
      
    }
    func calculateExclusiveTax(value:Double,percent: Double) -> Double {
        let val = value * percent
        return val/100.00
    }

    
}
extension Double {
    
    func toInt() -> Int? {
        let roundedValue = rounded(.toNearestOrEven)
        return Int(exactly: roundedValue)
    }
    
}
