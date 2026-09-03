//
//  CommonScanner.swift
//  GIS
//
//  Created by Macbook Pro on 14/08/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import AudioToolbox

enum CommonScannerScanResult {
    case correct(sku: String, stockID: String, imageURL: String?)
    case conflict(code: String)
    // Camera Stock Take conflict: keep SKU and Stock ID separately
    // so the popup can display the same format as the successful result.
    case conflictWithStockID(sku: String, stockID: String)
    case noData(code: String)
}

protocol ScannerDelegate {
    func mGetScannedData(value: String, type: String)
}

class CommonScanner: UIViewController,
                     AVCaptureMetadataOutputObjectsDelegate,
                     UIImagePickerControllerDelegate,
                     UINavigationControllerDelegate {

    // MARK: - IBOutlet

    @IBOutlet weak var mScannerCamView: UIView!
    @IBOutlet weak var mScannerGif: UIImageView!

    // MARK: - Camera

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    // MARK: - Existing Properties

    var mType = ""
    var delegate: ScannerDelegate? = nil

    // ONLY Stock Take sets this to true. Every other screen keeps the original one-shot scanner.
    var isStockTakeContinuous = false

    let shape = CAShapeLayer()
    let layer = CAGradientLayer()

    // MARK: - Scanner UI

    private let scanFrameView = UIView()
    private let scanDescriptionLabel = UILabel()

    private let closeButton = UIButton(type: .custom)
    private let galleryButton = UIButton(type: .custom)
    
    // Design flashlight button (bottom-center)
    private let flashButton = UIButton(type: .custom)
    private var isFlashOn = false

    private var didFindCode = false

    // Stock Take can keep this scanner open and continuously validate scans.
    // Other CommonScanner callers keep the original one-shot behaviour.
    var scanResultHandler: ((String) -> CommonScannerScanResult)?

    private let scanCountLabel = UILabel()
    private var scanCount = 0
    private var resultPopupView: UIView?
    private var resultPopupToken = UUID()

    // Corner layers
    private let topLeftCornerLayer = CAShapeLayer()
    private let topRightCornerLayer = CAShapeLayer()
    private let bottomLeftCornerLayer = CAShapeLayer()
    private let bottomRightCornerLayer = CAShapeLayer()

    // Semi-transparent black mask with a transparent scanner-frame cutout.
    // This is intentionally only used by CommonScanner's camera UI.
    private let cameraDimLayer = CAShapeLayer()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // -------------------------------------------------
        // Full screen scanner
        // -------------------------------------------------

        navigationItem.hidesBackButton = true

        navigationController?.setNavigationBarHidden(
            true,
            animated: false
        )

        navigationController?.navigationBar.isHidden = true

        edgesForExtendedLayout = [
            .top,
            .bottom
        ]

        extendedLayoutIncludesOpaqueBars = true

        view.backgroundColor = .black

        // -------------------------------------------------
        // UI
        // -------------------------------------------------

        setupScannerUI()
        setupCloseButton()
        setupGalleryButton()
        setupFlashButton()
        // -------------------------------------------------
        // Start scanner
        // -------------------------------------------------

        mStartQRcode()
    }


    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(
            true,
            animated: false
        )

        navigationController?.navigationBar.isHidden = true

        navigationItem.hidesBackButton = true

        didFindCode = false
        scanCount = 0
        scanCountLabel.text = "Scanned : 0"

        if captureSession != nil &&
            captureSession.isRunning == false {

            DispatchQueue.global(
                qos: .userInitiated
            ).async { [weak self] in

                self?.captureSession?.startRunning()
            }
        }
    }


    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        stopCamera()

        turnOffFlash()

           if captureSession?.isRunning == true {
               DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                   self?.captureSession?.stopRunning()
               }
           }

        // Restore navigation bar
        navigationController?.setNavigationBarHidden(
            false,
            animated: false
        )

        navigationController?.navigationBar.isHidden = false
    }


    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        updateScannerUIFrames()

        // Camera view fills the entire screen
        mScannerCamView.frame = view.bounds

        if let previewLayer = previewLayer {

            previewLayer.frame = mScannerCamView.bounds
        }
    }


    // MARK: - Status Bar

    override var prefersStatusBarHidden: Bool {

        return false
    }


    override var preferredStatusBarStyle: UIStatusBarStyle {

        return .lightContent
    }


    override var supportedInterfaceOrientations:
        UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        }
        return .portrait
    }


    // MARK: - Scanner UI

    private func setupScannerUI() {

        view.backgroundColor = .black

        // -------------------------------------------------
        // Camera
        // -------------------------------------------------

        mScannerCamView.backgroundColor = .black
        mScannerCamView.clipsToBounds = true

        mScannerCamView.translatesAutoresizingMaskIntoConstraints = true
        mScannerCamView.frame = view.bounds

        // Old GIF is not used in new design
        mScannerGif.isHidden = true

        // -------------------------------------------------
        // Scanner frame
        // -------------------------------------------------

        scanFrameView.backgroundColor = .clear
        scanFrameView.isUserInteractionEnabled = false

        view.addSubview(scanFrameView)

        // -------------------------------------------------
        // Camera dim mask
        // -------------------------------------------------
        // The entire camera is dimmed except for the scanner frame.
        // The transparent hole is updated together with scanFrameView.
        cameraDimLayer.fillColor = UIColor.black.withAlphaComponent(0.55).cgColor
        cameraDimLayer.fillRule = .evenOdd
        cameraDimLayer.contentsScale = UIScreen.main.scale
        view.layer.addSublayer(cameraDimLayer)

        // -------------------------------------------------
        // Description
        // -------------------------------------------------

        scanDescriptionLabel.text =
            "You can scan QR codes or Barcodes"

        scanDescriptionLabel.textColor = .white

        scanDescriptionLabel.font =
            UIFont.systemFont(
                ofSize: 14,
                weight: .regular
            )

        scanDescriptionLabel.textAlignment = .center

        scanDescriptionLabel.numberOfLines = 2

        scanDescriptionLabel.lineBreakMode =
            .byWordWrapping

        scanDescriptionLabel.adjustsFontSizeToFitWidth = true

        scanDescriptionLabel.minimumScaleFactor = 0.85

        scanDescriptionLabel.backgroundColor = .clear

        view.addSubview(scanDescriptionLabel)

        setupScanCountLabel()

        updateScannerUIFrames()
    }


    private func setupScanCountLabel() {
        scanCountLabel.text = "Scanned : 0"
        scanCountLabel.textColor = .white
        scanCountLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        scanCountLabel.textAlignment = .right
        scanCountLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanCountLabel)

        NSLayoutConstraint.activate([
            scanCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            scanCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            scanCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 110),
            scanCountLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    // MARK: - UI Frames

    private func updateScannerUIFrames() {
        let bounds = view.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        let safeTop = view.safeAreaInsets.top
        let safeBottom = view.safeAreaInsets.bottom
        let isPad = UIDevice.current.userInterfaceIdiom == .pad

        // iPad: keep the frame compact and move it lower for better balance.
        let horizontalMargin: CGFloat = isPad ? 50 : 42
        let maxFrameWidth = bounds.width - (horizontalMargin * 2)
        let frameSide = min(maxFrameWidth, isPad ? 440 : 340)
        let frameX = (bounds.width - frameSide) / 2

        // Keep the scan frame exactly centered on the screen in the Y axis.
        // Do not offset it by safe-area/top padding.
        let frameY = (bounds.height - frameSide) / 2

        scanFrameView.frame = CGRect(
            x: frameX,
            y: frameY,
            width: frameSide,
            height: frameSide
        )

        drawScannerCorners(frameSize: scanFrameView.bounds.size)
        updateCameraDimMask()

        // Flashlight is always horizontally centered.
        let flashSize: CGFloat = isPad ? 72 : 84
        let flashCenterY = bounds.height - (isPad ? 190 : 185)
        flashButton.frame = CGRect(
            x: (bounds.width - flashSize) / 2,
            y: flashCenterY - (flashSize / 2),
            width: flashSize,
            height: flashSize
        )

        // Center the helper text on the screen instead of anchoring it to the
        // gallery button. This is especially important on iPad.
        let descriptionWidth = min(bounds.width - 80, isPad ? 520 : 320)
        scanDescriptionLabel.frame = CGRect(
            x: (bounds.width - descriptionWidth) / 2,
            y: flashButton.frame.maxY + (isPad ? 24 : 18),
            width: descriptionWidth,
            height: 44
        )
        scanDescriptionLabel.textAlignment = .center
    }

    // MARK: - Camera Dim Mask

    private func updateCameraDimMask() {
        let bounds = view.bounds
        guard bounds.width > 0, bounds.height > 0 else {
            return
        }

        // Outer path = whole camera screen.
        // Inner path = scanner frame and is removed via even-odd fill.
        let path = UIBezierPath(rect: bounds)
        let holePath = UIBezierPath(rect: scanFrameView.frame)
        path.append(holePath)

        cameraDimLayer.frame = bounds
        cameraDimLayer.path = path.cgPath
    }


    // MARK: - Draw Scanner Corners

    private func drawScannerCorners(
        frameSize: CGSize
    ) {

        // Reference:
        // thinner line
        // shorter corner
        let cornerLength: CGFloat = 60
        let lineWidth: CGFloat = 5

        let layers = [
            topLeftCornerLayer,
            topRightCornerLayer,
            bottomLeftCornerLayer,
            bottomRightCornerLayer
        ]

        for cornerLayer in layers {

            cornerLayer.removeFromSuperlayer()

            cornerLayer.strokeColor =
                UIColor.white.cgColor

            cornerLayer.fillColor =
                UIColor.clear.cgColor

            cornerLayer.lineWidth =
                lineWidth

            cornerLayer.lineCap =
                .round

            cornerLayer.lineJoin =
                .round

            cornerLayer.contentsScale =
                UIScreen.main.scale

            scanFrameView.layer.addSublayer(
                cornerLayer
            )
        }


        // =================================================
        // TOP LEFT
        // =================================================

        let topLeft = UIBezierPath()

        topLeft.move(
            to: CGPoint(
                x: 0,
                y: cornerLength
            )
        )

        topLeft.addLine(
            to: CGPoint(
                x: 0,
                y: 0
            )
        )

        topLeft.addLine(
            to: CGPoint(
                x: cornerLength,
                y: 0
            )
        )

        topLeftCornerLayer.path =
            topLeft.cgPath


        // =================================================
        // TOP RIGHT
        // =================================================

        let topRight = UIBezierPath()

        topRight.move(
            to: CGPoint(
                x: frameSize.width - cornerLength,
                y: 0
            )
        )

        topRight.addLine(
            to: CGPoint(
                x: frameSize.width,
                y: 0
            )
        )

        topRight.addLine(
            to: CGPoint(
                x: frameSize.width,
                y: cornerLength
            )
        )

        topRightCornerLayer.path =
            topRight.cgPath


        // =================================================
        // BOTTOM LEFT
        // =================================================

        let bottomLeft = UIBezierPath()

        bottomLeft.move(
            to: CGPoint(
                x: 0,
                y: frameSize.height - cornerLength
            )
        )

        bottomLeft.addLine(
            to: CGPoint(
                x: 0,
                y: frameSize.height
            )
        )

        bottomLeft.addLine(
            to: CGPoint(
                x: cornerLength,
                y: frameSize.height
            )
        )

        bottomLeftCornerLayer.path =
            bottomLeft.cgPath


        // =================================================
        // BOTTOM RIGHT
        // =================================================

        let bottomRight = UIBezierPath()

        bottomRight.move(
            to: CGPoint(
                x: frameSize.width - cornerLength,
                y: frameSize.height
            )
        )

        bottomRight.addLine(
            to: CGPoint(
                x: frameSize.width,
                y: frameSize.height
            )
        )

        bottomRight.addLine(
            to: CGPoint(
                x: frameSize.width,
                y: frameSize.height - cornerLength
            )
        )

        bottomRightCornerLayer.path =
            bottomRight.cgPath
    }


    // MARK: - Close Button

    private func setupCloseButton() {

        closeButton.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)

        // Smaller than previous 60
        closeButton.layer.cornerRadius = 25

        closeButton.clipsToBounds = true

        let image = UIImage(
            systemName: "xmark",
            withConfiguration:
                UIImage.SymbolConfiguration(
                    pointSize: 20,
                    weight: .regular
                )
        )

        closeButton.setImage(
            image,
            for: .normal
        )

        closeButton.tintColor = .white

        closeButton.accessibilityLabel =
            "Close scanner"

        closeButton.addTarget(
            self,
            action: #selector(closeScanner),
            for: .touchUpInside
        )

        view.addSubview(closeButton)

        closeButton.translatesAutoresizingMaskIntoConstraints =
            false

        NSLayoutConstraint.activate([

            closeButton.widthAnchor.constraint(
                equalToConstant: 50
            ),

            closeButton.heightAnchor.constraint(
                equalToConstant: 50
            ),

            closeButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 30
            ),

            closeButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 18
            )
        ])
    }


    @objc private func closeScanner() {

        stopCamera()

        dismiss(
            animated: true
        )
    }


    // MARK: - Gallery Button

    private func setupGalleryButton() {

        // Stock Take must scan from the live camera only.
        // Do not expose photo-library selection in this mode.
        if isStockTakeContinuous {
            galleryButton.isHidden = true
            galleryButton.isUserInteractionEnabled = false
            return
        }

        galleryButton.backgroundColor =
            UIColor.white.withAlphaComponent(0.94)

        // Smaller button
        galleryButton.layer.cornerRadius = 10

        galleryButton.clipsToBounds = true

        let image = UIImage(
            systemName: "photo.on.rectangle",
            withConfiguration:
                UIImage.SymbolConfiguration(
                    pointSize: 23,
                    weight: .medium
                )
        )

        galleryButton.setImage(
            image,
            for: .normal
        )

        galleryButton.tintColor = .black

        galleryButton.imageView?.contentMode =
            .scaleAspectFit

        galleryButton.accessibilityLabel =
            "Choose photo"

        galleryButton.addTarget(
            self,
            action: #selector(openPhotoLibrary),
            for: .touchUpInside
        )

        view.addSubview(
            galleryButton
        )
    }

    // MARK: - Flashlight Button

    private func setupFlashButton() {
        guard let image = UIImage(named: "flash_ic") else {
            print("❌ Cannot find asset: flash_ic")
            return
        }

        flashButton.setImage(image, for: .normal)
        flashButton.imageView?.contentMode = .scaleAspectFit
        flashButton.accessibilityLabel = "Flashlight"

        flashButton.addTarget(
            self,
            action: #selector(toggleFlash),
            for: .touchUpInside
        )

        view.addSubview(flashButton)
    }

    @objc private func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else {
            return
        }

        do {
            try device.lockForConfiguration()

            if isFlashOn {
                device.torchMode = .off
                isFlashOn = false
            } else {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
                isFlashOn = true
            }

            device.unlockForConfiguration()

        } catch {
            print("❌ Flashlight error: \(error)")
        }
    }
    
    private func turnOffFlash() {
        guard isFlashOn,
              let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else {
            return
        }

        do {
            try device.lockForConfiguration()
            device.torchMode = .off
            device.unlockForConfiguration()
            isFlashOn = false
        } catch {
            print("❌ Cannot turn off flashlight: \(error)")
        }
    }
    
    // MARK: - Back

    @IBAction func mBack(_ sender: Any) {

        closeScanner()
    }


    // MARK: - Start QR / Barcode Scanner

    func mStartQRcode() {

        // Prevent duplicate session
        if captureSession != nil {
            return
        }

        let session =
            AVCaptureSession()

        captureSession = session

        guard let videoCaptureDevice =
                AVCaptureDevice.default(
                    for: .video
                ) else {

            failed()

            return
        }

        let videoInput:
            AVCaptureDeviceInput

        do {

            videoInput =
                try AVCaptureDeviceInput(
                    device: videoCaptureDevice
                )

        } catch {

            failed()

            return
        }


        // =================================================
        // INPUT
        // =================================================

        if session.canAddInput(
            videoInput
        ) {

            session.addInput(
                videoInput
            )

        } else {

            failed()

            return
        }


        // =================================================
        // OUTPUT
        // =================================================

        let metadataOutput =
            AVCaptureMetadataOutput()

        if session.canAddOutput(
            metadataOutput
        ) {

            session.addOutput(
                metadataOutput
            )

            metadataOutput.setMetadataObjectsDelegate(
                self,
                queue: DispatchQueue.main
            )

            metadataOutput.metadataObjectTypes = [

                .code128,
                .code39,
                .code93,
                .qr,
                .ean8,
                .ean13,
                .pdf417,
                .aztec,
                .dataMatrix,
                .upce,
                .itf14
            ]

        } else {

            failed()

            return
        }


        // =================================================
        // PREVIEW
        // =================================================

        let newPreviewLayer =
            AVCaptureVideoPreviewLayer(
                session: session
            )

        newPreviewLayer.videoGravity =
            .resizeAspectFill

        previewLayer =
            newPreviewLayer

        mScannerCamView.layer.insertSublayer(
            newPreviewLayer,
            at: 0
        )


        // =================================================
        // START
        // =================================================

        DispatchQueue.global(
            qos: .userInitiated
        ).async {

            session.startRunning()
        }
    }


    // MARK: - Stop Camera

    private func stopCamera() {

        guard let session =
                captureSession else {
            return
        }

        if session.isRunning {

            session.stopRunning()
        }
    }


    // MARK: - Failed

    func failed() {

        DispatchQueue.main.async { [weak self] in

            guard let self =
                    self else {
                return
            }

            let ac =
                UIAlertController(
                    title: "Scanning not supported",
                    message:
                        "Your device does not support scanning a code from an item. Please use a device with a camera.",
                    preferredStyle: .alert
                )

            ac.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .default
                )
            )

            self.present(
                ac,
                animated: true
            )
        }

        captureSession = nil
    }


    // MARK: - Camera Result

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {

        guard didFindCode == false else {
            return
        }

        guard let metadataObject = metadataObjects.first else {
            return
        }

        guard let readableObject =
                metadataObject as? AVMetadataMachineReadableCodeObject else {
            return
        }

        guard let stringValue = readableObject.stringValue,
              !stringValue.isEmpty else {
            return
        }

        didFindCode = true

        AudioServicesPlaySystemSound(
            kSystemSoundID_Vibrate
        )

        found(code: stringValue)
    }


    // MARK: - Found Code

    func found(code: String) {
        let cleanCode = code
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Stock Take is a continuous scanner. Keep the camera session alive,
        // send the value to StockTakePage, then show the result banner.
        if isStockTakeContinuous {
            let result = scanResultHandler?(cleanCode) ?? .noData(code: cleanCode)

            // The reference counter counts successfully matched Stock Take
            // items only. Conflicts must not increase the scanned count.
            if case .correct = result {
                scanCount += 1
                scanCountLabel.text = "Scanned : \(scanCount)"
            }

            delegate?.mGetScannedData(
                value: cleanCode,
                type: mType
            )

            showContinuousScanResult(result)
            scheduleNextScan()
            return
        }

        // Keep the original one-shot behaviour for all other scanner users.
        stopCamera()

        delegate?.mGetScannedData(
            value: cleanCode,
            type: mType
        )

        dismiss(animated: true)
    }

    private func scheduleNextScan() {
        // The same barcode can be delivered by AVCaptureMetadataOutput for
        // several consecutive frames. A short cooldown prevents duplicate
        // callbacks while keeping the camera running continuously.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.didFindCode = false
        }
    }

    private func makeConflictIcon() -> UIView {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "stocktake_ic_conflict")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private func showContinuousScanResult(_ result: CommonScannerScanResult) {
        resultPopupToken = UUID()
        let token = resultPopupToken

        resultPopupView?.removeFromSuperview()
        resultPopupView = nil

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 10
        card.clipsToBounds = false
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.10
        card.layer.shadowRadius = 7
        card.layer.shadowOffset = CGSize(width: 0, height: 2)

        view.addSubview(card)
        resultPopupView = card

        let iconSize: CGFloat = 24
        let horizontalPadding: CGFloat = 12
        let spacing: CGFloat = 9
        let cardHeight: CGFloat = 53

        var cardWidth: CGFloat = 180

        switch result {
        case let .correct(sku, stockID, _):
            let skuWidth = (sku as NSString).size(
                withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular)]
            ).width
            let stockWidth = (stockID as NSString).size(
                withAttributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular)]
            ).width
            cardWidth = iconSize + spacing + skuWidth + 20 + stockWidth + (horizontalPadding * 2)

        case let .conflictWithStockID(sku, stockID):
            let skuWidth = (sku as NSString).size(
                withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular)]
            ).width
            let stockWidth = (stockID as NSString).size(
                withAttributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular)]
            ).width
            cardWidth = iconSize + spacing + skuWidth + 20 + stockWidth + (horizontalPadding * 2)

        case let .conflict(code):
            let codeWidth = (code as NSString).size(
                withAttributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular)]
            ).width
            cardWidth = iconSize + spacing + codeWidth + (horizontalPadding * 2)

        case .noData:
            cardWidth = 180
        }

        cardWidth = min(max(cardWidth, 150), view.bounds.width - 40)

        // Popup is centered exactly in the gap between:
        //   1) bottom edge of the X button
        //   2) top edge of the scan rectangle
        // This keeps the popup visually tied to the scanner frame.
        let popupCenterY = (closeButton.frame.maxY + scanFrameView.frame.minY) / 2

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.topAnchor, constant: popupCenterY),
            card.widthAnchor.constraint(equalToConstant: cardWidth),
            card.heightAnchor.constraint(equalToConstant: cardHeight)
        ])

        switch result {
        case let .correct(sku, stockID, _):
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            card.addSubview(imageView)

            let skuLabel = UILabel()
            skuLabel.translatesAutoresizingMaskIntoConstraints = false
            skuLabel.text = sku
            skuLabel.textColor = UIColor(hex: "#333333")
            skuLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            card.addSubview(skuLabel)

            let dotLabel = UILabel()
            dotLabel.translatesAutoresizingMaskIntoConstraints = false
            dotLabel.text = "·"
            dotLabel.textColor = UIColor(hex: "#9A9A9A")
            dotLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            card.addSubview(dotLabel)

            let stockLabel = UILabel()
            stockLabel.translatesAutoresizingMaskIntoConstraints = false
            stockLabel.text = stockID
            stockLabel.textColor = UIColor(hex: "#777777")
            stockLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            card.addSubview(stockLabel)

            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: horizontalPadding),
                imageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: iconSize),
                imageView.heightAnchor.constraint(equalToConstant: iconSize),

                skuLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: spacing),
                skuLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),

                dotLabel.leadingAnchor.constraint(equalTo: skuLabel.trailingAnchor, constant: 8),
                dotLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),

                stockLabel.leadingAnchor.constraint(equalTo: dotLabel.trailingAnchor, constant: 8),
                stockLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                stockLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -horizontalPadding)
            ])

            // Always use the system placeholder icon for the scan result popup.
            // Do not load or wait for the product image URL.
            imageView.image = UIImage(systemName: "photo.artframe")
            imageView.tintColor = UIColor.systemGray


        case let .conflictWithStockID(sku, stockID):
            let iconView = UIImageView(image: UIImage(named: "stocktake_ic_conflict"))
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.contentMode = .scaleAspectFit
            card.addSubview(iconView)

            let skuLabel = UILabel()
            skuLabel.translatesAutoresizingMaskIntoConstraints = false
            skuLabel.text = sku
            skuLabel.textColor = UIColor(hex: "#333333")
            skuLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            card.addSubview(skuLabel)

            let dotLabel = UILabel()
            dotLabel.translatesAutoresizingMaskIntoConstraints = false
            dotLabel.text = "·"
            dotLabel.textColor = UIColor(hex: "#9A9A9A")
            dotLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            card.addSubview(dotLabel)

            let stockLabel = UILabel()
            stockLabel.translatesAutoresizingMaskIntoConstraints = false
            stockLabel.text = stockID
            stockLabel.textColor = UIColor(hex: "#777777")
            stockLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            card.addSubview(stockLabel)

            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: horizontalPadding),
                iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                iconView.widthAnchor.constraint(equalToConstant: iconSize),
                iconView.heightAnchor.constraint(equalToConstant: iconSize),

                skuLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: spacing),
                skuLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),

                dotLabel.leadingAnchor.constraint(equalTo: skuLabel.trailingAnchor, constant: 8),
                dotLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),

                stockLabel.leadingAnchor.constraint(equalTo: dotLabel.trailingAnchor, constant: 8),
                stockLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                stockLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -horizontalPadding)
            ])

        case let .conflict(code):
            let iconView = UIImageView(image: UIImage(named: "stocktake_ic_conflict"))
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.contentMode = .scaleAspectFit
            card.addSubview(iconView)

            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = code
            label.textColor = UIColor(hex: "#333333")
            label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            card.addSubview(label)

            NSLayoutConstraint.activate([
                iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: horizontalPadding),
                iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                iconView.widthAnchor.constraint(equalToConstant: iconSize),
                iconView.heightAnchor.constraint(equalToConstant: iconSize),

                label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: spacing),
                label.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -horizontalPadding)
            ])

        case .noData:
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "No search results found"
            label.textColor = UIColor(hex: "#555555")
            label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            label.textAlignment = .center
            card.addSubview(label)

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
                label.centerYAnchor.constraint(equalTo: card.centerYAnchor)
            ])
        }

        view.bringSubviewToFront(card)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self, weak card] in
            guard let self,
                  self.resultPopupToken == token,
                  let card = card else { return }

            UIView.animate(withDuration: 0.15, animations: {
                card.alpha = 0
            }, completion: { _ in
                guard self.resultPopupToken == token else { return }
                card.removeFromSuperview()
                if self.resultPopupView === card {
                    self.resultPopupView = nil
                }
            })
        }
    }

    // MARK: - Photo Library

    @objc private func openPhotoLibrary() {

        stopCamera()

        let picker =
            UIImagePickerController()

        picker.sourceType =
            .photoLibrary

        picker.delegate =
            self

        picker.allowsEditing =
            false

        picker.modalPresentationStyle =
            .fullScreen

        present(
            picker,
            animated: true
        )
    }


    // MARK: - Image Picker

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info:
            [UIImagePickerController.InfoKey: Any]
    ) {

        guard let image =
                info[.originalImage] as? UIImage else {

            picker.dismiss(
                animated: true
            ) { [weak self] in

                self?.restartCamera()
            }

            return
        }

        picker.dismiss(
            animated: true
        ) { [weak self] in

            self?.scanCodeFromImage(
                image
            )
        }
    }


    func imagePickerControllerDidCancel(
        _ picker: UIImagePickerController
    ) {

        picker.dismiss(
            animated: true
        ) { [weak self] in

            self?.restartCamera()
        }
    }


    // MARK: - Restart Camera

    private func restartCamera() {

        didFindCode = false

        guard let session =
                captureSession else {

            mStartQRcode()

            return
        }

        if session.isRunning == false {

            DispatchQueue.global(
                qos: .userInitiated
            ).async {

                session.startRunning()
            }
        }
    }


    // MARK: - Scan Code From Image

    private func scanCodeFromImage(
        _ image: UIImage
    ) {

        CommonClass.showFullLoader(
            view: self.view
        )

        DispatchQueue.global(
            qos: .userInitiated
        ).async { [weak self] in

            guard let self =
                    self else {
                return
            }

            guard let cgImage =
                    self.makeCGImage(
                        from: image
                    ) else {

                DispatchQueue.main.async {

                    CommonClass.stopLoader()

                    self.showScanError(
                        message:
                            "Unable to read the selected image."
                    )

                    self.restartCamera()
                }

                return
            }


            // =================================================
            // Vision
            // =================================================

            let request =
                VNDetectBarcodesRequest {
                    [weak self] request, error in

                    guard let self =
                            self else {
                        return
                    }

                    DispatchQueue.main.async {

                        CommonClass.stopLoader()


                        if let error =
                            error {

                            self.showScanError(
                                message:
                                    error.localizedDescription
                            )

                            self.restartCamera()

                            return
                        }


                        guard let observations =
                                request.results
                                as? [VNBarcodeObservation] else {

                            self.showScanError(
                                message:
                                    "No QR code or barcode found in this image."
                            )

                            self.restartCamera()

                            return
                        }


                        let result =
                            observations.first {

                                guard let payload =
                                        $0.payloadStringValue else {
                                    return false
                                }

                                return !payload.isEmpty
                            }


                        guard let code =
                                result?.payloadStringValue,
                              !code.isEmpty else {

                            self.showScanError(
                                message:
                                    "No QR code or barcode found in this image."
                            )

                            self.restartCamera()

                            return
                        }


                        AudioServicesPlaySystemSound(
                            kSystemSoundID_Vibrate
                        )

                        self.found(
                            code: code
                        )
                    }
                }


            // =================================================
            // Supported formats
            // =================================================

            request.symbologies = [

                .QR,
                .Code128,
                .Code39,
                .Code93,
                .EAN8,
                .EAN13,
                .PDF417,
                .Aztec,
                .DataMatrix,
                .UPCE,
                .ITF14
            ]


            // =================================================
            // Vision Handler
            // =================================================

            let handler =
                VNImageRequestHandler(
                    cgImage: cgImage,
                    orientation:
                        self.cgImageOrientation(
                            for: image
                        ),
                    options: [:]
                )

            do {

                try handler.perform(
                    [request]
                )

            } catch {

                DispatchQueue.main.async {

                    CommonClass.stopLoader()

                    self.showScanError(
                        message:
                            error.localizedDescription
                    )

                    self.restartCamera()
                }
            }
        }
    }


    // MARK: - Make CGImage

    private func makeCGImage(
        from image: UIImage
    ) -> CGImage? {

        if let cgImage =
            image.cgImage {

            return cgImage
        }


        if let ciImage =
            image.ciImage {

            let context =
                CIContext(
                    options: [
                        CIContextOption.priorityRequestLow:
                            true
                    ]
                )

            return context.createCGImage(
                ciImage,
                from: ciImage.extent
            )
        }

        return nil
    }


    // MARK: - Image Orientation

    private func cgImageOrientation(
        for image: UIImage
    ) -> CGImagePropertyOrientation {

        switch image.imageOrientation {

        case .up:
            return .up

        case .upMirrored:
            return .upMirrored

        case .down:
            return .down

        case .downMirrored:
            return .downMirrored

        case .left:
            return .left

        case .leftMirrored:
            return .leftMirrored

        case .right:
            return .right

        case .rightMirrored:
            return .rightMirrored

        @unknown default:
            return .up
        }
    }


    // MARK: - Error

    private func showScanError(
        message: String
    ) {

        CommonClass.showSnackBar(
            message: message
        )
    }
}
