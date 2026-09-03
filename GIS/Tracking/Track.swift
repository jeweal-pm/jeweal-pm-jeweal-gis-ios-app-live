//
//  Track.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 18/06/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//


import UIKit
import Alamofire
import AVFoundation



class Track: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    let shape = CAShapeLayer()
    let layer = CAGradientLayer()
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet weak var mScannerCamView: UIView!
    @IBOutlet weak var mScannerView: UIView!

    @IBOutlet weak var mScanNowBUTTON: UIButton!
    @IBOutlet weak var mHeadingLABEL: UILabel!
    @IBOutlet weak var mSubHeadingLABEL: UILabel!
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mSearchField: UITextField!
    @IBOutlet weak var mScannerImage: UIImageView!

    @IBOutlet weak var mQRLABEL: UILabel!
    
    @IBOutlet weak var mOrLABEL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mHeadingLABEL.text = "Track Stocks here".localizedString
        mQRLABEL.text = "Please Scan QR Code or Barcode to track details".localizedString
        mOrLABEL.text = "Or".localizedString
        mSubHeadingLABEL.text = "Please enter your Stock Id to track details".localizedString
        mScanNowBUTTON.setTitle("SCAN NOW".localizedString, for: .normal)
  if let gif = try? UIImage(gifName: "scanner.gif") {
    mScannerImage.setGifImage(gif)
} else {
    print("⚠️ ไม่พบไฟล์ scanner.gif")
}

        //mScannerImage.image = UIImage.gif(asset: "scanner")
        addDoneButtonOnKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        mSearchField.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        goToTrackStocks()
    }

    
    @IBAction func mHideScanner(_ sender: Any) {
        mScannerView.isHidden = true

        shape.removeFromSuperlayer()
        self.mScannerCamView.layer.sublayers?.remove(at: 0)
        layer.sublayers?.remove(at: 1)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
        captureSession = nil
    
    }
    
    @IBAction func mGo(_ sender: Any) {
        goToTrackStocks()
    }
    
    private func goToTrackStocks(){
        if let searchKey = mSearchField.text {
            
            self.view.endEditing(true)
            let storyBoard: UIStoryboard = UIStoryboard(name: "tr", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "TrackStocks") as? TrackStocks {
                home.mStockKey = searchKey
                self.navigationController?.pushViewController(home, animated:false)
                mSearchField.text = ""
            }
        } else {
            CommonClass.showSnackBar(message: "Please Fill Stock Id!")
        }
    }
    
    @IBAction func mScanNow(_ sender: Any) {
        mStartQRcode()
    }
    override func viewWillAppear(_ animated: Bool) {
        mSearchField.placeholder = "Search".localizedString
        mHeadingLABEL.text = "Trace with Authenticity".localizedString
        mSubHeadingLABEL.text = "Please enter stock Id to track".localizedString
  
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

 
    @IBAction func mBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)

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
            
            metadataOutput.metadataObjectTypes = [.code128,.code39,.qr,.ean8, .ean13, .pdf417]
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
        
        var _: SystemSoundID = 1000
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
            let storyBoard: UIStoryboard = UIStoryboard(name: "tr", bundle: nil)
            if let home = storyBoard.instantiateViewController(withIdentifier: "TrackStocks") as? TrackStocks {
                home.mStockKey = code
                self.navigationController?.pushViewController(home, animated:false)
                
                captureSession = nil
                self.mScannerView.isHidden = true
            }
        } else {
            CommonClass.showSnackBar(message: "Please scan valid QR/Bar code")
        }
        
        if captureSession != nil {
            captureSession.stopRunning()
        }
        
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}
