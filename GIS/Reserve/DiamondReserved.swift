//
//  DiamondReserved.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 07/04/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class DiamondReserved:  UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    
    @IBOutlet weak var mNoDataFound: UILabel!
    @IBOutlet weak var mRemoveButton: UIButton!
    @IBOutlet weak var mHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mSearchField: UITextField!
    
    @IBOutlet weak var mStockId: UILabel!
    
    @IBOutlet weak var mProductImage: UIImageView!
    
    @IBOutlet weak var mStatusName: UILabel!
    
    @IBOutlet weak var mStatus: UILabel!
    
    @IBOutlet weak var mLocation: UILabel!
    @IBOutlet weak var mProductInfo: UILabel!
    
    @IBOutlet weak var mProductDescription: UILabel!
    
    @IBOutlet weak var mShape: UILabel!
    
    @IBOutlet weak var mColor: UILabel!
    
    @IBOutlet weak var mCertificateName: UILabel!
    @IBOutlet weak var mClarity: UILabel!
    @IBOutlet weak var mCut: UILabel!
    @IBOutlet weak var mCarat: UILabel!
    
    @IBOutlet weak var mReserveTable: UITableView!
    
    var mLink = ""
    
    var mData = NSMutableArray()
    var mDefaultData = NSArray()
    
    
    
    var mIndex = -1
    var mSelectedItems = [String]()
    @IBOutlet weak var mHeading: UILabel!
    
    @IBOutlet weak var mCertificateLABEL: UILabel!
    @IBOutlet weak var mClarityLABEL: UILabel!
    @IBOutlet weak var mCaratLABEL: UILabel!
    @IBOutlet weak var mCutLABEL: UILabel!
    @IBOutlet weak var mColorLABEL: UILabel!
    @IBOutlet weak var mShapeLABEL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        mNoDataFound.text = "No Data Found!".localizedString
        mHeading.text = "Reserved Items".localizedString
        mSearchField.placeholder = "Search by Stock Id / Customer".localizedString
        mCertificateLABEL.text = "Certificate".localizedString
        mClarityLABEL.text = "Clarity".localizedString
        mCaratLABEL.text = "Carat".localizedString
        mCutLABEL.text = "Cut".localizedString
        mColorLABEL.text = "Color".localizedString
        mShapeLABEL.text = "Shape".localizedString
        
        self.mReserveTable.delegate = self
        self.mReserveTable.dataSource = self
        self.mReserveTable.reloadData()
        
    }
    
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mScanSearch(_ sender: UIButton) {
    }
    
    @IBAction func mSearchFilters(_ sender: UITextField) {
        
        if sender.text == "" {
            
            mIndex = 0
            self.mData = NSMutableArray(array: mDefaultData)
            mReserveTable.reloadData()
            
        }else {
            mIndex = 0
            mData = NSMutableArray()
            for i in mDefaultData {
                
                if let mData = i as? NSDictionary {
                    
                    let mValue = ("\(mData.value(forKey: "customer") ?? "")").lowercased()
                    let mStockId = "\(mData.value(forKey: "StockID") ?? "")"
                    let serach = sender.text ?? ""
                    
                    if mValue.contains(serach.lowercased()) || mStockId.contains(serach)  {
                        self.mData.add(mData)
                        mReserveTable.reloadData()
                    }else{
                        mReserveTable.reloadData()
                    }
                }
            }
        }
    }
    
    
    @IBAction func mOpenCertificateLink(_ sender: Any) {
        
        
        if mLink != "" {
            if let url = URL(string: mLink) {
                UIApplication.shared.open(url)
            }
        }else{
            CommonClass.showSnackBar(message: "No links found!")
        }
        
        
    }
    
    @IBAction func mCheckItems(_ sender: UIButton) {
        
        if let mRowData = mData[sender.tag] as? NSDictionary {
            
            if let id = mRowData.value(forKey: "id") as? String {
                if mSelectedItems.contains(id) {
                    mSelectedItems = mSelectedItems.filter {$0 != id }
                }else{
                    mSelectedItems.append(id)
                }
            }
            self.mReserveTable.reloadData()
        }
        
    }
    
    @IBAction func mRemoveItems(_ sender: Any) {
        
        CommonClass.showFullLoader(view: self.view)
        
        mGetData(url: mDiamondRemoveReserveAPI ,headers: sGisHeaders,  params: ["id":mSelectedItems]) { response , status in
            
            CommonClass.stopLoader()
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    self.mSelectedItems = [String]()
                    
                    
                    
                    mGetData(url: mDiamondReservedListAPI ,headers: sGisHeaders,  params: ["":""]) { response , status in
                        CommonClass.stopLoader()
                        if status {
                            self.mData =  NSMutableArray()
                            self.mDefaultData = NSArray()
                            if "\(response.value(forKey: "code") ?? "")" == "200" {
                                
                                if let mDataItems = response.value(forKey: "data") as? NSArray, mDataItems.count > 0 {
                                    
                                    self.mData =  NSMutableArray(array: mDataItems)
                                    self.mDefaultData = mDataItems
                                    
                                    if let mData = mDataItems[0] as? NSDictionary {
                                        self.mStockId.text = "\(mData.value(forKey: "StockID") ?? "--")"
                                        self.mProductInfo.text = "\(mData.value(forKey: "Carat") ?? "--") Carat, \(mData.value(forKey: "Shape") ?? "") - \(mData.value(forKey: "Colour") ?? "")/\(mData.value(forKey: "Clarity") ?? "")"
                                        
                                        self.mProductDescription.text = "\(mData.value(forKey: "Carat") ?? "--") carats, \(mData.value(forKey: "Colour") ?? "--") colour, \(mData.value(forKey: "Clarity") ?? "--") clarity \(mData.value(forKey: "Shape") ?? "--") shape , \(mData.value(forKey: "Cut") ?? "--") cut"
                                        self.mClarity.text = "\(mData.value(forKey: "Clarity") ?? "")"
                                        self.mCut.text = "\(mData.value(forKey: "Cut") ?? "")"
                                        self.mShape.text = "\(mData.value(forKey: "Shape") ?? "")"
                                        self.mColor.text = "\(mData.value(forKey: "Colour") ?? "")"
                                        self.mCarat.text = "\(mData.value(forKey: "Carat") ?? "")"
                                        self.mCertificateName.text = "\(mData.value(forKey: "GradedBy") ?? "")"
                                        self.mLink = "\(mData.value(forKey: "CertificationUrl") ?? "")"
                                        self.mLocation.text = "\(mData.value(forKey: "Location") ?? "")"
                                        self.mReserveTable.delegate = self
                                        self.mReserveTable.dataSource = self
                                        self.mReserveTable.reloadData()
                                    }
                                } else {
                                    self.setDefaults()
                                    return
                                }
                            }else{
                            }
                        }
                    }
                    
                }else{
                }
            }
        }
        
    }
    
    func setDefaults() {
        self.mStockId.text = "--"
        self.mProductInfo.text = "--"
        self.mProductDescription.text = "--"
        self.mClarity.text = "--"
        self.mCut.text = "--"
        self.mShape.text = "--"
        self.mColor.text = "--"
        self.mCarat.text = "--"
        self.mCertificateName.text = "--"
        self.mLink = ""
        self.mData =  NSMutableArray()
        self.mDefaultData = NSArray()
        self.mReserveTable.delegate = self
        self.mReserveTable.dataSource = self
        self.mReserveTable.reloadData()
    }
    
    override
    func viewWillAppear(_ animated: Bool) {
        
        
        CommonClass.showFullLoader(view: self.view)
        
        
        mGetData(url: mDiamondReservedListAPI , headers: sGisHeaders ,params: ["":""]) { response , status in
            CommonClass.stopLoader()
            if status {
                self.mData =  NSMutableArray()
                self.mDefaultData = NSArray()
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    
                    if let mDataItems = response.value(forKey: "data") as? NSArray, mDataItems.count > 0 {
                        
                        self.mData =  NSMutableArray(array: mDataItems)
                        self.mDefaultData = mDataItems
                        
                        if let mData = mDataItems[0] as? NSDictionary {
                            self.mStockId.text = "\(mData.value(forKey: "StockID") ?? "--")"
                            self.mProductInfo.text = "\(mData.value(forKey: "Carat") ?? "--") Carat, \(mData.value(forKey: "Shape") ?? "--") - \(mData.value(forKey: "Colour") ?? "--")/\(mData.value(forKey: "Clarity") ?? "--")"
                            
                            self.mProductDescription.text = "\(mData.value(forKey: "Carat") ?? "--") carats, \(mData.value(forKey: "Colour") ?? "--") colour, \(mData.value(forKey: "Clarity") ?? "--") clarity \(mData.value(forKey: "Shape") ?? "--") shape , \(mData.value(forKey: "Cut") ?? "--") cut"
                            self.mClarity.text = "\(mData.value(forKey: "Clarity") ?? "--")"
                            self.mCut.text = "\(mData.value(forKey: "Cut") ?? "--")"
                            self.mShape.text = "\(mData.value(forKey: "Shape") ?? "--")"
                            self.mColor.text = "\(mData.value(forKey: "Colour") ?? "--")"
                            self.mCarat.text = "\(mData.value(forKey: "Carat") ?? "--")"
                            self.mLocation.text = "\(mData.value(forKey: "Location") ?? "--")"
                            self.mCertificateName.text = "\(mData.value(forKey: "GradedBy") ?? "--")"
                            self.mLink = "\(mData.value(forKey: "CertificationUrl") ?? "--")"
                            
                            self.mReserveTable.delegate = self
                            self.mReserveTable.dataSource = self
                            self.mReserveTable.reloadData()
                        }
                    } else {
                        self.setDefaults()
                    }
                }else{
                    self.setDefaults()
                }
            }
        }
        
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if mData.count == 0 {
            mNoDataFound.isHidden = false
            mReserveTable.isHidden = true
            self.mStockId.text = "--"
            self.mProductInfo.text = "--"
            self.mProductDescription.text = "--"
            self.mClarity.text = "--"
            self.mCut.text = "--"
            self.mShape.text = "--"
            self.mColor.text = "--"
            self.mCarat.text = "--"
            self.mCertificateName.text = "--"
            self.mLink = ""
            
            mSelectedItems = [String]()
            mHeight.constant = 0
            mRemoveButton.isHidden = true
            
        }else{
            mNoDataFound.isHidden = true
            mReserveTable.isHidden = false
        }
        return mData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiamondReservedList") as? DiamondReservedList else {
            return UITableViewCell()
        }
        
        if let mData = mData[indexPath.row] as? NSDictionary {
            cell.mCheckUnckeckButton.tag = indexPath.row
            cell.mDueDate.text = "\(mData.value(forKey: "DueDate") ?? "--")"
            cell.mCustomerName.text = "\(mData.value(forKey: "customer") ?? "--")"
            cell.mAmount.text = "\(mData.value(forKey: "Price") ?? "--")"
            cell.mProductName.text = "\(mData.value(forKey: "Carat") ?? "--") Carat, \(mData.value(forKey: "Shape") ?? "--") - \(mData.value(forKey: "Colour") ?? "--")/\(mData.value(forKey: "Clarity") ?? "--")"
            cell.mStockId.text = "\(mData.value(forKey: "StockID") ?? "--")"
            
            cell.backgroundColor = (indexPath.row % 2 == 0) ? #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            mHeight.constant = mSelectedItems.isEmpty ? 0 : 50
            mRemoveButton.isHidden = mSelectedItems.isEmpty
            
            if let id = mData.value(forKey: "id") as? String, mSelectedItems.contains(id) {
                cell.mCheckIcon.image = UIImage(named: "check_item")
            }else{
                cell.mCheckIcon.image = UIImage(named: "uncheck_item")
            }
            
            if mIndex == indexPath.row {
                
                self.mStockId.text = "\(mData.value(forKey: "StockID") ?? "--")"
                self.mProductInfo.text = "\(mData.value(forKey: "Carat") ?? "--") Carat, \(mData.value(forKey: "Shape") ?? "--") - \(mData.value(forKey: "Colour") ?? "--")/\(mData.value(forKey: "Clarity") ?? "--")"
                self.mProductDescription.text = "\(mData.value(forKey: "Carat") ?? "--") carats, \(mData.value(forKey: "Colour") ?? "--") colour, \(mData.value(forKey: "Clarity") ?? "--") clarity \(mData.value(forKey: "Shape") ?? "--") shape , \(mData.value(forKey: "Cut")  ?? "--") cut"
                self.mClarity.text = "\(mData.value(forKey: "Clarity") ?? "--")"
                self.mCut.text = "\(mData.value(forKey: "Cut") ?? "--")"
                self.mShape.text = "\(mData.value(forKey: "Shape") ?? "--")"
                self.mColor.text = "\(mData.value(forKey: "Colour") ?? "--")"
                self.mCarat.text = "\(mData.value(forKey: "Carat") ?? "--")"
                self.mLocation.text = "\(mData.value(forKey: "Location") ?? "--")"
                self.mCertificateName.text = "\(mData.value(forKey: "GradedBy") ?? "--")"
                self.mLink = "\(mData.value(forKey: "CertificationUrl") ?? "--")"
            }
        }
        cell.layoutSubviews()
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let mData = mData[indexPath.row] as? NSDictionary else {
            return
        }
        
        mIndex = indexPath.row
        
        self.mStockId.text = "\(mData.value(forKey: "StockID") ?? "--")"
        self.mProductInfo.text = "\(mData.value(forKey: "Carat") ?? "--") Carat, \(mData.value(forKey: "Shape") ?? "--") - \(mData.value(forKey: "Colour") ?? "--")/\(mData.value(forKey: "Clarity") ?? "--")"
        
        self.mProductDescription.text = "\(mData.value(forKey: "Carat") ?? "--") carats, \(mData.value(forKey: "Colour") ?? "--") colour, \(mData.value(forKey: "Clarity") ?? "--") clarity \(mData.value(forKey: "Shape") ?? "--") shape , \(mData.value(forKey: "Cut") ?? "--") cut"
        self.mClarity.text = "\(mData.value(forKey: "Clarity") ?? "--")"
        self.mCut.text = "\(mData.value(forKey: "Cut") ?? "--")"
        self.mShape.text = "\(mData.value(forKey: "Shape") ?? "--")"
        self.mColor.text = "\(mData.value(forKey: "Colour") ?? "--")"
        self.mCarat.text = "\(mData.value(forKey: "Carat") ?? "--")"
        
        self.mLocation.text = "\(mData.value(forKey: "Location") ?? "--")"
        self.mCertificateName.text = "\(mData.value(forKey: "GradedBy") ?? "--")"
        self.mLink = "\(mData.value(forKey: "CertificationUrl") ?? "--")"
        
    }
    
    
}
