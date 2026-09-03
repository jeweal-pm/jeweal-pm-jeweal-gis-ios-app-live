//
//  SalesPerson.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 04/04/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class SalesPersonTableCell : UITableViewCell , UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var mTableHeight: NSLayoutConstraint!
    @IBOutlet weak var mNotes: UITextView!
    
    @IBOutlet weak var mCustomerImage: UIImageView!
    @IBOutlet weak var mParkItemsTable: UITableView!
    @IBOutlet weak var mCustomerName: UILabel!
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mCheckImage: UIImageView!
    
    @IBOutlet weak var mMobile: UILabel!
    @IBOutlet weak var mType: UILabel!
    @IBOutlet weak var mDate: UILabel!
    
    var mCartData = NSArray()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mCartData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ParkNestedCell") as? ParkNestedCell,
              let mData = mCartData[indexPath.row] as? NSDictionary else {
            return UITableViewCell()
        }
        
        cell.mSNo.text = "\(indexPath.row + 1)"
        cell.mProductName.text = "\(mData.value(forKey: "name") ?? "")"
        cell.mQty.text = "\(mData.value(forKey: "Qty") ?? "")"
        cell.mPrice.text = "\(mData.value(forKey: "currency") ?? "")" + "\(mData.value(forKey: "price") ?? "")"
        cell.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
        cell.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "")"
        cell.mMetalSizeColor.text = "\(mData.value(forKey: "metal_name") ?? "")" + "\(mData.value(forKey: "size_name") ?? "")"
        
        
        cell.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
        
        return cell
    }
}

class TransactionCell : UITableViewCell {
    
    @IBOutlet weak var mCheckImage: UIImageView!
    @IBOutlet weak var mCheckButton: UIButton!
    @IBOutlet weak var mPrice: UILabel!
    @IBOutlet weak var mTotalQuantity: UILabel!
    @IBOutlet weak var mTotalInvoice: UILabel!
    @IBOutlet weak var mCustomerName: UILabel!
    @IBOutlet weak var mAddressMobile: UILabel!
    @IBOutlet weak var mCustomerImage: UIImageView!
    
    @IBOutlet weak var mTotalQuantityLABEL: UILabel!
    @IBOutlet weak var mTotalInvoiceLABEL: UILabel!
    @IBOutlet weak var mTotalAmountLABEL: UILabel!
    
}

class SalesPerson: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    let mDatePicker:UIDatePicker = UIDatePicker()
    @IBOutlet weak var mProfilePicture: UIImageView!
    
    @IBOutlet weak var mUserName: UILabel!
    
    @IBOutlet weak var mCloudAccount: UILabel!
    @IBOutlet weak var mLocation: UILabel!
    @IBOutlet weak var mOrganization: UILabel!
    @IBOutlet weak var mTime: UILabel!
    @IBOutlet weak var mDOB: UILabel!
    @IBOutlet weak var TransactionTable: UITableView!
    @IBOutlet weak var mCustomerTable: UITableView!
    
    @IBOutlet weak var mTransactionLabel: UILabel!
    @IBOutlet weak var mTransactionLine: UILabel!
    
    @IBOutlet weak var mCustomerLabel: UILabel!
    @IBOutlet weak var mCustomerLine: UILabel!
    
    @IBOutlet weak var mTotalCustomers: UILabel!
    @IBOutlet weak var mTotalCustomerView: UIView!
    
    @IBOutlet weak var mTransactionView: UIStackView!
    
    @IBOutlet weak var mTotalQuantity: UILabel!
    @IBOutlet weak var mTotalInvoice: UILabel!
    @IBOutlet weak var mTotalAmount: UILabel!
    @IBOutlet weak var mCustomerView: UIStackView!
    
    @IBOutlet weak var mDetailsView: UIView!
    @IBOutlet weak var mViewMoreCheckIcon: UIImageView!
    @IBOutlet weak var mViewMoreLess: UILabel!
    @IBOutlet weak var mMostAmount: UILabel!
    @IBOutlet weak var mCurrentDate: UITextField!
    var mMonth = ""
    var mYear = ""
    var mSalespersonTransactionData = NSArray()
    var mCustomerTransactionData = NSArray()
    
    var delegate:SalesPersonTransactionDelegate? = nil
    var mIndex = -1
    // Sales Person selected from the POS Sales Person list.
    var mSalesPersonId = ""
    
    @IBOutlet weak var mStoreLABEL: UILabel!
    
    @IBOutlet weak var mCloudAccountLABEL: UILabel!
    @IBOutlet weak var mOrganizationLABEL: UILabel!
    
    @IBOutlet weak var mTotalAmountLABEL: UILabel!
    @IBOutlet weak var mHeading: UILabel!
    
    @IBOutlet weak var mTotalInvoiceLABEL: UILabel!
    
    @IBOutlet weak var mTotalCustomerLABEL: UILabel!
    @IBOutlet weak var mTotalQuantityLABEL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        mShowDatePicker()
        
        mTotalCustomerLABEL.text = "Total Customer".localizedString
        
        mStoreLABEL.text = "Store".localizedString
        mCloudAccountLABEL.text = "Cloud Account".localizedString
        mOrganizationLABEL.text = "Organization".localizedString
        mTotalAmountLABEL.text = "Total Amount".localizedString
        mHeading.text = "Sales Person".localizedString
        mTotalInvoiceLABEL.text = "Total Invoice".localizedString
        mTotalQuantityLABEL.text = "Total Quantity".localizedString
        mTransactionLabel.text = "Transaction".localizedString
        mCustomerLabel.text = "Customer".localizedString
        mViewMoreLess.text = "View More".localizedString
        
        mCustomerTable.rowHeight = 181
        mTransactionLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
        mCustomerLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        mTransactionLine.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
        mCustomerLine.backgroundColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        mTransactionView.isHidden = false
        mCustomerView.isHidden = true
        
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM yyyy"
        
        let formatter2 = DateFormatter()
        formatter2.calendar = Calendar(identifier: .gregorian)
        formatter2.locale = Locale(identifier: "en_US_POSIX")
        formatter2.dateFormat = "HH:mm"
        mDOB.text = formatter.string(from: currentDateTime)
        mTime.text = formatter2.string(from: currentDateTime)

        // Prevent the profile date/time from being truncated with "...".
        mDOB.numberOfLines = 1
        mDOB.adjustsFontSizeToFitWidth = true
        mDOB.minimumScaleFactor = 0.75
        mTime.numberOfLines = 1
        mTime.adjustsFontSizeToFitWidth = true
        mTime.minimumScaleFactor = 0.75
        
        let mMonthm = DateFormatter()
        mMonthm.dateFormat = "MMM"
        
        let mMonthInt = DateFormatter()
        mMonthInt.dateFormat = "MM"
        
        let mYeard = DateFormatter()
        mYeard.calendar = Calendar(identifier: .gregorian)
        mYeard.locale = Locale(identifier: "en_US_POSIX")
        mYeard.dateFormat = "yyyy"
        
        let mYearInt = DateFormatter()
        mYearInt.calendar = Calendar(identifier: .gregorian)
        mYearInt.locale = Locale(identifier: "en_US_POSIX")
        mYearInt.dateFormat = "yyyy"
        mCurrentDate.text  =   "\(mMonthm.string(from: mDatePicker.date)) "+"\(mYeard.string(from: mDatePicker.date))"
        mMonth = "\(mMonthInt.string(from: mDatePicker.date))"
        mYear = "\(mYearInt.string(from: mDatePicker.date))"
        
        self.mMostAmount.text = "Low to High"
        mGetSalesPersonProfile()
        
        
        
        
    }
    
    
    // MARK: - Sales Person Profile API
    // Backend endpoint:
    // POST /api/v1/Mobile/pos/report/salesPersonProfile
    //
    // The API response is mapped into the existing Sales Person UI:
    // salesperson, period, transactions and customers.
    private let mSalesPersonProfileURL = "https://api2uat.gis247.net/api/v1/Mobile/pos/report/salesPersonProfile"

    private func mGetSalesPersonProfile() {
        let calendar = Calendar(identifier: .gregorian)
        let selectedDate = mDatePicker.date

        let month = calendar.component(.month, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)

        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: selectedDate)

        guard !mSalesPersonId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ Sales Person Profile: missing sales_person_id")
            return
        }

        let params: [String: Any] = [
            "sales_person_id": mSalesPersonId,
            "month": month,
            "year": year,
            "date": date
        ]

        print("========== SALES PERSON PROFILE API ==========")
        print("URL =", mSalesPersonProfileURL)
        print("PAYLOAD =", params)
        print("==============================================")

        mGetData(
            url: mSalesPersonProfileURL,
            headers: sGisHeaders,
            params: params
        ) { [weak self] response, status in
            guard let self = self, status else {
                print("❌ SALES PERSON PROFILE API FAILED")
                return
            }

            print("========== SALES PERSON PROFILE RESPONSE ==========")
            print(response)
            print("====================================================")

            DispatchQueue.main.async {
                self.mMapSalesPersonProfileResponse(response)
            }
        }
    }

    private func mMapSalesPersonProfileResponse(_ response: NSDictionary) {

        // MARK: salesperson
        if let salesperson = response.value(forKey: "salesperson") as? NSDictionary {

            let displayName = "\(salesperson.value(forKey: "display_name") ?? "")"
            let name = "\(salesperson.value(forKey: "name") ?? "")"
            let imageURL = "\(salesperson.value(forKey: "image") ?? "")"
            let country = "\(salesperson.value(forKey: "country") ?? "")"
            let phone = "\(salesperson.value(forKey: "phone") ?? "")"
            let datetimeDisplay = "\(salesperson.value(forKey: "datetime_display") ?? "")"
            let datetime = "\(salesperson.value(forKey: "datetime") ?? "")"

            mUserName.text = !displayName.isEmpty ? displayName : name

            if !imageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let url = URL(string: imageURL) {
                mProfilePicture.contentMode = .scaleAspectFill
                mProfilePicture.downlaodImageFromUrl(urlString: imageURL)
                _ = url
            }

            // These fields are available from the new API.
            // Keep them mapped to the existing labels so the existing UI
            // can display the returned profile information without requiring
            // storyboard changes.
            mLocation.text = country.isEmpty ? "--" : country
            mCloudAccount.text = phone.isEmpty ? "--" : phone

            // Always display the profile date in Gregorian/AD format.
            // Prefer the API's ISO `datetime` value because `datetime_display`
            // may contain a Buddhist Era (BE) year.
            if let isoDate = ISO8601DateFormatter().date(from: datetime) {
                let dateFormatter = DateFormatter()
                dateFormatter.calendar = Calendar(identifier: .gregorian)
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.timeZone = TimeZone.current
                dateFormatter.dateFormat = "dd MMM yyyy"
                mDOB.text = dateFormatter.string(from: isoDate)

                dateFormatter.dateFormat = "HH:mm"
                mTime.text = dateFormatter.string(from: isoDate)
            } else if !datetimeDisplay.isEmpty {
                // Fallback for older responses that only provide datetime_display.
                // Convert a trailing BE year (e.g. 2569) to AD (2026).
                let parts = datetimeDisplay.components(separatedBy: " | ")
                let datePart = parts.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? datetimeDisplay

                // Convert a BE year in the fallback string to AD without using
                // a closure-based String replacement (which is not available
                // on the String API used by this project).
                var adDatePart = datePart
                let dateComponents = datePart.components(separatedBy: " ")
                if let yearIndex = dateComponents.indices.last,
                   let beYear = Int(dateComponents[yearIndex]),
                   beYear >= 2400, beYear <= 3000 {
                    var convertedComponents = dateComponents
                    convertedComponents[yearIndex] = String(beYear - 543)
                    adDatePart = convertedComponents.joined(separator: " ")
                }

                mDOB.text = adDatePart
                mTime.text = parts.count >= 2 ? parts.dropFirst().joined(separator: " | ").trimmingCharacters(in: .whitespacesAndNewlines) : ""
            } else {
                mDOB.text = ""
                mTime.text = ""
            }

            mDOB.numberOfLines = 1
            mDOB.adjustsFontSizeToFitWidth = true
            mDOB.minimumScaleFactor = 0.75
            mTime.numberOfLines = 1
            mTime.adjustsFontSizeToFitWidth = true
            mTime.minimumScaleFactor = 0.75
        }

        // MARK: period
        if let period = response.value(forKey: "period") as? NSDictionary {
            // Do not use period.label here because the API returns the Buddhist Era (BE).
            // The profile date selector must remain Gregorian/AD.
            let displayFormatter = DateFormatter()
            displayFormatter.calendar = Calendar(identifier: .gregorian)
            displayFormatter.locale = Locale(identifier: "en_US_POSIX")
            displayFormatter.dateFormat = "MMM yyyy"
            mCurrentDate.text = displayFormatter.string(from: self.mDatePicker.date)

            if let month = period.value(forKey: "month") as? NSNumber {
                mMonth = String(month.intValue)
            } else if let month = period.value(forKey: "month") as? String {
                mMonth = month
            }

            if let year = period.value(forKey: "year") as? NSNumber {
                mYear = String(year.intValue)
            } else if let year = period.value(forKey: "year") as? String {
                mYear = year
            }
        }

        // MARK: transactions summary
        // The new API returns summary data only. The existing transaction
        // detail table is therefore cleared until the backend provides a
        // transaction list in this endpoint.
        if let transactions = response.value(forKey: "transactions") as? NSDictionary {

            mTotalInvoice.text = "\(transactions.value(forKey: "total_invoice") ?? "0")"
            mTotalQuantity.text = "\(transactions.value(forKey: "total_quantity") ?? "0")"

            if let amountDisplay = transactions.value(forKey: "total_amount_display") as? String,
               !amountDisplay.isEmpty {
                mTotalAmount.text = amountDisplay
            } else {
                mTotalAmount.text = "\(transactions.value(forKey: "total_amount") ?? "0")"
            }

            mSalespersonTransactionData = NSArray()
            TransactionTable.reloadData()
        }

        // MARK: customers
        if let customers = response.value(forKey: "customers") as? NSDictionary {

            let total = customers.value(forKey: "total") ?? "0"
            mTotalCustomers.text = "\(total)"

            if let customerList = customers.value(forKey: "list") as? NSArray {

                // Map the new customer keys to the keys already used by
                // TransactionCell, so the existing storyboard/cell remains intact.
                let mappedCustomers: [NSDictionary] = customerList.compactMap { item in
                    guard let customer = item as? NSDictionary else { return nil }

                    let mapped: [String: Any] = [
                        "customer_id": customer.value(forKey: "id") ?? "",
                        "customer_name": customer.value(forKey: "name") ?? "--",
                        "customer_profile": customer.value(forKey: "image") ?? "",
                        "total_invoice": customer.value(forKey: "total_invoice") ?? "0",
                        "total_qty": customer.value(forKey: "total_quantity") ?? "0",
                        "total_amount": customer.value(forKey: "total_amount_display")
                            ?? customer.value(forKey: "total_amount")
                            ?? "0",
                        "customer_country": "",
                        "customer_mobile": ""
                    ]

                    return NSDictionary(dictionary: mapped)
                }

                mCustomerTransactionData = NSArray(array: mappedCustomers)
            } else {
                mCustomerTransactionData = NSArray()
            }

            mCustomerTable.delegate = self
            mCustomerTable.dataSource = self
            mCustomerTable.reloadData()
        } else {
            mCustomerTransactionData = NSArray()
            mCustomerTable.reloadData()
        }
    }

    @IBAction func mSelectTransaction(_ sender: Any) {
        mTransactionLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
        mCustomerLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        mTransactionLine.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
        mCustomerLine.backgroundColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        mTransactionView.isHidden = false
        mCustomerView.isHidden = true
        
    }
    
    @IBAction func mSelectCustomer(_ sender: Any) {
        mCustomerLabel.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
        mTransactionLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        mCustomerLine.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
        mTransactionLine.backgroundColor = #colorLiteral(red: 0.6431372549, green: 0.6431372549, blue: 0.6431372549, alpha: 1)
        mTransactionView.isHidden = true
        mCustomerView.isHidden = false
    }
    
    
    @IBAction func mBack(_ sender: Any) {
        self.dismiss(animated: true)
        
    }
    
    
    @IBAction func mViewMore(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            mViewMoreCheckIcon.image = UIImage(systemName: "chevron.down")
            mDetailsView.isHidden = true
            mViewMoreLess.text = "View More".localizedString
        }else{
            mViewMoreLess.text = "View Less".localizedString
            mDetailsView.isHidden = false
            mViewMoreCheckIcon.image = UIImage(systemName:  "chevron.up")
        }
    }
    
    
    @IBAction func mChooseDate(_ sender: Any) {
        mCurrentDate.becomeFirstResponder()
    }
    
    func mShowDatePicker(){
        let currentDate = Date()
        var datecomp = DateComponents()
        let min = Calendar.init(identifier: .gregorian)
        
        mDatePicker.preferredDatePickerStyle = .wheels
        // Always show/select Gregorian (AD) dates in the Sales Person profile.
        mDatePicker.calendar = Calendar(identifier: .gregorian)
        mDatePicker.locale = Locale(identifier: "en_US_POSIX")
        datecomp.year = -5
        let minDates = min.date(byAdding: datecomp, to: currentDate)
        
        datecomp.year = 0
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
        
        mCurrentDate.inputAccessoryView = mToolBar
        mCurrentDate.inputView = mDatePicker
        
    }
    @objc func doneDatePick(){
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let deliveryDate = dateFormatter.string(from: mDatePicker.date)

        let displayFormatter = DateFormatter()
        displayFormatter.calendar = Calendar(identifier: .gregorian)
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")
        displayFormatter.dateFormat = "MMM yyyy"
        mCurrentDate.text = displayFormatter.string(from: mDatePicker.date)
        
        let monthFormatter = DateFormatter()
        monthFormatter.calendar = Calendar(identifier: .gregorian)
        monthFormatter.locale = Locale(identifier: "en_US_POSIX")
        monthFormatter.dateFormat = "MM"

        let yearFormatter = DateFormatter()
        yearFormatter.calendar = Calendar(identifier: .gregorian)
        yearFormatter.locale = Locale(identifier: "en_US_POSIX")
        yearFormatter.dateFormat = "yyyy"

        mMonth = monthFormatter.string(from: mDatePicker.date)
        mYear = yearFormatter.string(from: mDatePicker.date)
        
        self.mMostAmount.text = "Low to High"
        mGetSalesPersonProfile()
        
        self.view.endEditing(true)
        
        
        
        
    }
    @objc func mCancelDatePick(){
        self.view.endEditing(true)
    }
    @IBAction func mMostAmount(_ sender: Any) {
        let ascending = self.mMostAmount.text == "Low to High"

        let sorted = (mCustomerTransactionData as? [NSDictionary] ?? []).sorted { left, right in
            let leftValue = Double("\(left.value(forKey: "total_amount") ?? "0")"
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0

            let rightValue = Double("\(right.value(forKey: "total_amount") ?? "0")"
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0

            return ascending ? leftValue < rightValue : leftValue > rightValue
        }

        mCustomerTransactionData = NSArray(array: sorted)
        mCustomerTable.reloadData()
        self.mMostAmount.text = ascending ? "High to Low" : "Low to High"
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == TransactionTable {
            return mSalespersonTransactionData.count
            
        }
        return mCustomerTransactionData.count
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        let cells = UITableViewCell()
        if tableView == TransactionTable {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SalesPersonTableCell") as? SalesPersonTableCell,
                  let mData = mSalespersonTransactionData[indexPath.row] as? NSDictionary else {
                return UITableViewCell()
            }
            
            
            cell.mCustomerName.text = "\(mData.value(forKey: "customer_name") ?? "--")"
            cell.mType.text = "\(mData.value(forKey: "order_no") ?? "--")"
            cell.mMobile.text = "\(mData.value(forKey: "customer_country") ?? "--")," + "\(mData.value(forKey: "customer_mobile") ?? "--")"
            cell.mDate.text = "\(mData.value(forKey: "date") ?? "--")"
            
            cell.mCustomerImage.contentMode = .scaleAspectFill
            cell.mCustomerImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "customer_profile") ?? "")")
            if let mCart = mData.value(forKey: "items") as? NSArray {
                if mCart.count > 0 {
                    cell.mCartData = mCart
                    cell.mParkItemsTable.delegate = cell
                    cell.mParkItemsTable.dataSource = cell
                    cell.mParkItemsTable.reloadData()
                    cell.mParkItemsTable.layoutIfNeeded()
                    cell.mParkItemsTable.isHidden = false
                    cell.mTableHeight.constant = cell.mParkItemsTable.contentSize.height
                }else{
                    cell.mParkItemsTable.isHidden = true
                    cell.mTableHeight.constant = 0
                    
                }
                
            }else{
                cell.mParkItemsTable.isHidden = true
                cell.mTableHeight.constant = 0
                
            }
            
            return cell
            
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as? TransactionCell,
            let mData = mCustomerTransactionData[indexPath.row] as? NSDictionary else {
                return UITableViewCell()
            }
            
            cell.mTotalAmountLABEL.text = "Total Amount".localizedString
            cell.mTotalInvoiceLABEL.text = "Total Invoice".localizedString
            cell.mTotalQuantityLABEL.text = "Total Quantity".localizedString
            
            cell.mCustomerImage.contentMode = .scaleAspectFill
            
            cell.mCustomerName.text = "\(mData.value(forKey: "customer_name") ?? "--")"
            cell.mPrice.text = "\(mData.value(forKey: "total_amount") ?? "--")"
            cell.mAddressMobile.text = "\(mData.value(forKey: "customer_country") ?? "--")," + "\(mData.value(forKey: "customer_mobile") ?? "--")"
            cell.mTotalQuantity.text = "\(mData.value(forKey: "total_qty") ?? "--")"
            cell.mTotalInvoice.text = "\(mData.value(forKey: "total_invoice") ?? "--")"
            cell.mCustomerImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "customer_profile") ?? "")")
            
            
            
            
            return cell
        }
        
        
        return cells
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == mCustomerTable {
            return 180
        }
        return 100
    }
    
}

