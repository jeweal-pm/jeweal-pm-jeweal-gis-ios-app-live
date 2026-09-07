//
//  DiamondProductDetails.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 31/10/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class DiamondProductDetails: UIViewController , UIViewControllerTransitioningDelegate ,GetCustomerDataDelegate{

    private var selectedSalesPersonId: String {
        return (UserDefaults.standard.string(forKey: "SALESPERSONID") ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    
    
    @IBOutlet weak var mCertificationImage: UIImageView!
    
    @IBOutlet weak var mPrice: UILabel!
    @IBOutlet weak var mCertificateNumber: UILabel!
    @IBOutlet weak var mCertificateName: UILabel!
    @IBOutlet weak var mDescription: UITextView!
    @IBOutlet weak var mDiamondName: UILabel!
    @IBOutlet weak var mProductImage: UIImageView!
    var mProductId = ""
   
    @IBOutlet weak var mStockId2: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    
    @IBOutlet weak var mShape: UILabel!
    
    @IBOutlet weak var mCarat: UILabel!
    
    @IBOutlet weak var mColor: UILabel!
    
    @IBOutlet weak var mClarity: UILabel!
    
    @IBOutlet weak var mCut: UILabel!
    
    @IBOutlet weak var mPolish: UILabel!
    
    @IBOutlet weak var mMeasurement: UILabel!
    @IBOutlet weak var mSymmetry: UILabel!
    
    @IBOutlet weak var mCulet: UILabel!
    @IBOutlet weak var mFluorescence: UILabel!
    @IBOutlet weak var mDepth: UILabel!
    
    @IBOutlet weak var mGirdle: UILabel!
    @IBOutlet weak var mTable: UILabel!
    
    @IBOutlet weak var mGradedBy: UILabel!
    
    @IBOutlet weak var mCertification: UILabel!
    
    @IBOutlet weak var mReserveButton: UIButton!
    
    @IBOutlet weak var mBottomView: UIView!
    var mStatus = ""
    var mProductData = NSDictionary()
    var mCustomerId = ""
    
    var mReservedCustomerId = ""
    var mReservedCustomerName = ""
    var mAllImages = [String]()
    
    
    @IBOutlet weak var mHeading: UILabel!
    @IBOutlet weak var mDiamondDetailsLABEL: UILabel!
    @IBOutlet weak var mHeadingLABEL: UILabel!
    @IBOutlet weak var mStokIdLABEL: UILabel!
    @IBOutlet weak var mShapeLABEL: UILabel!
    @IBOutlet weak var mCaratLABEL: UILabel!
    @IBOutlet weak var mColourLABEL: UILabel!
    @IBOutlet weak var mClarityLABEL: UILabel!
    @IBOutlet weak var mCutLABEL: UILabel!
    @IBOutlet weak var mPolishLABEL: UILabel!
    @IBOutlet weak var mSymmetryLABEL: UILabel!
    @IBOutlet weak var mFluorescenceLABEL: UILabel!
    @IBOutlet weak var mDepthLABEL: UILabel!
    @IBOutlet weak var mTableLABEL: UILabel!
    @IBOutlet weak var mGridleLABEL: UILabel!
    @IBOutlet weak var mCuletLABEL: UILabel!
    @IBOutlet weak var mMeasurementsLABEL: UILabel!
    @IBOutlet weak var mGradedByLABEL: UILabel!
    @IBOutlet weak var mCertificationLABEL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        mBottomView.layer.cornerRadius = 10
        mBottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        mBottomView.dropShadow()
        
        if UserDefaults.standard.string(forKey: "pickDiamond") != nil {
            mReserveButton.backgroundColor = UIColor(named : "themeColor")
            mReserveButton.setTitle("ADD TO CART".localizedString, for: .normal)
        }else{
            mReserveButton.setTitle("RESERVE".localizedString, for: .normal)
        }
    }
    
    
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mOpenImageViewer(_ sender: Any) {
        
        if !mAllImages.isEmpty {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
            if let mGlobalImageViewer = storyBoard.instantiateViewController(withIdentifier: "GlobalImageViewer") as? GlobalImageViewer {
                mGlobalImageViewer.modalPresentationStyle = .overFullScreen
                mGlobalImageViewer.mSKUName = self.mDiamondName.text ??  "--"
                mGlobalImageViewer.mAllImages = self.mAllImages
                mGlobalImageViewer.isMixMatch = true
                mGlobalImageViewer.transitioningDelegate = self
                self.present(mGlobalImageViewer,animated: false)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mDiamondDetailsLABEL.text = "Diamond Details".localizedString
        mHeadingLABEL.text = "Diamond".localizedString
        mStokIdLABEL.text = "Stock ID".localizedString
        mShapeLABEL.text = "Shape".localizedString
        mCaratLABEL.text = "Carat".localizedString
        mColourLABEL.text = "Colour".localizedString
        mClarityLABEL.text = "Clarity".localizedString
        mCutLABEL.text = "Cut".localizedString
        mPolishLABEL.text = "Polish".localizedString
        mSymmetryLABEL.text = "Symmetry".localizedString
        mFluorescenceLABEL.text = "Fluorescence".localizedString
        mDepthLABEL.text = "Depth".localizedString
        mTableLABEL.text = "Table".localizedString
        mGridleLABEL.text = "Gridle".localizedString
        mCuletLABEL.text = "Culet".localizedString
        mMeasurementsLABEL.text = "Measurements".localizedString
        mGradedByLABEL.text = "Graded By".localizedString
        mCertificationLABEL.text = "Certification".localizedString
        CommonClass.showFullLoader(view: self.view)
        let params:[String: Any] = ["id" : mProductId]
        
        print("mDiamondDetailsAPI params = ",params)
        
        mGetData(url: mDiamondDetailsAPI,headers: sGisHeaders,  params: params) { response , status in
            CommonClass.stopLoader()
            if status {
            if "\(response.value(forKey: "code") ?? "")" == "200" {
                if let mData = response.value(forKey: "data") as? NSDictionary {
                    print("mDiamondDetailsAPI mData = ",mData)
                    if let mImages = mData.value(forKey: "image") as? [String] {
                        if mImages.count > 0 {
                            self.mAllImages = mImages
                            self.mProductImage.downlaodImageFromUrl(urlString: mImages[0])
                        }
                    }
                    self.mProductData = mData
                    self.mDiamondName.text = "\(mData.value(forKey: "Carat") ?? "--") Carat, \(mData.value(forKey: "Shape") ?? "--") - \(mData.value(forKey: "Colour") ?? "--")/\(mData.value(forKey: "Clarity") ?? "--")"
                    self.mStockId2.text = "\(mData.value(forKey: "StockID") ?? "--")"
                    self.mStockId.text = "\(mData.value(forKey: "StockID") ?? "--")"
                    self.mShape.text = "\(mData.value(forKey: "Shape") ?? "--")"
                    self.mCarat.text = "\(mData.value(forKey: "Carat") ?? "--")"
                    self.mColor.text = "\(mData.value(forKey: "Colour") ?? "--")"
                    self.mClarity.text = "\(mData.value(forKey: "Clarity") ?? "--")"
                    self.mCut.text = "\(mData.value(forKey: "Cut") ?? "--")"
                    self.mPolish.text = "\(mData.value(forKey: "Polish") ?? "--")"
                    self.mMeasurement.text = "\(mData.value(forKey: "Symmetry") ?? "--")"
                    self.mSymmetry.text = "\(mData.value(forKey: "Symmetry") ?? "--")"
                    self.mCulet.text = "\(mData.value(forKey: "Culet") ?? "--")"
                    self.mFluorescence.text = "\(mData.value(forKey: "Fluoresence") ?? "--")"
                    self.mDepth.text = "\(mData.value(forKey: "Depth") ?? "--")"
                    self.mGirdle.text = "\(mData.value(forKey: "Gridle") ?? "--")"
                    self.mTable.text = "\(mData.value(forKey: "Table") ?? "--")"
                    self.mGradedBy.text = "\(mData.value(forKey: "GradedBy") ?? "--")"
                    self.mCertification.text = "\(mData.value(forKey: "Certification") ?? "--")"
                    self.mPrice.text = "\(mData.value(forKey: "Price") ?? "--")"
                    self.mCertificateNumber.text = "\(mData.value(forKey: "Certification") ?? "--")"
                    self.mCertificateName.text = "\(mData.value(forKey: "GradedBy") ?? "--")"
                    self.mStatus = "\(mData.value(forKey: "Status") ?? "--")"
                    
                    if UserDefaults.standard.string(forKey: "pickDiamond") != nil {
                    }else{
                        if self.mStatus == "1" {
                            self.mReserveButton.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8, blue: 1, alpha: 1)
                        } else if self.mStatus == "3" {
                            self.mReserveButton.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
                        }
                    }
                    
                    if let mCustomerName = mData.value(forKey: "customer") as? String {
                        self.mReservedCustomerName = mCustomerName
                    }
                    if let mRCustomerId =  mData.value(forKey: "customer_id") as? String{
                        self.mReservedCustomerId = mRCustomerId
                    }
                    
                }
                
            } else if "\(response.value(forKey: "code") ?? "")" == "403" {
                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
            } else {
          
            }
        }
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

    
    
    @IBAction func mReserveNow(_ sender: Any) {
        
        if mStatus != "1" { CommonClass.showSnackBar(message: "This item is already reserved!"); return }
        if mProductData == nil {
            CommonClass.showSnackBar(message: "Invalid Item");
            return
        }
        
        if let isPicked =  UserDefaults.standard.string(forKey: "pickDiamond") {
            
            mCustomerId  = UserDefaults.standard.string( forKey: "DEFAULTCUSTOMER") ?? ""
            
            if mCustomerId == "" {
                self.mOpenCustomerSheet()
            }
 
            
            if mCustomerId != mReservedCustomerId && isPicked == "reserve" {
                CommonClass.showSnackBar(message: "This Item is reserved for \(mReservedCustomerName)")
                self.mOpenCustomerSheet()
                return
            }
            
            if isPicked == "reserve" {
                
                let mParams = ["diamond_id":mProductId, "customer_id":mCustomerId, "sales_person_id":selectedSalesPersonId, "order_type":"reserve","product_type":"inventory"] as [String : Any]
                
                mGetData(url: mAddDiamondProduct,headers: sGisHeaders, params: mParams) { response , status in
                    CommonClass.stopLoader()
                    if status {
                        if "\(response.value(forKey: "code") ?? "")" == "200" {
                            
                            let storyBoard: UIStoryboard = UIStoryboard(name: "reserveOrderBoard", bundle: nil)
                            if let mHomePage  = storyBoard.instantiateViewController(withIdentifier: "ReserveCart") as? ReserveCart {
                                self.navigationController?.pushViewController(mHomePage, animated:true)
                            }
                            
                        }else if "\(response.value(forKey: "code") ?? "")" == "403" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        } else{
                            
                        }
                    }
                }
                
                
                return
                
            }
         
            let mParams = ["diamond_id":mProductId, "customer_id":mCustomerId, "sales_person_id":selectedSalesPersonId, "order_type":"pos_order","product_type":"inventory"] as [String : Any]
            
            mGetData(url: mAddDiamondProduct,headers: sGisHeaders, params: mParams) { response , status in
                CommonClass.stopLoader()
                if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    
                    let storyBoard: UIStoryboard = UIStoryboard(name: "posBoard", bundle: nil)
                    if let mHomePage  = storyBoard.instantiateViewController(withIdentifier: "POSTabBarController") as? POSTabBarController {
                        mHomePage.mIndex = 2
                        self.navigationController?.pushViewController(mHomePage, animated:true)
                    }
                }else if "\(response.value(forKey: "code") ?? "")" == "403" {
                    CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                }else{
              
                }
            }
        }
            

        }else{
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "diamondModule", bundle: nil)
            if let mDiamondReserveCart = storyBoard.instantiateViewController(withIdentifier: "DiamondReserveCart") as? DiamondReserveCart {
                mDiamondReserveCart.mData = mProductData
                self.navigationController?.pushViewController(mDiamondReserveCart, animated:true)
            }
        }

 
            
    
    }
    
}
