//
//  RepairDesign.swift
//  GIS
//
//  Created by Apple Hawkscode on 05/10/21.
//

import UIKit
import  DropDown
import Alamofire

class RepairListCell : UICollectionViewCell {
  
    @IBOutlet weak var mOptionsButt: UIButton!
    @IBOutlet weak var mOptions: UILabel!
}

class RepairDesign : UIViewController , UIImagePickerControllerDelegate ,UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var mConcept: UITextView!
    @IBOutlet weak var mPicturesCollection: UICollectionView!
    @IBOutlet weak var mConceptLabel: UILabel!
    @IBOutlet weak var mConceptImage: UIImageView!
    @IBOutlet weak var mConceptSeparator: UILabel!
   
    @IBOutlet weak var mPictureImage: UIImageView!
    @IBOutlet weak var mPictureLabel: UILabel!

    var mStatus = ""
    var mImageStatus = ""
    var mKey = ""
    var mEditId = ""
    var mProductId = ""
    var mCartId = ""
    var mPage = 0
    
    var mSelectedIndex = [IndexPath]()
    var mOptionsId = [String]()
    
    @IBOutlet weak var mConceptHeader: UILabel!
    @IBOutlet weak var mDesignConceptView: UIView!

    @IBOutlet weak var mImageUploadView: UIView!

    @IBOutlet weak var mRepairCollection: UICollectionView!

    var mRepairOptionData =  NSArray()
    
    var mCustomDesignData = NSDictionary()
    var mImageArray = [UIImage]()
    var mImagesArray = [String]()
    var mImageImageArray = [UIImageView]()
    var mFontsArray = [String]()
    var mFontsIdArray = [String]()

    var mFontId = ""
    var mCustomerId = ""
    var mRepairCartId = ""
    var mRepairListId = ""
    var mRepairList = NSMutableDictionary()
    
    var imagePicker = UIImagePickerController()
    var logoPicker = UIImagePickerController()
    
    var mData = NSDictionary()
    
    var mCustomerNameT = ""
    var mCustomerNumberT = ""
    var mCustomerAddressT = ""
    var mList = [String]()
    
    @IBOutlet weak var mProductName: UILabel!
    
    @IBOutlet weak var mStockId: UILabel!
//    @IBOutlet weak var mLocationName: UILabel!
    @IBOutlet weak var mMetaTag: UILabel!
    @IBOutlet weak var mMetalName: UILabel!
    @IBOutlet weak var mStoneName: UILabel!
    @IBOutlet weak var mSizeName: UILabel!
    @IBOutlet weak var mCollectionName: UILabel!

    @IBOutlet weak var mProductImage: UIImageView!
    
    @IBOutlet weak var mMetalLABEL: UILabel!
    @IBOutlet weak var mStoneLABEL: UILabel!
    
    @IBOutlet weak var mSizeLABEL: UILabel!
    
    @IBOutlet weak var mCollectionLABEL: UILabel!
    
    @IBOutlet weak var mWriteYourConceptLABEL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
        mProductName.text = "\(mData.value(forKey: "SKU") ?? "--")"
        mStockId.text = "\(mData.value(forKey: "stock_id") ?? "--")"

        mMetaTag.text = "\(mData.value(forKey: "name") ?? "--")"
        mMetalName.text = "\(mData.value(forKey: "metal_name") ?? "")"
        mStoneName.text = "\(mData.value(forKey: "stone_name") ?? "--")"
        mSizeName.text = "\(mData.value(forKey: "size_name") ?? "--")"
        mCollectionName.text = "\(mData.value(forKey: "collection_name") ?? "--")"
//        mLocationName.text = "\(mData.value(forKey: "location_name") ?? "--" )"
        mConceptHeader.text = "Repair".localizedString
        mConceptLabel.textColor = UIColor(named: "themeColor")
        mConceptSeparator.backgroundColor =  UIColor(named: "themeExtraLightText1")
        mConceptImage.image = UIImage(named: "process_icon")
        mPictureLabel.textColor = UIColor(named: "theme6A")
        mPictureImage.image = UIImage(named: "repair_picture_grey")
        mConceptLabel.text = "Process".localizedString
        mPictureLabel.text = "Picture".localizedString

        if mStatus != "0" {
            
        }
        let tap =  UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
              view.addGestureRecognizer(tap)
              tap.cancelsTouchesInView = false
        
        mImageUploadView.isHidden = true
        mDesignConceptView.isHidden = false
        mPicturesCollection.delegate = self
        mPicturesCollection.dataSource = self
        
        
        mRepairCollection.delegate = self
        mRepairCollection.dataSource = self
        
        if mStatus != "0" {
            self.mImageStatus = "1"
    
        }
        mGetOption()
    }
    
    
    
    @IBAction func mSelectProcess(_ sender: Any) {
   
    }
    
    @IBAction func mSelectPicture(_ sender: Any) {
    
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if mStatus == "1" {
            let params:[String: Any] = ["custom_cart_id":mCartId,"customer_id":mCustomerId , "order_type": "repair_order"]
            
            CommonClass.showFullLoader(view: self.view)
            
            mGetData(url: mCustomDesignDetails, headers: sGisHeaders,  params: params) { response , status in
                CommonClass.stopLoader()
                if status {
                    if "\(response.value(forKey: "code") ?? "")" == "200" {
                        self.mImageStatus = "1"
                        
                        if let mData = response.value(forKey: "data") as? NSDictionary {
                            
                            if let mCustomDesignData = mData.value(forKey: "repair_design") as? NSDictionary {
                                
                                self.mConcept.text = mCustomDesignData.value(forKey: "description") as? String
                                if let list = mCustomDesignData.value(forKey: "repair_list") as? [String] {
                                    self.mList = list
                                    
                                    if self.mList.count > 0 {
                                        for i in 0...self.mRepairOptionData.count - 1 {
                                            
                                            if let data = self.mRepairOptionData[i] as? NSDictionary {
                                                let id  = data.value(forKey: "id") as? String ?? ""
                                                for j in self.mList {
                                                    if id == j {
                                                        self.mOptionsId.append(j)
                                                        self.mSelectedIndex.append(IndexPath(row:i,section: 0))
                                                    }
                                                }
                                                
                                                self.mRepairCollection.reloadData()
                                            }
                                        }
                                    }
                                }
                                
                                if let mImageDesign = mCustomDesignData.value(forKey: "image_design") as? [String] {
                                    if mImageDesign.count > 0 {
                                        for i in mImageDesign {
                                            self.mImagesArray.append(i)
                                            self.mPicturesCollection.reloadData()
                                        }
                                    }else{
                                        self.mImageStatus = ""
                                    }
                                }else{
                                    self.mImageStatus = ""
                                }
                            }
                        }
                        
                        
                        
                        
                        
                        
                        
                    }else{
                    }
                }
            }
            
        }
        
        
        mMetalLABEL.text = "Metal".localizedString
        mStoneLABEL.text = "Stone".localizedString
        
        mSizeLABEL.text = "Size".localizedString
        
        mCollectionLABEL.text = "Collection".localizedString
        mWriteYourConceptLABEL.text = "Write your concept design".localizedString
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       
    }
    override func viewDidLayoutSubviews() {
        
 

    }
    
  
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mRepairCollection {
            return mRepairOptionData.count
        }else {
        if mStatus != "" {
            return mImagesArray.count
        }
        return mImagesArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
    var cell =  UICollectionViewCell()
        
        if collectionView == mRepairCollection {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "RepairListCell",for:indexPath) as? RepairListCell {
                if let mData = mRepairOptionData[indexPath.row] as? NSDictionary {
                    cells.mOptions.text = "\(mData.value(forKey: "name") ?? "")"
                }
                cells.mOptionsButt.tag = indexPath.row
                if mSelectedIndex.contains(indexPath) {
                    cells.mOptions.backgroundColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
                }else{
                    cells.mOptions.backgroundColor = #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
                
                cells.layoutSubviews()
                cell = cells
            }
        }else {
            if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCell", for: indexPath) as? PictureCell {
                
                cells.mImageView.contentMode = .scaleAspectFill
                cells.mButton.tag = indexPath.row
                
                if mStatus != "" {
                    cells.mImageView.downlaodImageFromUrl(urlString: mImagesArray[indexPath.row])
                }else{
                    cells.mImageView.downlaodImageFromUrl(urlString: mImagesArray[indexPath.row])
                }
                
                cell = cells
            }
        }
        
        return cell
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if collectionView == mRepairCollection {
            
            let layout = collectionViewLayout as? UICollectionViewFlowLayout
            layout?.minimumLineSpacing =  0
            layout?.minimumInteritemSpacing = 0
            
            return CGSize(width: mRepairCollection.bounds.width/2  , height: 35)
        }
        return CGSize(width: 0, height: 0)
    }
    
    @IBAction func mOptionButton(_ sender: UIButton) {
        
        let mIndexPath = IndexPath(row:sender.tag ,section: 0)
        let mData = mRepairOptionData[sender.tag] as? NSDictionary

        if self.mOptionsId.contains("\(mData?.value(forKey: "id") ?? "")") {
            self.mOptionsId = mOptionsId.filter {$0 != "\(mData?.value(forKey: "id") ?? "")" }
        }else{
            self.mOptionsId.append("\(mData?.value(forKey: "id") ?? "")")
        }
        
        if self.mSelectedIndex.contains(mIndexPath) {
            self.mSelectedIndex = mSelectedIndex.filter {$0 != mIndexPath }
        }else{
            self.mSelectedIndex.append(mIndexPath)
        }

        self.mRepairCollection.reloadData()
        
    }

    @IBAction func mRemove(_ sender: UIButton) {
        
        let alert:UIAlertController=UIAlertController(title: "Remove Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Remove", style: UIAlertAction.Style.default) {
            UIAlertAction in
            
            if self.mStatus != "" {
                
                self.mImagesArray.remove(at:sender.tag)
                self.mPicturesCollection.reloadData()
                if self.mImagesArray.count < 1 {
                    self.mImageStatus = ""
                }
            }else{
                self.mImagesArray.remove(at:sender.tag)
                self.mPicturesCollection.reloadData()
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            
            UIAlertAction in
        }
        
        // Add the actions
        
        alert.addAction(cameraAction)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func openCamera(_ sourceType: UIImagePickerController.SourceType) {
        if mKey == "" {
    imagePicker.sourceType = sourceType
     imagePicker.allowsEditing = false
    self.present(imagePicker, animated: true, completion: nil)
        }else{
            logoPicker.sourceType = sourceType
            logoPicker.allowsEditing = false
            self.present(logoPicker, animated: true, completion: nil)
        }
    }
    
    
    
    
     


    // MARK: UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if picker == imagePicker {
       
            imagePicker.dismiss(animated: true, completion: nil)

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let base64EncodedPath = image.toBase64()
                mGetImageUrl(base64: base64EncodedPath ?? "", type: "images")
            }
        }
      
    }

    func mGetImageUrl(base64 : String , type: String){
        let params:[String: Any] = ["image":base64,"name":type]
        
        CommonClass.showFullLoader(view: self.view)
        
        mGetData(url: mGenerateImageUrlAPI,headers: sGisHeaders,  params: params) { response , status in
            CommonClass.stopLoader()
            if status {
                if "\(response.value(forKey: "code") ?? "")" == "200" {
                    
                    if response.value(forKey: "data") == nil {
                        return
                    }
                    
                    if (response.value(forKey: "data") as? NSDictionary)?.value(forKey: "images") == nil {
                        return
                    }
                    
                    if let mData = response.value(forKey: "data") as? NSDictionary,
                       let image = mData.value(forKey: "images") as? NSDictionary,
                       let imageUrl = image.value(forKey: "url") as? String {
                        
                        self.mImagesArray.append(imageUrl)
                        self.mPicturesCollection.reloadData()
                        
                        CommonClass.showSnackBar(message: "Image uploaded successfully!")
                    }
                    
                }else{
                }
            }
        }
    }

   
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
     picker.dismiss(animated: true, completion: nil)
     
    }
     
    private func addPencilKit() {
    
    }
    
    @IBAction func mChooseImage(_ sender: Any) {
        
        if  self.mImageStatus == "" {
            mKey = ""
            mStatus = ""
            
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
                
                
                let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    self.openCamera(UIImagePickerController.SourceType.camera)
                }
                let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    self.openCamera(UIImagePickerController.SourceType.photoLibrary)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                    
                    UIAlertAction in
                }
                
                // Add the actions
                imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
                alert.addAction(cameraAction)
                alert.addAction(gallaryAction)
                alert.addAction(cancelAction)
                addActionSheetForiPad(actionSheet: alert)
                self.present(alert, animated: true, completion: nil)
                
            }else{
                let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
                let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    self.openCamera(UIImagePickerController.SourceType.camera)
                }
                let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default) {
                    UIAlertAction in
                    self.openCamera(UIImagePickerController.SourceType.photoLibrary)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                    
                    UIAlertAction in
                }
                
                // Add the actions
                imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
                alert.addAction(cameraAction)
                alert.addAction(gallaryAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }else{
            CommonClass.showSnackBar(message: "Please remove already added pictures!")
        }
    }
    
  
 
     
    @IBAction func mBack(_ sender: Any) {
        
        if mPage == 0 {
            self.navigationController?.popViewController(animated: true)
             mPage = 0
             
        }else if mPage == 1 {
            mConceptHeader.text = "Repair".localizedString
            mConceptLabel.textColor = UIColor(named: "themeColor")
            mConceptSeparator.backgroundColor =  UIColor(named: "themeExtraLightText1")
            mConceptImage.image = UIImage(named: "process_icon")
            mPictureLabel.textColor = UIColor(named: "theme6A")
            mPictureImage.image = UIImage(named: "repair_picture_grey")
            
            mDesignConceptView.isHidden = false
            mImageUploadView.isHidden = true
            mPage = 0
        }
    }
    
    @IBAction func mRight(_ sender: Any) {
       
        if mPage == 0 {
           
        
            
            
            mConceptHeader.text = "Picture".localizedString
             mConceptLabel.textColor = UIColor(named: "themeColor")
            mConceptSeparator.backgroundColor =  UIColor(named: "themeColor")
            mConceptImage.image = UIImage(named: "process_icon")
            mPictureLabel.textColor = UIColor(named: "themeColor")
            mPictureImage.image = UIImage(named: "repair_picture_green")
            
            
            mDesignConceptView.isHidden = true
           // mCanvasView.isHidden = true
            mImageUploadView.isHidden = false
         
            mPage = 1
            
        }else if mPage == 1 {
            
            if mStatus != ""{
                for i in 0..<mImagesArray.count{
                    let mIndexPath = IndexPath(row: i ,section: 0)
                    if let cell = self.mPicturesCollection.cellForItem(at: mIndexPath) as? PictureCell {
                        if let img = cell.mImageView.image {
                            mImageArray.append(img)
                        }
                    }
                }
                mUploaddData()
                
            }else{
                mUploaddData()
            }
            
        }
    }
    
    
    func mUploaddData() {
        
        CommonClass.showFullLoader(view: view)
        
        let mData = NSMutableDictionary()
        let mRepairData = NSMutableDictionary()
        
        
        let mLocation = UserDefaults.standard.string(forKey: "location")
        
        mRepairData.setValue(mConcept.text ?? "", forKey: "description")
        mRepairData.setValue(self.mOptionsId, forKey: "repair_list")
        mRepairData.setValue(mImagesArray, forKey: "image_design")
        mData.setValue(mCustomerId, forKey: "customer_id")
        mData.setValue(mLocation ?? "", forKey: "location_id")
        mData.setValue(mCartId, forKey: "custom_cart_id")
        mData.setValue(mRepairData, forKey: "repair_design")
        let parameterS: Parameters = ["data":mData,
                                      "status_type": "repair_order"]
        
        mGetData(url: mUpdateProductStoneDetails,headers: sGisHeaders,  params: parameterS) { response , status in
            CommonClass.stopLoader()
            if status {
                
                if let mCode =  response.value(forKey: "code") as? Int {
                    
                    if mCode == 200 {
                        let storyBoard: UIStoryboard = UIStoryboard(name: "moreBoard", bundle: nil)
                        if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "RepairOrderController") as? RepairOrderController {
                            self.navigationController?.pushViewController(mCustomCart, animated:true)
                        }
                    }
                    
                    if mCode == 400 {
                        CommonClass.showSnackBar(message: "\(response.value(forKey: "message") ?? "OOP's something went wrong!")")
                        return
                    }
                }
            }}
        
    }
    
    
    func mGetFonts(){
        
        let urlPath = mFonts
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:nil, headers: sGisHeaders2).responseJSON
            { response in
                
                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    guard let jsonData = response.data else {
                        CommonClass.showSnackBar(message: "OOP's something went wrong!")
                        return
                    }
                    
                    let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    if let jsonResult = json as? NSDictionary {
                        let data = jsonResult.value(forKey: "font") as? NSArray
                    }
                }
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
    }
    
    func mGetOption(){
        let mParamRepair = ["query":"{Repair{id name}}"]
        AF.request(mGrapQlUrl, method:.post,parameters: mParamRepair, encoding:JSONEncoding.default, headers: sGisHeaders ).responseJSON
        { response in
            if(response.error != nil) {
                UserDefaults.standard.set(nil, forKey: "REPAIR_DESIGN")
            }else{
                guard let jsonData = response.data else {
                    return
                }
                let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                guard let jsonResult = json as? NSDictionary else {
                    return
                }
                
                UserDefaults.standard.set(jsonResult, forKey: "REPAIR_DESIGN")
                
                self.mRepairOptionData = NSArray()
                
                if let mResults = jsonResult.value(forKey: "data") as? NSDictionary {
                    if let mData = mResults.value(forKey: "Repair") as? NSArray{
                        
                        if mData.count > 0 {
                            self.mRepairOptionData =  mData

                            self.mRepairCollection.reloadData()
                        }
                    }
                    
                }
            }
        }
        
    }
}
