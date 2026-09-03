//
//  GlobalImageViewer.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 09/04/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire

class GlobalImageCell: UICollectionViewCell {
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mImage: UIImageView!
}

class GlobalImageViewer: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
    
    @IBOutlet weak var mZoomableImage: PanZoomImageView!
    @IBOutlet weak var mSKU: UILabel!
    @IBOutlet weak var mProductName: UILabel!
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mCollectionView: UICollectionView!
    var mProductId = ""
    var mSKUName = ""
    var mProductNameString = ""
    var mImageData = NSArray()
    var mAllImages = [String]()
    var isMixMatch = false
    var selectedImageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
        swipeGestureRecognizer.direction = .right
        
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(_:)))
        leftSwipeGestureRecognizer.direction = .left
        
        self.mZoomableImage.addGestureRecognizer(swipeGestureRecognizer)
        self.mZoomableImage.addGestureRecognizer(leftSwipeGestureRecognizer)
        
        mProductName.text = "--"
        mSKU.text = "--"
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        self.mCollectionView.delegate = self
        self.mCollectionView.dataSource = self
        configureCollectionViewLayout()
        
        print("mProductNameString = \(mProductNameString)")
        print("mSKUName = \(mSKUName)")
        mProductName.text = mProductNameString
        mSKU.text = mSKUName
        if isMixMatch {
            self.mZoomableImage.imageView.downlaodImageFromUrl(urlString: mAllImages[0])
            self.mCollectionView.reloadData()
        }else{
            getImageData(mProductId: mProductId)
        }
        
    }
    
    func configureCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        mCollectionView.collectionViewLayout = layout
    }
    
    private func getImageData(mProductId: String){
        let mParamRepair = ["query":"{ProductImages(product_id:\"\(mProductId)\") {image name}}"]
        
        print("getImageData mParamRepair = \(mParamRepair)")
        
        CommonClass.showFullLoader(view: self.view)
        AF.request(mGrapQlUrl, method:.post,parameters: mParamRepair, encoding:JSONEncoding.default, headers: sGisHeaders).responseJSON
        { [self] response in
            CommonClass.stopLoader()
            
            guard let jsonData = response.data else {
                CommonClass.showSnackBar(message: "Oops! Something went wrong.")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary,
                   let mResults = json.value(forKey: "data") as? NSDictionary,
                   let mProductData = mResults.value(forKey: "ProductImages") as? NSDictionary,
                   let mData = mProductData.value(forKey: "image") as? NSArray,
                   mData.count > 0 {
                    print("getImageData Data = \(mData)")
                    if let mImageItems = mData[0] as? NSDictionary {
                        self.mProductName.text = "\(mProductData.value(forKey: "name") ?? "")"
                        self.mZoomableImage.imageView.downlaodImageFromUrl(urlString: "\(mImageItems.value(forKey: "thumbnail") ?? "")")
                        self.mImageData = mData
                        self.mCollectionView.delegate = self
                        self.mCollectionView.dataSource = self
                        self.mCollectionView.reloadData()
                    }
                } else {
                    CommonClass.showSnackBar(message: "No Image Data Available")
                }
            } catch {
                CommonClass.showSnackBar(message: "Oops! Something went wrong.")
            }
        }
    }
    
    
    
    @objc private func handleSwipeLeft(_ sender: UISwipeGestureRecognizer) {
        
        if self.mZoomableImage.zoomScale == 1 {
            // Do something when the user swipes right
            let previousSelectedIndex = selectedImageIndex
            selectedImageIndex += 1
            if selectedImageIndex >= mImageData.count {
                selectedImageIndex = mImageData.count - 1
            }
            
            guard mImageData.count > 0 else {
                return
            }

            guard selectedImageIndex >= 0,
                  selectedImageIndex < mImageData.count else {
                return
            }
            
            if isMixMatch {
                if mAllImages[selectedImageIndex] != "" {
                    self.setImage(link: mAllImages[selectedImageIndex])
                }else{
                    self.mZoomableImage.isHidden = true
                }
            }else{
                if let mData = mImageData[selectedImageIndex] as? NSDictionary {
                    if "\(mData.value(forKey:"thumbnail") ?? "")" != "" {
                        self.setImage(link: "\(mData.value(forKey:"thumbnail") ?? "")")
                    }else{
                        self.mZoomableImage.isHidden = true
                    }
                }
            }

            var indexPathsToReload = [IndexPath(item: selectedImageIndex, section: 0)]
            if previousSelectedIndex != selectedImageIndex {
                let previousIndexPath = IndexPath(item: previousSelectedIndex, section: 0)
                indexPathsToReload.append(previousIndexPath)
            }
            self.mCollectionView.reloadItems(at: indexPathsToReload)
        }
    }
    
    @objc private func handleSwipeRight(_ sender: UISwipeGestureRecognizer) {
        
        
        if self.mZoomableImage.zoomScale == 1 {
            // Do something when the user swipes Left
            let previousSelectedIndex = selectedImageIndex
            selectedImageIndex -= 1
            if selectedImageIndex < 0 {
                selectedImageIndex = 0
            }
            
            guard mImageData.count > 0 else {
                return
            }

            guard selectedImageIndex >= 0,
                  selectedImageIndex < mImageData.count else {
                return
            }
            
            if isMixMatch {
                if mAllImages[selectedImageIndex] != "" {
                    self.setImage(link: mAllImages[selectedImageIndex])
                }else{
                    self.mZoomableImage.isHidden = true
                }
            }else{
                if let mData = mImageData[selectedImageIndex] as? NSDictionary {
                    
                    if "\(mData.value(forKey:"thumbnail") ?? "")" != "" {
                        self.setImage(link: "\(mData.value(forKey:"thumbnail") ?? "")")
                    }else{
                        self.mZoomableImage.isHidden = true
                    }
                }
            }
            var indexPathsToReload = [IndexPath(item: selectedImageIndex, section: 0)]
            if previousSelectedIndex != selectedImageIndex {
                let previousIndexPath = IndexPath(item: previousSelectedIndex, section: 0)
                indexPathsToReload.append(previousIndexPath)
            }
            self.mCollectionView.reloadItems(at: indexPathsToReload)
        }
    }
    
    @IBAction func mBack(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isMixMatch {
            return mAllImages.count
        }
        return mImageData.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = UICollectionViewCell()
        
        if let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "GlobalImageCell",for:indexPath) as? GlobalImageCell {
        
            cells.mView.borderWidth = (selectedImageIndex == indexPath.row) ? 2 : 0
            cells.mView.borderColor = (selectedImageIndex == indexPath.row) ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            
            if isMixMatch {
                cells.mImage.downlaodImageFromUrl(urlString: mAllImages[indexPath.row])
            }else{
                let mData = mImageData[indexPath.row] as? NSDictionary
                cells.mImage.downlaodImageFromUrl(urlString: "\(mData?.value(forKey:"thumbnail") ?? "")")
            }
            cells.mImage.contentMode = .scaleAspectFill
            return cells
        } else {
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previousSelectedIndex = selectedImageIndex
        self.selectedImageIndex = indexPath.row
        if isMixMatch {
            if mAllImages[indexPath.row] != "" {
                self.setImage(link: mAllImages[indexPath.row])
            }else{
                self.mZoomableImage.isHidden = true
            }
        }else{
            let mData = mImageData[indexPath.row] as? NSDictionary
            
            if let thumbnail = mData?.value(forKey:"thumbnail") as? String, !thumbnail.isEmpty {
                self.setImage(link: thumbnail)
            }else{
                self.mZoomableImage.isHidden = true
            }
        }
        var indexPathsToReload = [indexPath]
        if previousSelectedIndex != selectedImageIndex {
            let previousIndexPath = IndexPath(item: previousSelectedIndex, section: 0)
            indexPathsToReload.append(previousIndexPath)
        }
        self.mCollectionView.reloadItems(at: indexPathsToReload)
    }
    
    func setImage(link:String){
        if let url = URL(string: link)
        {
            let task = URLSession.shared.dataTask(with: url)
            { data, response, error in
                
                guard let data = data, error == nil else {
                    self.mZoomableImage.isHidden = true
                    return }
                
                DispatchQueue.main.sync()
                {
                    self.mZoomableImage.isHidden = false
                    self.mZoomableImage.imageView.image = UIImage(data: data)
                }
            }
            task.resume()
        }else{
            self.mZoomableImage.isHidden = true
            
        }
    }
    
}

