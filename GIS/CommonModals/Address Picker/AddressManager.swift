//
//  AddressManager.swift
//  GIS
//
//  Created by Sumit Meena on 10/04/24.
//  Copyright © 2024 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
import DropDown

protocol AddressManagerDelegate: AnyObject {
    func didEditAddress(addressData: [String : Any]?, addressType: AddressType)
}

enum AddressType {
    case editBillingAddress
    case editShippingAddress
    case addBillingAddress
    case addShippingAddress
    
    var viewTitleText : String {
        switch self {
        case .editBillingAddress:
            "Edit Billing Address".localizedString
        case .editShippingAddress:
            "Edit Shipping Address".localizedString
        case .addBillingAddress:
            "Add Billing Address".localizedString
        case .addShippingAddress:
            "Add Shipping Address".localizedString
        }
    }
    
    var formTitleText : String {
        switch self {
        case .editBillingAddress, .addBillingAddress:
            "Billing Address".localizedString
        case .editShippingAddress, .addShippingAddress:
            "Shipping Address".localizedString
        }
    }
    
    var defaultAddressText : String {
        switch self {
        case .editBillingAddress, .addBillingAddress:
            "Default Billing Address".localizedString
        case .editShippingAddress, .addShippingAddress:
            "Default Shipping Address".localizedString
        }
    }
    
}

class AddressManager : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var mViewTitleLabel: UILabel!        // Default : Edit Billing Address
    @IBOutlet weak var mFormTitleLabel: UILabel!        // Default : Billing Address
    @IBOutlet weak var mCompanyLabel: UILabel!          // Default : Company
    @IBOutlet weak var mEditCompany: UITextField!
    @IBOutlet weak var mAddressLabel: UILabel!          // Default : Address*
    @IBOutlet weak var mEditAddress: UITextField!
    @IBOutlet weak var mCountryLabel: UILabel!          // Default : Country*
    @IBOutlet weak var mEditCountry: UITextField!
    @IBOutlet weak var mStateLabel: UILabel!            // Default : Province/State
    @IBOutlet weak var mEditState: UITextField!
    @IBOutlet weak var mCityLabel: UILabel!             // Default : City
    @IBOutlet weak var mEditCity: UITextField!
    @IBOutlet weak var mZipCodeLabel: UILabel!          // Default : Zip Code
    @IBOutlet weak var mEditZipCode: UITextField!
    @IBOutlet weak var mTaxIdNoLabel: UILabel!          // Default : Tax ID No.
    @IBOutlet weak var mEditTaxIdNo: UITextField!
    @IBOutlet weak var mDefaultAddressLabel: UILabel!   // Default : Default Billing Address
    @IBOutlet weak var mSwitchDefaultAddress: UISwitch!
    @IBOutlet weak var mRemoveButtonView: UIView!
    
    // MARK: Variables
    
    var manageLocally = false   // This state should be true when opend from Edit or Create customer.
    var countryList : [[String : Any]] = []
    var addressType : AddressType = .editBillingAddress
    var addressData : [String : Any] = [:]
    var customerID = ""
    var mCountryId = ""
    weak var delegate: AddressManagerDelegate?
    
    // MARK: override functions
    override func viewWillAppear(_ animated: Bool) {
        setUpInitialValues()
    }
    
    override func viewDidLoad() {
        print("AddressManager OPEN")
        mViewTitleLabel.text = "Edit Billing Address".localizedString
        mFormTitleLabel.text = "Billing Address".localizedString
        mCompanyLabel.text = "Company".localizedString
        mAddressLabel.text = "Address*".localizedString
        mCountryLabel.text = "Country*".localizedString
        mStateLabel.text = "Province/State".localizedString
        mCityLabel.text = "City".localizedString
        mZipCodeLabel.text = "Zip Code".localizedString
        mTaxIdNoLabel.text = "Tax ID No.".localizedString
        mDefaultAddressLabel.text = "Default Billing Address".localizedString
        
        mGetCountries()
        sLoadDataInView()
    }
    
    // MARK: All Button Actions
    
    @IBAction func mBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mSaveAddress(_ sender: Any) {
        guard mEditAddress.text?.isEmpty != true else {
            CommonClass.showSnackBar(message: "Address field is required.")
            return
        }
        guard mEditCountry.text?.isEmpty != true else {
            CommonClass.showSnackBar(message: "Country field is required.")
            return
        }
        
        if manageLocally {
            let udid = addressData["UDID"]
            addressData =  ["customer_id": customerID,
                            "address": mEditAddress.text ?? "",
                            "company": mEditCompany.text ?? "",
                            "country": ["label": mEditCountry.text ?? "",
                                        "value": mCountryId],
                            "state": mEditState.text ?? "",
                            "city": mEditCity.text ?? "",
                            "fullAddress": "\(mEditAddress.text ?? ""), \(mEditCity.text ?? ""), \(mEditState.text ?? ""), \(mEditCountry.text ?? ""), \(mEditZipCode.text ?? "")",
                            "zipcode": mEditZipCode.text ?? "",
                            "tax_number": mEditTaxIdNo.text ?? "",
                            "is_default": mSwitchDefaultAddress.isOn ? 1 : 0]
            
            if addressType == .editBillingAddress || addressType == .editShippingAddress {
                if let udid = udid {
                    addressData["UDID"] = udid
                }
            }
            
            delegate?.didEditAddress(addressData: addressData, addressType: addressType)
            self.navigationController?.popViewController(animated: true)
        } else {
            mUpdateAddress()
        }
    }
    
    @IBAction func mOpenCountryDropDown(_ sender: Any) {
        print("AddressManager mOpenCountryDropDown")
        var countryNameList: [String] = []
        for country in countryList {
            if let cName = country["name"] as? String {
                countryNameList.append(cName)
            }
        }
        
        let dropdown = DropDown()
        dropdown.anchorView = self.mEditCountry
        dropdown.direction = .any
        dropdown.bottomOffset = CGPoint(x: 0, y: self.mEditCountry.frame.size.height)
        dropdown.width = 200
        dropdown.dataSource = countryNameList
        dropdown.selectionAction = {
            [unowned self](index:Int, item: String) in
            self.mEditCountry.text  = item
            self.mCountryId = "\(self.countryList[index]["id"] ?? "")"
        }
        dropdown.show()
    }
    
    @IBAction func mRemoveAddress(_ sender: Any) {
        delegate?.didEditAddress(addressData: nil, addressType: addressType)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: Table View|Collection View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    // MARK: Function
    private func setUpInitialValues(){
        mViewTitleLabel.text = addressType.viewTitleText
        mFormTitleLabel.text = addressType.formTitleText
        mDefaultAddressLabel.text = addressType.defaultAddressText
        
        mRemoveButtonView.isHidden = !manageLocally || (manageLocally && (addressType == .addBillingAddress || addressType == .addShippingAddress))
    }
    
    private func sLoadDataInView(){
        mEditAddress.text = "\(addressData["address"] ?? "")"
        let country = addressData["country"] as? [String : Any]
        mEditCountry.text = "\(country?["label"] ?? "")"
        mCountryId = "\(country?["value"] ?? "")"
        mEditState.text = "\(addressData["state"] ?? "")"
        mEditCity.text = "\(addressData["city"] ?? "")"
        mEditZipCode.text = "\(addressData["zipcode"] ?? "")"
        mEditTaxIdNo.text = "\(addressData["tax_number"] ?? "")"
        mSwitchDefaultAddress.isOn = (addressData["is_default"] as? Int == 1) ? true : false
    }
    
    // MARK: API Calls
    
    private func mUpdateAddress() {
        let url = mEditAndSaveCustomerAddress
        let billingType = (addressType == .editBillingAddress || addressType == .addBillingAddress)
        
        _ = addressData["country"] as? [String : Any]
        
        // TO save address
        var params : [String : Any] = ["customer_id": customerID,
                                       "type_billing": billingType,
                                       "address": mEditAddress.text ?? "",
                                       "country": mCountryId,
                                       "state": mEditState.text ?? "",
                                       "city": mEditCity.text ?? "",
                                       "zipcode": mEditZipCode.text ?? "",
                                       "tax_number": mEditTaxIdNo.text ?? "",
                                       "is_default": mSwitchDefaultAddress.isOn ? 1 : 0]
        
        switch addressType {
        case .editBillingAddress, .editShippingAddress:
            params["UDID"] = addressData["UDID"] ?? ""
        case .addBillingAddress, .addShippingAddress:
            break
        }
        
        
        guard Reachability.isConnectedToNetwork() == true else {
            CommonClass.showSnackBar(message: "Please check your internet connection.")
            return
        }
        
        CommonClass.showFullLoader(view: self.view)
        AF.request(url, method:.post, parameters: params, encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
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

                if let code = json["statusCode"] as? Int {
                    
                    switch code {
                    case 200:
                        if let message = json["message"] {
                            CommonClass.showSnackBar(message: "\(message)")
                        }
                        self.navigationController?.popViewController(animated: true)
                    case 403:
                        CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                    default:
                        let errorMessage = json["errors"] as? String ?? "An error occurred."
                        CommonClass.showSnackBar(message: "Error \(code): \(errorMessage)")
                    }
                } else {
                    CommonClass.showSnackBar(message: "Oops, something went wrong!")
                }
            } catch {
                CommonClass.showSnackBar(message: "Oops, something went wrong!")
            }
            
        }
        
    }
    
    func mGetCountries(){
        
        let urlPath = mGrapQlUrl
        let params = ["query":"{countries{name id sortname phoneCode}}"]
        
        if Reachability.isConnectedToNetwork() == true {
            CommonClass.showFullLoader(view: self.view)
            AF.request(urlPath, method:.post, parameters:params,encoding:JSONEncoding.default, headers: sGisHeaders2).responseJSON
            { response in
                CommonClass.stopLoader()
                
                if(response.error != nil){
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                }else{
                    if let jsonData = response.data {
                        
                        let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                        
                        if let jsonResult = json as? NSDictionary,
                           let sData = jsonResult.value(forKey: "data") as? NSDictionary,
                           let data = sData.value(forKey: "countries") as? [[String : Any]] {
                            self.countryList.removeAll()
                            self.countryList = data.sorted {
                                guard let name1 = ($0["name"] as? String)?.lowercased(),
                                      let name2 = ($1["name"] as? String)?.lowercased()
                                else {
                                    return false
                                }
                                return name1 < name2
                            } // key = 'name' for country and 'id' for country id
                        }
                    }
                }
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
    }
    
}
