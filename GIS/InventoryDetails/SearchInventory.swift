//
//  SearchInventory.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 27/06/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation


class SearchInventory: UIViewController, UITableViewDelegate , UITableViewDataSource, AVCaptureMetadataOutputObjectsDelegate {

    let shape = CAShapeLayer()
    let layer = CAGradientLayer()
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet weak var mScannerCamView: UIView!
    @IBOutlet weak var mScannerImage: UIImageView!
    @IBOutlet weak var mScannerView: UIView!


    @IBOutlet weak var mScanNowButton: UIButton!
    var mCartData = NSMutableArray()
    var mCustomerId = ""
    @IBOutlet weak var mProductSearch: UITextField!
    var mSearchData = NSMutableArray()
    @IBOutlet weak var mCustomSearchTable: UITableView!

    @IBOutlet weak var mHeader: UILabel!
    var mType = ""
    var mFrom = ""
    var mKey = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        if let gif = try? UIImage(gifName: "scanner.gif") {
    mScannerImage.setGifImage(gif)
} else {
    print("⚠️ ไม่พบไฟล์ scanner.gif")
}


        //mScannerImage.image = UIImage.gif(asset: "scanner")
        
        mHeader.text = mType.localizedString
        // Do any additional setup after loading the view.
    }
           
    override func viewDidAppear(_ animated: Bool) {

        mProductSearch.placeholder = "Search".localizedString
                   
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
            
        if mFrom != "" {
            mKey = "1"
            mStartQRcode()
        }else{
            mKey = ""
        }
    }
    
    
    
    @IBAction func mBack(_ sender: Any) {
        mFrom = ""
        mKey = ""
        
        self.navigationController?.popViewController(animated:true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mSearchData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        var cell = UITableViewCell()
        
        guard let cells = tableView.dequeueReusableCell(withIdentifier: "CustomSearchCell") as? CustomSearchCell else {
            return cell
        }
        cell = cells
        
        if let mData = mSearchData[indexPath.row] as? NSDictionary {
            
            if let name = mData.value(forKey: "name") as? String {
                cells.mProductName.text = name
            }
            
            if self.mType == "Inventory" {
                if let SKU = mData.value(forKey: "SKU") as? String {
                    cells.mStockName.text = SKU
                }
                if let stockId = mData.value(forKey: "stock_id") as? String,
                   let locationName = mData.value(forKey: "location_name") as? String,
                   let poQty = mData.value(forKey: "po_QTY") as? String {
                    
                    cells.mLocationQty.text = "\(stockId) \(locationName) \(poQty)"
                }
            }
            
            cells.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let mData = mSearchData[indexPath.row] as? NSDictionary {
            let storyBoard: UIStoryboard = UIStoryboard(name: "invdata", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "InventoryDetails") as? InventoryDetails {
                home.mData = mData
                self.mFrom = ""
                self.mKey = ""
                self.navigationController?.pushViewController(home, animated:true)
            }
        }
    }
    
    @IBAction func mSearchNow(_ sender: Any) {
        let value  = mProductSearch.text?.count
        if value != 0 {

            self.mSearchProductByKeys(value: mProductSearch.text ?? "")
        }else {
            
            if mProductSearch.text  == "" {
                
            }
            self.view.endEditing(true)
            
        }
    }
    
    func mSearchProductByKeys(value: String){
        
        let mLocation = UserDefaults.standard.string(forKey: "location") ?? ""
        
        var urlPath = ""
        var params = [String:Any]()
        
        if mType == "Inventory" {
            
            urlPath =  mInventorySearch
            params = ["location_id": mLocation, "stockId": value] as [String : Any]
            
        } else if mType == "Quick View"{
            urlPath =  mQuickViewSearch
            params = ["search": value, "posLocation_id":mLocation]
            
        }else{
            urlPath =  mSearchProductByKey
            params = ["key": value, "posLocation_id":mLocation]
            
        }
        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, parameters:params, headers: sGisHeaders2).responseJSON
            { response in
                
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
                    self.mSearchData = NSMutableArray()
                    if let mData = jsonResult.value(forKey: "data") as? NSArray {
                        
                        if mData.count > 0 {
                            
                            if self.mType == "Inventory" {
                                
                                
                                if mData.count == 1 {
                                    
                                    if self.mKey != "" {
                                        if let data = mData[0] as? NSDictionary {
                                            let storyBoard: UIStoryboard = UIStoryboard(name: "invdata", bundle: nil)
                                            if let home = storyBoard.instantiateViewController(withIdentifier: "InventoryDetails") as? InventoryDetails {
                                                home.mData = data
                                                self.navigationController?.pushViewController(home, animated:true)
                                            }
                                        }
                                    }else{
                                        
                                        self.mSearchData = NSMutableArray()
                                        
                                        for data in mData {
                                            if let mDatas = data as? NSDictionary {
                                                self.mSearchData.add(mDatas)
                                            }
                                        }
                                        
                                        self.mCustomSearchTable.delegate = self
                                        self.mCustomSearchTable.dataSource = self
                                        self.mCustomSearchTable.reloadData()
                                        
                                    }
                                    
                                }else{
                                    self.mFrom = ""
                                    self.mKey = ""
                                    self.mSearchData = NSMutableArray()
                                    
                                    for data in mData {
                                        if let mDatas = data as? NSDictionary {
                                            self.mSearchData.add(mDatas)
                                        }
                                    }
                                    
                                    self.mCustomSearchTable.delegate = self
                                    self.mCustomSearchTable.dataSource = self
                                    self.mCustomSearchTable.reloadData()
                                }
                                
                            }
                            
                        }else{
                            self.mSearchData = NSMutableArray()
                            self.mCustomSearchTable.reloadData()
                        }
                        
                        
                    }else{
                        self.mSearchData = NSMutableArray()
                        self.mCustomSearchTable.reloadData()
                    }
                    
                }else{
                    if let error = jsonResult.value(forKey: "error") as? String {
                        if error == "Authorization has been expired" {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                        }
                    }
                }
                
            }
        }else{
        }
        
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    @IBAction func mShowScanner(_ sender: Any) {
        self.mKey = "1"
        mStartQRcode()
    }
    
    @IBAction func mHideScanner(_ sender: Any) {
        
        mFrom = ""
        mKey = ""
        
        mScannerView.isHidden = true
        
        shape.removeFromSuperlayer()
        self.mScannerCamView.layer.sublayers?.remove(at: 0)
        layer.sublayers?.remove(at: 1)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
        captureSession = nil
        
    }
    
    
    
    func mStartQRcode(){
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            metadataOutput.metadataObjectTypes = [.code128,.code39,
                                                  .qr,.ean8, .ean13, .pdf417]
        } else {
            failed()
            return
        }
        
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = mScannerCamView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        mScannerCamView.layer.addSublayer(previewLayer)
        
        mScannerView.isHidden = false
        
        captureSession.startRunning()
        
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            found(code: stringValue)
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        
        if code != "" {
            
            self.mSearchProductByKeys(value: code)
            
            captureSession = nil
            self.mScannerView.isHidden = true
        }else{
            
            
            CommonClass.showSnackBar(message: "Please scan valid QR/Bar code")
        }
        
        
        
        if captureSession != nil {
            captureSession.stopRunning()
        }
        
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    
    func createScanningIndicator() {
        
        let height: CGFloat = 15
        let opacity: Float = 0.4
        let topColor = UIColor.green.withAlphaComponent(0)
        let bottomColor = UIColor.green
        
        let layer = CAGradientLayer()
        layer.colors = [topColor.cgColor, bottomColor.cgColor]
        layer.opacity = opacity
        
        let squareWidth = mScannerCamView.frame.width * 0.6
        let xOffset = mScannerCamView.frame.width * 0.2
        let yOffset = mScannerCamView.frame.midY - (squareWidth / 2)
        layer.frame = CGRect(x: xOffset, y: yOffset, width: squareWidth, height: height)
        
        self.mScannerCamView.layer.insertSublayer(layer, at: 1)
        
        let initialYPosition = layer.position.y
        let finalYPosition = initialYPosition + squareWidth - height
        let duration: CFTimeInterval = 2
        
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue = initialYPosition as NSNumber
        animation.toValue = finalYPosition as NSNumber
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        
        layer.add(animation, forKey: nil)
    }
    
    func createScanningFrame() {
        
        let lineLength: CGFloat = 15
        let squareWidth = mScannerCamView.frame.width * 0.6
        let topLeftPosX = mScannerCamView.frame.width * 0.2
        let topLeftPosY = mScannerCamView.frame.midY - (squareWidth / 2)
        let btmLeftPosY = mScannerCamView.frame.midY + (squareWidth / 2)
        let btmRightPosX = mScannerCamView.frame.midX + (squareWidth / 2)
        let topRightPosX = mScannerCamView.frame.width * 0.8
        
        let path = UIBezierPath()
        
        //top left
        path.move(to: CGPoint(x: topLeftPosX, y: topLeftPosY + lineLength))
        path.addLine(to: CGPoint(x: topLeftPosX, y: topLeftPosY))
        path.addLine(to: CGPoint(x: topLeftPosX + lineLength, y: topLeftPosY))
        
        //bottom left
        path.move(to: CGPoint(x: topLeftPosX, y: btmLeftPosY - lineLength))
        path.addLine(to: CGPoint(x: topLeftPosX, y: btmLeftPosY))
        path.addLine(to: CGPoint(x: topLeftPosX + lineLength, y: btmLeftPosY))
        
        //bottom right
        path.move(to: CGPoint(x: btmRightPosX - lineLength, y: btmLeftPosY))
        path.addLine(to: CGPoint(x: btmRightPosX, y: btmLeftPosY))
        path.addLine(to: CGPoint(x: btmRightPosX, y: btmLeftPosY - lineLength))
        
        //top right
        path.move(to: CGPoint(x: topRightPosX, y: topLeftPosY + lineLength))
        path.addLine(to: CGPoint(x: topRightPosX, y: topLeftPosY))
        path.addLine(to: CGPoint(x: topRightPosX - lineLength, y: topLeftPosY))
        
        
        shape.path = path.cgPath
        shape.strokeColor = UIColor.white.cgColor
        shape.lineWidth = 3
        shape.fillColor = UIColor.clear.cgColor
        
        self.mScannerCamView.layer.insertSublayer(shape, at: 1)
    }
    
}

