//
//  LanguageController.swift
//  GIS
//
//  Created by Apple Hawkscode on 17/11/20.
//

import UIKit
import Alamofire
import UIDrawer

class LanguageCell: UITableViewCell {
    
    @IBOutlet weak var mFlag: UIImageView!
    @IBOutlet weak var mName: UILabel!
    
}
class LanguageController: UIViewController , UITableViewDelegate ,  UITableViewDataSource, UIViewControllerTransitioningDelegate {
    
    
    @IBOutlet weak var mProfilePicture: UIImageView!
    @IBOutlet weak var mHello: UILabel!
    
    @IBOutlet weak var mFirstName: UILabel!
    @IBOutlet weak var mBrandImage: UIImageView!
    
    @IBOutlet weak var mBackgroundImage: UIImageView!
    @IBOutlet weak var mLastName: UILabel!
    @IBOutlet weak var mLanguage: UILabel!
    var mLocationData = NSArray()
    
    @IBOutlet weak var mLanguageView: UIView!
    @IBOutlet weak var mLanguageTable: UITableView!
    var mLanguageData = NSArray()
    @IBOutlet weak var mView: UIView!
    
    @IBOutlet weak var mEnterBUTTON: UIButton!
    @IBOutlet weak var mChooseLanLABEL: UILabel!
    @IBOutlet weak var mLanguageName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mLastName.isHidden = true
        
        self.mFirstName.textAlignment = .center
        
        if let lang = UserDefaults.standard.string(forKey: "LANG") {
            switch lang {
                case "EN": AppLanguage.shared.set(index: .english)
                case "TH": AppLanguage.shared.set(index: .thai)
                case "JA": AppLanguage.shared.set(index: .japanese)
                case "AR": AppLanguage.shared.set(index: .arabic)
                case "CH": AppLanguage.shared.set(index: .chinese)
                case "RU": AppLanguage.shared.set(index: .russian)
                default:   AppLanguage.shared.set(index: .english)
            }
        }

        
        mLanguageName.text = "Language".localizedString
        mBackgroundImage.contentMode = .scaleToFill
        
        //Updateing Headers
        updateHeader()
        
        mFetchProfileData()
        
        mView.layer.cornerRadius = 20
        mView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Updateing Headers
        updateHeader()
        
        
        let mParamService = ["query":"{generalsetup{productChoice isQuotation POS_partial_payment isPark servicelabers}}"]
        
        AF.request(mGrapQlUrl, method:.post,parameters: mParamService, encoding:JSONEncoding.default, headers: sGisHeaders ).responseJSON
        { response in
            
            UserDefaults.standard.set(false, forKey: "isMixMatch")
            UserDefaults.standard.set(false, forKey: "isServiceLabour")
            UserDefaults.standard.set(false, forKey: "isQuotation")
            UserDefaults.standard.set(false, forKey: "isPartial")
            UserDefaults.standard.set(false, forKey: "isPark")
            if(response.error != nil) {
                
                UserDefaults.standard.set(nil, forKey: "SERVICE_LABOUR")
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
                if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                    if let mGeneralSetup = mData.value(forKey: "generalsetup") as? NSDictionary {
                        
                        
                        if let mPartial = mGeneralSetup.value(forKey: "POS_partial_payment") as? String {
                            if mPartial == "1" {
                                UserDefaults.standard.set(true, forKey: "isPartial")
                            }else{
                                UserDefaults.standard.set(false, forKey: "isPartial")
                            }
                        }else{
                            UserDefaults.standard.set(false, forKey: "isPartial")
                        }
                        
                        if let mMixMatch = mGeneralSetup.value(forKey: "productChoice") as? String {
                            if mMixMatch == "1" {
                                UserDefaults.standard.set(true, forKey: "isMixMatch")
                            }else{
                                UserDefaults.standard.set(false, forKey: "isMixMatch")
                            }
                        }else{
                            UserDefaults.standard.set(false, forKey: "isMixMatch")
                        }
                        
                        if let mQuotation = mGeneralSetup.value(forKey: "isQuotation") as? String {
                            if mQuotation == "1" {
                                UserDefaults.standard.set(true, forKey: "isQuotation")
                            }else{
                                UserDefaults.standard.set(false, forKey: "isQuotation")
                            }
                        }else{
                            UserDefaults.standard.set(false, forKey: "isQuotation")
                        }
                        
                        
                        if let mPark = mGeneralSetup.value(forKey: "isPark") as? String {
                            if mPark == "1" {
                                UserDefaults.standard.set(true, forKey: "isPark")
                            }else{
                                UserDefaults.standard.set(false, forKey: "isPark")
                            }
                        }else{
                            UserDefaults.standard.set(false, forKey: "isPark")
                        }
                        
                        if let mServiceLabour = mGeneralSetup.value(forKey: "servicelabers") as? String {
                            if mServiceLabour == "1" {
                                UserDefaults.standard.set(true, forKey: "isServiceLabour")
                            }else{
                                UserDefaults.standard.set(false, forKey: "isServiceLabour")
                            }
                        }else{
                            UserDefaults.standard.set(false, forKey: "isServiceLabour")
                        }
                    }else{
                        
                    }
                    
                }
                
                
            }
        }
        
        
        self.view.backgroundColor = UIColor(named: "themeBackground")
        
        //swipe down language to close
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeDownGesture.direction = .down
        mLanguageView.addGestureRecognizer(swipeDownGesture)
    }
    
    @objc private func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        if !mLanguageView.isHidden {
            mLanguageView.slideTop()
            mLanguageView.isHidden = true
        }
    }
    
    func updateHeader(){
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        if let userToken = mUserLoginToken, let posToken = mUserLoginTokenPos {
            sGisHeaders["Authorization"] = userToken
            sGisHeaders["pos-authorization"] = posToken
            sGisHeaders2["Authorization"] = userToken
            sGisHeaders2["pos-authorization"] = posToken
        }
    }
    
    @IBAction func mMinimize(_ sender: Any) {
        mLanguageView.slideTop()
        mLanguageView.isHidden = true
        
    }
    @IBAction func mChooseLanguage(_ sender:  UIButton) {
        sender.showAnimation{}
        mLanguageView.isHidden = false
        mLanguageView.slideFromBottom()
        
    }
    
    
    @IBAction func mEnter(_ sender: UIButton) {
        sender.showAnimation{
            let storyBoard: UIStoryboard = UIStoryboard(name: "reserveBoard", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "HomePage1") as? HomePage {
                guard let fName = self.mFirstName, let lName = self.mLastName.text else {
                    return
                }
                UserDefaults.standard.set("\(fName) \(lName)", forKey: "userName")
                self.navigationController?.setViewControllers([home], animated:true)
                
            }
        }
    }
    
    
    
    
    func presentationController(forPresented presented: UIViewController , presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let style = DrawerPresentationController(presentedViewController: presented, presenting: presenting)
        style.bounce = true
        style.blurEffectStyle = .extraLight
        return style
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mLanguageData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell") as? LanguageCell{
            
            if let mData = mLocationData[indexPath.row] as? NSDictionary {
                cell.mFlag.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "flag") ?? "")")
                cell.mName.text = "\(mData.value(forKey: "name") ?? "")"
                cell.mName.layer.cornerRadius = 0
            }
            
            return cell
        }else { return UITableViewCell() }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mLanguageView.slideTop()
        mLanguageView.isHidden = true
        
        if let mData = mLocationData[indexPath.row] as? NSDictionary {
            
            let item = "\(mData.value(forKey: "name") ?? "")"
            if item.contains("English"){
                AppLanguage.shared.set(index: .english)
                mLanguage.text = "EN"
                
                setLang()
                
            }else if item.contains("Arabic"){
                AppLanguage.shared.set(index: .arabic)
                mLanguage.text = "AR"
                
                setLang()
            }else if item.contains("Thai"){
                AppLanguage.shared.set(index: .thai)
                mLanguage.text = "TH"
                
                setLang()
            }else if item.contains("Chinese"){
                setLang()
                AppLanguage.shared.set(index: .chinese)
                mLanguage.text = "CH"
                
                setLang()
            }else if item.contains("Japanese"){
                AppLanguage.shared.set(index: .japanese)
                mLanguage.text = "JA"
                
                setLang()
            }else if item.contains("Russian"){
                AppLanguage.shared.set(index: .russian)
                mLanguage.text = "RU"
                
                setLang()
            }
        }
    }
    
    func setLang(){
        
        mEnterBUTTON.setTitle("Enter".localizedString, for: .normal)
        mChooseLanLABEL.text = "Choose Language".localizedString
        mLanguageName.text = "Language".localizedString
        mHello.text = "Hello!".localizedString
        
    }
    
    func mFetchProfileData(){
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        let urlPath = mFetchProfileDetails
        
        if Reachability.isConnectedToNetwork() == true {
            
            AF.request(urlPath, method:.post, parameters:nil, headers: sGisHeaders2).responseJSON
            { response in
                
//                print("mFetchProfileData response = \(response)")
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
                    
                    if jsonResult.value(forKey: "code") as? Int == 200 {
                        
                        if let mData = jsonResult.value(forKey: "data") as? NSDictionary {
                            
                            self.mFirstName.text = "\(mData.value(forKey: "first_name") ?? "")" + " \(mData.value(forKey: "last_name") ?? "")"
                            self.mBackgroundImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "flash_image") ?? "")")
                            
                            let brandLogoURL = "\(mData.value(forKey: "brand_logo") ?? "")"
                            // Keep the active company's logo available to Home as well.
                            UserDefaults.standard.set(brandLogoURL, forKey: "brand_logo")
                            self.mBrandImage.downlaodImageFromUrl(urlString: brandLogoURL)
//                            self.mProfilePicture.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "myProfile") ?? "")")
                            let profileURL = "\(mData.value(forKey: "myProfile") ?? "")"

                            print("🔥 PROFILE URL =", profileURL)

                            self.mProfilePicture.alpha = 1.0

                            self.mProfilePicture.downlaodImageFromUrl(
                                urlString: profileURL
                            )

                            if profileURL.contains("1711620112703") {
                                self.mProfilePicture.alpha = 0.35
                            } else {
                                self.mProfilePicture.alpha = 1.0
                            }
//                            print("self.mProfilePicture.downlaodImageFromUrl = \(mData.value(forKey: "myProfile") ?? "")")
                            UserDefaults.standard.set("\(mData.value(forKey: "myProfile") ?? "")", forKey: "SALESPERSON_IMAGE")
                            
                            if let mLanguage = mData.value(forKey: "language") as? NSArray {
                                self.mLanguageData = mLanguage
                                self.mLocationData = mLanguage
                                self.mLanguageTable.delegate = self
                                self.mLanguageTable.dataSource = self
                                self.mLanguageTable.reloadData()
                            }
                            
                            UserDefaults.standard.setValue(self.mLocationData, forKey: "LANGUAGE")
                        } else {
                            CommonClass.showSnackBar(message: "Something went wrong!")
                        }
                    } else  if jsonResult.value(forKey: "code") as? Int == 400 {
                        
                        CommonClass.showSnackBar(message: "\(jsonResult.value(forKey: "error")!)")
                        
                    }else{
                        CommonClass.showSnackBar(message: "Something went wrong!")
                    }
                    
                }
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
    
    
}











