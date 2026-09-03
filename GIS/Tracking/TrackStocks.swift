//
//  TrackStocks.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 09/06/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire

class TrackStoneDetailsCell : UITableViewCell {
    
    @IBOutlet weak var sStoneName: UILabel!
    @IBOutlet weak var sPcs: UILabel!
    @IBOutlet weak var sWeight: UILabel!
    @IBOutlet weak var sCertificateNumber: UILabel!
    @IBOutlet weak var sCertificateType: UILabel!
    
}

class TrackItems : UITableViewCell {
    
    @IBOutlet weak var mDocumentView: UIView!
    @IBOutlet weak var mDateView: UIView!
    @IBOutlet weak var mStoreFromView: UIView!
    @IBOutlet weak var mStoreToView: UIView!
    @IBOutlet weak var mStoreNameView: UIView!
    @IBOutlet weak var mLovationNameView: UIView!
    @IBOutlet weak var mClientNameView: UIView!
    @IBOutlet weak var mCountryView: UIView!
    @IBOutlet weak var mNationalityView: UIView!
    @IBOutlet weak var mCustomOrderView: UIView!
    @IBOutlet weak var mQtyView: UIView!
    @IBOutlet weak var mZoneView: UIView!
    
    @IBOutlet weak var mDocumentStack: UIStackView!
    
    @IBOutlet weak var mDocumentId: UILabel!
    @IBOutlet weak var mDateStack: UIStackView!
    
    @IBOutlet weak var mZone: UILabel!
    @IBOutlet weak var mZoneStack: UIStackView!
    
    @IBOutlet weak var mQtyStack: UIStackView!
    @IBOutlet weak var mCustomOrder: UILabel!
    
    @IBOutlet weak var mCustomOrderStack: UIStackView!
    @IBOutlet weak var mNAtionality: UILabel!
    
    @IBOutlet weak var mNationalityStack: UIStackView!
    @IBOutlet weak var mCuntryStack: UIStackView!
    
    @IBOutlet weak var mClientNameStack: UIStackView!
    @IBOutlet weak var mLocationStack: UIStackView!
    @IBOutlet weak var mStoreNameStack: UIStackView!
    @IBOutlet weak var mToStoreStack: UIStackView!
    @IBOutlet weak var mStoreFrom: UILabel!
    @IBOutlet weak var mToStore: UILabel!
    @IBOutlet weak var mStoreFromStack: UIStackView!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mDate: UILabel!
    @IBOutlet weak var mType: UILabel!
    @IBOutlet weak var mMetal: UILabel!
    @IBOutlet weak var mSize: UILabel!
    @IBOutlet weak var mStone: UILabel!
    @IBOutlet weak var mQty: UILabel!
    @IBOutlet weak var mPrice: UILabel!
    @IBOutlet weak var mRefNo: UILabel!
    @IBOutlet weak var mLocation: UILabel!
    
    @IBOutlet weak var mCountryName: UILabel!
    @IBOutlet weak var mClientName: UILabel!
    @IBOutlet weak var mStoreName: UILabel!
    @IBOutlet weak var mDescription: UITextView!
    @IBOutlet weak var mBottomCircle: UIImageView!
    
    @IBOutlet weak var mTopCircle: UIImageView!
    
    @IBOutlet weak var mTopConst: NSLayoutConstraint!
    
    @IBOutlet weak var mBottomConst: NSLayoutConstraint!
    
}

class TrackStocks: UIViewController , UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var mTable: UITableView!
    
    
    @IBOutlet weak var mView: UIView!
    
    var mTrackData:[[String: Any]]  = []
    
    @IBOutlet weak var mNoDataView: UIView!
    
    
    
    
    @IBOutlet weak var mPLabel: UILabel!
    
    @IBOutlet weak var mALabel: UILabel!
    
    @IBOutlet weak var mPButton: UIButton!
    
    @IBOutlet weak var mAButton: UIButton!
    
    @IBOutlet weak var mNoDataLABEL: UILabel!
    
    @IBOutlet weak var mActivityView: UIView!
    
    @IBOutlet weak var mProductView: UIView!
    
    @IBOutlet weak var mBlockId: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mSKU: UILabel!
    
    
    
    @IBOutlet weak var mMetal: UILabel!
    
    @IBOutlet weak var mMetalWeight: UILabel!
    
    
    @IBOutlet weak var mStone: UILabel!
    @IBOutlet weak var mPieces: UILabel!
    
    @IBOutlet weak var mStoneWeight: UILabel!
    @IBOutlet weak var mLab1Name: UILabel!
    @IBOutlet weak var mLab1Id: UILabel!
    @IBOutlet weak var mLab2Name: UILabel!
    @IBOutlet weak var mLab2Id: UILabel!
    
    @IBOutlet weak var mSize: UILabel!
    @IBOutlet weak var mCurrency: UILabel!
    @IBOutlet weak var mPrice: UILabel!
    @IBOutlet weak var mQty: UILabel!
    
    var mStockKey = ""
    
    
    @IBOutlet weak var mHeadingLABEL: UILabel!
    
    @IBOutlet weak var mBlockIdLABEL: UILabel!
    @IBOutlet weak var mStockIdLABEL: UILabel!
    @IBOutlet weak var mSKULABEL: UILabel!
    @IBOutlet weak var mProductInformationLABEL: UILabel!
    @IBOutlet weak var mMetalDetailsLABEL: UILabel!
    @IBOutlet weak var mMetalLABEL: UILabel!
    @IBOutlet weak var mWeightLABEL: UILabel!
    @IBOutlet weak var mStoneDetailsLABEL: UILabel!
    @IBOutlet weak var mStoneLABEL: UILabel!
    @IBOutlet weak var mPcsLABEL: UILabel!
    @IBOutlet weak var mStoneWeightLABEL: UILabel!
    @IBOutlet weak var mOtherDetailsLABEL: UILabel!
    @IBOutlet weak var mSizeLABEL: UILabel!
    @IBOutlet weak var mCurrencyLABEL: UILabel!
    @IBOutlet weak var mPriceLABEL: UILabel!
    @IBOutlet weak var mQtyLABEL: UILabel!
    
    //Track Details Stone
    @IBOutlet weak var sTrackStoneDetailsTable: UITableView!
    private var sTrackStoneList: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        // Setup view
        mInitView()
        // Fetch Product Details
        mTrackProductDetails()
    }
    
    private func mInitView(){
        mHeadingLABEL.text = "Trace".localizedString
        mBlockIdLABEL.text = "Block Id".localizedString
        mStockIdLABEL.text = "Stock Id".localizedString
        mSKULABEL.text = "SKU".localizedString
        mProductInformationLABEL.text = "Product Information".localizedString
        mMetalDetailsLABEL.text = "Metal Details".localizedString
        mMetalLABEL.text = "Metal".localizedString
        mWeightLABEL.text = "Weight".localizedString
        mStoneDetailsLABEL.text = "Stone Details".localizedString
        mOtherDetailsLABEL.text = "Other Details".localizedString
        mSizeLABEL.text = "Size".localizedString
        mCurrencyLABEL.text = "Currency".localizedString
        mPriceLABEL.text = "Price".localizedString
        mQtyLABEL.text = "Qty".localizedString
        self.mPButton.setTitle("Product".localizedString, for: .normal)
        self.mAButton.setTitle("Activity".localizedString, for: .normal)
        
        mNoDataLABEL.text = "No Data Found!".localizedString
        mPButton.setTitleColor(.link, for: .normal)
        mPLabel.backgroundColor = .link
        mALabel.backgroundColor = .white
        mAButton.setTitleColor(.darkGray, for: .normal)
        mProductView.isHidden = false
        mActivityView.isHidden = true
        
        self.mBlockId.text = "--"
        self.mStockId.text = "--"
        self.mSKU.text = "--"
        self.mMetal.text = "--"
        self.mMetalWeight.text = "--"
        self.mSize.text = "--"
        self.mCurrency.text = "--"
        self.mPrice.text = "--"
        self.mQty.text = "--"
        
        self.sTrackStoneDetailsTable.delegate = self
        self.sTrackStoneDetailsTable.dataSource = self
        
        self.mTable.delegate = self
        self.mTable.dataSource = self
    }
    
    
    @IBAction func mBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mProductClicked(_ sender: Any) {
        mPButton.setTitleColor(UIColor(named:"themeLightText"), for: .normal)
        mPLabel.backgroundColor = UIColor(named:"themeColor")
        
        mALabel.backgroundColor = UIColor(named:"themeExtraLightText1")
        mAButton.setTitleColor(UIColor(named:"themeExtraLightText1"), for: .normal)
        
        mProductView.isHidden = false
        mActivityView.isHidden = true
        mTrackProductDetails()
    }
    
    @IBAction func mActivityClicked(_ sender: Any) {
        mAButton.setTitleColor(UIColor(named:"themeLightText"), for: .normal)
        mALabel.backgroundColor = UIColor(named:"themeColor")
        
        mPLabel.backgroundColor = UIColor(named:"themeExtraLightText1")
        mPButton.setTitleColor(UIColor(named:"themeExtraLightText1"), for: .normal)
        mProductView.isHidden = true
        mActivityView.isHidden = false
        mTrackProductHistory()
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.mTable {
            return mTrackData.count
        } else if tableView == self.sTrackStoneDetailsTable {
            return sTrackStoneList.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = UITableViewCell()
        if tableView == self.mTable {
            if let cells = tableView.dequeueReusableCell(withIdentifier: "TrackItems") as? TrackItems {
                
                let mData = mTrackData[indexPath.row] as [String: Any]
                
                if let discription = mData["description"] as? String , !discription.isEmpty {
                    cells.mDescription.text = "Description: \(discription): \(mData["document_id"] ?? "")"
                    cells.mDescription.isHidden = false
                }else {
                    cells.mDescription.isHidden = true
                }
                
                cells.mType.text = "\(mData["activity"] ?? "UNK")"
                
                if let dockId = mData["document_id"] as? String, !dockId.isEmpty {
                    cells.mDocumentId.text = dockId
                    cells.mDocumentStack.isHidden = false
                    cells.mDocumentView.isHidden = false
                }else {
                    cells.mDocumentStack.isHidden = true
                    cells.mDocumentView.isHidden = true
                    
                }
                
                if let date = mData["transaction_date"] as? String, !date.isEmpty {
                    cells.mDate.text = date
                    cells.mDateStack.isHidden = false
                    cells.mDateView.isHidden = false
                    
                }else {
                    cells.mDateView.isHidden = true
                    cells.mDateStack.isHidden = true
                    
                }
                
                if let storeName = mData["nameOfStore"] as? String, !storeName.isEmpty {
                    cells.mStoreName.text = storeName
                    cells.mStoreNameStack.isHidden = false
                    cells.mStoreNameView.isHidden = false
                    
                }else {
                    cells.mStoreNameView.isHidden = true
                    cells.mStoreNameStack.isHidden = true
                    
                }
                
                if let zone = mData["transactionZone"] as? String, !zone.isEmpty {
                    cells.mZone.text = zone
                    cells.mZoneStack.isHidden = false
                    cells.mZoneView.isHidden = false
                    
                }else {
                    cells.mZoneStack.isHidden = true
                    cells.mZoneView.isHidden = true
                    
                }
                
                if let location = mData["store_city"] as? String, !location.isEmpty {
                    cells.mLocation.text = location
                    cells.mLovationNameView.isHidden = false
                    cells.mLocationStack.isHidden = false
                    
                }else {
                    cells.mLocationStack.isHidden = true
                    cells.mLovationNameView.isHidden = true
                    
                }
                
                if let data = mData["clientName"] as? String, !data.isEmpty {
                    cells.mClientName.text = data
                    cells.mClientNameStack.isHidden = false
                    cells.mClientNameView.isHidden = false
                    
                }else {
                    cells.mClientNameStack.isHidden = true
                    cells.mClientNameView.isHidden = true
                    
                }
                
                if let data = mData["country"] as? String, !data.isEmpty {
                    cells.mCountryName.text = data
                    cells.mCuntryStack.isHidden = false
                    cells.mCountryView.isHidden = false
                    
                }else {
                    cells.mCuntryStack.isHidden = true
                    cells.mCountryView.isHidden = true
                    
                }
                
                if let data = mData["nationality"] as? String, !data.isEmpty {
                    cells.mNAtionality.text = data
                    cells.mNationalityStack.isHidden = false
                    cells.mNationalityView.isHidden = false
                    
                }else {
                    cells.mNationalityStack.isHidden = true
                    cells.mNationalityView.isHidden = true
                    
                }
                
                if let data = mData["customOrder"] as? String, !data.isEmpty {
                    cells.mCustomOrder.text = data
                    cells.mCustomOrderStack.isHidden = false
                    cells.mCustomOrderView.isHidden = false
                    
                }else {
                    cells.mCustomOrderStack.isHidden = true
                    cells.mCustomOrderView.isHidden = true
                    
                }
                
                if let data = mData["store_from"] as? String, !data.isEmpty {
                    cells.mStoreFrom.text = data
                    cells.mStoreFromStack.isHidden = false
                    cells.mStoreFromView.isHidden = false
                    
                }else {
                    cells.mStoreFromStack.isHidden = true
                    cells.mStoreFromView.isHidden = true
                    
                }
                
                if let data = mData["to_store"] as? String, !data.isEmpty {
                    cells.mToStore.text = data
                    cells.mToStoreStack.isHidden = false
                    cells.mStoreToView.isHidden = false
                    
                }else {
                    cells.mToStoreStack.isHidden = true
                    cells.mStoreToView.isHidden = true
                    
                }
                
                if let data = mData["QTY"] as? String, !data.isEmpty {
                    cells.mQty.text = data
                    cells.mQtyView.isHidden = false
                    cells.mQtyStack.isHidden = false
                    
                }else {
                    cells.mQtyStack.isHidden = true
                    cells.mQtyView.isHidden = true
                }
                
                cells.mTopConst.constant = 5
                if indexPath.row == (mTrackData.count - 1 ) {
                    cells.mBottomConst.constant = 5
                    cells.mBottomCircle.isHidden = false
                }else{
                    cells.mBottomConst.constant = -24
                    cells.mBottomCircle.isHidden = true
                    
                }
                
                cell = cells
            }
        }
        else if tableView == self.sTrackStoneDetailsTable {
            
            if let cells = tableView.dequeueReusableCell(withIdentifier: "TrackStoneDetailsCell") as? TrackStoneDetailsCell {
                
                let mData = self.sTrackStoneList[indexPath.row]
                cells.sStoneName.text = "\(mData["stone_name"] ?? "")"
                cells.sPcs.text = "\(mData["Pcs"] ?? "")"
                cells.sWeight.text = "\(mData["Cts"] ?? "")"
                
                if let certificate = mData["certificate"] as? [String: Any] {
                    cells.sCertificateType.text = "\(certificate["type"] ?? "")"
                    cells.sCertificateNumber.text = "\(certificate["number"] ?? "")"
                }
                
                cell = cells
            }
        }
        return cell
    }
    
    
    func mTrackProductDetails(){
        
        guard Reachability.isConnectedToNetwork() == true else {
            CommonClass.showSnackBar(message: "Please check your internet connection.")
            return
        }
        
        let params = ["stock_id": self.mStockKey] as [String : Any]
        let urlPath =  mTrackProductDetailsApi
        
        CommonClass.showFullLoader(view: self.view)
        AF.request(urlPath, method:.post,parameters: params,encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
            CommonClass.stopLoader()
            
            guard let jsonData = response.data else {
                CommonClass.showSnackBar(message: "Oops, something went wrong!")
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                      let code = json["code"] as? Int else {
                    CommonClass.showSnackBar(message: "Oops, something went wrong!")
                    return
                }
                
                switch code {

                case 200:

                    if let data = json["data"] as? [String: Any] {

                        self.mBlockId.text = "\(data["_id"] ?? "--")"
                        self.mStockId.text = "\(data["stock_id"] ?? "--")"
                        self.mSKU.text = "\(data["SKU"] ?? "--")"

                        self.mMetal.text = "\(data["metal"] ?? "--")"
                        self.mMetalWeight.text = "\(data["GrossWt"] ?? "--")"

                        self.mSize.text = "\(data["size"] ?? "--")"
                        self.mCurrency.text = "\(data["currency"] ?? "--")"
                        self.mPrice.text = "\(data["price"] ?? "--")"
                        self.mQty.text = "\(data["po_QTY"] ?? "--")"

                        if let stones = data["stones"] as? [[String:Any]] {
                            self.sTrackStoneList = stones
                            self.sTrackStoneDetailsTable.reloadData()
                        }
                    }

                case 403:

                    CommonClass.sessionExpired(isExpired: true,
                                               navigation: self.navigationController)

                default:

                    let message = json["message"] as? String ?? "Oops, something went wrong!"

                    CommonClass.showSnackBar(message: message)
                }
//                switch code {
//                case 200:
//                    if let data = json["data"] as? [String: Any] {
//                        
//                        self.mBlockId.text = "\(data["_id"] ?? "--")"
//                        self.mStockId.text = "\(data["stock_id"] ?? "--")"
//                        self.mSKU.text = "\(data["SKU"] ?? "--")"
//                        
//                        self.mMetal.text = "\(data["metal"] ?? "--")"
//                        self.mMetalWeight.text = "\(data["GrossWt"] ?? "--")"
//                        
//                        self.mSize.text = "\(data["size"] ?? "--")"
//                        self.mCurrency.text = "\(data["currency"] ?? "--")"
//                        self.mPrice.text = "\(data["price"] ?? "--")"
//                        self.mQty.text = "\(data["po_QTY"] ?? "--")"
//
//                        if let stones = data["stones"] as? [[String:Any]] {
//                            self.sTrackStoneList = stones
//                            self.sTrackStoneDetailsTable.reloadData()
//                            
//                        }
//                        
//                    }
//                case 403:
//                    CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
//                default:
//                    let errorMessage = json["message"] as? String ?? "An error occurred."
//                    CommonClass.showSnackBar(message: "Error \(code): \(errorMessage)")
//                }
            } catch {
                CommonClass.showSnackBar(message: "Oops, something went wrong!")
            }
        }
        
        
    }
    
    func mTrackProductHistory(){
        
        guard Reachability.isConnectedToNetwork() == true else {
            CommonClass.showSnackBar(message: "Please check your internet connection.")
            return
        }
        
        let params = ["stock_id": self.mStockKey] as [String : Any]
        let urlPath =  mTrackProductHistoryApi
        
        CommonClass.showFullLoader(view: self.view)
        AF.request(urlPath, method:.post,parameters: params,encoding: JSONEncoding.default, headers: sGisHeaders).responseJSON { response in
            
            CommonClass.stopLoader()
            
            guard let jsonData = response.data else {
                CommonClass.showSnackBar(message: "Oops, something went wrong!")
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                      let code = json["code"] as? Int else {
                    CommonClass.showSnackBar(message: "Oops, something went wrong!")
                    return
                }
                
                switch code {
                case 200:
                    if let data = json["data"] as? [[String: Any]] , data.count > 0 {
                        self.mTrackData = data
                        self.mTable.reloadData()
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
