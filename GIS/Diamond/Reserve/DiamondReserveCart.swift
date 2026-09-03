//
//  DiamondReserveCart.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 31/10/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import UIKit
import UIDrawer
import Alamofire

class DiamondReserveCart: UIViewController , GetCustomerDataDelegate , UIViewControllerTransitioningDelegate , UITextViewDelegate {
 
    
    
    @IBOutlet weak var mCustomerName: UILabel!
    @IBOutlet weak var mCustomerImage: UIImageView!
    
    @IBOutlet weak var mSelectedCustomerIcon: UIImageView!
    
    @IBOutlet weak var mProductImage: UIImageView!
    
    
    
    

    
    
    @IBOutlet weak var mCheckOutView: UIView!
    

    @IBOutlet weak var mProductInfo: UILabel!
    
    @IBOutlet weak var mShape: UILabel!
    
    @IBOutlet weak var mTotalCarats: UILabel!
    
    @IBOutlet weak var mStockId: UILabel!
    
    
    @IBOutlet weak var mAmount: UILabel!
    @IBOutlet weak var mDueDate: UITextField!
    @IBOutlet weak var mNotes: UITextView!
    
    let mDatePicker:UIDatePicker = UIDatePicker()
    var mData = NSDictionary()
    var mCustomerId = ""
    

    @IBOutlet weak var mSubmitButton: UIButton!
    @IBOutlet weak var mNoteLABEL: UILabel!
    @IBOutlet weak var mCustomerLABEL: UILabel!
    @IBOutlet weak var mHeading: UILabel!

    // MARK: - Note Suggestions
    private var mNoteSuggestionsView: UIView?
    private var mNoteSuggestionButtons: [UIButton] = []
    private var mIsSelectingNoteSuggestion = false
    private var mNoteSuggestionsLockedFrame: CGRect?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleNoteOutsideTap(_:))
        )
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mSubmitButton.setTitle("SUBMIT".localizedString, for: .normal)
        mNoteLABEL.text = "Note".localizedString
        mHeading.text = "Reserve".localizedString
        mCustomerLABEL.text = "Customer".localizedString

        // Do any additional setup after loading the view.
        
        self.mProductInfo.text = "\(mData.value(forKey: "Carat") ?? "") Carat, \(mData.value(forKey: "Shape") ?? "") - \(mData.value(forKey: "Colour") ?? "")/\(mData.value(forKey: "Clarity") ?? "")"
        
        self.mStockId.text = "\(mData.value(forKey: "StockID") ?? "")"
        self.mShape.text = "\(mData.value(forKey: "Shape") ?? "")"
        self.mTotalCarats.text = "\(mData.value(forKey: "Carat") ?? "")"
        self.mAmount.text = "\(mData.value(forKey: "Price") ?? "")"
        self.mProductImage.downlaodImageFromUrl(urlString: "")
        self.mCustomerName.text = ""
        mCustomerImage.contentMode = .scaleAspectFill

        
        mNotes.delegate = self
        mNotes.text = "Eg. Urgent Order"
        mNotes.textColor = .placeholderText
        mNotes.borderWidth = 0
        setupNoteSuggestions()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(noteKeyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(noteKeyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
//        formatter.dateFormat = "MM/dd/yyy"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MM/dd/yyyy"
        
        mDueDate.text =  formatter.string(from: currentDateTime)
        }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    override
    func viewDidAppear(_ animated: Bool) {
        
        mShowDatePicker()
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
            home.delegate = self
            home.modalPresentationStyle = .automatic
            home.transitioningDelegate = self
            self.present(home,animated: true)
        }
    }

    @IBAction func mBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView == mNotes {
//
//            mNotes.text = ""
//            mNotes.textColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//
//        }
//
//
//    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == mNotes {
            if mNotes.text == "Eg. Urgent Order" {
                mNotes.text = ""
                mNotes.textColor = .black
            }

            // Show all Reserve suggestions as soon as Note is tapped.
            showNoteSuggestions()
        }
    }
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView == mNotes {
//            if mNotes.text == "" {
//                mNotes.text = "Eg. Urgent Order"
//                mNotes.textColor = .placeholderText
//            }
//        }
//    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == mNotes {
            if mNotes.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                mNotes.text = "Eg. Urgent Order"
                mNotes.textColor = .placeholderText
            }

            if !mIsSelectingNoteSuggestion {
                hideNoteSuggestions()
            }
        }
    }
   
    
    

    // MARK: - Note Suggestions

    private func setupNoteSuggestions() {
        // UITextView uses UITextViewDelegate for editing events.
    }

    private func tomorrowSuggestionDate() -> String {
        let calendar = Calendar(identifier: .gregorian)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM yyyy"

        return formatter.string(from: tomorrow)
    }

    private func currentNoteSuggestions() -> [String] {
        return [
            "Pickup on \(tomorrowSuggestionDate()), 2:00 PM",
            "On hold until closing time",
            "Customer response",
            "Payment verification"
        ]
    }

    private func showNoteSuggestions() {
        guard let window = view.window else { return }

        hideNoteSuggestions()

        let suggestions = currentNoteSuggestions()

        let popup = UIView()
        popup.backgroundColor = .white
        popup.layer.cornerRadius = 9
        popup.layer.masksToBounds = false
        popup.layer.shadowColor = UIColor.black.cgColor
        popup.layer.shadowOpacity = 0.14
        popup.layer.shadowOffset = CGSize(width: 0, height: 2)
        popup.layer.shadowRadius = 6

        let popupWidth: CGFloat = 220
        let headerHeight: CGFloat = 38
        let rowHeight: CGFloat = 38
        let popupHeight = headerHeight + CGFloat(suggestions.count) * rowHeight + 8
        let gap: CGFloat = 10

        // Capture the position BEFORE the keyboard moves the form.
        let noteFrame = mNotes.convert(mNotes.bounds, to: window)

        let x = max(
            8,
            min(noteFrame.minX, window.bounds.width - popupWidth - 8)
        )

        // Suggestions sit directly above Note, like the other Cart screens.
        var y = noteFrame.minY - popupHeight - gap

        // Fallback only if there is not enough room above.
        if y < window.safeAreaInsets.top + 8 {
            y = noteFrame.maxY + gap
        }

        let popupFrame = CGRect(
            x: x,
            y: y,
            width: popupWidth,
            height: popupHeight
        )

        popup.frame = popupFrame

        // Lock the popup in UIWindow coordinates. Do not follow mNotes
        // when UIKit moves the form for the keyboard.
        mNoteSuggestionsLockedFrame = popupFrame

        window.addSubview(popup)
        window.bringSubviewToFront(popup)

        mNoteSuggestionsView = popup
        mNoteSuggestionButtons.removeAll()

        let title = UILabel(frame: CGRect(
            x: 16,
            y: 0,
            width: popupWidth - 32,
            height: headerHeight
        ))
        title.text = "Suggestions"
        title.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        title.textColor = .label
        popup.addSubview(title)

        for (index, suggestion) in suggestions.enumerated() {
            let button = UIButton(type: .system)
            button.frame = CGRect(
                x: 16,
                y: headerHeight + CGFloat(index) * rowHeight,
                width: popupWidth - 24,
                height: rowHeight
            )
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(
                top: 0,
                left: 8,
                bottom: 0,
                right: 2
            )
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.setTitleColor(.darkGray, for: .normal)
            button.setTitle(suggestion, for: .normal)
            button.tag = index
            button.addTarget(
                self,
                action: #selector(selectNoteSuggestion(_:)),
                for: .touchUpInside
            )

            popup.addSubview(button)
            mNoteSuggestionButtons.append(button)
        }
    }

    @objc private func selectNoteSuggestion(_ sender: UIButton) {
        guard let title = sender.title(for: .normal), !title.isEmpty else {
            return
        }

        mIsSelectingNoteSuggestion = true

        mNotes.text = title
        mNotes.textColor = .black

        hideNoteSuggestions()

        mNotes.resignFirstResponder()
        view.endEditing(true)

        mIsSelectingNoteSuggestion = false
    }

    @objc private func handleNoteOutsideTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }

        guard let window = view.window else {
            hideNoteSuggestions()
            view.endEditing(true)
            return
        }

        let point = gesture.location(in: window)

        if let popup = mNoteSuggestionsView,
           popup.frame.contains(point) {
            return
        }

        let noteFrame = mNotes.convert(mNotes.bounds, to: window)

        if noteFrame.contains(point) {
            return
        }

        hideNoteSuggestions()
        view.endEditing(true)
    }

    @objc private func noteKeyboardWillShow(notification: Notification) {
        // IMPORTANT: Do not recalculate from mNotes.
        // The popup position was captured before the keyboard appeared.
        keepNoteSuggestionsLocked()
    }

    @objc private func noteKeyboardWillHide(notification: Notification) {
        keepNoteSuggestionsLocked()
    }

    private func keepNoteSuggestionsLocked() {
        guard let popup = mNoteSuggestionsView,
              let lockedFrame = mNoteSuggestionsLockedFrame else {
            return
        }

        popup.frame = lockedFrame

        if let window = view.window {
            window.bringSubviewToFront(popup)
        }
    }

    private func hideNoteSuggestions() {
        mNoteSuggestionsView?.removeFromSuperview()
        mNoteSuggestionsView = nil
        mNoteSuggestionButtons.removeAll()
        mNoteSuggestionsLockedFrame = nil
    }

    @IBAction func mDeleteReserve(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mOpenImages(_ sender: Any) {
  
    }
    
    func mCreateNewCustomer() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let mCreateCustomer = storyBoard.instantiateViewController(withIdentifier: "CreateCustomer") as? CreateCustomer {
            self.navigationController?.pushViewController(mCreateCustomer, animated:true)
        }
    }
    func mGetCustomerData(data: NSMutableDictionary) {
        
        UserDefaults.standard.set(data.value(forKey: "id") as? String ?? "", forKey: "DEFAULTCUSTOMER")
        UserDefaults.standard.set(data.value(forKey: "profile") ?? "", forKey: "DEFAULTCUSTOMERPICTURE")
        UserDefaults.standard.set(data.value(forKey: "name") as? String ?? "", forKey: "DEFAULTCUSTOMERNAME")

        self.mCustomerName.text = data.value(forKey: "name") as? String
        self.mCustomerId = data.value(forKey: "id") as? String ?? ""
        self.mCustomerImage.contentMode = .scaleAspectFill
        self.mCustomerImage.downlaodImageFromUrl(urlString: data.value(forKey: "profile") as? String ?? "")
        self.mSelectedCustomerIcon.image = UIImage(named: "selected_customer")

    }

    
    @IBAction func mChooseCustomer(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "CustomerPicker") as? CustomerPicker {
            home.delegate = self
            home.modalPresentationStyle = .automatic
            home.transitioningDelegate = self
            self.present(home,animated: true)
        }
    }
   
    
    
    @IBAction func mCreateReseveNow(_ sender: Any) {
        
        if mCustomerId == "" {
            CommonClass.showSnackBar(message: "Please choose customer!")
            
        }
        
        if mDueDate.text?.count == 0 {
            CommonClass.showSnackBar(message: "Please choose due date!")
            return
        }
//        if mNotes.text == "Eg. Urgent Order" {
//            CommonClass.showSnackBar(message: "Please fill notes!")
//            return
//        }
//        if mNotes.text?.count == 0 {
//            CommonClass.showSnackBar(message: "Please fill notes!")
//            return
//        }
        
        let currentDateTime = Date()
        let formattedDate =  currentDateTime.getFormattedDate(format: "MM/dd/yyyy")
        
        
        let params:[String: Any] = ["id" : mData.value(forKey: "id") as? String ?? "" , "customer_id": self.mCustomerId, "date":formattedDate,"dueDate":self.mDueDate.text ?? "", "remark":self.mNotes.text ?? ""]
        
        CommonClass.showFullLoader(view: self.view)
        
        mGetData(url: mDiamondCreateReserveAPI,headers: sGisHeaders,  params: params) { response , status in
            CommonClass.stopLoader()
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    
                    let storyBoard: UIStoryboard = UIStoryboard(name: "diamondModule", bundle: nil)
                    if let mDiamondProductDetails = storyBoard.instantiateViewController(withIdentifier: "DiamondReservedItems") as? DiamondReservedItems {
                        var controllers = self.navigationController?.viewControllers
                        controllers?.removeLast()
                        controllers?.removeLast()
                        controllers?.append(mDiamondProductDetails)
                        if let navStack = controllers {
                            self.navigationController?.setViewControllers(navStack, animated: true)
                        }
                    }
                }else if "\(response.value(forKey: "code") ?? "")" == "403" {
                    CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                }
            }
        }
        
    }
    
    
    
    func mShowDatePicker(){
        
        let currentDate = Date()
        var datecomp = DateComponents()
        let min = Calendar.init(identifier: .gregorian)
        
        mDatePicker.preferredDatePickerStyle = .wheels
        datecomp.day = 0
        let minDates = min.date(byAdding: datecomp, to: currentDate)
        
        datecomp.year = 5
        let maxDates = min.date(byAdding: datecomp, to: currentDate)
        mDatePicker.minimumDate = minDates
        mDatePicker.maximumDate = maxDates
        mDatePicker.datePickerMode = .date
        mDatePicker.backgroundColor = .white
        //ToolBar
        let mToolBar = UIToolbar()
        mToolBar.sizeToFit()
        mToolBar.backgroundColor = .white
        mToolBar.barTintColor = .white
        let mDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneDatePick))
        let mSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let mCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(mCancelDatePick))
        mToolBar.setItems([mDone, mSpace,mCancel], animated: false)
    
        mDueDate.inputAccessoryView = mToolBar
        mDueDate.inputView = mDatePicker
    
    }
    @objc func doneDatePick(){
//        let mDayd = DateFormatter()
//            mDayd.dateFormat = "dd"
//
//        let mMonthm = DateFormatter()
//            mMonthm.dateFormat = "MM"
//
//        let mYeard = DateFormatter()
//            mYeard.dateFormat = "yyyy"
//
//        let gregorian = Calendar(identifier: .gregorian)
//        let locale = Locale(identifier: "en_US_POSIX")
//
//        mDayd.calendar = gregorian
//        mDayd.locale = locale
//
//        mMonthm.calendar = gregorian
//        mMonthm.locale = locale
//
//        mYeard.calendar = gregorian
//        mYeard.locale = locale
              
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy"

        mDueDate.text = formatter.string(from: mDatePicker.date)
        
//        mDueDate.text  = "\(mMonthm.string(from: mDatePicker.date))/" +  "\(mDayd.string(from: mDatePicker.date))/"+"\(mYeard.string(from: mDatePicker.date))"

        self.view.endEditing(true)
   
    }
    @objc func mCancelDatePick(){
        self.view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension Date {
    func getFormattedDate(format: String) -> String {
        let dateFormat = DateFormatter()
        dateFormat.calendar = Calendar(identifier: .gregorian)
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = format
        return dateFormat.string(from: self)
    }
}
