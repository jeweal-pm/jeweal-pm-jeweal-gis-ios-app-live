//
//  WishListController.swift
//  GIS
//
//  Created by Apple Hawkscode on 30/03/21.
//

import Alamofire
import UIKit

class WishlistCell: UITableViewCell {
    
    
    @IBOutlet weak var mDislikeButton: UIButton!
    @IBOutlet weak var mSKUName: UILabel!
    
    @IBOutlet weak var mDeleteButton: UIButton!
    @IBOutlet weak var mOrderButton: UIButton!
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mMetaTag: UITextView!
    
    @IBOutlet weak var mAmount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
   
    }
 

    
}


class WishListController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout,GetCustomerDataDelegate, UIViewControllerTransitioningDelegate {

    
    @IBOutlet weak var mCatalogCollectionView: UICollectionView!
    var mCatalogData = NSMutableArray()
    
    var mSearchCustomerData = NSArray()
    @IBOutlet weak var mNoData: UILabel!

    var mCustomerId = ""
    @IBOutlet weak var mSearchField: UITextField!
     var mWishListData = NSMutableArray()
    var mKey = ""
    
    @IBOutlet weak var mHeadingLABEL: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        mHeadingLABEL.text = "Wishlist".localizedString
       // mNoData.text = "No Data Found!".localizedString
        mSearchField.placeholder = "Search by SKU".localizedString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mCatalogCollectionView.dataSource = self
        self.mCatalogCollectionView.delegate = self
        
       mGetWish(value: "")
    }
    

   
    @IBAction func mBack(_ sender: Any) {
        self.dismiss(animated: true)

        self.navigationController?.popViewController(animated:true)
        
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
    
    
    @IBAction func mSearchEdit(_ sender: UITextField) {
        
        
        if sender.text == "" {
            mCatalogData = NSMutableArray(array: mSearchCustomerData)
            mCatalogCollectionView.reloadData()
        } else {
            mCatalogData = NSMutableArray()
            
            for i in mSearchCustomerData {
                if let mData = i as? NSDictionary {
                    let mValue = "\(mData.value(forKey: "SKU") ?? "")"
                    if mValue.lowercased().contains(sender.text?.lowercased() ?? "") {
                        mCatalogData.add(mData)
                        mCatalogCollectionView.reloadData()
                    }else{
                        mCatalogCollectionView.reloadData()
                    }
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
        
        if let customerId = data.value(forKey: "id") as? String {
          UserDefaults.standard.set(customerId, forKey: "DEFAULTCUSTOMER")
          self.mCustomerId = customerId
        }

        if let profilePicture = data.value(forKey: "profile") as? String {
          UserDefaults.standard.set(profilePicture, forKey: "DEFAULTCUSTOMERPICTURE")
        }

        if let customerName = data.value(forKey: "name") as? String {
          UserDefaults.standard.set(customerName, forKey: "DEFAULTCUSTOMERNAME")
        }
        mGetWish (value:"")

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        if collectionView == self.mCatalogCollectionView {
           count = mCatalogData.count
            if count == 0 {
                mNoData.isHidden = false
                self.mCatalogCollectionView.isHidden = true
                
            }else{
                mNoData.isHidden = true
                self.mCatalogCollectionView.isHidden = false
            }
       
        }
        
        return count
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        if collectionView == self.mCatalogCollectionView {
            
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCell",for:indexPath) as? CatalogCell {
                
                if let mData = mCatalogData[indexPath.row] as? NSDictionary {
                    
                    cells.mHeart.image = UIImage(systemName: "heart.fill")
                    cells.mHeart.tintColor = UIColor(named: "themeLightRed")
                    cells.mProductLikeButt.tag = indexPath.row
                    
                    let skuAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                        .foregroundColor: UIColor(named: "themeColor") ?? UIColor.black ]
                    let nameAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                        .foregroundColor: #colorLiteral(red: 0.3181298765, green: 0.3326592986, blue: 0.328506533, alpha: 1) ]
                    
                    let finalName = NSMutableAttributedString()
                    finalName.append(NSAttributedString(string: "\(mData.value(forKey: "item_name")  as? String ?? "")\n", attributes: nameAttributes))
                    finalName.append(NSAttributedString(string: "\(mData.value(forKey: "SKU")  as? String ?? "")", attributes: skuAttributes))
                    
                    cells.mProductName.attributedText = finalName
                    
                    cells.mPrice.text = "\(mData.value(forKey: "price") ?? "0.00")"
                    cells.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
                }
                cell = cells
            }
        }
        
        return cell
        
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == mCatalogCollectionView {

            
                            if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
                                if UIDevice.current.userInterfaceIdiom == .pad {
                                    return CGSize(width: mCatalogCollectionView.bounds.width/3 , height: 350)
                                }else{
                                    layout.minimumInteritemSpacing = 0
                                    return CGSize(width: mCatalogCollectionView.bounds.width/2  , height: 350)
                                }
                            }
         }
 
        return CGSize(width: view.frame.size.width/2 - 30 , height:50)
        
        
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let storyBoard: UIStoryboard = UIStoryboard(name: "catalog", bundle: nil)
        if let mProfile = storyBoard.instantiateViewController(withIdentifier: "POSAddToCartNew") as? POSAddToCart {
            if let catalogData = mCatalogData[indexPath.row] as? NSDictionary {
                mProfile.mData = catalogData
                mProfile.mType = "\(mProfile.mData.value(forKey: "type") ?? "")"
            }
            mProfile.mCustomerId = mCustomerId
            self.navigationController?.pushViewController(mProfile, animated:true)
        }
    }
    
 
    
    
//Catalog/productsList
    
    @IBAction func mLikeDislike(_ sender: UIButton) {
        
        if mCustomerId != "" {
            guard let mData = mCatalogData[sender.tag] as? NSDictionary else {
                return
            }
            CommonClass.showFullLoader(view: self.view)
            let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
            let mSKU = "\(mData.value(forKey: "SKU") ?? "")"
            let mProductId = "\(mData.value(forKey: "product_id") ?? "")"
            let mItemId = "\(mData.value(forKey: "item_id") ?? "")"
//            let params = ["location":mLocation,"customer_id":mCustomerId, "isWishlist":"1","SKU":mSKU, "product_id": mProductId]
            let params = [

                "location":mLocation,
                "customer_id":mCustomerId,
                "isWishlist":"1",
                "SKU":mSKU,
                "product_id":mProductId,
                "item_id":mItemId

            ]
            mGetData(url: mAddToFav,headers: sGisHeaders,  params: params) { response , status in
                if status {
                    if let code = response.value(forKey: "code") as? Int{
                        if code == 200 {
                            if response.value(forKey: "data") == nil {
                                CommonClass.stopLoader()
                                return
                            }else {
                                self.mGetWish(value: "", isShowLoader: false)
                            }
                        } else {
                            CommonClass.stopLoader()
                            if let message = response.value(forKey: "message") as? String {
                                CommonClass.showSnackBar(message: "Error \(code): \(message)")
                            }
                        }
                    }else {
                        CommonClass.stopLoader()
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    }
                }
            }
        }else{
            
            CommonClass.showSnackBar(message: "Please choose Customer!")
        }
        
    }
 
 
     
    
 
    func mGetWish(value: String, isShowLoader: Bool = true){
       
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        let urlPath =  mGetCustomerWishList
        let params = ["search": value ,"customer_id": mCustomerId,"location":mLocation]
        
        if Reachability.isConnectedToNetwork() == true {
            if isShowLoader {
                CommonClass.showFullLoader(view: self.view)
            }
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
            { response in
                defer {
                    CommonClass.stopLoader()
                }
                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    
                    guard let jsonData = response.data else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    guard let jsonResult = json as? NSDictionary else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    self.mCatalogData = NSMutableArray()
                    
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        if let data = jsonResult.value(forKey: "data") as? NSArray,
                           data.count > 0 {
                            
                            self.mSearchCustomerData = data
                            self.mCatalogData = NSMutableArray(array: data)
                            
                            self.mCatalogCollectionView.delegate  =  self
                            self.mCatalogCollectionView.dataSource  =  self
                            self.mCatalogCollectionView.reloadData()
                        }else{
                            self.mNoData.text = "No Data Found!".localizedString
                            self.mCatalogCollectionView.reloadData()
                        }
                        
                    }else{
                        self.mNoData.text = "No Data Found!".localizedString
                        self.mCatalogCollectionView.reloadData()
                    }
                }
            }
            
        }else{
            CommonClass.stopLoader()
            self.mNoData.text = "No Data Found!".localizedString
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
    }

}
