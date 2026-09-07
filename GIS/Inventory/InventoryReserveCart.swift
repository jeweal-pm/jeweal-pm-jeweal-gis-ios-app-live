//
//  InventoryReserveCart.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 02/12/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import UIKit
import UIDrawer
import Alamofire

class ReserveNewItems : UITableViewCell {
    let mDatePicker:UIDatePicker = UIDatePicker()

    @IBOutlet weak var mAmount: UITextField!
    @IBOutlet weak var mChooseDate: UIButton!
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mSno: UILabel!
    @IBOutlet weak var mRemarks: UITextField!
    @IBOutlet weak var mProductInfo: UILabel!
    @IBOutlet weak var mDeleteItem: UIButton!
    @IBOutlet weak var mSKU: UILabel!
    @IBOutlet weak var mDueDate: UITextField!
    @IBOutlet weak var mPlusButton: UIButton!
    @IBOutlet weak var mMaterialInfo: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mQuantity: UILabel!
    @IBOutlet weak var mMinusButton: UIButton!
 
}

class InventoryReserveCart: UIViewController , GetCustomerDataDelegate , UIViewControllerTransitioningDelegate , UITextViewDelegate , UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {

    enum ReserveSource {
        case itemSearch
        case quickView
        case myInventory

        var payloadFlag: String {
            switch self {
            case .itemSearch: return "byItemSearchMobile"
            case .quickView: return "byQuickViewMobile"
            case .myInventory: return "byMyInventoryMobile"
            }
        }
    }
    
    var mCurrentIndex = -1
    @IBOutlet weak var mCustomerName: UILabel!
    @IBOutlet weak var mCustomerImage: UIImageView!
    @IBOutlet weak var mSelectedCustomerIcon: UIImageView!
    var mQuantityData = [Int]()
    @IBOutlet weak var mReserveCartTable: UITableView!
    @IBOutlet weak var mCheckOutView: UIView!
    let mDatePicker:UIDatePicker = UIDatePicker()
    private var mReserveData = NSMutableArray()
    var mOriginalData = NSArray()
    
    var mCustomerId = ""
    @IBOutlet weak var mReserveHeadingLABEL: UILabel!
    @IBOutlet weak var mCustomerLABEL: UILabel!
    
    @IBOutlet weak var mSubmitBUTTON: UIButton!
    
    var mIsCrossLocationReserve = false
    var mCrossLocationId = ""
    var reserveSource: ReserveSource = .myInventory

    // MARK: - Reserve Note Suggestions
    private var reserveSuggestionsView: UIView?
    private var reserveSuggestionsButtons: [UIButton] = []
    private var reserveVisibleSuggestions: [String] = []
    private weak var activeReserveNoteField: UITextField?
    private var reserveSuggestionSessionActive = false
    private var reserveDismissTapGesture: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        self.mReserveHeadingLABEL.text = "Reserve".localizedString
        mCustomerLABEL.text = "Customer".localizedString
        mSubmitBUTTON.setTitle("SUBMIT".localizedString, for: .normal)
        mReserveData = NSMutableArray(array: mOriginalData )

        // IMPORTANT:
        // QuickView passes mIsCrossLocationReserve and mCrossLocationId
        // into this controller BEFORE the view is presented.
        // Do NOT reset these values here, otherwise the selected destination
        // location is lost before createReserveOrder is called.
        //
        // Keep the values passed from QuickView as the primary source.
        // If QuickView did not provide them, fall back to the item metadata.
        if mCrossLocationId.isEmpty {
            for case let item as NSDictionary in mReserveData {
                let crossLocationId =
                    "\(item.value(forKey: "crossLocationId") ?? "")"
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if !crossLocationId.isEmpty {
                    mCrossLocationId = crossLocationId
                    mIsCrossLocationReserve = true
                    break
                }
            }
        }

        // If a cross-location ID exists, the order must be sent as
        // a cross-location reservation.
        if !mCrossLocationId.isEmpty {
            mIsCrossLocationReserve = true
        }

        print("========== INVENTORY RESERVE CART INIT ==========")
        print("mIsCrossLocationReserve =", mIsCrossLocationReserve)
        print("mCrossLocationId =", mCrossLocationId)
        print("================================================")

        mQuantityData = [Int]()
        
        for i in mReserveData {
            if let mData = i as? NSDictionary {
                mQuantityData.append(Int("\(mData.value(forKey: "po_QTY") ?? "0")") ?? 0)
            }
        }
        self.mReserveCartTable.delegate  = self
        self.mReserveCartTable.dataSource = self
        self.mReserveCartTable.reloadData()
        
        mCustomerName.text = ""
        mCustomerImage.contentMode = .scaleAspectFill
        
        setupReserveKeyboardDismissGesture()
        
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    // Preserve cross-location metadata whenever the cart item dictionary is rebuilt.
    private func copyCrossLocationMetadata(from source: NSDictionary, to target: NSMutableDictionary) {
        let crossLocationId = "\(source.value(forKey: "crossLocationId") ?? "")"
        let crossLocation = source.value(forKey: "crosslocation") as? Bool ?? false

        if !crossLocationId.isEmpty {
            target.setValue(crossLocationId, forKey: "crossLocationId")
        }
        target.setValue(crossLocation, forKey: "crosslocation")
    }
    
    override
    func viewDidAppear(_ animated: Bool) {
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
    
    
    
    
    
    
    @IBAction func mMinusButton(_ sender: UIButton) {
        
        
        let index = sender.tag
        if let mInvData = mReserveData[index] as? NSDictionary,
           let cells = mReserveCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? ReserveNewItems {
            
            let mMinQty = 1
            var mCurrentQty = Int(cells.mQuantity.text ?? "") ?? 0
            if  mCurrentQty == mMinQty {
                cells.mQuantity.text = "\(mMinQty)"
                cells.mAmount.text = "\((Double("\(mInvData.value(forKey: "formattedPrice") ?? "0")") ?? 0.0) * (Double(mMinQty)))"
            }else{
                mCurrentQty = mCurrentQty - 1
                cells.mQuantity.text = "\(mCurrentQty)"
                cells.mAmount.text = "\((Double("\(mInvData.value(forKey: "formattedPrice") ?? "0")") ?? 0.0) * (Double(mCurrentQty)))"
            }
            
            let mData = NSMutableDictionary()
            mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
            mData.setValue("\(cells.mQuantity.text ?? "")", forKey: "quantity")
            mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "")", forKey: "po_QTY")
            
            mData.setValue("\(mInvData.value(forKey: "sku") ?? "")", forKey: "sku")
            mData.setValue("\(mInvData.value(forKey: "stockId") ?? "")", forKey: "stockId")
            
            mData.setValue("\(mInvData.value(forKey: "price") ?? "")", forKey: "price")
            mData.setValue("\(mInvData.value(forKey: "Matatag") ?? "")", forKey: "Matatag")
            mData.setValue("\(mInvData.value(forKey: "image") ?? "")", forKey: "image")
            mData.setValue("\(mInvData.value(forKey: "metal") ?? "")", forKey: "metal")
            mData.setValue("\(mInvData.value(forKey: "size") ?? "")", forKey: "size")
            mData.setValue("\(mInvData.value(forKey: "dueDate") ?? "")", forKey: "dueDate")
            mData.setValue("\(mInvData.value(forKey: "notes") ?? "")", forKey: "notes")
            
            copyCrossLocationMetadata(from: mInvData, to: mData)
            mReserveData.removeObject(at: index)
            mReserveData.insert(mData, at: index)
        }
    }
    
    
    @IBAction func mPlusButton(_ sender: UIButton) {
        let index = sender.tag
        
        if let mInvData = mReserveData[index] as? NSDictionary,
           let cells = mReserveCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? ReserveNewItems {
            
            let mMaxQty =  mQuantityData[index]
            var mCurrentQty = Int(cells.mQuantity.text ?? "") ?? 0
            if  mCurrentQty == mMaxQty {
                cells.mQuantity.text = "\(mMaxQty)"
                
                cells.mAmount.text = "\((Double("\(mInvData.value(forKey: "formattedPrice") ?? "0")") ?? 0.0) * (Double(mMaxQty)))"
                
                
                
                
            }else{
                mCurrentQty = mCurrentQty + 1
                cells.mQuantity.text = "\(mCurrentQty)"
                cells.mAmount.text = "\((Double("\(mInvData.value(forKey: "formattedPrice") ?? "0")") ?? 0.0) * (Double(mCurrentQty)))"
                
                
            }
            
            let mData = NSMutableDictionary()
            mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
            mData.setValue("\(cells.mQuantity.text ?? "")", forKey: "quantity")
            mData.setValue("\(mInvData.value(forKey: "sku") ?? "")", forKey: "sku")
            mData.setValue("\(mInvData.value(forKey: "stockId") ?? "")", forKey: "stockId")
            mData.setValue("\(mInvData.value(forKey: "price") ?? "")", forKey: "price")
            mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "")", forKey: "po_QTY")
            mData.setValue("\(mInvData.value(forKey: "Matatag") ?? "")", forKey: "Matatag")
            mData.setValue("\(mInvData.value(forKey: "image") ?? "")", forKey: "image")
            mData.setValue("\(mInvData.value(forKey: "metal") ?? "")", forKey: "metal")
            mData.setValue("\(mInvData.value(forKey: "size") ?? "")", forKey: "size")
            mData.setValue("\(mInvData.value(forKey: "dueDate") ?? "")", forKey: "dueDate")
            mData.setValue("\(mInvData.value(forKey: "notes") ?? "")", forKey: "notes")
            
            copyCrossLocationMetadata(from: mInvData, to: mData)
            mReserveData.removeObject(at: index)
            mReserveData.insert(mData, at: index)
        }
    }
    
    
    @IBAction func mChooseDate(_ sender: UIButton) {
        guard let cells = mReserveCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? ReserveNewItems else {
            return
        }
        
        mCurrentIndex = sender.tag
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
        mToolBar.setItems([mCancel, mSpace,mDone], animated: false)
        cells.mDueDate.inputAccessoryView = mToolBar
        cells.mDueDate.inputView = mDatePicker
        cells.mDueDate.becomeFirstResponder()
        
    }
    
    @objc
    func doneDatePick(){
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy"
        
        let deliveryDate = formatter.string(from: mDatePicker.date)
        
        if let cell1 = mReserveCartTable.cellForRow(at: IndexPath(row: mCurrentIndex, section: 0)) as? ReserveNewItems {
            
            cell1.mDueDate.text  = deliveryDate
            
            
            if let mInvData = mReserveData[mCurrentIndex] as? NSDictionary {
                
                let mData = NSMutableDictionary()
                mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
                mData.setValue("\(mInvData.value(forKey: "quantity") ?? "")", forKey: "quantity")
                mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "")", forKey: "po_QTY")
                mData.setValue("\(mInvData.value(forKey: "sku") ?? "")", forKey: "sku")
                mData.setValue("\(mInvData.value(forKey: "stockId") ?? "")", forKey: "stockId")
                mData.setValue("\(mInvData.value(forKey: "price") ?? "")", forKey: "price")
                mData.setValue("\(mInvData.value(forKey: "Matatag") ?? "")", forKey: "Matatag")
                mData.setValue("\(mInvData.value(forKey: "image") ?? "")", forKey: "image")
                mData.setValue("\(mInvData.value(forKey: "metal") ?? "")", forKey: "metal")
                mData.setValue("\(mInvData.value(forKey: "size") ?? "")", forKey: "size")
                //                mData.setValue("\(cell1.mDueDate.text ?? "")", forKey: "dueDate")
                mData.setValue(deliveryDate, forKey: "dueDate")
                mData.setValue("\(mInvData.value(forKey: "notes") ?? "")", forKey: "notes")
                
                copyCrossLocationMetadata(from: mInvData, to: mData)
                mReserveData.removeObject(at: mCurrentIndex)
                mReserveData.insert(mData, at: mCurrentIndex)
            }
            self.view.endEditing(true)
        }
        
    }
    @objc func mCancelDatePick(){
        self.view.endEditing(true)
    }
    
    @IBAction func mDueDateOnChange(_ sender: UITextField) {
        
    }
    
    @IBAction func mEditAmount(_ sender: UITextField) {
        
        if let mInvData = mReserveData[sender.tag] as? NSDictionary,
           let mOrgData = mOriginalData[sender.tag] as? NSDictionary,
           let cells = mReserveCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? ReserveNewItems {
            
            if sender.text == "" || sender.text == "0" {
                cells.mAmount.text = "\(mOrgData.value(forKey: "formattedPrice") ?? "")"
                let mData = NSMutableDictionary()
                mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
                mData.setValue("\(mInvData.value(forKey: "quantity") ?? "")", forKey: "quantity")
                mData.setValue("\(mInvData.value(forKey: "sku") ?? "")", forKey: "sku")
                mData.setValue("\(mInvData.value(forKey: "stockId") ?? "")", forKey: "stockId")
                mData.setValue(cells.mAmount.text ?? "0", forKey: "formattedPrice")
                mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "0")", forKey: "po_QTY")
                
                mData.setValue("\(mInvData.value(forKey: "Matatag") ?? "")", forKey: "Matatag")
                mData.setValue("\(mInvData.value(forKey: "image") ?? "")", forKey: "image")
                mData.setValue("\(mInvData.value(forKey: "metal") ?? "")", forKey: "metal")
                mData.setValue("\(mInvData.value(forKey: "size") ?? "")", forKey: "size")
                mData.setValue("\(mInvData.value(forKey: "dueDate") ?? "")", forKey: "dueDate")
                mData.setValue("\(mInvData.value(forKey: "notes") ?? "")", forKey: "notes")
                copyCrossLocationMetadata(from: mInvData, to: mData)
                mReserveData.removeObject(at: sender.tag)
                mReserveData.insert(mData, at: sender.tag)
                
                return
            }
            
            
            let mData = NSMutableDictionary()
            mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
            mData.setValue("\(mInvData.value(forKey: "quantity") ?? "")", forKey: "quantity")
            mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "")", forKey: "po_QTY")
            
            mData.setValue("\(mInvData.value(forKey: "sku") ?? "")", forKey: "sku")
            mData.setValue("\(mInvData.value(forKey: "stockId") ?? "")", forKey: "stockId")
            mData.setValue(cells.mAmount.text, forKey: "price")
            mData.setValue("\(mInvData.value(forKey: "Matatag") ?? "")", forKey: "Matatag")
            mData.setValue("\(mInvData.value(forKey: "image") ?? "")", forKey: "image")
            mData.setValue("\(mInvData.value(forKey: "metal") ?? "")", forKey: "metal")
            mData.setValue("\(mInvData.value(forKey: "size") ?? "")", forKey: "size")
            mData.setValue("\(mInvData.value(forKey: "dueDate") ?? "")", forKey: "dueDate")
            mData.setValue("\(mInvData.value(forKey: "notes") ?? "")", forKey: "notes")
            
            copyCrossLocationMetadata(from: mInvData, to: mData)
            mReserveData.removeObject(at: sender.tag)
            mReserveData.insert(mData, at: sender.tag)
            
        }
    }
    
    @IBAction func mEditremarks(_ sender: UITextField) {
        
        if let mInvData = mReserveData[sender.tag] as? NSDictionary,
           let cells = mReserveCartTable.cellForRow(at: IndexPath(row: sender.tag , section: 0)) as? ReserveNewItems {
            let mData = NSMutableDictionary()
            mData.setValue("\(mInvData.value(forKey: "id") ?? "")", forKey: "id")
            mData.setValue("\(mInvData.value(forKey: "quantity") ?? "")", forKey: "quantity")
            mData.setValue("\(mInvData.value(forKey: "po_QTY") ?? "")", forKey: "po_QTY")
            
            mData.setValue("\(mInvData.value(forKey: "sku") ?? "")", forKey: "sku")
            mData.setValue("\(mInvData.value(forKey: "stockId") ?? "")", forKey: "stockId")
            mData.setValue("\(mInvData.value(forKey: "price") ?? "")", forKey: "price")
            mData.setValue("\(mInvData.value(forKey: "Matatag") ?? "")", forKey: "Matatag")
            mData.setValue("\(mInvData.value(forKey: "image") ?? "")", forKey: "image")
            mData.setValue("\(mInvData.value(forKey: "metal") ?? "")", forKey: "metal")
            mData.setValue("\(mInvData.value(forKey: "size") ?? "")", forKey: "size")
            mData.setValue("\(mInvData.value(forKey: "dueDate") ??  "")", forKey: "dueDate")
            //            mData.setValue(cells.mRemarks.text ?? "", forKey: "notes")
            mData.setValue(cells.mRemarks.text ?? "", forKey: "remark")
            mData.setValue(cells.mRemarks.text ?? "", forKey: "note")
            copyCrossLocationMetadata(from: mInvData, to: mData)
            mReserveData.removeObject(at: sender.tag)
            mReserveData.insert(mData, at: sender.tag)
        }
    }

    // MARK: - Reserve Note Suggestions

    private func reserveSuggestionItems() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM yyyy"
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let pickup = "Pickup on \(formatter.string(from: tomorrow)), 2:00 PM"

        return [
            pickup,
            "On hold until closing time",
            "Customer response",
            "Payment verification"
        ]
    }

    private func setupReserveNoteSuggestions() {
        guard reserveSuggestionsView == nil else { return }

        let popup = UIView()
        popup.backgroundColor = .white
        popup.layer.cornerRadius = 6
        popup.layer.shadowColor = UIColor.black.cgColor
        popup.layer.shadowOpacity = 0.14
        popup.layer.shadowRadius = 8
        popup.layer.shadowOffset = CGSize(width: 0, height: 3)
        popup.isHidden = true
        view.addSubview(popup)
        reserveSuggestionsView = popup

        let title = UILabel()
        title.text = "Suggestions"
        title.font = UIFont(name: "segoe_bold", size: 10) ?? .boldSystemFont(ofSize: 10)
        title.textColor = .label
        title.translatesAutoresizingMaskIntoConstraints = false
        popup.addSubview(title)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: popup.topAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: 18),
            title.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -12),
            title.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func showReserveSuggestions() {
        guard reserveSuggestionSessionActive,
              let noteField = activeReserveNoteField else { return }

        setupReserveNoteSuggestions()
        guard let popup = reserveSuggestionsView else { return }

        let query = (noteField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let allItems = reserveSuggestionItems()
        let items = query.isEmpty ? allItems : allItems.filter {
            $0.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }

        reserveSuggestionsButtons.forEach { $0.removeFromSuperview() }
        reserveSuggestionsButtons.removeAll()

        guard !items.isEmpty else {
            reserveVisibleSuggestions = []
            popup.isHidden = true
            return
        }
        reserveVisibleSuggestions = items

        let titleHeight: CGFloat = 32
        let rowHeight: CGFloat = 42
        let popupWidth = min(CGFloat(306), view.bounds.width - 20)
        let popupHeight = titleHeight + CGFloat(items.count) * rowHeight + 8

        let noteFrame = noteField.convert(noteField.bounds, to: view)
        var x = noteFrame.minX
        var y = noteFrame.minY - popupHeight - 8
        if x + popupWidth > view.bounds.width - 10 { x = view.bounds.width - popupWidth - 10 }
        if x < 10 { x = 10 }
        if y < view.safeAreaInsets.top + 8 { y = view.safeAreaInsets.top + 8 }

        popup.frame = CGRect(x: x, y: y, width: popupWidth, height: popupHeight)
        popup.isHidden = false

        for (index, item) in items.enumerated() {
            let button = UIButton(type: .system)
            button.tag = index
            button.setTitle(item, for: .normal)
            button.setTitleColor(.label, for: .normal)
            button.titleLabel?.font = UIFont(name: "segoe_regular", size: 14) ?? .systemFont(ofSize: 14)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 10)
            button.addTarget(self, action: #selector(reserveSuggestionTapped(_:)), for: .touchUpInside)
            button.frame = CGRect(x: 0, y: titleHeight + CGFloat(index) * rowHeight, width: popupWidth, height: rowHeight)
            popup.addSubview(button)
            reserveSuggestionsButtons.append(button)
        }
    }

    private func hideReserveSuggestions() {
        reserveSuggestionsView?.isHidden = true
    }

    @objc private func reserveSuggestionTapped(_ sender: UIButton) {
        guard let noteField = activeReserveNoteField else { return }
        guard sender.tag >= 0, sender.tag < reserveVisibleSuggestions.count else { return }

        noteField.text = reserveVisibleSuggestions[sender.tag]
        mEditremarks(noteField)
        reserveSuggestionSessionActive = false
        hideReserveSuggestions()
        noteField.resignFirstResponder()
    }

    @objc private func reserveNoteEditingChanged(_ textField: UITextField) {
        guard reserveSuggestionSessionActive, textField === activeReserveNoteField else { return }
        showReserveSuggestions()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard (0..<mReserveData.count).contains(textField.tag) else { return }
        activeReserveNoteField = textField
        reserveSuggestionSessionActive = true
        DispatchQueue.main.async { [weak self] in
            self?.showReserveSuggestions()
        }
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        guard textField === activeReserveNoteField else { return true }

        textField.text = ""
        mEditremarks(textField)
        reserveSuggestionSessionActive = true
        DispatchQueue.main.async { [weak self] in
            self?.showReserveSuggestions()
        }
        return false
    }

    private func setupReserveKeyboardDismissGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(reserveDismissKeyboardAndSuggestions(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
        reserveDismissTapGesture = tap
    }

    @objc private func reserveDismissKeyboardAndSuggestions(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        if let noteField = activeReserveNoteField,
           noteField.convert(noteField.bounds, to: view).contains(point) {
            return
        }

        reserveSuggestionSessionActive = false
        hideReserveSuggestions()
        view.endEditing(true)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === reserveDismissTapGesture else { return true }

        if let touchedView = touch.view {
            if let noteField = activeReserveNoteField,
               touchedView === noteField || touchedView.isDescendant(of: noteField) {
                return false
            }
            if let popup = reserveSuggestionsView,
               touchedView === popup || touchedView.isDescendant(of: popup) {
                return false
            }
        }
        return true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reserveSuggestionSessionActive = false
        hideReserveSuggestions()
        view.endEditing(true)
    }
    
    
    @IBAction func mDeleteReserve(_ sender: UIButton) {
        mDeleteCartItems(index: sender.tag)
    }
    
    func mDeleteCartItems(index: Int) {
        self.mReserveData.removeObject(at: index)
        self.mReserveCartTable.reloadData()
        
    }
    @IBAction func mOpenImages(_ sender: UIButton) {
        
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
            self.mDeleteCartItems(index: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mReserveData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        guard let cells = tableView.dequeueReusableCell(withIdentifier: "ReserveNewItems") as? ReserveNewItems else {
            return UITableViewCell()
        }
        
        cells.mDueDate.tag = indexPath.row
        cells.mSno.text = "#\(indexPath.row + 1)"
        
        if let mData = mReserveData[indexPath.row] as? NSDictionary {
            cells.mRemarks.tag = indexPath.row
            cells.mRemarks.delegate = self
            cells.mRemarks.removeTarget(self, action: #selector(reserveNoteEditingChanged(_:)), for: .editingChanged)
            cells.mRemarks.addTarget(self, action: #selector(reserveNoteEditingChanged(_:)), for: .editingChanged)
            cells.mChooseDate.tag = indexPath.row
            cells.mPlusButton.tag = indexPath.row
            cells.mMinusButton.tag = indexPath.row
            cells.mDeleteItem.tag = indexPath.row
            cells.mAmount.tag = indexPath.row
            cells.mRemarks.placeholder = "EX. Urgent Order".localizedString
            cells.mRemarks.clearButtonMode = .whileEditing
            cells.mRemarks.text = "\(mData.value(forKey: "remark") ?? mData.value(forKey: "note") ?? "")"
            cells.mDueDate.text = "\(mData.value(forKey: "dueDate") ?? "--")"
            cells.mProductInfo.text = "\(mData.value(forKey: "Matatag") ?? "--")"
            cells.mSKU.text = "\(mData.value(forKey: "sku") ?? "--")"
            cells.mMaterialInfo.text = "\(mData.value(forKey: "metal") ?? "--")" + " \(mData.value(forKey: "size") ?? "--")"
            
            cells.mAmount.text = "\(mData.value(forKey: "formattedPrice") ?? mData.value(forKey: "price") ?? "--")"
            cells.mQuantity.text = "\(mData.value(forKey: "quantity") ?? "--")"
            cells.mStockId.text = "\(mData.value(forKey: "stockId") ?? "--")"
            cells.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "image") ?? "")")
            
            if let reserveDate = UserDefaults.standard.string(forKey: "reserveDeliveryDate") {
                let inputFormatter = DateFormatter()
                inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                if let date = inputFormatter.date(from: reserveDate) {
                    let outputFormatter = DateFormatter()
                    outputFormatter.dateFormat = "MM/dd/yyyy"
                    let outputDateString = outputFormatter.string(from: date)
                    cells.mDueDate.text = outputDateString
                }
            }
            
        }
        return cells
    }
    
    func mCreateNewCustomer() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
        if let mCreateCustomer = storyBoard.instantiateViewController(withIdentifier: "CreateCustomer") as? CreateCustomer {
            self.navigationController?.pushViewController(mCreateCustomer, animated:true)
        }
    }
    
    func mGetCustomerData(data: NSMutableDictionary) {
        if let id = data.value(forKey: "id") as? String {
            UserDefaults.standard.set(id, forKey: "DEFAULTCUSTOMER")
            self.mCustomerId = id
        }
        UserDefaults.standard.set(data.value(forKey: "profile") ?? "", forKey: "DEFAULTCUSTOMERPICTURE")
        
        if let name = data.value(forKey: "name") as? String {
            UserDefaults.standard.set(name, forKey: "DEFAULTCUSTOMERNAME")
            self.mCustomerName.text = name
        }
        
        self.mCustomerImage.downlaodImageFromUrl(urlString: "\(data.value(forKey: "profile") ?? "")")
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
            return
        }
        
        if mReserveData.count == 0 {
            CommonClass.showSnackBar(message: "No items in cart!")
            return
        }
        
        print("mCreateReseveNow")
        
        let mReserveProductsData = NSMutableArray()
        
        for item in mReserveData {
            if let value = item as? NSDictionary {
                
                let mData = NSMutableDictionary()
                
                print("mCreateReseveNow value = \(value)")
                
                // Backend createReserveOrder payload
                mData.setValue(
                    "\(value.value(forKey: "stockId") ?? "")",
                    forKey: "stock_id"
                )
                
                mData.setValue(
                    Int("\(value.value(forKey: "quantity") ?? "0")") ?? 0,
                    forKey: "reserve_qty"
                )
                
                mData.setValue(
                    "\(value.value(forKey: "id") ?? "")",
                    forKey: "po_product_id"
                )
                
                mData.setValue(
                    "\(value.value(forKey: "remark") ?? "")",
                    forKey: "remark"
                )
                
                mReserveProductsData.add(mData)
            }
        }
        
        print("mReserveProductsData = \(mReserveProductsData)")
        
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        // TODO:
        // Get these values from the existing project/user/order data.
        let deliveryDate = UserDefaults.standard.string(forKey: "reserveDeliveryDate") ?? ""
        let transactionDate = ISO8601DateFormatter().string(from: Date())
        
        // Only use the explicit Sales Person selection. The generic
        // sales_person_id key may contain the logged-in user's ID.
        let salesPersonId =
            (UserDefaults.standard.string(forKey: "SALESPERSONID") ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

        print("DEBUG_CREATE_RESERVE_SALES_PERSON_ID =", salesPersonId)
        
        var voucherId =
        UserDefaults.standard.string(forKey: "voucher_id") ?? ""
        if let mInvData = mReserveData[0] as? NSDictionary {
            voucherId = "\(mInvData.value(forKey: "voucher_id") ?? UserDefaults.standard.string(forKey: "voucher_id") ?? "")"
        }
        
        var params: [String: Any] = [
            "customer_id": mCustomerId,
            "ref_no": "",
            "delivery_date": deliveryDate,
            "transaction_date": transactionDate,
            "sales_person_id": salesPersonId,
            "byMobile": true,
            "voucher_id": voucherId,
            "reservedItems": mReserveProductsData
        ]
        // Only one source flag is included for each reserve request.
        params[reserveSource.payloadFlag] = true
        
        // Cross-location Reserve
        // mCrossLocationId is passed directly from QuickView and must not
        // depend on the crosslocation flag stored inside each cart item.
        // This prevents the destination location from disappearing from
        // createReserveOrder payload.
        var payloadCrossLocationId =
            mCrossLocationId.trimmingCharacters(in: .whitespacesAndNewlines)

        // Fallback for older/cart-created items that already contain
        // crossLocationId metadata.
        if payloadCrossLocationId.isEmpty {
            for case let item as NSDictionary in mReserveData {
                let itemCrossLocationId =
                    "\(item.value(forKey: "crossLocationId") ?? "")"
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if !itemCrossLocationId.isEmpty {
                    payloadCrossLocationId = itemCrossLocationId
                    break
                }
            }
        }

        if !payloadCrossLocationId.isEmpty {
            params["crosslocation"] = true
            params["crossLocationId"] = payloadCrossLocationId
        }

        print("========== CROSS LOCATION PAYLOAD ==========")
        print("mIsCrossLocationReserve =", mIsCrossLocationReserve)
        print("mCrossLocationId =", mCrossLocationId)
        print("payloadCrossLocationId =", payloadCrossLocationId)
        print("crosslocation =", params["crosslocation"] ?? "nil")
        print("crossLocationId =", params["crossLocationId"] ?? "nil")
        print("============================================")
        
        CommonClass.showFullLoader(view: self.view)
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        print("========== FINAL RESERVE ORDER PAYLOAD ==========")
        print("IS CROSS LOCATION =", mIsCrossLocationReserve)
        print("CROSS LOCATION ID =", mCrossLocationId)
        print("PARAMS =", params)
        print("=================================================")
        
        //        let mCreateReserveOrder =
        //            "\(baseURL)/api/v1/Mobile/my/createReserveOrder"
        
        mGetData(
            url: mCreateReserveOrder,
            headers: sGisHeaders,
            params: params
        ) { response, status in
            
            CommonClass.stopLoader()
            
            if status {
                
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    
                    CommonClass.showSnackBar(
                        message: "Reserved Items Successfully!"
                    )
                    
                    let storyBoard =
                    UIStoryboard(name: "reserveBoard", bundle: nil)
                    
                    if let mInventoryPage =
                        storyBoard.instantiateViewController(
                            withIdentifier: "InventoryPageNew"
                        ) as? InventoryPage {
                        
                        self.navigationController?.pushViewController(
                            mInventoryPage,
                            animated: true
                        )
                    }
                    
                } else {
                    let message = "\(response.value(forKey: "message") ?? "OOP's something went wrong!")"
                    print("Reserve Order API Error =", response)
                    CommonClass.showSnackBar(message: message)
                }
                
            } else {
                print("Reserve Order API Failed")
                CommonClass.showSnackBar(message: "Reserve order failed. Please try again.")
            }
        }
    }
    //    @IBAction func mCreateReseveNow(_ sender: Any) {
    //
    //        if mCustomerId == "" {
    //            CommonClass.showSnackBar(message: "Please choose customer!")
    //            return
    //        }
    //
    //        if mReserveData.count == 0 {
    //            CommonClass.showSnackBar(message: "No items in cart!")
    //            return
    //        }
    //
    //        print("mCreateReseveNow")
    //        let mReserveProductsData = NSMutableArray()
    //        for item in mReserveData {
    //            if let value = item as? NSDictionary {
    //                let mData = NSMutableDictionary()
    //                print("mCreateReseveNow value = \(value)")
    ////                mData.setValue("\(value.value(forKey: "sku") ?? "")", forKey: "SKU")
    ////                mData.setValue("\(value.value(forKey: "stockId") ?? "")", forKey: "stock_id")
    ////                mData.setValue("\(value.value(forKey: "quantity") ?? "")", forKey: "reserve_qty")
    ////                mData.setValue("\(value.value(forKey: "price") ?? "")", forKey: "price")
    ////                mData.setValue("\(value.value(forKey: "remark") ?? "")", forKey: "remark")
    ////                mData.setValue("\(value.value(forKey: "dueDate") ?? "" )", forKey: "dueDate")
    ////                mData.setValue("\(value.value(forKey: "id") ?? "")", forKey: "po_product_id")
    //
    //                mData.setValue(
    //                    "\(value.value(forKey: "stockId") ?? "")",
    //                    forKey: "stock_id"
    //                )
    //
    //                mData.setValue(
    //                    Int("\(value.value(forKey: "quantity") ?? "0")") ?? 0,
    //                    forKey: "reserve_qty"
    //                )
    //
    //                mData.setValue(
    //                    "\(value.value(forKey: "id") ?? "")",
    //                    forKey: "po_product_id"
    //                )
    //
    //                mData.setValue(
    //                    "\(value.value(forKey: "remark") ?? "")",
    //                    forKey: "remark"
    //                )
    //
    ////                mData.setValue(
    ////                    "\(value.value(forKey: "crossLocationId") ?? "")",
    ////                    forKey: "crossLocationId"
    ////                )
    ////
    ////                mData.setValue(
    ////                    value.value(forKey: "crosslocation") as? Bool ?? false,
    ////                    forKey: "crosslocation"
    ////                )
    //                mReserveProductsData.add(mData)
    //            }
    //        }
    //
    //        print("mReserveProductsData = \(mReserveProductsData)")
    //        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
    //
    ////        var params:[String: Any] = [
    ////            "reservedItems" : mReserveProductsData,
    ////            "customer_id" : mCustomerId,
    ////            "location_id": mLocation]
    //
    //        var params: [String: Any] = [
    //            "customer_id": mCustomerId,
    //            "ref_no": "",
    //            "delivery_date": deliveryDate,
    //            "transaction_date": transactionDate,
    //            "sales_person_id": salesPersonId,
    //            "voucher_id": voucherId,
    //            "reservedItems": mReserveProductsData
    //        ]
    //
    //        if mIsCrossLocationReserve {
    //            params["crosslocation"] = true
    //            params["crossLocationId"] = mCrossLocationId
    //        }
    //
    //        CommonClass.showFullLoader(view: self.view)
    //
    //        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
    //        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
    //
    //        print("========== FINAL RESERVE PAYLOAD ==========")
    //        print("IS CROSS LOCATION =", mIsCrossLocationReserve)
    //        print("CROSS LOCATION ID =", mCrossLocationId)
    //        print("PARAMS =", params)
    //        print("===========================================")
    //
    ////        mGetData(url: mCreateReserve ,headers: sGisHeaders,  params: params) { response , status in
    //        mGetData(url: mCreateReserveOrder ,headers: sGisHeaders,  params: params) { response , status in
    //            CommonClass.stopLoader()
    //            if status {
    //                if "\(response.value(forKey: "code") ?? "")" == "200" {
    //
    //                    CommonClass.showSnackBar(message: "Reserved Items Successfully!")
    //                    let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
    //                    if let mInventoryPage = storyBoard.instantiateViewController(withIdentifier: "InventoryPageNew") as? InventoryPage {
    //                        self.navigationController?.pushViewController(mInventoryPage, animated:true)
    //                    }
    //                }else{
    //                }
    //            }
    //        }
    //
    //    }
}
