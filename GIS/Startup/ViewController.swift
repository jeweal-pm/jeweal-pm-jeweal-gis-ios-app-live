//
//  ViewController.swift
//  GIS
//
//  Created by Apple Hawkscode on 15/10/20.
//

import UIKit
import Alamofire

class Collect :UICollectionViewCell {
    
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var mName: UILabel!
    
    @IBOutlet weak var mStackView: UIStackView!
    @IBOutlet weak var mAddtoCart: UIButton!
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{

 
    @IBOutlet weak var mV: UIView!
    
    @IBOutlet weak var mCollectionView: UICollectionView!
    
    
  
    var mIndex = 0
    @IBOutlet weak var mS1: UISlider!
    @IBOutlet weak var mStack: UIStackView!
    var mPaymentData =  NSArray()
    
   
   

      override func viewDidLoad() {
          super.viewDidLoad()
        

         
         mCollectionView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        mFetchStore(key: "")
         
         
     }

      @objc
      func pay() {
          
      }
     
      
    
    @IBAction func mDelete(_ sender: Any) {


    }
    @IBAction func onSlideS1(_ sender: UISlider) {
        
        
        let round = Float(sender.value/0.10).rounded()
        let newVal = Float(round) * 0.10
        sender.setValue(newVal, animated: false)
        sender.addTarget(self, action: #selector(onSlide(slider: event:index:)), for: .valueChanged)


    }
    
    @objc func onSlide(slider: UISlider , event: UIEvent ,index: Int){
        
        if let touchEvent = event.allTouches?.first {
            
            switch touchEvent.phase {
                
            case .began: break
                
            case .moved: break
                
            case .ended:
                
                if(slider.value == 0.0){
                       
                               }
            if(slider.value == 0.25){
                 
                }
                if(slider.value == 0.5){
            
                               
            
            }
                
                if(slider.value == 0.75){
              
                                               
                               }
            if(slider.value == 1.0){
              
            }
                
            default:
                break
            }
        }
    }
  
    override func viewWillAppear(_ animated: Bool) {
    }
    
 
    @IBAction func mTestButton(_ sender: Any) {
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mPaymentData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        
         if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "Collect",for:indexPath) as? Collect,
            let mData = mPaymentData[indexPath.row] as? NSDictionary{
             cells.mImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "logo") ?? "")")
             cells.mName.text = mData.value(forKey: "name") as? String ?? ""
             if mIndex == indexPath.row {
                 cells.borderColor = .systemBlue
                 cells.borderWidth = 1
                 cells.layer.cornerRadius = 10
                 
             }else {
                 
                 cells.borderWidth = 0
                 cells.layer.cornerRadius = 10
             }
             
             return cells
         } else {return UICollectionViewCell()}
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "Collect",for:indexPath) as? Collect,
           let layout = collectionViewLayout as? UICollectionViewFlowLayout{
            let width = collectionView.frame.width / 2
            return CGSize(width: 120, height: 90)
        } else {return CGSize(width: 120, height: 90)}
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mIndex = indexPath.row
        
        self.mCollectionView.reloadData()
    }
    
    
    func mFetchStore(key: String){
        
        let mLocation = UserDefaults.standard.string(forKey: "location")
        
        let urlPath =  mFetchStoreData
        let params = ["login_token": mUserLoginToken ?? "", "location_id":mLocation ?? ""]
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
            { response in
                
                if(response.error != nil){
                    
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    
                }else{
                    if let jsonData = response.data {
                        
                        let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                        
                        if let jsonResult = json as? NSDictionary{
                            if jsonResult.value(forKey: "code") as? Int == 200 {
                                
                                if let mPaymentMethod = jsonResult.value(forKey: "Payment_method") as? NSDictionary,
                                   let mData = mPaymentMethod.value(forKey: "Credit Card") as? NSArray {
                                    if mData.count > 0 {
                                        self.mPaymentData = mData
                                        self.mCollectionView.delegate = self
                                        self.mCollectionView.dataSource = self
                                        self.mCollectionView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                    
                }
                
                
            }
        }else{
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }

}

