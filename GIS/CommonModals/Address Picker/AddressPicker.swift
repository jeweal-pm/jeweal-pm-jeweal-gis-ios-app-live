//
//  AddressPicker.swift
//  GIS
//
//  Created by Sumit Meenaon 26/03/24.
//  Copyright © 2024 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire

protocol GetAddressDataDelegate {
    func mGetAddress(data : NSMutableDictionary)
}

class BillingAddressListCell: UITableViewCell {
    
    @IBOutlet weak var mFullAddress: UILabel!
    @IBOutlet weak var mEditBillingAddressButton: UIButton!
}

class ShippingAddressListCell: UITableViewCell {
    
    @IBOutlet weak var mFullAddress: UILabel!
    @IBOutlet weak var mEditShippingAddressButton: UIButton!
}

class AddressPicker : UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    // MARK: Delegate
    var delegate:GetAddressDataDelegate? = nil
    
    
    // MARK: Outlets
    @IBOutlet weak var mMainAddressPickerView: UIView!
    @IBOutlet weak var mToolbarView: UIView!
    @IBOutlet weak var mBackButtonView: UIView!
    @IBOutlet weak var mLabelAddressCustomer: UILabel!
    @IBOutlet weak var mLabelBillingAddress: UILabel!
    @IBOutlet weak var mBillingArrowDownImage: UIImageView!
    @IBOutlet weak var mBillingAddress: UILabel!
    @IBOutlet weak var mBillingAddressSuggestionView: UIView!
    @IBOutlet weak var mHeightBillingAddressSuggestionsView: NSLayoutConstraint! // Default 200
    
    @IBOutlet weak var mLabelShippingAddress: UILabel!
    @IBOutlet weak var mShippingArrowDownImage: UIImageView!
    @IBOutlet weak var mShippingAddress: UILabel!
    @IBOutlet weak var mShippingAddressSuggestionsView: UIView!
    @IBOutlet weak var mHeightShippingAddressSuggestionsView: NSLayoutConstraint! // Default 200
    
    @IBOutlet weak var mAddBillingAddressLabel: UILabel!
    @IBOutlet weak var mAddShippingAddressLabel: UILabel!
    
    @IBOutlet weak var mSearchBillingAddress: UITextField!
    @IBOutlet weak var mSearchShippingAddress: UITextField!
    
    @IBOutlet weak var mBillingAddressTable: UITableView!
    @IBOutlet weak var mShippingAddressTable: UITableView!
    
    // MARK: Variables
    var isPresentedViaPresentMethod = false
    var mCustomerId = ""
    private var mBillingAddressList : [[String : Any]] = []
    private var mFilteredBillingAddressList : [[String : Any]] = []
    private var mShippingAddressList : [[String : Any]] = []
    private var mFilteredShippingAddressList : [[String : Any]] = []
    
    private var mSelectedBAddressUDID = ""
    private var mSelectedSAddressUDID = ""
    
    // MARK: Override/Delegate functions
    override func viewWillAppear(_ animated: Bool) {
        setUpOnFirstLoad()
    }
    
    override func viewDidLoad() {
        mLabelAddressCustomer.text = "Address Customer".localizedString
        mLabelBillingAddress.text = "Billing Address".localizedString
        mBillingAddress.text = "Billing Address".localizedString
        mLabelShippingAddress.text = "Shipping Address".localizedString
        mShippingAddress.text = "Shipping Address".localizedString
        mAddBillingAddressLabel.text = "Add billing address".localizedString
        mAddShippingAddressLabel.text = "Add shipping address".localizedString
    }
    
    //SearchField onchange
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == self.mSearchBillingAddress {
            filterBillingAddresses(textField.text ?? "")
        } else if textField == self.mSearchShippingAddress {
            filterShippingAddresses(textField.text ?? "")
        }
    }
    
    // MARK: All Button Actions
    @IBAction func mBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mShowBillingAddresses(_ sender: Any) {
        UIView.transition(with: mBillingAddressSuggestionView, duration: 0.1, options: .transitionCrossDissolve , animations: {
            self.mBillingAddressSuggestionView.isHidden = !self.mBillingAddressSuggestionView.isHidden
            self.mHeightBillingAddressSuggestionsView.constant = self.mBillingAddressSuggestionView.isHidden ? 0 : 200
        })
    }
    
    @IBAction func mShowShippingAddresses(_ sender: Any) {
        UIView.transition(with: mShippingAddressSuggestionsView, duration: 0.1, options: .transitionCrossDissolve , animations: {
            self.mShippingAddressSuggestionsView.isHidden = !self.mShippingAddressSuggestionsView.isHidden
            self.mHeightShippingAddressSuggestionsView.constant = self.mShippingAddressSuggestionsView.isHidden ? 0 : 200
        })
    }
    
    @IBAction func mAddBillingAddress(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "AddressPicker", bundle: nil)
        guard let addressManager = storyBoard.instantiateViewController(withIdentifier: "AddressManager") as? AddressManager else { return }
        addressManager.addressType = .addBillingAddress
        addressManager.customerID = mCustomerId
        self.navigationController?.pushViewController(addressManager, animated:true)
    }
    
    @IBAction func mAddShippingAddress(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "AddressPicker", bundle: nil)
        guard let addressManager = storyBoard.instantiateViewController(withIdentifier: "AddressManager") as? AddressManager else { return }
        addressManager.addressType = .addShippingAddress
        addressManager.customerID = mCustomerId
        self.navigationController?.pushViewController(addressManager, animated:true)
    }
    
    // MARK: Table View|Collection View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (tableView){
        case mBillingAddressTable:
            return mFilteredBillingAddressList.count
        case mShippingAddressTable:
            return mFilteredShippingAddressList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (tableView){
        case mBillingAddressTable:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "BillingAddressListCell") as? BillingAddressListCell {
                let billingAddress = mFilteredBillingAddressList[indexPath.row] as [String : Any]
                cell.mFullAddress.text = "\(billingAddress["fullAddress"] as? String ?? "")"
                cell.mEditBillingAddressButton.tag = indexPath.row
                if mSelectedBAddressUDID == "\(billingAddress["UDID"] as? String ?? "")" {
                    cell.mFullAddress.textColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }
                return cell
            } else { return UITableViewCell() }
        case mShippingAddressTable:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ShippingAddressListCell") as? ShippingAddressListCell {
                let shippingAddress = mFilteredShippingAddressList[indexPath.row] as [String : Any]
                cell.mFullAddress.text = "\(shippingAddress["fullAddress"] as? String ?? "")"
                cell.mEditShippingAddressButton.tag = indexPath.row
                if mSelectedSAddressUDID == "\(shippingAddress["UDID"] as? String ?? "")" {
                    cell.mFullAddress.textColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }
                return cell
            } else { return UITableViewCell() }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case mBillingAddressTable:
            let billingAddress = mFilteredBillingAddressList[indexPath.row] as [String : Any]
            self.mBillingAddress.text = "\(billingAddress["fullAddress"] as? String ?? "")"
            mSelectedBAddressUDID = "\(billingAddress["UDID"] as? String ?? "")"
            
            UserDefaults.standard.setValue(mSelectedBAddressUDID, forKey: "CustomerBillingAddressUDID")
            
            UIView.transition(with: mBillingAddressSuggestionView, duration: 0.1, options: .transitionCrossDissolve , animations: {
                self.mBillingAddressSuggestionView.isHidden = true
                self.mHeightBillingAddressSuggestionsView.constant = 0
            })
        case mShippingAddressTable:
            let shippingAddress = mFilteredShippingAddressList[indexPath.row] as [String : Any]
            self.mShippingAddress.text = "\(shippingAddress["fullAddress"] as? String ?? "")"
            mSelectedSAddressUDID = "\(shippingAddress["UDID"] as? String ?? "")"
            
            UserDefaults.standard.setValue(mSelectedSAddressUDID, forKey: "CustomerShippingAddressUDID")
            
            UIView.transition(with: mShippingAddressSuggestionsView, duration: 0.1, options: .transitionCrossDissolve , animations: {
                self.mShippingAddressSuggestionsView.isHidden = true
                self.mHeightShippingAddressSuggestionsView.constant = 0
            })
        default: break
        }
    }
    
    //mBillingAddressTable edit address button
    @IBAction func mEditBillingAddress(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "AddressPicker", bundle: nil)
        guard let addressManager = storyBoard.instantiateViewController(withIdentifier: "AddressManager") as? AddressManager else { return }
        addressManager.addressType = .editBillingAddress
        addressManager.customerID = mCustomerId
        addressManager.addressData = mFilteredBillingAddressList[sender.tag]
        self.navigationController?.pushViewController(addressManager, animated:true)
    }
    //mShippingAddressTable edit address button
    @IBAction func mEditShippingAddress(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "AddressPicker", bundle: nil)
        guard let addressManager = storyBoard.instantiateViewController(withIdentifier: "AddressManager") as? AddressManager else { return }
        addressManager.addressType = .editShippingAddress
        addressManager.customerID = mCustomerId
        addressManager.addressData = mFilteredShippingAddressList[sender.tag]
        self.navigationController?.pushViewController(addressManager, animated:true)
    }
    
    
    // MARK: Function
    private func setUpOnFirstLoad(){
        //Set initial values
        mHeightBillingAddressSuggestionsView.constant = 0
        mBillingAddressSuggestionView.isHidden = true
        mHeightShippingAddressSuggestionsView.constant = 0
        mShippingAddressSuggestionsView.isHidden = true
        
        if isPresentedViaPresentMethod {
            mBackButtonView.isHidden = true
        }
        
        mBillingAddressTable.delegate = self
        mBillingAddressTable.dataSource = self
        
        mShippingAddressTable.delegate = self
        mShippingAddressTable.dataSource = self
        getCustomerAddressList()
        
        mSearchBillingAddress.addTarget(self, action: #selector(AddressPicker.textFieldDidChange(_:)), for: .editingChanged)
        
        mSearchShippingAddress.addTarget(self, action: #selector(AddressPicker.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    func filterBillingAddresses(_ searchText: String) {
        
        if searchText.isEmpty {
            mFilteredBillingAddressList = mBillingAddressList
        } else {
            mFilteredBillingAddressList = mBillingAddressList.filter { item in
                guard let address = item["fullAddress"] as? String else {
                    return false
                }
                return address.contains(searchText)
            }
        }
        mBillingAddressTable.reloadData()
    }
    
    func filterShippingAddresses(_ searchText: String) {
        
        if searchText.isEmpty {
            mFilteredShippingAddressList = mShippingAddressList
        } else {
            mFilteredShippingAddressList = mShippingAddressList.filter { item in
                guard let address = item["fullAddress"] as? String else {
                    return false
                }
                return address.contains(searchText)
            }
        }

        mShippingAddressTable.reloadData()
    }
    
    // MARK: API Calls
    
    private func getCustomerAddressList(){
        
        guard Reachability.isConnectedToNetwork() == true else {
            CommonClass.showSnackBar(message: "Please check your internet connection.")
            return
        }
        
        let params = ["customer_id": mCustomerId] as [String : Any]
        let urlPath =  mGetCustomerAddressList
        
        CommonClass.showFullLoader(view: self.view)
        AF.request(urlPath, method:.post,parameters: params,encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
            CommonClass.stopLoader()
            
            guard let jsonData = response.data else {
                CommonClass.showSnackBar(message: "Oops, something went wrong!")
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                    CommonClass.showSnackBar(message: "Oops, something went wrong!")
                    return
                }
                guard let code = json["code"] as? Int else {
                    CommonClass.showSnackBar(message: "Oops, something went wrong!")
                    return
                }
                
                switch code {
                case 200:
                    if let data = json["data"] as? [String: Any] {
                        if let billingAddressList = data["billing_address"] as? [[String : Any]] {
                            self.mBillingAddressList = billingAddressList
                            self.mFilteredBillingAddressList = billingAddressList
                            self.mBillingAddressTable.reloadData()
                            
                            for address in self.mFilteredBillingAddressList {
                                if address["is_default"] as? Int == 1 {
                                    self.mBillingAddress.text = "\(address["fullAddress"] ?? "")"
                                    UserDefaults.standard.setValue("\(address["UDID"] ?? "")", forKey: "CustomerBillingAddressUDID")
                                }
                            }
                            
                        }
                        if let shippingAddressList = data["shipping_address"] as? [[String : Any]] {
                            self.mShippingAddressList = shippingAddressList
                            self.mFilteredShippingAddressList = shippingAddressList
                            self.mShippingAddressTable.reloadData()
                            
                            for address in self.mFilteredShippingAddressList {
                                if address["is_default"] as? Int == 1 {
                                    self.mShippingAddress.text = "\(address["fullAddress"] ?? "")"
                                    UserDefaults.standard.setValue("\(address["UDID"] ?? "")", forKey: "CustomerShippingAddressUDID")
                                }
                            }
                        }
                    }
                case 403:
                    CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                default:
                    let errorMessage = json["message"] as? String ?? "An error occurred."
                    CommonClass.showSnackBar(message: "Error \(code): \(errorMessage)")
                }
            } catch {
                CommonClass.showSnackBar(message: "Oops, something went wrong!")
            }
        }
        
        
    }
    
}
