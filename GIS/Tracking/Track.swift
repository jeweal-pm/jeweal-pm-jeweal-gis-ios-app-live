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



class Track: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIGestureRecognizerDelegate {
    
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

    // MARK: - GIS Trace keyboard
    private weak var traceCardView: UIView?
    private var traceCenterYConstraint: NSLayoutConstraint?
    private let traceKeyboardLift: CGFloat = 45
    private var keyboardIsActuallyVisible = false

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

        configureTraceSearchInput()
        addDoneButtonOnKeyboard()
        configureTraceKeyboardHandling()
        configureTapOutsideToDismissKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }

        keyboardIsActuallyVisible = false
        restoreTracePosition(animated: false)
        view.endEditing(true)
    }
    
    private func configureTraceSearchInput() {
        mSearchField.keyboardType = .numberPad
        mSearchField.autocorrectionType = .no
        mSearchField.spellCheckingType = .no
        mSearchField.textContentType = .none
    }

    private func configureTraceKeyboardHandling() {
        // Find the white Trace card from the real search field hierarchy.
        // Storyboard:
        // UITextField -> UIStackView -> search row UIView -> vertical UIStackView -> Trace card UIView
        var current: UIView? = mSearchField
        for _ in 0..<4 {
            current = current?.superview
        }
        traceCardView = current

        resolveTraceCenterConstraintIfNeeded()

        // IMPORTANT:
        // Do not use keyboardWillShow / keyboardWillHide here.
        // On the first opening iOS may temporarily transition the keyboard,
        // which caused the card to move up and immediately reset.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(traceKeyboardDidShow(_:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(traceKeyboardDidHide(_:)),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }

    private func resolveTraceCenterConstraintIfNeeded() {
        guard traceCenterYConstraint == nil,
              let card = traceCardView else { return }

        // The storyboard centers the Trace card (mD9-S3-vHC) to the controller root view.
        traceCenterYConstraint = view.constraints.first(where: { constraint in
            guard constraint.firstAttribute == .centerY,
                  constraint.secondAttribute == .centerY else {
                return false
            }

            let first = constraint.firstItem as? UIView
            let second = constraint.secondItem as? UIView

            return (first === card && second === view) ||
                   (first === view && second === card)
        })

        print("⌨️ GIS Trace centerY constraint found =", traceCenterYConstraint != nil)
    }

    @objc private func traceKeyboardDidShow(_ notification: Notification) {
        keyboardIsActuallyVisible = true
        resolveTraceCenterConstraintIfNeeded()

        // Run on the next main-loop turn so the very first keyboard layout has
        // completely finished before changing our own Auto Layout constraint.
        DispatchQueue.main.async { [weak self] in
            self?.applyTraceKeyboardLift()
        }

        // First keyboard creation can perform one extra layout pass.
        // Re-assert the SAME absolute constraint once after that pass.
        // This does not add another 45pt; it simply keeps the final value at 45pt.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            guard let self = self, self.keyboardIsActuallyVisible else { return }
            self.applyTraceKeyboardLift()
        }
    }

    private func applyTraceKeyboardLift() {
        guard keyboardIsActuallyVisible,
              let constraint = traceCenterYConstraint else { return }

        let firstIsCard = (constraint.firstItem as? UIView) === traceCardView

        // Always use an absolute value. Never accumulate movement.
        constraint.constant = firstIsCard ? -traceKeyboardLift : traceKeyboardLift

        UIView.animate(
            withDuration: 0.18,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
            animations: { [weak self] in
                self?.view.layoutIfNeeded()
            },
            completion: nil
        )
    }

    @objc private func traceKeyboardDidHide(_ notification: Notification) {
        keyboardIsActuallyVisible = false
        restoreTracePosition(animated: true)
    }

    private func restoreTracePosition(animated: Bool) {
        guard let constraint = traceCenterYConstraint else { return }

        constraint.constant = 0

        let changes: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        }

        if animated {
            UIView.animate(
                withDuration: 0.18,
                delay: 0,
                options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
                animations: changes,
                completion: nil
            )
        } else {
            changes()
        }
    }

    private func configureTapOutsideToDismissKeyboard() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(traceDismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    @objc private func traceDismissKeyboard() {
        view.endEditing(true)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Tapping the text field itself should not immediately dismiss its keyboard.
        var touched: UIView? = touch.view

        while let current = touched {
            if current === mSearchField {
                return false
            }
            touched = current.superview
        }

        return true
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
    

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
