//  StockTakePage.swift
//  GIS
//
//  Created by Apple Hawkscode on 11/12/20.
//

import UIKit
import CoreBluetooth
import AVFoundation
import Alamofire
import Foundation
import SwiftyGif

#if !targetEnvironment(simulator)
import EARfidFramework
#endif


class DeviceItems: UITableViewCell {
    @IBOutlet weak var mDeviceName: UILabel!
    @IBOutlet weak var mDeviceStatus: UILabel!
    @IBOutlet weak var mDeviceId: UILabel!

    private var activityIndicator: UIActivityIndicatorView?
    private var checkImageView: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        selectionStyle = .none

        mDeviceName.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        mDeviceName.textColor = UIColor.label

        mDeviceId.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        mDeviceId.textColor = UIColor.secondaryLabel

        // The reference UI only shows name + serial and a state icon.
        mDeviceStatus.isHidden = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator?.stopAnimating()
        activityIndicator = nil
        checkImageView = nil
        accessoryView = nil
    }

    func configure(name: String, id: String, connected: Bool, loading: Bool) {
        mDeviceName.text = name
        mDeviceId.text = id
        mDeviceStatus.isHidden = true

        activityIndicator?.stopAnimating()
        activityIndicator = nil
        checkImageView = nil

        if loading {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.color = UIColor.systemGray3
            spinner.startAnimating()
            accessoryView = spinner
            activityIndicator = spinner
        } else if connected {
            let imageView = UIImageView(
                image: UIImage(systemName: "checkmark.circle.fill")
            )
            imageView.tintColor = UIColor(red: 0.36, green: 0.78, blue: 0.76, alpha: 1.0)
            imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            imageView.contentMode = .scaleAspectFit
            accessoryView = imageView
            checkImageView = imageView
        } else {
            accessoryView = nil
        }
    }

    func setData(_ data: CBPeripheral, _ isConnected: Bool = false) {
        configure(
            name: data.name ?? "Unknown Device",
            id: data.identifier.uuidString,
            connected: isConnected,
            loading: false
        )
    }
}

class StockTakePage: UIViewController, UITableViewDelegate , UITableViewDataSource, AVCaptureMetadataOutputObjectsDelegate, UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout ,UIViewControllerTransitioningDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, GetInventoryFiltersDelegate, ScannerDelegate {
    func mGetScannedData(
        value: String,
        type: String
    ) {
        let scanValue = value
            .components(separatedBy: .newlines)
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? value

        print("FULL SCAN =", value)
        print("SCAN VALUE =", scanValue)

        // IMPORTANT: values coming from RFID / camera scan must NOT be
        // written into the Search field. The Search field is reserved for
        // text entered by the user (keyboard).
        //
        // Camera scans still need to be processed using the scanned value,
        // so pass that value directly to mGetScanResults instead of putting
        // it into mSearchStock.
        if type == "stockTakeCamera" {
            // Camera/Zebra scanner data must use the same decode rule as Zebra RFID.
            // If the value is a Zebra hex-encoded numeric stock ID, decode it first.
            let decodedScanValue = decodeZebraStockScanValue(scanValue)
            print("📷 CAMERA RAW =", scanValue)
            print("📷 CAMERA DECODED =", decodedScanValue)
            mGetScanResults(searchText: decodedScanValue, showPopup: false)
        } else {
            // Manual/search popup is rendered by StockTakePage.
            mGetScanResults(showPopup: true)
        }
    }


    @IBOutlet weak var mSearchDeviceView: UIView!
    @IBOutlet weak var mBottomView: UIView!
    
    @IBOutlet weak var mScanNowLabel: UILabel!
    
    let shape = CAShapeLayer()
    let layer = CAGradientLayer()
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var prevPeripheral : CBPeripheral?
    var SiriID = ""
    
    var bluetoothService : BluetoothLeService?
    
    @IBOutlet weak var mScannerCamView: UIView!
    @IBOutlet weak var mScannerImage: UIImageView!
    
    @IBOutlet weak var mDeviceView: UIView!
    let storyBoard: UIStoryboard = UIStoryboard(name: "stockBoard", bundle: nil)
    
    var m_lock: NSLock?
    @IBOutlet weak var mConnectIcon: UIImageView!
    @IBOutlet weak var mConnectLabel: UILabel!
    
    @IBOutlet weak var mRefreshIcon: UIImageView!
    @IBOutlet weak var mRefreshLabel: UILabel!
    
    @IBOutlet weak var mPowerIcon: UIImageView!
    @IBOutlet weak var mPowerLabel: UILabel!
    
    @IBOutlet weak var mMoreIcon: UIImageView!
    @IBOutlet weak var mMoreLabel: UILabel!
    
    @IBOutlet weak var mConnectDeviceLABEL: UILabel!
    @IBOutlet weak var mStartIcon: UIImageView!
    
    var cr_characteristic: CBCharacteristic?
    
    @IBOutlet weak var mDeviceTableView: UITableView!
    var mTimer = Timer()
    var mPeripherals = [CBPeripheral]()
    var mPeripheral : CBPeripheral?
    var mPerph = CBCentralManager()
    var mDeviceData = NSMutableArray()
    var mDataTags = [String]()
    var mSelected = -1
    var heartRatePeripheral: CBPeripheral!
    
    var mDATA = [""]
    @IBOutlet weak var mSearchStock: UITextField!
    @IBOutlet weak var mTotalStocks: UILabel!
    
    @IBOutlet weak var mScannedStocks: UILabel!
    
    @IBOutlet weak var mUnscannedStocks: UILabel!
    @IBOutlet weak var mConflictStocks: UILabel!
    @IBOutlet weak var mUnknownStocks: UILabel!
    var mScannedData = [String]()
    var mScannedSKU = [String]()
    var mScannedCount = [Int]()
    var mUnscannedData = [String]()
    var mConflictData = [String]()
    var mInventoryData = NSArray()
    var mTData = NSArray()
    
    var mStatusData = NSMutableArray()
    var mSCANNED = NSMutableArray()
    var mUNSCANNED = NSMutableArray()
    var mCONFLICTARRAY = NSMutableArray()
    var mUNKNOWNARRAY = NSMutableArray()
    
    var mSAVESCANNED = NSMutableArray()
    var mSAVEUNSCANNED = NSMutableArray()
    var mCONFLICT = [String]()
    var FINALCONFLICT = [String]()
    var mINVData = NSMutableArray()
    var m_recvData: Data?
    
    @IBOutlet weak var mStartScannView: UIView!
    @IBOutlet weak var mScannerView: UIView!
    
    @IBOutlet weak var mStockTakeHeaderLABEL: UILabel!
    
    @IBOutlet weak var mTotalLABEL: UILabel!
    
    @IBOutlet weak var mScannedLABEL: UILabel!
    
    @IBOutlet weak var mUnscannedLABEL: UILabel!
    
    @IBOutlet weak var mConflictLABEL: UILabel!
    
    @IBOutlet weak var mUnknownLABEL: UILabel!
    @IBOutlet weak var mFilterView: UIView!
    @IBOutlet weak var mFilterSubView: UIView!
    @IBOutlet weak var mFilterLABEL: UILabel!
    @IBOutlet weak var mClearAllBUTTON: UIButton!
    @IBOutlet weak var mFItemLABEL: UILabel!
    @IBOutlet weak var mFSelectAllBUTTON: UIButton!
    @IBOutlet weak var mFCollectionLABEL: UILabel!
    @IBOutlet weak var mFMetalLABEL: UILabel!
    @IBOutlet weak var mFCollectionSelectAllBUTTON: UIButton!
    @IBOutlet weak var mFMetalSelectAllBUTTON: UIButton!
    @IBOutlet weak var mFLocationSelectAllBUTTON: UIButton!
    @IBOutlet weak var mFLocationLABEL: UILabel!
    @IBOutlet weak var mItemCollectionView: UICollectionView!
    @IBOutlet weak var mCollectCollectionView: UICollectionView!
    @IBOutlet weak var mMetalCollectionView: UICollectionView!
    @IBOutlet weak var mLocationCollectionView: UICollectionView!
    @IBOutlet weak var mApplyFilterView: UIView!
    
    @IBOutlet weak var mApplyFilterBUTTON: UIButton!
    
    var mItemsData = NSArray()
    var mItemsId = [String]()
    
    var mCollectionData = NSArray()
    var mCollectionId = [String]()
    
    var mMetalsData = NSArray()
    var mMetalsId = [String]()
    
    var mStonesData = NSArray()
    var mStonesId = [String]()
    
    var mStatusId = [String]()
    
    var mLocationsData = NSArray()
    var mLocationsId = [String]()
    
    var mSizeData = NSArray()
    var mSizeId = [String]()
    
    var mMinPrices = ""
    var mMaxPrices = ""
    var mFilterData = NSMutableDictionary()
    
    
    @IBOutlet weak var mPowerView: UIView!
    @IBOutlet weak var mPowerSlider: UISlider!
    @IBOutlet weak var mFrequencySlider: UISlider!
    @IBOutlet weak var mPowerValue: UILabel!
    @IBOutlet weak var mFrequency: UILabel!
    
    @IBOutlet weak var mPowerpLABEL: UILabel!
    @IBOutlet weak var mPowerLABEL: UILabel!
    @IBOutlet weak var mFrequencyLABEL: UILabel!
    var centralManager : CBCentralManager?
    let ScanPeriod : Double = 10.0
    var arrPeripheral = Array<CBPeripheral>()
    var devices = [ScanDevice]()
    
    //MIC related outlets
    @IBOutlet weak var sMicParentView: UIView!
    @IBOutlet weak var sMicImageView: UIImageView!
    private let speechRecongniger = SpeechRecognizer(localeIdentifier: "en-US")
    private var isSpeechRecongnitionOn = false
    
    //Stock Take loader
    @IBOutlet weak var sStockTakeLoading: UIView!
    
    //Zebra
    var readers: [srfidReaderInfo] = []
    var isShowingZebra = false
    private var stockMap = [String: NSDictionary]()

    // ATID Reader SDK
    // ATID uses the same CoreBluetooth discovery path as the existing
    // Bluetooth readers, but connection/inventory is handled by
    // EARfidFramework instead of BluetoothLeService.
    #if !targetEnvironment(simulator) && canImport(EARfidFramework)
    private var atidDevice: EADeviceBluetoothLe?
    private var atidReader: EAReader?
    #endif
    private var atidPeripheral: CBPeripheral?
    private var atidPeripheralIdentifiers = Set<UUID>()
    private var atidInventoryRunning = false
    // True only after EAReader has finished its asynchronous initialization
    // and the tag-data configuration has completed off the main thread.
    private var atidReaderReady = false
    // The ATID SDK can send initialization callbacks while a disconnect is in
    // progress. Keep disconnect idempotent and ignore those stale callbacks.
    private var isATIDDisconnecting = false
    // ResultNotConnected and ResultTimeout can be delivered repeatedly for a
    // single failed handshake. Handle only the first one.
    private var atidConnectionFailed = false

    // Zebra can report the same EPC many times while the tag remains in range.
    private var recentRFIDReads: [String: Date] = [:]
    private let rfidReadDebounceInterval: TimeInterval = 1.0

    // UI state for the Device bottom sheet.
    private var pendingZebraReaderID: Int32?
    private var pendingBluetoothIdentifier: UUID?
    private var deviceConnectionTimeout: DispatchWorkItem?
    private var deviceEmptyStateView: UIView?
    private var powerEmptyStateView: UIView?
    private var deviceDiscoveryTimer: Timer?

    // Stock Take reference UI state
    private var isSaveInProgress = false
    private var hasSuccessfulSave = false
    private var hasSaveFailed = false
    private var saveActivityIndicator: UIActivityIndicatorView?
    private var resultToastView: UIView?
    // Full-screen dimmer used while Save is in progress. It blocks all taps behind the Save popup.
    private var saveBlockingOverlay: UIView?
    // Save toast progress bar
    private var saveProgressView: UIView?
    private var saveProgressWidthConstraint: NSLayoutConstraint?
    private var saveProgressTimer: DispatchSourceTimer?
    private var manualResultPopupView: UIView?
    private var manualResultPopupToken = UUID()
    private var referenceHeaderOverlay: UIView?
    private var referenceSearchOverlay: UIView?
    private var referenceSummaryOverlay: UIView?
    private var referenceBottomOverlay: UIView?
    private var referenceBottomButtons: [String: UIButton] = [:]
    private var referenceBottomLabels: [String: UILabel] = [:]
    private var referenceLegacyLineMask: UIView?
    private var referenceSummaryCards: [UIView] = []
    private var referenceSummaryValueLabels: [UILabel] = []
    private var referenceSummaryDetailLabels: [UILabel] = []
    private var referenceSummarySoldLabels: [UILabel] = []
    private weak var referencePlayButton: UIButton?
    // After Pause, Stop remains available until the user explicitly taps Stop.
    private var canStopAfterPause = false

    // User explicitly pressed Stop. In this state Play is disabled until Clear.
    private var isStoppedState = false

    // Prevent rapid Play/Pause toggling from sending multiple scanner commands
    // before the scanner has finished processing the previous command.
    private var scannerToggleBlockedUntil: Date?
    private let scannerToggleDebounceInterval: TimeInterval = 1.0
    private var referenceDeviceSheet: UIView?
    private var referencePowerNoDeviceSheet: UIView?
    private var referenceSheetDimView: UIView?

    // Programmatic reference-search controls.
    // Keep strong references so they can always be promoted above the
    // UITextField / legacy storyboard views and receive touch events.
    private weak var referenceMicButton: UIButton?
    private weak var referenceSearchScanButton: UIButton?
    private weak var referenceFilterButton: UIButton?
    private weak var referenceSearchClearButton: UIButton?

    // Programmatic Power sheet matching the supplied reference image.
    private var referencePowerSheet: UIView?
    private weak var referencePowerSlider: UISlider?
    private weak var referenceFrequencySlider: UISlider?
    private weak var referencePowerValueLabel: UILabel?
    private weak var referenceFrequencyValueLabel: UILabel?
    private weak var referenceFrequencySelector: UIButton?
    private var referenceDeviceEmptyStateView: UIView?

    private var stockTakeTotalWeightG: Double = 0
    private var stockTakeTotalSold: Double = 0
    private var hasStockTakeAPISummary: Bool = false
    private var stockTakeSoldData: [NSDictionary] = []
    
    // MARK: - Reference UI (programmatic overlay)
    // This intentionally covers the legacy storyboard summary/bottom layout so
    // the screen matches the supplied Stock Take reference without requiring
    // storyboard constraint changes.
    private func buildReferenceStockTakeOverlay() {
        // Keep the exposed safe-area background at the very top and bottom white.
        // The summary section below remains responsible for its own #FAFAFA fill.
        view.backgroundColor = .white
        // Explicit safe-area covers ensure the system-exposed top and bottom
        // areas stay pure white even when a parent container uses #FAFAFA.
        let topSafeAreaBackground = UIView()
        topSafeAreaBackground.translatesAutoresizingMaskIntoConstraints = false
        topSafeAreaBackground.backgroundColor = .white
        view.addSubview(topSafeAreaBackground)

        let bottomSafeAreaBackground = UIView()
        bottomSafeAreaBackground.translatesAutoresizingMaskIntoConstraints = false
        bottomSafeAreaBackground.backgroundColor = .white
        view.addSubview(bottomSafeAreaBackground)

        NSLayoutConstraint.activate([
            topSafeAreaBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSafeAreaBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSafeAreaBackground.topAnchor.constraint(equalTo: view.topAnchor),
            topSafeAreaBackground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bottomSafeAreaBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSafeAreaBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSafeAreaBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomSafeAreaBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        // Hide the legacy storyboard bottom bar.
        // The reference UI below provides the complete bottom bar, so keeping
        // the old bar visible would result in TWO rows of controls.
        mBottomView?.isHidden = true

        referenceHeaderOverlay?.removeFromSuperview()
        referenceSearchOverlay?.removeFromSuperview()
        referenceSummaryOverlay?.removeFromSuperview()
        referenceBottomOverlay?.removeFromSuperview()
        referenceLegacyLineMask?.removeFromSuperview()
        referenceSummaryCards.removeAll()
        referenceSummaryValueLabels.removeAll()
        referenceSummaryDetailLabels.removeAll()
        referenceSummarySoldLabels.removeAll()
        referenceBottomButtons.removeAll()
        referenceBottomLabels.removeAll()

        // Hide the old storyboard search row. The reference search row below
        // is built programmatically so its mic / scan / filter positions are
        // independent of the storyboard constraints.
        mSearchStock?.superview?.isHidden = true
        sMicParentView?.isHidden = true

        // Header
        let header = UIView()
        header.backgroundColor = UIColor(hex: "#FFFFFF")
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)
        referenceHeaderOverlay = header

        let back = UIButton(type: .system)
        back.translatesAutoresizingMaskIntoConstraints = false
        back.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        back.tintColor = .label
        back.addTarget(self, action: #selector(referenceBackTapped), for: .touchUpInside)
        header.addSubview(back)

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Stock Take"
        title.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        title.textColor = .label
        title.textAlignment = .center
        header.addSubview(title)

        let save = UIButton(type: .system)
        save.translatesAutoresizingMaskIntoConstraints = false
        save.setImage(
            UIImage(named: "stocktake_ic_save") ?? UIImage(systemName: "square.and.arrow.down"),
            for: .normal
        )
        save.tintColor = UIColor(hex: "#D2D2D2")
        save.alpha = 1.0
        save.addTarget(self, action: #selector(referenceSaveTapped), for: .touchUpInside)
        header.addSubview(save)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 57),
            back.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            back.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            back.widthAnchor.constraint(equalToConstant: 32),
            back.heightAnchor.constraint(equalToConstant: 32),
            title.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            save.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            save.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            save.widthAnchor.constraint(equalToConstant: 32),
            save.heightAnchor.constraint(equalToConstant: 32)
        ])

        // Search row: white 71pt area with a 40pt rounded capsule.
        // Microphone and scan are inside the capsule; filter stays outside.
        let search = buildReferenceSearchBar(below: header)

        // Hide the old storyboard summary cards. They are still underneath the
        // reference cards and their colored top/bottom separators can otherwise
        // peek through the gaps.
        hideLegacySummaryCards()

        // Summary overlay. It sits between the search area and bottom bar.
        let summary = UIView()
        // Figma reference: the area around the cards is #FAFAFA.
        summary.backgroundColor = UIColor(hex: "#FAFAFA")
        summary.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(summary)
        referenceSummaryOverlay = summary
        // Summary cards are interactive. The legacy storyboard has buttons
        // underneath these cards with different hit areas/actions, so letting
        // touches pass through causes the wrong Stock Take result screen to open.
        summary.isUserInteractionEnabled = true

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8 // Figma spacing between summary cards
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        summary.addSubview(stack)

        let definitions: [(String, String, UIColor, String, Selector)] = [
            ("Total", "cube", UIColor(hex: "#4D72AA").withAlphaComponent(0.10), "0", #selector(referenceTotalTapped)),
            ("Scanned", "viewfinder", UIColor(hex: "#00A38D").withAlphaComponent(0.10), "0", #selector(referenceScannedTapped)),
            ("Conflict", "viewfinder.circle", UIColor(hex: "#F46565").withAlphaComponent(0.10), "0", #selector(referenceConflictTapped)),
            ("Unknown", "questionmark.viewfinder", UIColor(hex: "#F57B30").withAlphaComponent(0.10), "0", #selector(referenceUnknownTapped)),
            ("Unscanned", "xmark.viewfinder", UIColor(hex: "#868686").withAlphaComponent(0.10), "0", #selector(referenceUnscannedTapped))
        ]

        for definition in definitions {
            let card = makeReferenceSummaryCard(
                title: definition.0,
                iconName: definition.1,
                iconBackground: definition.2,
                value: definition.3,
                action: definition.4
            )
            stack.addArrangedSubview(card)
            referenceSummaryCards.append(card)
        }

        let searchBottom = search.bottomAnchor

        // Reserve the complete bottom control area first.
        // Summary cards must stop above this area so the Play button is never clipped.
        let bottomBarHeight: CGFloat = 80
        let bottomTop = view.safeAreaLayoutGuide.bottomAnchor
        NSLayoutConstraint.activate([
            summary.topAnchor.constraint(equalTo: searchBottom, constant: 16),
            summary.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            summary.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Summary area ends at the footer. The stack itself keeps its
            // fixed Figma card heights, leaving the remaining space below
            // Unscanned as the visual gap before the footer.
            summary.bottomAnchor.constraint(equalTo: bottomTop, constant: -bottomBarHeight),
            stack.topAnchor.constraint(equalTo: summary.topAnchor),
            stack.leadingAnchor.constraint(equalTo: summary.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: summary.trailingAnchor, constant: -16)
        ])

        // Cover only the legacy storyboard separator lines that sit in the
        // unused gaps around the new reference cards. Do not change the card
        // positions or touch handling.
        let lineMask = UIView()
        lineMask.backgroundColor = UIColor(hex: "#FAFAFA")
        lineMask.isUserInteractionEnabled = false
        lineMask.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineMask)
        referenceLegacyLineMask = lineMask
        NSLayoutConstraint.activate([
            lineMask.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lineMask.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lineMask.topAnchor.constraint(equalTo: searchBottom),
            lineMask.bottomAnchor.constraint(equalTo: summary.topAnchor)
        ])

        // Bottom bar overlay. The storyboard currently has the wrong order.
        let bottom = UIView()
        // Figma reference: footer is pure white.
        bottom.backgroundColor = UIColor(hex: "#FFFFFF")
        bottom.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottom)
        referenceBottomOverlay = bottom

        NSLayoutConstraint.activate([
            bottom.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottom.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottom.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            // Fixed height keeps the reference bottom bar compact and fully visible.
            bottom.heightAnchor.constraint(equalToConstant: bottomBarHeight)
        ])

        // The reference cards should have no colored separator peeking out
        // from the legacy two-column storyboard layout. The summary overlay
        // is already opaque, so only the small gap immediately above the
        // bottom bar needs an opaque cover.
        let bottomLineMask = UIView()
        bottomLineMask.backgroundColor = UIColor(hex: "#FAFAFA")
        bottomLineMask.isUserInteractionEnabled = false
        bottomLineMask.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomLineMask)
        NSLayoutConstraint.activate([
            bottomLineMask.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomLineMask.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomLineMask.topAnchor.constraint(equalTo: summary.bottomAnchor),
            bottomLineMask.bottomAnchor.constraint(equalTo: bottom.topAnchor)
        ])

        let bottomStack = UIStackView()
        bottomStack.axis = .horizontal
        bottomStack.alignment = .center
        bottomStack.distribution = .fillEqually
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        bottom.addSubview(bottomStack)

        let connect = makeReferenceBottomItem(icon: "antenna.radiowaves.left.and.right", title: "Connect", action: #selector(referenceConnectTapped))
        let power = makeReferenceBottomItem(icon: "slider.vertical.3", title: "Power", action: #selector(referencePowerTapped))
        let play = makeReferencePlayItem()
        let stop = makeReferenceBottomItem(icon: "stop.fill", title: "Stop", action: #selector(referenceStopTapped))
        let clear = makeReferenceBottomItem(icon: "arrow.clockwise", title: "Clear", action: #selector(mRefresh))

        [connect, power, play, stop, clear].forEach { bottomStack.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            // Pull the four outer controls toward the centered Play button.
            bottomStack.leadingAnchor.constraint(equalTo: bottom.leadingAnchor, constant: 48),
            bottomStack.trailingAnchor.constraint(equalTo: bottom.trailingAnchor, constant: -48),
            bottomStack.topAnchor.constraint(equalTo: bottom.topAnchor),
            bottomStack.bottomAnchor.constraint(equalTo: bottom.bottomAnchor)
        ])
    }

    
    private func buildReferenceSearchBar(below header: UIView) -> UIView {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.backgroundColor = UIColor(hex: "#FFFFFF")
            view.addSubview(container)
            referenceSearchOverlay = container
            container.isUserInteractionEnabled = true

            // Figma reference:
            // ONE rounded search capsule only.
            // Search icon + text + mic + scan are inside it.
            // Filter is outside the capsule.
            let bar = UIView()
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.backgroundColor = UIColor(hex: "#FAFAFA")
            bar.layer.cornerRadius = 20
            bar.clipsToBounds = true
            container.addSubview(bar)

            if let searchField = mSearchStock {
                searchField.removeFromSuperview()
                searchField.translatesAutoresizingMaskIntoConstraints = false
                searchField.backgroundColor = .clear
                searchField.layer.cornerRadius = 0
                searchField.layer.masksToBounds = false
                searchField.borderStyle = .none
                searchField.font = UIFont.systemFont(ofSize: 14, weight: .regular)
                searchField.textColor = .label
                searchField.tintColor = UIColor(hex: "#8A8A8A")
                searchField.placeholder = "Search SKU or Stock ID"
                // Use a custom clear button so it matches the Quick View search:
                // gray circular background with a white X, positioned immediately
                // before the microphone.
                searchField.clearButtonMode = .never
                searchField.addTarget(
                    self,
                    action: #selector(referenceSearchTextChanged(_:)),
                    for: .editingChanged
                )

                let searchIcon = UIImageView(
                    image: UIImage(
                        systemName: "magnifyingglass",
                        withConfiguration: UIImage.SymbolConfiguration(
                            pointSize: 22,
                            weight: .regular
                        )
                    )
                )
                searchIcon.tintColor = UIColor(hex: "#A5A5A5")
                searchIcon.contentMode = .scaleAspectFit
                searchIcon.translatesAutoresizingMaskIntoConstraints = false

                let searchLeft = UIView()
                searchLeft.translatesAutoresizingMaskIntoConstraints = false
                searchLeft.backgroundColor = .clear
                searchLeft.addSubview(searchIcon)

                NSLayoutConstraint.activate([
                    searchLeft.widthAnchor.constraint(equalToConstant: 42),
                    searchLeft.heightAnchor.constraint(equalToConstant: 40),
                    searchIcon.leadingAnchor.constraint(equalTo: searchLeft.leadingAnchor, constant: 8),
                    searchIcon.centerYAnchor.constraint(equalTo: searchLeft.centerYAnchor),
                    searchIcon.widthAnchor.constraint(equalToConstant: 24),
                    searchIcon.heightAnchor.constraint(equalToConstant: 24)
                ])

                searchField.leftView = searchLeft
                searchField.leftViewMode = .always

                bar.addSubview(searchField)

                // The text field must NOT have its own visible capsule.
                // It ends before the mic/scan area.
                NSLayoutConstraint.activate([
                    searchField.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
                    searchField.topAnchor.constraint(equalTo: bar.topAnchor),
                    searchField.bottomAnchor.constraint(equalTo: bar.bottomAnchor),
                    searchField.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -112)
                ])
            }

            // Clear button — same visual treatment as the Quick View search:
            // 28x28 gray circle with a white X. It is shown only when the
            // Stock Take search field contains text.
            let clearButton = UIButton(type: .custom)
            clearButton.translatesAutoresizingMaskIntoConstraints = false
            clearButton.accessibilityLabel = "Clear Search"
            clearButton.backgroundColor = UIColor(hex: "#CCCCCC")
            clearButton.layer.cornerRadius = 8
            clearButton.clipsToBounds = true

            let clearImage = UIImage(
                systemName: "xmark",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 8,
                    weight: .semibold
                )
            )
            clearButton.setImage(
                clearImage?.withTintColor(.white, renderingMode: .alwaysOriginal),
                for: .normal
            )
            clearButton.addTarget(
                self,
                action: #selector(referenceSearchClearTapped),
                for: .touchUpInside
            )
            clearButton.isHidden = (mSearchStock?.text?.isEmpty ?? true)
            bar.addSubview(clearButton)

            let micButton = UIButton(type: .system)
            micButton.translatesAutoresizingMaskIntoConstraints = false
            micButton.isUserInteractionEnabled = true
            micButton.accessibilityLabel = "Voice Search"
            let micImage: UIImage = UIImage(named: "stocktake_ic_mic")
                ?? UIImage(
                    systemName: "mic.fill",
                    withConfiguration: UIImage.SymbolConfiguration(
                        pointSize: 18,
                        weight: .regular
                    )
                )!
            micButton.setImage(
                micImage.withRenderingMode(.alwaysTemplate),
                for: .normal
            )
            micButton.tintColor = UIColor(hex: "#868686")
            micButton.addTarget(self, action: #selector(referenceMicTapped), for: .touchUpInside)
            bar.addSubview(micButton)

            let scanButton = UIButton(type: .system)
            scanButton.translatesAutoresizingMaskIntoConstraints = false
            scanButton.isUserInteractionEnabled = true
            scanButton.accessibilityLabel = "Scan"
            let scanImage: UIImage = UIImage(named: "stocktake_ic_scan")
                ?? UIImage(
                    systemName: "viewfinder",
                    withConfiguration: UIImage.SymbolConfiguration(
                        pointSize: 18,
                        weight: .regular
                    )
                )!

            scanButton.setImage(
                scanImage.withRenderingMode(.alwaysTemplate),
                for: .normal
            )
            scanButton.tintColor = UIColor(hex: "#777777")
            scanButton.addTarget(self, action: #selector(referenceSearchScanTapped), for: .touchUpInside)
            bar.addSubview(scanButton)

            // Filter is outside the search capsule and uses stocktake_ic_filter.
            let filterButton = UIButton(type: .system)
            filterButton.translatesAutoresizingMaskIntoConstraints = false
            filterButton.isUserInteractionEnabled = true
            filterButton.accessibilityLabel = "Filter"

            let filterImage: UIImage = UIImage(named: "stocktake_ic_filter")
                ?? UIImage(
                    systemName: "line.3.horizontal.decrease",
                    withConfiguration: UIImage.SymbolConfiguration(
                        pointSize: 18,
                        weight: .regular
                    )
                )!

            filterButton.setImage(
                filterImage.withRenderingMode(.alwaysTemplate),
                for: .normal
            )
            filterButton.tintColor = UIColor(hex: "#1C1B1F")
            filterButton.addTarget(self, action: #selector(referenceFilterTapped), for: .touchUpInside)
            container.addSubview(filterButton)

            // Retain the controls and promote them above the search field.
            referenceMicButton = micButton
            referenceSearchScanButton = scanButton
            referenceFilterButton = filterButton
            referenceSearchClearButton = clearButton

            NSLayoutConstraint.activate([
                container.topAnchor.constraint(equalTo: header.bottomAnchor),
                container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                // Reference search area is 71pt high. The capsule itself remains 40pt.
                container.heightAnchor.constraint(equalToConstant: 71),

                // Single capsule: 15pt top / 16pt bottom, white around it.
                bar.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                bar.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -49),
                bar.topAnchor.constraint(equalTo: container.topAnchor, constant: 15),
                bar.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),

                // Smaller icons, matching the Figma reference.
                // Clear button sits directly before the microphone.
                clearButton.trailingAnchor.constraint(equalTo: micButton.leadingAnchor, constant: -8),
                clearButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
                clearButton.widthAnchor.constraint(equalToConstant: 16),
                clearButton.heightAnchor.constraint(equalToConstant: 16),

                micButton.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -43),
                micButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
                micButton.widthAnchor.constraint(equalToConstant: 28),
                micButton.heightAnchor.constraint(equalToConstant: 28),

                scanButton.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -8),
                scanButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
                scanButton.widthAnchor.constraint(equalToConstant: 28),
                scanButton.heightAnchor.constraint(equalToConstant: 28),

                // Filter remains outside the capsule.
                filterButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
                filterButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                filterButton.widthAnchor.constraint(equalToConstant: 28),
                filterButton.heightAnchor.constraint(equalToConstant: 28)
            ])

            // Keep the action controls on top after Auto Layout has resolved frames.
            DispatchQueue.main.async { [weak self, weak micButton, weak scanButton, weak filterButton] in
                guard let self = self else { return }
                self.view.bringSubviewToFront(container)
                container.bringSubviewToFront(micButton!)
                container.bringSubviewToFront(scanButton!)
                container.bringSubviewToFront(filterButton!)
                bar.bringSubviewToFront(clearButton)
                bar.bringSubviewToFront(micButton!)
                bar.bringSubviewToFront(scanButton!)
            }

            return container
        }
    
//    private func buildReferenceSearchBar(below header: UIView) -> UIView {
//        let container = UIView()
//        container.translatesAutoresizingMaskIntoConstraints = false
//        container.backgroundColor = UIColor(hex: "#FFFFFF")
//        view.addSubview(container)
//        referenceSearchOverlay = container
//        container.isUserInteractionEnabled = true
//
//        // Figma reference:
//        // ONE rounded search capsule only.
//        // Search icon + text + mic + scan are inside it.
//        // Filter is outside the capsule.
//        let bar = UIView()
//        bar.translatesAutoresizingMaskIntoConstraints = false
//        bar.backgroundColor = UIColor(hex: "#FAFAFA")
//        bar.layer.cornerRadius = 20
//        bar.clipsToBounds = true
//        container.addSubview(bar)
//
//        if let searchField = mSearchStock {
//            searchField.removeFromSuperview()
//            searchField.translatesAutoresizingMaskIntoConstraints = false
//            searchField.backgroundColor = .clear
//            searchField.layer.cornerRadius = 0
//            searchField.layer.masksToBounds = false
//            searchField.borderStyle = .none
//            searchField.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//            searchField.textColor = .label
//            searchField.tintColor = UIColor(hex: "#8A8A8A")
//            searchField.placeholder = "Search SKU or Stock ID"
//            searchField.clearButtonMode = .never
//
//            let searchIcon = UIImageView(
//                image: UIImage(
//                    systemName: "magnifyingglass",
//                    withConfiguration: UIImage.SymbolConfiguration(
//                        pointSize: 22,
//                        weight: .regular
//                    )
//                )
//            )
//            searchIcon.tintColor = UIColor(hex: "#A5A5A5")
//            searchIcon.contentMode = .scaleAspectFit
//            searchIcon.translatesAutoresizingMaskIntoConstraints = false
//
//            let searchLeft = UIView()
//            searchLeft.translatesAutoresizingMaskIntoConstraints = false
//            searchLeft.backgroundColor = .clear
//            searchLeft.addSubview(searchIcon)
//
//            NSLayoutConstraint.activate([
//                searchLeft.widthAnchor.constraint(equalToConstant: 42),
//                searchLeft.heightAnchor.constraint(equalToConstant: 40),
//                searchIcon.leadingAnchor.constraint(equalTo: searchLeft.leadingAnchor, constant: 8),
//                searchIcon.centerYAnchor.constraint(equalTo: searchLeft.centerYAnchor),
//                searchIcon.widthAnchor.constraint(equalToConstant: 24),
//                searchIcon.heightAnchor.constraint(equalToConstant: 24)
//            ])
//
//            searchField.leftView = searchLeft
//            searchField.leftViewMode = .always
//
//            bar.addSubview(searchField)
//
//            // The text field must NOT have its own visible capsule.
//            // It ends before the mic/scan area.
//            NSLayoutConstraint.activate([
//                searchField.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
//                searchField.topAnchor.constraint(equalTo: bar.topAnchor),
//                searchField.bottomAnchor.constraint(equalTo: bar.bottomAnchor),
//                searchField.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -112)
//            ])
//        }
//
//        let micButton = UIButton(type: .system)
//        micButton.translatesAutoresizingMaskIntoConstraints = false
//        micButton.isUserInteractionEnabled = true
//        micButton.accessibilityLabel = "Voice Search"
//        micButton.isUserInteractionEnabled = true
//        micButton.isExclusiveTouch = true
//        let micImage: UIImage = UIImage(named: "stocktake_ic_mic")
//            ?? UIImage(
//                systemName: "mic.fill",
//                withConfiguration: UIImage.SymbolConfiguration(
//                    pointSize: 18,
//                    weight: .regular
//                )
//            )!
//        micButton.setImage(
//            micImage.withRenderingMode(.alwaysTemplate),
//            for: .normal
//        )
//        micButton.tintColor = UIColor(hex: "#868686")
//        micButton.addTarget(self, action: #selector(referenceMicTapped), for: .touchUpInside)
//        bar.addSubview(micButton)
//
//        let scanButton = UIButton(type: .system)
//        scanButton.translatesAutoresizingMaskIntoConstraints = false
//        scanButton.isUserInteractionEnabled = true
//        scanButton.accessibilityLabel = "Scan"
//        scanButton.isUserInteractionEnabled = true
//        scanButton.isExclusiveTouch = true
//        let scanImage: UIImage = UIImage(named: "stocktake_ic_scan")
//            ?? UIImage(
//                systemName: "viewfinder",
//                withConfiguration: UIImage.SymbolConfiguration(
//                    pointSize: 18,
//                    weight: .regular
//                )
//            )!
//
//        scanButton.setImage(
//            scanImage.withRenderingMode(.alwaysTemplate),
//            for: .normal
//        )
//        scanButton.tintColor = UIColor(hex: "#777777")
//        scanButton.addTarget(self, action: #selector(referenceSearchScanTapped), for: .touchUpInside)
//        bar.addSubview(scanButton)
//
//        // Filter is outside the search capsule and uses stocktake_ic_filter.
//        let filterButton = UIButton(type: .system)
//        filterButton.translatesAutoresizingMaskIntoConstraints = false
//        filterButton.isUserInteractionEnabled = true
//        filterButton.accessibilityLabel = "Filter"
//
//        let filterImage: UIImage = UIImage(named: "stocktake_ic_filter")
//            ?? UIImage(
//                systemName: "line.3.horizontal.decrease",
//                withConfiguration: UIImage.SymbolConfiguration(
//                    pointSize: 18,
//                    weight: .regular
//                )
//            )!
//
//        filterButton.setImage(
//            filterImage.withRenderingMode(.alwaysTemplate),
//            for: .normal
//        )
//        filterButton.tintColor = UIColor(hex: "#1C1B1F")
//        filterButton.addTarget(self, action: #selector(referenceFilterTapped), for: .touchUpInside)
//        container.addSubview(filterButton)
//
//        // Retain the controls and promote them above the search field.
//        referenceMicButton = micButton
//        referenceSearchScanButton = scanButton
//        referenceFilterButton = filterButton
//
//        NSLayoutConstraint.activate([
//            container.topAnchor.constraint(equalTo: header.bottomAnchor),
//            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            // Reference search area is 71pt high. The capsule itself remains 40pt.
//            container.heightAnchor.constraint(equalToConstant: 71),
//
//            // Single capsule: 15pt top / 16pt bottom, white around it.
//            bar.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
//            bar.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -49),
//            bar.topAnchor.constraint(equalTo: container.topAnchor, constant: 15),
//            bar.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
//
//            // Smaller icons, matching the Figma reference.
//            micButton.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -43),
//            micButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
//            micButton.widthAnchor.constraint(equalToConstant: 28),
//            micButton.heightAnchor.constraint(equalToConstant: 28),
//
//            scanButton.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -8),
//            scanButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
//            scanButton.widthAnchor.constraint(equalToConstant: 28),
//            scanButton.heightAnchor.constraint(equalToConstant: 28),
//
//            // Filter remains outside the capsule.
//            filterButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
//            filterButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
//            filterButton.widthAnchor.constraint(equalToConstant: 28),
//            filterButton.heightAnchor.constraint(equalToConstant: 28)
//        ])
//
//        // Keep the action controls above the search field/bar after Auto Layout.
//        // The search field can otherwise cover the mic/scan hit areas even though
//        // the icons are visually visible.
////        DispatchQueue.main.async { [weak self, weak micButton, weak scanButton, weak filterButton] in
////            guard let self = self,
////                  let micButton = micButton,
////                  let scanButton = scanButton,
////                  let filterButton = filterButton else { return }
////
////            // Put the whole search overlay above older storyboard views.
////            self.view.bringSubviewToFront(container)
////
////            // Inside the overlay, put the filter above everything.
////            container.bringSubviewToFront(filterButton)
////
////            // Inside the capsule, the buttons must be above the UITextField.
////            bar.bringSubviewToFront(micButton)
////            bar.bringSubviewToFront(scanButton)
////
////            // Explicitly enable interaction.
////            micButton.isUserInteractionEnabled = true
////            scanButton.isUserInteractionEnabled = true
////            filterButton.isUserInteractionEnabled = true
////        }
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//
//            // Search bar must be above legacy storyboard views
//            self.view.bringSubviewToFront(container)
//
//            // Filter above container content
//            container.bringSubviewToFront(filterButton)
//
//            // Mic + Scan MUST be above UITextField
//            bar.bringSubviewToFront(micButton)
//            bar.bringSubviewToFront(scanButton)
//
//            micButton.isUserInteractionEnabled = true
//            scanButton.isUserInteractionEnabled = true
//            filterButton.isUserInteractionEnabled = true
//
//            print("✅ Search buttons ready")
//        }
//
//        return container
//    }

    private func makeReferenceSummaryCard(title: String, iconName: String, iconBackground: UIColor, value: String, action: Selector) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(hex: "#FFFFFF")
        card.layer.cornerRadius = 4
        card.clipsToBounds = true
        card.isUserInteractionEnabled = true

        let cardButton = UIButton(type: .custom)
        cardButton.translatesAutoresizingMaskIntoConstraints = false
        cardButton.backgroundColor = .clear
        cardButton.accessibilityLabel = title
        cardButton.addTarget(self, action: action, for: .touchUpInside)
        card.addSubview(cardButton)

        let color: UIColor = {
            switch title {
            case "Total": return UIColor(hex: "#4D72AA")
            case "Scanned": return UIColor(hex: "#00A38D")
            case "Conflict": return UIColor(hex: "#F46565")
            case "Unknown": return UIColor(hex: "#F57B30")
            case "Unscanned": return UIColor(hex: "#868686")
            default: return .secondaryLabel
            }
        }()

        let iconPanel = UIView()
        iconPanel.backgroundColor = iconBackground
        iconPanel.translatesAutoresizingMaskIntoConstraints = false
        iconPanel.isUserInteractionEnabled = false
        card.addSubview(iconPanel)

        let assetName: String = {
            switch title {
            case "Total": return "stocktake_ic_total"
            case "Scanned": return "stocktake_ic_scanned"
            case "Conflict": return "stocktake_ic_conflict"
            case "Unknown": return "stocktake_ic_unknown"
            case "Unscanned": return "stocktake_ic_unscanned"
            default: return ""
            }
        }()

        let icon = UIImageView(image: UIImage(named: assetName) ?? UIImage(systemName: iconName))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = color
        icon.contentMode = .scaleAspectFit
        icon.isUserInteractionEnabled = false
        iconPanel.addSubview(icon)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = color
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        valueLabel.textColor = color
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let detailLabel = UILabel()
        detailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        detailLabel.textColor = UIColor(hex: "#222222")
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.isHidden = !(title == "Total" || title == "Scanned" || title == "Unscanned")

        let soldLabel = UILabel()
        soldLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        soldLabel.textColor = UIColor(hex: "#222222")
        soldLabel.textAlignment = .right
        soldLabel.translatesAutoresizingMaskIntoConstraints = false
        soldLabel.isHidden = title != "Total"

        // Only the "xxx sold" text in the Total card is tappable.
        // Keep the rest of the Total card behavior unchanged.
        if title == "Total" {
            soldLabel.isUserInteractionEnabled = true
            soldLabel.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(referenceSoldTapped))
            )
        }

        referenceSummaryValueLabels.append(valueLabel)
        referenceSummaryDetailLabels.append(detailLabel)
        referenceSummarySoldLabels.append(soldLabel)

        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        card.addSubview(detailLabel)
        card.addSubview(soldLabel)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 112),
            iconPanel.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            iconPanel.topAnchor.constraint(equalTo: card.topAnchor),
            iconPanel.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            iconPanel.widthAnchor.constraint(equalToConstant: 119.2),
            icon.centerXAnchor.constraint(equalTo: iconPanel.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconPanel.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 40),
            icon.heightAnchor.constraint(equalToConstant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: iconPanel.trailingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: soldLabel.leadingAnchor, constant: -8),
            soldLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            // "sold" must sit on the same baseline row as pcs / grams.
            soldLabel.centerYAnchor.constraint(equalTo: detailLabel.centerYAnchor),
            soldLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 55),
            cardButton.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            cardButton.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            cardButton.topAnchor.constraint(equalTo: card.topAnchor),
            cardButton.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        if title == "Conflict" || title == "Unknown" {
            NSLayoutConstraint.activate([
                titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: -16),
                valueLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: 16)
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
                valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
                detailLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8)
            ])
        }

        card.bringSubviewToFront(cardButton)
        if title == "Total" {
            card.bringSubviewToFront(soldLabel)
        }
        return card
    }

    private func hideLegacySummaryCards() {
        let legacyLabels: [UIView?] = [
            mTotalStocks, mScannedStocks, mConflictStocks, mUnknownStocks, mUnscannedStocks,
            mTotalLABEL, mScannedLABEL, mConflictLABEL, mUnknownLABEL, mUnscannedLABEL
        ]

        // Each of these labels belongs to one of the old storyboard cards.
        // Hide only that card container, not the search/header/bottom controls.
        for item in legacyLabels {
            if let superview = item?.superview, superview !== view {
                superview.isHidden = true
            }
        }
    }

    private func makeReferenceBottomItem(icon: String, title: String, action: Selector) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = title
        button.addTarget(self, action: action, for: .touchUpInside)
        container.addSubview(button)

        let assetName: String = {
            switch title {
            case "Connect": return "stocktake_ic_connect"
            case "Power": return "stocktake_ic_power"
            case "Stop": return "stocktake_ic_stop"
            case "Clear": return "stocktake_ic_clear"
            default: return ""
            }
        }()

        button.setImage(
            UIImage(named: assetName) ?? UIImage(systemName: icon),
            for: .normal
        )
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .top
        // Lower the icon group slightly within the footer.
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        let active = UIColor(hex: "#1C1B1F")
        let disabled = UIColor(hex: "#D2D2D2")
        let baseColor = (title == "Connect" || title == "Power" || title == "Clear") ? active : disabled

        button.tintColor = baseColor
        referenceBottomButtons[title] = button

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = baseColor
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        container.addSubview(label)
        referenceBottomLabels[title] = label

        // Full-area hit target: tapping the icon OR the label must open the sheet.
        // The image/label remain visually centered while the button owns the
        // entire bottom-item touch area.
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            // Keep each label closer to its icon while shifting the full item down.
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 40),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -2)
        ])

        return container
    }

    private func makeReferencePlayItem() -> UIView {
        // Reference: the play button is NOT vertically centered in the footer.
        // Its center sits about 18pt below the footer's top edge, so the
        // 50.67pt circle overlaps the top edge of the footer by about 7pt.
        let container = UIView()
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false

        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = "Start Scan"
        button.backgroundColor = UIColor(hex: "#FFFFFF")
        button.layer.cornerRadius = 25.335
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(referencePlayTapped), for: .touchUpInside)
        container.addSubview(button)
        referencePlayButton = button

        button.setImage(
            UIImage(systemName: "play.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal),
            for: .normal
        )
        button.tintColor = UIColor(hex: "#FFFFFF")
        button.imageView?.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([
            // Force the arranged item to occupy the complete footer height.
            container.heightAnchor.constraint(equalToConstant: 80),

            button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            // Reference position: centerY = footer top + 18pt.
            button.centerYAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            button.widthAnchor.constraint(equalToConstant: 50.67),
            button.heightAnchor.constraint(equalToConstant: 50.67)
        ])

        return container
    }

    private func updateReferenceHeaderSaveButton() {
        guard let header = referenceHeaderOverlay else { return }

        let hasScannedData = (Int(mScannedStocks?.text ?? "0") ?? 0) > 0
        let hasConflictData = (Int(mConflictStocks?.text ?? "0") ?? 0) > 0
        let hasUnknownData = (Int(mUnknownStocks?.text ?? "0") ?? 0) > 0
        let hasSaveableData = hasScannedData || hasConflictData || hasUnknownData

        // Save is enabled when Scanned, Conflict, or Unknown has data.
        let saveEnabled = hasSaveableData
            && !isSaveInProgress
            && !hasSuccessfulSave
            && !canStopAfterPause

        let saveButtons = header.subviews.compactMap { $0 as? UIButton }

        for button in saveButtons {
            if button.frame.maxX > header.bounds.width * 0.75 {
                button.tintColor = saveEnabled
                    ? UIColor(hex: "#00A38D")
                    : UIColor(hex: "#D2D2D2")
                button.alpha = 1.0
                button.isEnabled = saveEnabled
            }
        }
    }

    private func updateReferencePlayButton() {
        let connected = isAnyRFIDConnected
        let running = bluetoothService?.scannerIsRunning == 1 || ZebraRFIDService.shared.isInventoryRunning || atidInventoryRunning

        let activeColor = UIColor(hex: "#111111")
        let tealColor = UIColor(hex: "#00A38D")
        let disabledColor = UIColor(hex: "#D2D2D2")
        let redColor = UIColor(hex: "#FF5B5B")

        referenceBottomButtons["Connect"]?.tintColor = connected ? tealColor : activeColor
        referenceBottomLabels["Connect"]?.textColor = activeColor

        referenceBottomButtons["Power"]?.tintColor = connected ? tealColor : activeColor
        referenceBottomLabels["Power"]?.textColor = activeColor

        // STOP is active while scanning and after Pause.
        let stopEnabled = running || canStopAfterPause
        let stopButton = referenceBottomButtons["Stop"]
        if stopEnabled {
            stopButton?.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            stopButton?.tintColor = redColor
        } else {
            stopButton?.setImage(
                UIImage(named: "stocktake_ic_stop") ?? UIImage(systemName: "stop.fill"),
                for: .normal
            )
            stopButton?.tintColor = disabledColor
        }
        stopButton?.isEnabled = stopEnabled
        // Status is conveyed by icons; all enabled footer labels stay black.
        referenceBottomLabels["Stop"]?.textColor = stopEnabled ? activeColor : disabledColor

        // CLEAR is disabled only on the initial Ready state.
        let clearEnabled = running || canStopAfterPause || isStoppedState || hasStockTakeData()
        referenceBottomButtons["Clear"]?.tintColor = clearEnabled ? activeColor : disabledColor
        referenceBottomButtons["Clear"]?.isEnabled = clearEnabled
        referenceBottomLabels["Clear"]?.textColor = clearEnabled ? activeColor : disabledColor

        updateReferenceHeaderSaveButton()

        guard let button = referencePlayButton else { return }

        if running {
            // SCANNING: Pause active/orange.
            button.backgroundColor = UIColor(hex: "#FFB51B")
            button.setImage(
                UIImage(systemName: "pause.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal),
                for: .normal
            )
            button.isEnabled = true
        } else if isStoppedState {
            // STOP: Play visible but disabled/grey.
            button.backgroundColor = disabledColor
            button.setImage(
                UIImage(systemName: "play.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal),
                for: .normal
            )
            button.isEnabled = false
        } else if connected {
            // READY or PAUSED: Play active/teal.
            button.backgroundColor = tealColor
            button.setImage(
                UIImage(systemName: "play.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal),
                for: .normal
            )
            button.isEnabled = true
        } else {
            button.backgroundColor = disabledColor
            button.setImage(
                UIImage(systemName: "play.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal),
                for: .normal
            )
            button.isEnabled = false
        }

        button.tintColor = UIColor(hex: "#FFFFFF")
        button.imageView?.tintColor = UIColor(hex: "#FFFFFF")
        button.imageView?.alpha = 1.0
    }

    private func numericValue(_ value: Any?) -> Double {
        if let number = value as? NSNumber { return number.doubleValue }
        let string = "\(value ?? "")".replacingOccurrences(of: ",", with: "")
        return Double(string) ?? 0
    }

    private func quantity(of item: NSDictionary) -> Double {
        return numericValue(item["po_QTY"] ?? item["qty"] ?? item["quantity"])
    }

    private func weightGrams(of item: NSDictionary) -> Double {
        let keys = ["weight", "weight_g", "weight_gram", "grams", "gram", "total_weight", "gross_weight", "net_weight"]
        for key in keys where item[key] != nil {
            return numericValue(item[key])
        }
        if let details = item["product_details"] as? NSDictionary {
            for key in keys where details[key] != nil {
                return numericValue(details[key])
            }
        }
        return 0
    }

    private func soldQuantity(from items: [NSDictionary], totalItemCount: Int, totalPcs: Double) -> Double {
        let keys = ["sold", "sold_qty", "sold_quantity", "soldQty"]
        var found = false
        var sold = 0.0
        for item in items {
            for key in keys where item[key] != nil {
                found = true
                sold += numericValue(item[key])
                break
            }
        }
        if found { return max(0, sold) }
        // The supplied reference shows 1,000 items / 1,200 pcs / 200 sold.
        // If the API does not expose sold explicitly, derive the same metric.
        return max(0, totalPcs - Double(totalItemCount))
    }

    private func summaryMetrics(for items: [NSDictionary]) -> (items: Int, pcs: Double, grams: Double) {
        var pcs = 0.0
        var grams = 0.0
        for item in items {
            pcs += quantity(of: item)
            grams += weightGrams(of: item)
        }
        return (items.count, pcs, grams)
    }

    private func formattedNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = value.rounded() == value ? 0 : 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    private func makeReferenceDetailText(pcs: String, grams: String) -> NSAttributedString {
        let result = NSMutableAttributedString()

        let pcsText = NSAttributedString(
            string: "\(pcs) pcs",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor(hex: "#222222")
            ]
        )

        let gramsText = NSAttributedString(
            string: "   (\(grams) g)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor(hex: "#868686")
            ]
        )

        result.append(pcsText)
        result.append(gramsText)
        return result
    }

    private func updateReferenceSummaryCards() {
        guard referenceSummaryValueLabels.count == 5,
              referenceSummaryDetailLabels.count == 5,
              referenceSummarySoldLabels.count == 5 else { return }

        let allItems = mInventoryData.compactMap { $0 as? NSDictionary }
        let scannedItems = mSCANNED.compactMap { $0 as? NSDictionary }
        let unscannedItems = mUNSCANNED.compactMap { $0 as? NSDictionary }

        let total = summaryMetrics(for: allItems)
        let scanned = summaryMetrics(for: scannedItems)
        let unscanned = summaryMetrics(
            for: unscannedItems.isEmpty &&
            total.items > 0 &&
            scanned.items == 0
            ? allItems
            : unscannedItems
        )

        // Keep the old counters working for the rest of the screen/payload.
        let conflict = Int(mConflictStocks?.text ?? "0") ?? 0
        let unknown = Int(mUnknownStocks?.text ?? "0") ?? 0

        let values = [
            total.items,
            scanned.items,
            conflict,
            unknown,
            unscanned.items
        ]

        for (index, value) in values.enumerated() {
            referenceSummaryValueLabels[index].text =
                NumberFormatter.localizedString(
                    from: NSNumber(value: value),
                    number: .decimal
                )
        }

        // ============================================================
        // TOTAL CARD
        // Use values from Stock Take API when available.
        //
        // API:
        // total_qty
        // total_weight
        // total_sold
        // ============================================================

        let displayTotalWeightG = hasStockTakeAPISummary
            ? stockTakeTotalWeightG
            : total.grams

        // Sold is available only from the API's sold_data array.
        let displayTotalSold = soldDataQuantity(stockTakeSoldData)

        referenceSummaryDetailLabels[0].attributedText =
            makeReferenceDetailText(
                pcs: formattedNumber(total.pcs),
                grams: formattedNumber(displayTotalWeightG)
            )

        referenceSummarySoldLabels[0].text = "\(NumberFormatter.localizedString(from: NSNumber(value: Int(displayTotalSold.rounded())),number: .decimal)) sold"

        // ============================================================
        // SCANNED
        // ============================================================

        referenceSummaryDetailLabels[1].attributedText =
            makeReferenceDetailText(
                pcs: formattedNumber(scanned.pcs),
                grams: formattedNumber(scanned.grams)
            )

        referenceSummarySoldLabels[1].text = ""

        // ============================================================
        // CONFLICT
        // ============================================================

        referenceSummaryDetailLabels[2].text = ""
        referenceSummarySoldLabels[2].text = ""

        // ============================================================
        // UNKNOWN
        // ============================================================

        referenceSummaryDetailLabels[3].text = ""
        referenceSummarySoldLabels[3].text = ""

        // ============================================================
        // UNSCANNED
        // ============================================================

        referenceSummaryDetailLabels[4].attributedText =
            makeReferenceDetailText(
                pcs: formattedNumber(unscanned.pcs),
                grams: formattedNumber(unscanned.grams)
            )

        referenceSummarySoldLabels[4].text = ""

        updateReferencePlayButton()
    }
//    private func updateReferenceSummaryCards() {
//        guard referenceSummaryValueLabels.count == 5,
//              referenceSummaryDetailLabels.count == 5,
//              referenceSummarySoldLabels.count == 5 else { return }
//
//        let allItems = mInventoryData.compactMap { $0 as? NSDictionary }
//        let scannedItems = mSCANNED.compactMap { $0 as? NSDictionary }
//        let unscannedItems = mUNSCANNED.compactMap { $0 as? NSDictionary }
//
//        // Reference UI uses ITEM count as the large number, while pcs / grams are
//        // the aggregate PO quantity and weight returned by the inventory API.
//        let total = summaryMetrics(for: allItems)
//        let scanned = summaryMetrics(for: scannedItems)
//        let unscanned = summaryMetrics(for: unscannedItems.isEmpty && total.items > 0 && scanned.items == 0 ? allItems : unscannedItems)
//
//        // Keep the old counters working for the rest of the screen/payload.
//        let conflict = Int(mConflictStocks?.text ?? "0") ?? 0
//        let unknown = Int(mUnknownStocks?.text ?? "0") ?? 0
//
//        let values = [total.items, scanned.items, conflict, unknown, unscanned.items]
//        for (index, value) in values.enumerated() {
//            referenceSummaryValueLabels[index].text = NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
//        }
//
//        let totalSold = soldQuantity(from: allItems, totalItemCount: total.items, totalPcs: total.pcs)
//        referenceSummaryDetailLabels[0].attributedText = makeReferenceDetailText(
//            pcs: formattedNumber(total.pcs),
//            grams: formattedNumber(total.grams)
//        )
//        referenceSummarySoldLabels[0].text = "\(NumberFormatter.localizedString(from: NSNumber(value: Int(totalSold.rounded())), number: .decimal)) sold"
//
//        referenceSummaryDetailLabels[1].attributedText = makeReferenceDetailText(
//            pcs: formattedNumber(scanned.pcs),
//            grams: formattedNumber(scanned.grams)
//        )
//        referenceSummarySoldLabels[1].text = ""
//
//        referenceSummaryDetailLabels[2].text = ""
//        referenceSummarySoldLabels[2].text = ""
//        referenceSummaryDetailLabels[3].text = ""
//        referenceSummarySoldLabels[3].text = ""
//
//        referenceSummaryDetailLabels[4].attributedText = makeReferenceDetailText(
//            pcs: formattedNumber(unscanned.pcs),
//            grams: formattedNumber(unscanned.grams)
//        )
//        referenceSummarySoldLabels[4].text = ""
//
//        updateReferencePlayButton()
//    }

    @objc private func referenceSearchTextChanged(_ sender: UITextField) {
            referenceSearchClearButton?.isHidden = (sender.text?.isEmpty ?? true)
    }

    @objc private func referenceSearchClearTapped() {
        mSearchStock?.text = ""
        referenceSearchClearButton?.isHidden = true
        mSearchStock?.becomeFirstResponder()

        // Keep the existing Stock Take search behavior intact.
        // Do not start/stop scanning or alter any other state here.
    }
    
    @objc private func referenceMicTapped() {
        print("🔥 referenceMicTapped")
        sSpeakStockIdOrSku(self)
    }

    @objc private func referenceSearchScanTapped() {
        print("🔥 referenceSearchScanTapped")
//        mOpenScanner(self)
        mOpenQRScanner()
    }
    
    func mOpenQRScanner() {

        let storyBoard = UIStoryboard(name: "transactions", bundle: nil)

        if let scanner =
            storyBoard.instantiateViewController(
                withIdentifier: "CommonScanner"
            ) as? CommonScanner {

            scanner.delegate = self
            scanner.mType = "stockTakeCamera"
            scanner.isStockTakeContinuous = true

            // Stock Take uses a continuous camera scanner.
            // The scanner stays open after every read and asks StockTakePage
            // whether the scanned code is a valid item before showing the
            // result banner.
            scanner.scanResultHandler = { [weak self] code in
                guard let self = self else {
                    return .conflict(code: code)
                }
                return self.stockTakeScannerResult(for: code)
            }

            scanner.modalPresentationStyle = .overFullScreen

            self.present(scanner, animated: true)
        }
    }

    // MARK: - Stock Take camera validation

    // MARK: - Stock Take camera validation

    private func stockTakeScannerResult(for code: String) -> CommonScannerScanResult {
        // CommonScanner can return the raw encoded value. Decode it before
        // comparing with SKU / stock_id, using the same rule as Zebra RFID.
        let decodedCode = decodeZebraStockScanValue(code)
        print("📷 STOCK TAKE SCAN RAW =", code)
        print("📷 STOCK TAKE SCAN DECODED =", decodedCode)
        let searchKey = normalizedStockLookupKey(decodedCode)

        guard !searchKey.isEmpty else {
            return .noData(code: code)
        }

        // The API data contains both available inventory and sold stock.
        // po_QTY == 0 means the stock is already sold => Conflict.
        for rawItem in mInventoryData {
            guard let item = rawItem as? NSDictionary else { continue }

            let sku = "\(item["SKU"] ?? "")"
            let stockID = "\(item["stock_id"] ?? "")"

            guard searchKey == normalizedStockLookupKey(sku)
                    || searchKey == normalizedStockLookupKey(stockID) else {
                continue
            }

            let poQty = numericValue(item["po_QTY"] ?? item["qty"] ?? item["quantity"])

            if poQty <= 0 {
                return .conflictWithStockID(
                    sku: sku.isEmpty ? code : sku,
                    stockID: stockID
                )
            }

            if mScannedData.contains(stockID) {
                // A repeat read of the same item is not a mismatch. The
                // scanner result is intentionally successful so the camera
                // UI never presents the item as a Conflict; the count is
                // still protected by mGetScanResults/getRFIDData.
                return .correct(
                    sku: sku.isEmpty ? code : sku,
                    stockID: stockID,
                    imageURL: nil
                )
            }

            let imageURL = ["main_image", "images", "image"]
                .compactMap { key -> String? in
                    guard let value = item[key] as? String, !value.isEmpty else { return nil }
                    return value
                }
                .first

            return .correct(
                sku: sku.isEmpty ? code : sku,
                stockID: stockID,
                imageURL: imageURL
            )
        }

        return .noData(code: code)
    }

    @objc private func referenceFilterTapped() {
        mFilter(self)
    }

    @objc private func referenceBackTapped() {
        print("referenceBackTapped")
        guard shouldConfirmLeavingWithoutSave() else {
            navigationController?.popViewController(animated: true)
            return
        }

        showLeaveWithoutSavingConfirmation()
    }

    @objc private func referenceTotalTapped() {
        mTotalScanned(self)
    }

    @objc private func referenceSoldTapped() {
        // When sold_data is absent, the card reads Sold (0) and has no action.
        guard !stockTakeSoldData.isEmpty else { return }

        let soldPage = SoldStock()
        soldPage.mSoldData = stockTakeSoldData
        soldPage.mCount = "\(Int(soldDataQuantity(stockTakeSoldData)))"
        navigationController?.pushViewController(soldPage, animated: true)
    }

    private func soldDataQuantity(_ items: [NSDictionary]) -> Double {
        guard !items.isEmpty else { return 0 }

        let quantity = items.reduce(0.0) { total, item in
            total + numericValue(item["sold_qty"] ?? item["sold"] ?? item["sold_quantity"] ?? item["soldQty"])
        }
        return quantity > 0 ? quantity : Double(items.count)
    }

    @objc private func referenceScannedTapped() {
        mScanned(self)
    }

    @objc private func referenceConflictTapped() {
        mConflictUnknown(self)
    }

    @objc private func referenceUnknownTapped() {
        mUnknownTags(self)
    }

    @objc private func referenceUnscannedTapped() {
        mUnscanned(self)
    }

    @objc private func referenceSaveTapped() {
        let button = UIButton(type: .system)
        mMore(button)
    }

    @objc private func referenceConnectTapped() {
        let button = UIButton(type: .system)
        mConnect(button)
    }

    @objc private func referencePowerTapped() {
        // Always use the programmatic reference Power sheet.  This avoids the
        // old storyboard sheet, whose layout does not match the supplied design.
        print("referencePowerTapped")
        if referencePowerSheet?.isHidden == false {
            closeReferencePowerSheet()
        } else {
            showReferencePowerSheet()
        }
    }

    @objc private func referencePlayTapped() {
        let button = UIButton(type: .system)
        mStart(button)
    }

    @objc private func referenceStopTapped() {
        // READY/STOP: nothing to do.
        if isStoppedState {
            return
        }

        // PAUSE -> STOP.
        if canStopAfterPause &&
            !ZebraRFIDService.shared.isInventoryRunning &&
            !atidInventoryRunning &&
            bluetoothService?.scannerIsRunning != 1 {
            canStopAfterPause = false
            isStoppedState = true
            recentRFIDReads.removeAll()
            updateScannerControls()
            return
        }

        // SCANNING -> STOP.
        mRefresh(self)
        canStopAfterPause = false
        isStoppedState = true
        updateScannerControls()
    }

    @objc private func referenceClearTapped() {
        canStopAfterPause = false
        isStoppedState = false
        clearStockTakeResults()
    }

    private func syncReferenceOverlayVisibility() {
        // Keep the Stock Take screen visible underneath the bottom sheet.
        // The reference design uses a light dim overlay, NOT the legacy
        // storyboard layout and NOT a full-screen white replacement.
        let deviceOpen = !(referenceDeviceSheet?.isHidden ?? true)
        let powerOpen = !(referencePowerNoDeviceSheet?.isHidden ?? true)
        let sheetOpen = deviceOpen || powerOpen

//        let connectedPowerOpen =
//            !(mPowerView?.isHidden ?? true) && isAnyRFIDConnected
//        let anySheetOpen = sheetOpen || connectedPowerOpen
        
        let referencePowerOpen =
            !(referencePowerSheet?.isHidden ?? true)

        let connectedPowerOpen =
            !(mPowerView?.isHidden ?? true) && isAnyRFIDConnected

        let anySheetOpen =
            sheetOpen || connectedPowerOpen || referencePowerOpen

        if anySheetOpen {
            if referenceSheetDimView == nil {
                let dim = UIView()
                dim.translatesAutoresizingMaskIntoConstraints = false
                dim.backgroundColor = UIColor.black.withAlphaComponent(0.12)
                dim.isUserInteractionEnabled = true
                dim.addGestureRecognizer(
                    UITapGestureRecognizer(
                        target: self,
                        action: #selector(referenceSheetDimTapped)
                    )
                )
                view.addSubview(dim)
                referenceSheetDimView = dim
                NSLayoutConstraint.activate([
                    dim.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    dim.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    dim.topAnchor.constraint(equalTo: view.topAnchor),
                    dim.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
            }
            referenceSheetDimView?.isHidden = false
            view.bringSubviewToFront(referenceSheetDimView!)

            // Bottom bar is part of the page underneath the sheet.
            if let bottom = referenceBottomOverlay {
                view.bringSubviewToFront(bottom)
            }

            if let deviceSheet = referenceDeviceSheet {
                view.bringSubviewToFront(deviceSheet)
            }
            if let powerSheet = referencePowerNoDeviceSheet {
                view.bringSubviewToFront(powerSheet)
            }

            // Connected Power uses the existing slider sheet. It must be
            // above the bottom bar and above the dim layer.
//            if connectedPowerOpen, let connectedPowerSheet = mPowerView {
//                connectedPowerSheet.isHidden = false
//                view.bringSubviewToFront(connectedPowerSheet)
//            }
            if referencePowerOpen, let powerSheet = referencePowerSheet {
                powerSheet.isHidden = false
                view.bringSubviewToFront(powerSheet)
            }

            if connectedPowerOpen, let connectedPowerSheet = mPowerView {
                connectedPowerSheet.isHidden = false
                view.bringSubviewToFront(connectedPowerSheet)
            }
        } else {
            referenceSheetDimView?.isHidden = true
        }
    }

    @objc private func referenceSheetDimTapped() {
        // Tapping the dimmed page area dismisses the currently open sheet.
        referenceDeviceSheet?.isHidden = true
        referencePowerNoDeviceSheet?.isHidden = true
        mDeviceView?.isHidden = true
        mPowerView?.isHidden = true
        referenceBottomButtons["Power"]?.isSelected = false
        deviceDiscoveryTimer?.invalidate()
        deviceDiscoveryTimer = nil
        syncReferenceOverlayVisibility()
        updateScannerControls()
    }

    override func viewWillAppear(_ animated: Bool) {
        // Set default slider values
        // Design default: power 50%, frequency 0%.
        // Storyboard-safe: some versions of Stock Take do not contain
        // the Power/Frequency outlets.
        mPowerSlider?.setValue(0.5, animated: false)
        mFrequencySlider?.setValue(0.0, animated: false)

        // Set default labels and text to match the Stock Take design.
        if isZebraRFIDConnected {
            _ = ZebraRFIDService.shared.refreshCurrentPower()
            mPowerValue?.text = "\(ZebraRFIDService.shared.currentPower) / \(ZebraRFIDService.shared.maxPower)"
        } else {
            mPowerValue?.text = "50%"
        }
        mFrequency?.text = "0%"
        mScanNowLabel?.text = "Scan now".localizedString
        mStockTakeHeaderLABEL?.text = "Stock Take".localizedString
        mTotalLABEL?.text = "TOTAL".localizedString
        mScannedLABEL?.text = "SCANNED".localizedString
        mUnscannedLABEL?.text = "UNSCANNED".localizedString
        mConflictLABEL?.text = "CONFLICT".localizedString
        mUnknownLABEL?.text = "UNKNOWN".localizedString
        mConnectLabel?.text = "Connect".localizedString
        mRefreshLabel?.text = "Clear".localizedString
        mConnectDeviceLABEL?.text = "Connect".localizedString
        mFrequencyLABEL?.text = "Frequency".localizedString
        mPowerpLABEL?.text = "Power".localizedString
        mPowerLabel?.text = "Power".localizedString
        mMoreLabel?.text = "Save".localizedString
        mSearchStock?.placeholder = "Search by SKU / Stock ID".localizedString
        
        // Set UI states
        mPowerView?.isHidden = true
        mDeviceView?.isHidden = true
        referenceDeviceSheet?.isHidden = true
        referencePowerNoDeviceSheet?.isHidden = true
        mFilterView?.isHidden = true
        
        // Set UI colors and images
        mPowerLabel?.textColor = UIColor(named: "theme6A")
        mStartIcon?.image = UIImage(named: "play_icgreen")
        mConnectIcon?.image = UIImage(named: "connect_icgrey")
        mConnectLabel?.textColor = UIColor(named: "theme6A")
        updateReferenceStockTakeUI()

        // Returning from Home can leave legacy storyboard views above the
        // programmatic footer. Restore the footer as the top interactive layer.
        if let bottom = referenceBottomOverlay {
            view.bringSubviewToFront(bottom)
        }
        updateReferencePlayButton()

        // Do not call updateScannerControls() during viewWillAppear.
        // Some storyboard versions do not have all bottom-bar outlets connected yet.

        // Do not build the Power sheet here. Some storyboard versions do not
        // contain every optional Power-sheet outlet. The sheet is built safely
        // when the user taps Power.

        // Start capture session if not running
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        
        super.viewWillAppear(animated)

        print("========== STOCK TAKE UI OUTLET CHECK ==========")
        print("mStartIcon =", mStartIcon != nil)
        print("mStartScannView =", mStartScannView != nil)
        print("mConnectIcon =", mConnectIcon != nil)
        print("mConnectLabel =", mConnectLabel != nil)
        print("mPowerIcon =", mPowerIcon != nil)
        print("mPowerLabel =", mPowerLabel != nil)
        print("mPowerView =", mPowerView != nil)
        print("mPowerSlider =", mPowerSlider != nil)
        print("mFrequencySlider =", mFrequencySlider != nil)
        print("mDeviceView =", mDeviceView != nil)
        print("mDeviceTableView =", mDeviceTableView != nil)
        print("===============================================")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let startView = mStartScannView {
            let diameter = min(startView.bounds.width, startView.bounds.height)
            if diameter > 0 {
                startView.layer.cornerRadius = diameter / 2
            }
        }
        updateBottomBarAppearance()
        updateReferenceSummaryCards()
        updateReferencePlayButton()

        // Keep the new interactive controls above every legacy storyboard view.
        if let header = referenceHeaderOverlay {
            view.bringSubviewToFront(header)
        }
        if let search = referenceSearchOverlay {
            view.bringSubviewToFront(search)
        }
        if let summary = referenceSummaryOverlay {
            view.bringSubviewToFront(summary)
        }
        if let mask = referenceLegacyLineMask {
            view.bringSubviewToFront(mask)
        }
        if let bottom = referenceBottomOverlay {
            view.bringSubviewToFront(bottom)
        }

        // IMPORTANT: do this LAST. When a sheet is open it must be above the
        // dim view AND above the bottom bar, otherwise the bar intercepts taps.
        syncReferenceOverlayVisibility()
    }

    override func viewWillDisappear(_ animated: Bool) {

        deviceDiscoveryTimer?.invalidate()
        deviceDiscoveryTimer = nil

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }

        // Stock Take owns its RFID sessions. Leaving this screen by any
        // route must release the reader so returning to Stock Take always
        // requires the user to choose Connect again.
        disconnectRFIDForStockTakeExit()

        super.viewWillDisappear(animated)
    }

    private func disconnectRFIDForStockTakeExit() {
        deviceConnectionTimeout?.cancel()
        deviceConnectionTimeout = nil
        pendingBluetoothIdentifier = nil
        pendingZebraReaderID = nil
        recentRFIDReads.removeAll()

        if ZebraRFIDService.shared.isInventoryRunning {
            ZebraRFIDService.shared.stopInventory()
        }

        if ZebraRFIDService.shared.isConnected ||
            ZebraRFIDService.shared.currentReaderID != -1 {
            print("Stock Take exit: disconnect Zebra RFID")
            ZebraRFIDService.shared.disconnect()
        }

        if atidPeripheral != nil || atidInventoryRunning || atidReaderReady {
            print("Stock Take exit: disconnect ATID RFID")
            disconnectATIDReader()
        }

        if bluetoothService?.peripheral != nil {
            print("Stock Take exit: disconnect legacy Bluetooth reader")
            disconnectLegacyBluetoothReader()
        }

        DispatchQueue.main.async { [weak self] in
            self?.updateScannerControls()
            self?.mDeviceTableView.reloadData()
        }
    }
  
    
    private var isATIDRFIDConnected: Bool {
        #if !targetEnvironment(simulator) && canImport(EARfidFramework)
        return atidPeripheral?.state == .connected && atidReader != nil && atidReaderReady
        #else
        // EARfidFramework is device-only. RFID is unavailable on Simulator.
        return false
        #endif
    }

    private var isAnyRFIDConnected: Bool {
        // Existing Bluetooth reader connection
        if bluetoothService?.isConnected() == true {
            return true
        }

        // Zebra: currentReaderID is assigned immediately when the
        // communication session succeeds, while isConnected is updated
        // by the SDK callback shortly afterwards.
        if ZebraRFIDService.shared.isConnected ||
            ZebraRFIDService.shared.currentReaderID != -1 {
            return true
        }

        // ATID Reader is considered ready only after EAReader initialization
        // and tag-data configuration have completed. This prevents Play from
        // being enabled while EARfidFramework is still initializing.
        if isATIDRFIDConnected {
            return true
        }

        return false
    }

    private var isZebraRFIDConnected: Bool {
        return ZebraRFIDService.shared.isConnected
    }

    private func isATIDPeripheral(_ peripheral: CBPeripheral) -> Bool {
        return atidPeripheralIdentifiers.contains(peripheral.identifier)
    }

    private func isATIDReaderName(_ name: String) -> Bool {
        let upper = name.uppercased()
        return upper.contains("AT188") ||
               upper.contains("AT188NP") ||
               upper.contains("AT388") ||
               upper.contains("ATS100") ||
               upper.contains("ATS200")
    }

    private func updateScannerControls() {
        updateReferencePlayButton()
        let connected = isAnyRFIDConnected
        let running = bluetoothService?.scannerIsRunning == 1 || ZebraRFIDService.shared.isInventoryRunning || atidInventoryRunning
        let hasScannedData = (Int(mScannedStocks?.text ?? "0") ?? 0) > 0
        let hasConflictData = (Int(mConflictStocks?.text ?? "0") ?? 0) > 0
        let hasUnknownData = (Int(mUnknownStocks?.text ?? "0") ?? 0) > 0
        let hasSaveableData = hasScannedData || hasConflictData || hasUnknownData
        updateReferenceSummaryCards()

        // IMPORTANT:
        // Do not force-unwrap storyboard outlets here.
        // Different Stock Take storyboard versions have different optional
        // outlets. Each control is updated only when that outlet exists.

        // CONNECT
        if let icon = mConnectIcon {
            icon.image = UIImage(named: connected ? "connect_icgreen" : "connect_icgrey")
            icon.contentMode = .scaleAspectFit
        }
        if let label = mConnectLabel {
            label.text = "Connect".localizedString
            label.textColor = UIColor(hex: "#1C1B1F")
            label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        }

        // CENTER SCAN BUTTON
        if let icon = mStartIcon {
            if running {
                if #available(iOS 13.0, *) {
                    icon.image = UIImage(systemName: "pause.fill")
                    icon.tintColor = .white
                }
            } else if connected {
                // The storyboard icon sits above the programmatic green Play
                // button on some layouts. It must be white while the reader
                // is ready; the green asset would otherwise make the triangle
                // look disabled even though the button is active.
                icon.image = UIImage(systemName: "play.fill")
                icon.tintColor = .white
            } else {
                icon.image = UIImage(named: "play_icgreen")
                icon.tintColor = nil
            }
            icon.alpha = connected ? 1.0 : 0.45
            icon.contentMode = .scaleAspectFit
        }

        if let scanView = mStartScannView {
            if running {
                scanView.backgroundColor = UIColor(red: 1.0, green: 0.67, blue: 0.05, alpha: 1.0)
            } else {
                scanView.backgroundColor = UIColor(named: "themeColor")
            }

            let width = scanView.bounds.width
            let height = scanView.bounds.height
            if width > 0 && height > 0 {
                scanView.layer.cornerRadius = min(width, height) / 2
            }
            scanView.clipsToBounds = true
        }

        // STOP while scanning / CLEAR while idle
        if let icon = mRefreshIcon {
            if running {
                if #available(iOS 13.0, *) {
                    icon.image = UIImage(systemName: "stop.fill")
                    icon.tintColor = UIColor.systemRed
                }
            } else {
                icon.image = UIImage(named: "refresh_icgreen")
                icon.tintColor = UIColor(named: "themeColor")
            }
            icon.contentMode = .scaleAspectFit
        }

        if let label = mRefreshLabel {
            label.text = running ? "Stop".localizedString : "Clear".localizedString
            label.textColor = UIColor(named: "theme6A") ?? .secondaryLabel
            label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        }

        // POWER
        if let icon = mPowerIcon {
            icon.image = UIImage(named: connected ? "power_icgreen" : "power_icgrey")
            icon.contentMode = .scaleAspectFit
        }
        if let label = mPowerLabel {
            label.textColor = UIColor(hex: "#1C1B1F")
            label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        }

        // SAVE
        if let icon = mMoreIcon {
            if isSaveInProgress {
                icon.image = UIImage(named: "save_ic")
                icon.alpha = 0.45
            } else if hasSaveableData {
                icon.image = UIImage(named: "save_ic")
                icon.alpha = 1.0
            } else {
                icon.image = UIImage(named: "save_icg")
                icon.alpha = 0.45
            }
            icon.contentMode = .scaleAspectFit
            icon.isUserInteractionEnabled = false
        }

        if let label = mMoreLabel {
            label.text = "Save".localizedString
            label.textColor = hasSaveableData && !isSaveInProgress
                ? (UIColor(named: "themeColor") ?? .label)
                : (UIColor(named: "theme6A") ?? .secondaryLabel)
            label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        }
    }

    private func updateReferenceStockTakeUI() {
        view.backgroundColor = UIColor(hex: "#FAFAFA")

        if let bottom = mBottomView {
            bottom.backgroundColor = UIColor(hex: "#FFFFFF")
            bottom.layer.cornerRadius = 0
            bottom.layer.maskedCorners = []
            bottom.layer.shadowColor = UIColor.clear.cgColor
            bottom.layer.shadowOpacity = 0
            bottom.layer.shadowRadius = 0
            bottom.layer.shadowOffset = .zero
        }

        // Search field
        if let search = mSearchStock {
            // The UITextField lives inside the single reference search capsule.
            // Do not give the field its own background/corner radius.
            search.backgroundColor = .clear
            search.layer.cornerRadius = 0
            search.clipsToBounds = false
            search.borderStyle = .none
            search.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            search.textColor = .label
        }

        // Bottom sheet appearance
        [mDeviceView, mPowerView].forEach {
            $0?.backgroundColor = .systemBackground
            $0?.layer.cornerRadius = 16
            $0?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0?.clipsToBounds = true
        }

        if let table = mDeviceTableView {
            table.backgroundColor = .clear
            table.separatorStyle = .none
        }

        // Default values from the reference.
        if let slider = mPowerSlider {
            slider.minimumValue = 0
            slider.maximumValue = 1
            slider.setValue(0.5, animated: false)
        }
        if let slider = mFrequencySlider {
            slider.minimumValue = 0
            slider.maximumValue = 1
            slider.setValue(0.0, animated: false)
        }
        mPowerValue?.text = "50%"
        mFrequency?.text = "0%"

        updatePowerSheetState()
    }

    private func updateBottomBarAppearance() {
        // Storyboard-safe UI refresh.
        mConnectLabel?.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        mRefreshLabel?.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        mPowerLabel?.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        mMoreLabel?.font = UIFont.systemFont(ofSize: 11, weight: .regular)

        mConnectIcon?.contentMode = .scaleAspectFit
        mRefreshIcon?.contentMode = .scaleAspectFit
        mPowerIcon?.contentMode = .scaleAspectFit
        mMoreIcon?.contentMode = .scaleAspectFit
        mStartIcon?.contentMode = .scaleAspectFit
    }

    private func updateDeviceEmptyState() {
        guard let table = mDeviceTableView else { return }

        // When the reference Device sheet is being used, show the empty state
        // directly inside the sheet. UITableView.backgroundView is unreliable
        // here because the table is moved into a bottom-sheet container.
        if referenceDeviceSheet != nil {
            let empty = referenceDeviceEmptyStateView
            empty?.isHidden = !devices.isEmpty
            table.isHidden = devices.isEmpty
            table.backgroundView = nil
            return
        }

        table.isHidden = false

        if devices.isEmpty {
            if deviceEmptyStateView == nil {
                let container = UIView()
                container.backgroundColor = .clear
                container.translatesAutoresizingMaskIntoConstraints = false

                let imageView = UIImageView(
                    image: UIImage(systemName: "antenna.radiowaves.left.and.right.slash")
                )
                imageView.tintColor = UIColor(hex: "#868686")
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false

                let title = UILabel()
                title.text = "Device not found"
                title.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                title.textColor = UIColor(hex: "#222222")
                title.textAlignment = .center
                title.translatesAutoresizingMaskIntoConstraints = false

                let subtitle = UILabel()
                subtitle.text = "Please check your connection and try again."
                subtitle.font = UIFont.systemFont(ofSize: 13, weight: .regular)
                subtitle.textColor = UIColor(hex: "#868686")
                subtitle.textAlignment = .center
                subtitle.numberOfLines = 2
                subtitle.translatesAutoresizingMaskIntoConstraints = false

                let stack = UIStackView(arrangedSubviews: [imageView, title, subtitle])
                stack.axis = .vertical
                stack.alignment = .center
                stack.spacing = 10
                stack.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(stack)

                NSLayoutConstraint.activate([
                    imageView.widthAnchor.constraint(equalToConstant: 36),
                    imageView.heightAnchor.constraint(equalToConstant: 36),
                    stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                    stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                    stack.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 20),
                    stack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -20)
                ])

                deviceEmptyStateView = container
            }
            table.backgroundView = deviceEmptyStateView
        } else {
            table.backgroundView = nil
        }
    }

    @objc private func zebraReaderChanged(_ notification: Notification) {
        // IMPORTANT: Zebra raises the reader-available notification immediately
        // after it adds the device internally. At that exact moment
        // ZebraRFIDService.shared.availableReaders can still be empty.
        // The notification object is therefore the first source of truth.
        // Falling back to availableReaders keeps compatibility with the old
        // notification behaviour.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            var discoveredReaders: [srfidReaderInfo] = []

            if let reader = notification.object as? srfidReaderInfo {
                discoveredReaders = [reader]
            } else if let readers = notification.object as? [srfidReaderInfo] {
                discoveredReaders = readers
            } else {
                discoveredReaders = ZebraRFIDService.shared.availableReaders
            }

            // If the notification arrived without a usable object, try the
            // service list once more. This also handles a notification that
            // is posted before the service has finished updating its array.
            if discoveredReaders.isEmpty {
                discoveredReaders = ZebraRFIDService.shared.availableReaders
            }

            print("🦓 Zebra Reader Changed")
            print("🦓 Notification object =", notification.object as Any)
            print("🦓 Readers received =", discoveredReaders.count)

            for reader in discoveredReaders {
                let readerID = reader.getReaderID()
                let serial = reader.getReaderSerialNumber() ?? ""
                print("🦓 Reader = ID:\(readerID), Serial:\(serial)")

                // Keep the local list in sync as well.
                let readerExists = self.readers.contains {
                    $0.getReaderID() == readerID
                }
                if !readerExists {
                    self.readers.append(reader)
                }

                // The Device sheet uses `devices`, not `readers`, as its data
                // source. This is the important part that makes the reader
                // actually appear in the UITableView.
                let deviceExists = self.devices.contains {
                    $0.type == .zebra && $0.zebraReader?.getReaderID() == readerID
                }
                if !deviceExists {
                    self.devices.append(ScanDevice(reader: reader))
                }
            }

            self.updateDeviceEmptyState()
            self.mDeviceTableView.reloadData()
            self.syncReferenceOverlayVisibility()
        }
    }

    @objc private func zebraConnectionChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            self.deviceConnectionTimeout?.cancel()
            self.deviceConnectionTimeout = nil
            self.pendingZebraReaderID = nil

            if ZebraRFIDService.shared.isConnected {
                self.mDeviceView.isHidden = true
            }
            self.updateScannerControls()
            self.updatePowerSheetState()
            self.updateDeviceEmptyState()
            self.mDeviceTableView.reloadData()

            // The Zebra SDK may report its connected event while legacy
            // storyboard views are still finishing their own layout pass.
            // Refresh once more on the next run loop so the visible Play
            // control cannot remain grey even though it already accepts taps.
            if ZebraRFIDService.shared.isConnected {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self,
                          ZebraRFIDService.shared.isConnected else { return }
                    self.updateScannerControls()
                    self.referencePlayButton?.isEnabled = !self.isStoppedState
                }
            }
        }
    }

    private func startDeviceConnectionTimeout() {
        deviceConnectionTimeout?.cancel()

        // Keep the identifier captured for this individual attempt. The
        // timeout must tear down an incomplete AT388 SDK session; otherwise
        // the next tap reuses a half-initialized EADevice.
        let connectingBluetoothIdentifier = pendingBluetoothIdentifier

        let timeout = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            // Some Bluetooth/RFID connection failures do not produce an SDK
            // callback. Fully reset an unfinished AT388 connection as well
            // as clearing the row spinner, so the device can be selected
            // again immediately.
            if let connectingBluetoothIdentifier,
               self.atidPeripheral?.identifier == connectingBluetoothIdentifier,
               !self.atidReaderReady {
                print("❌ ATID connection timed out; resetting incomplete session")
                self.disconnectATIDReader()
            }
            self.pendingBluetoothIdentifier = nil
            self.pendingZebraReaderID = nil
            self.updateScannerControls()
            self.mDeviceTableView.reloadData()
            CommonClass.showSnackBar(message: "Unable to connect to device")
        }

        deviceConnectionTimeout = timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 12, execute: timeout)
    }

    @objc private func zebraInventoryChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            self.updateScannerControls()
        }
    }

    @objc private func zebraRegionRequired(_ notification: Notification) {
        let message = (notification.object as? String) ?? "Set the RFID region in Power before scanning."
        DispatchQueue.main.async {
            self.updateScannerControls()
            CommonClass.showSnackBar(message: message)
        }
    }

    @objc
    func tagRead(_ notification: Notification) {

        guard let value = notification.object as? String else { return }

        // IMPORTANT: Always decode at the StockTakePage boundary too.
        // This protects us even if ZebraRFIDService sends the RAW EPC.
        let tag = decodeZebraStockScanValue(value)

        guard !tag.isEmpty else { return }

        print("📡 ZEBRA RFID RAW     =", value)
        print("📡 ZEBRA RFID DECODED =", tag)

        let now = Date()
        if let lastRead = recentRFIDReads[tag],
           now.timeIntervalSince(lastRead) < rfidReadDebounceInterval {
            print("↩️ Ignore duplicate Zebra RFID =", tag)
            return
        }
        recentRFIDReads[tag] = now

        if recentRFIDReads.count > 500 {
            let cutoff = now.addingTimeInterval(-rfidReadDebounceInterval)
            recentRFIDReads = recentRFIDReads.filter { $0.value >= cutoff }
        }

        print("📡 ZEBRA RFID READ =", tag)

        DispatchQueue.main.async {
            // RFID reads are processed directly and must NOT populate the
            // Search field. Search text is user-entered only.

            // A tag that has already been counted in this Stock Take must not
            // become a Conflict simply because Zebra keeps seeing it.
            if let item = self.stockMap[tag] {
                let stockID = "\(item["stock_id"] ?? "")"
                if !stockID.isEmpty && self.mScannedData.contains(stockID) {
                    print("↩️ Ignore already scanned Zebra stock =", stockID)
                    return
                }
            }

            self.getRFIDData(data: tag)
        }
    }
    
//    @objc
//    func tagRead(_ notification: Notification) {
//
//        guard let epc = notification.object as? String else {
//            return
//        }
//
//
//        let searchKey: String
//
//        if let decoded = ZebraRFIDService.shared.decodeFromHex(epc),
//           decoded.range(of: #"^\d{1,12}$"#, options: .regularExpression) != nil {
//            print("New RFID Format")
//            searchKey = decoded
//        } else {
//            print("Old RFID Format")
//            searchKey = epc
//        }
////        if let decoded = ZebraRFIDService.shared.decodeFromHex(epc) {
////
////            print("New RFID Format")
////            searchKey = decoded
////
////        } else {
////
////            print("Old RFID Format")
////            searchKey = epc
////        }
//
//        print("RAW =RAW =", epc)
//        print("SEARCH =", searchKey)
//
//        DispatchQueue.main.async {
//
//            self.mSearchStock.text = searchKey
//            self.getRFIDData(data: searchKey)
//
//        }
////        mSearchStock?.text = searchKey
////
////        getRFIDData(data: searchKey)
//    }
    
    @objc
    func barcodeRead(_ notification: Notification) {

        guard let code = notification.object as? String else {
            return
        }

        // IMPORTANT:
        // Zebra RFID tags are decoded inside ZebraRFIDService before
        // .zebraTagRead is posted. Zebra barcode events are currently posted
        // as raw text, so do the same decode step here before lookup.
        // Normal barcode text such as "2212291" is kept unchanged because
        // decodeFromHex() will fail and we fall back to the original value.
        let decodedCode = decodeZebraStockScanValue(code)

        print("📦 BARCODE RAW =", code)
        print("📦 BARCODE DECODED =", decodedCode)

        // Scanner input must NOT populate the Search field.
        // Lookup only after the value has been decoded.
        getRFIDData(data: decodedCode)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
//    @objc func scannerRead(_ noti: Notification) {
//
//        guard let result = noti.object as? ScanResult else {
//            return
//        }
//
//        switch result.type {
//
//        case .rfid:
//            print("RFID =", result.value)
//
//        case .barcode:
//            print("Barcode =", result.value)
//        }
//
//        callAPI(result.value)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _ = ZebraRFIDService.shared
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(tagRead(_:)),
            name: .zebraTagRead,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(barcodeRead(_:)),
            name: .zebraBarcodeRead,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(zebraConnectionChanged(_:)),
            name: .zebraConnectionChanged,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(zebraInventoryChanged(_:)),
            name: .zebraInventoryChanged,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(zebraRegionRequired(_:)),
            name: .zebraRegionRequired,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(zebraReaderChanged(_:)),
            name: .zebraReaderChanged,
            object: nil
        )
        
        
        // Retrieve user login token from UserDefaults
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")

        // Configure filter subview
        mFilterSubView.layer.cornerRadius = 20
        mFilterSubView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        // Initialize Bluetooth service
        bluetoothService = BluetoothLeService(main: self)

        // Set delegates and data sources for collection views
        mItemCollectionView.delegate = self
        mItemCollectionView.dataSource = self
        mCollectCollectionView.delegate = self
        mCollectCollectionView.dataSource = self
        mMetalCollectionView.delegate = self
        mMetalCollectionView.dataSource = self
        mLocationCollectionView.delegate = self
        mLocationCollectionView.dataSource = self

        // Set initial stock counts
        mScannedStocks.text = "0"
        mUnscannedStocks.text = "0"
        mConflictStocks.text = "0"
        mTotalStocks.text = "0"
        mUnknownStocks.text = "0"
       if let gif = try? UIImage(gifName: "scanner.gif") {
            mScannerImage.setGifImage(gif)
        } else {
            print("⚠️ ไม่พบไฟล์ scanner.gif")
        }


        //mScannerImage.image = UIImage.gif(asset: "scanner")

        // Add tap gesture to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false

        // Configure bottom view
        mBottomView.layer.cornerRadius = 0
        mBottomView.layer.maskedCorners = []
        mBottomView.dropShadow()

        // Apply the reference Stock Take appearance only after storyboard
        // outlets are guaranteed to exist.
        updateReferenceStockTakeUI()

        // Configure search device view
        mSearchDeviceView.layer.cornerRadius = 10
        mSearchDeviceView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        // Configure power view
        mPowerView.layer.cornerRadius = 10
        mPowerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        // Configure apply filter view
        mApplyFilterView.layer.cornerRadius = 10
        mApplyFilterView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mApplyFilterView.dropShadow()

        // Set delegates and data sources for device table view
        self.mDeviceTableView.delegate = self
        self.mDeviceTableView.dataSource = self
        self.mDeviceTableView.separatorStyle = .none
        self.mDeviceTableView.backgroundColor = .clear
        self.updateDeviceEmptyState()

        // Fetch inventory data
        self.mGetInventoryDataStock(key: "")

        // Add done button to keyboard
        addDoneButtonOnKeyboard()
        print("Siri ID: \(SiriID)")
        self.mSearchStock.text = SiriID

        // Hide the legacy storyboard bottom bar before building the reference UI.
        // This prevents the old Connect/Clear/Play/Power/Save row from appearing underneath.
        mBottomView?.isHidden = true

        // Build the reference Stock Take UI over the legacy storyboard cards.
        buildReferenceStockTakeOverlay()
        updateReferenceSummaryCards()
    }
    
    
    func mGetInventoryFilterData(itemsId: [String], metalId: [String], collectionId: [String], stoneId: [String], sizeId: [String], locationId: [String], statusId: [String], minPrice: String, maxPrice: String) {
        
        mItemsId = itemsId
        mMetalsId = metalId
        mCollectionId = collectionId
        mStonesId = stoneId
        mSizeId = sizeId
        mStatusId = statusId
        mLocationsId = locationId
        mMinPrices = minPrice
        mMaxPrices = maxPrice
        
        mGetInventoryDataStock(key: "")
    }
    
    //Mic Button
    @IBAction func sSpeakStockIdOrSku(_ sender: Any) {
        
        if !isSpeechRecongnitionOn {
            self.isSpeechRecongnitionOn = true
            self.sMicImageView.image = UIImage(systemName: "mic.slash.fill")
            speechRecongniger.startRecognition { value in
                
                DispatchQueue.main.async {
                    self.isSpeechRecongnitionOn = false
                    self.sMicImageView.image = UIImage(systemName: "mic.fill")
                    if let text = value , !text.isEmpty{
                        self.mSearchStock.text = text
                        self.mSearchStock.becomeFirstResponder()
                    }
                }
            }
            
        } else {
            self.sMicImageView.image = UIImage(systemName: "mic.fill")
            self.isSpeechRecongnitionOn = false
            speechRecongniger.stopRecognition()
        }

    }

    @IBAction func mFrequencySliding(_ sender: UISlider) {
        let percent = Int((sender.value * 100).rounded())
        sender.setValue(Float(percent) / 100.0, animated: false)
        mFrequency.text = "\(percent)%"

        // Frequency here is the legacy reader duty-cycle control.
        // Zebra RFID uses its own RF/link-profile configuration and does not
        // expose the same on/off duty-cycle API, so keep this control UI-only
        // for Zebra until the product confirms the required Zebra mapping.
        guard !isZebraRFIDConnected else { return }

        let on = Int(Double(percent) * 2.0)
        let off = 200 - on
        bluetoothService?.sendSettingTxCycle(on: on, off: off)
    }

    @IBAction func mPowerSliding(_ sender: UISlider) {
        let percent = Int((sender.value * 100).rounded())
        sender.setValue(Float(percent) / 100.0, animated: false)
        mPowerValue.text = "\(percent)%"

        if isZebraRFIDConnected {
            let minPower = ZebraRFIDService.shared.minPower
            let maxPower = ZebraRFIDService.shared.maxPower
            let range = max(1, maxPower - minPower)
            let requestedPower = minPower + Int32(
                (Double(range) * Double(percent) / 100.0).rounded()
            )

            _ = ZebraRFIDService.shared.setPowerValue(requestedPower)
            mPowerValue.text = "\(ZebraRFIDService.shared.currentPower) / \(maxPower)"
            return
        }

        // Legacy reader power is represented as attenuation from max power.
        let attenuation = min(9, max(0, Int((100 - percent) / 10)))
        let power = attenuation == 0 ? 0 : -attenuation
        bluetoothService?.sendSettingTxPower(power: power)
    }

    
    @IBAction func mFilter(_ sender: Any) {
        
        view.endEditing(true)
        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
        guard let mFilters = storyBoard.instantiateViewController(withIdentifier: "CommonFilters") as? CommonFilters else { return }
        mFilters.delegate = self
        mFilters.mType = "inventory"
        mFilters.hideLocation = true
        mFilters.mItemsId = mItemsId
        mFilters.mMetalsId = mMetalsId
        mFilters.mCollectionId = mCollectionId
        mFilters.mStonesId = mStonesId
        mFilters.mSizeId = mSizeId
        mFilters.mLocationsId = mStatusId
        mFilters.mStatusId = mLocationsId
        mFilters.mMinPrices = mMinPrices
        mFilters.mMaxPrices = mMaxPrices
        mFilters.modalPresentationStyle = .automatic
        mFilters.transitioningDelegate = self
        self.present(mFilters,animated: true)
    }
    
    
    
    @IBAction func mMinimizeFilter(_ sender: Any) {
        mFilterView.slideTop()
        mFilterView.isHidden = true
    }
    
    @IBAction func mApplyFilter(_ sender: Any) {
        let defaultZero = "0"
        self.mScannedStocks.text = defaultZero
        self.mUnscannedStocks.text = defaultZero
        self.mConflictStocks.text = defaultZero
        self.mUnknownStocks.text = defaultZero
        
        self.mScannedData = []
        self.mScannedSKU = []
        self.mScannedCount = []
        self.mUnscannedData = []
        self.mConflictData = []
        self.mInventoryData = NSArray()
        self.mStatusData = NSMutableArray()
        self.mSCANNED = NSMutableArray()
        self.mUNSCANNED = NSMutableArray()
        self.mSAVESCANNED = NSMutableArray()
        self.mSAVEUNSCANNED = NSMutableArray()
        self.mCONFLICT = []
        self.FINALCONFLICT = []
        
        mGetInventoryDataStock(key: "")
        mFilterView.slideTop()
        mFilterView.isHidden = true
    }
    
    // MARK: - ATID Reader SDK

    #if !targetEnvironment(simulator) && canImport(EARfidFramework)
    private func connectATID(_ peripheral: CBPeripheral) {
        guard isATIDPeripheral(peripheral) else {
            print("⚠️ connectATID called for non-ATID peripheral")
            return
        }

        // CoreBluetooth may report the same BLE peripheral more than once.
        // Do not restart the AT388 SDK handshake while it is already
        // connecting: restarting it is the main cause of a very slow
        // connection and a permanently spinning row.
        if pendingBluetoothIdentifier == peripheral.identifier,
           atidPeripheral?.identifier == peripheral.identifier,
           (peripheral.state == .connecting ||
            (peripheral.state == .connected && atidDevice != nil)) {
            print("ℹ️ ATID connection already in progress =", peripheral.name ?? "Unknown")
            return
        }

        isATIDDisconnecting = false
        atidConnectionFailed = false

        if bluetoothService?.isConnected() == true {
            disconnectLegacyBluetoothReader()
        }

        if ZebraRFIDService.shared.isConnected ||
            ZebraRFIDService.shared.currentReaderID != -1 {
            ZebraRFIDService.shared.disconnect()
        }

        pendingBluetoothIdentifier = peripheral.identifier
        atidPeripheralIdentifiers.insert(peripheral.identifier)
        atidPeripheral = peripheral

        print("🔵 ATID CONNECT REQUEST =", peripheral.name ?? "Unknown")
        print("🔵 ATID UUID =", peripheral.identifier.uuidString)

        if peripheral.state == .connected {
            finishATIDPeripheralConnection(peripheral)
        } else {
            centralManager?.connect(peripheral, options: nil)
        }

        updateScannerControls()
        mDeviceTableView.reloadData()
    }

    private func finishATIDPeripheralConnection(_ peripheral: CBPeripheral) {
        guard isATIDPeripheral(peripheral) else { return }

        if atidDevice == nil {
            atidDevice = EADeviceBluetoothLe(
                peripheral: peripheral,
                delegate: self
            )
        }
    }

    private func disconnectLegacyBluetoothReader() {
        guard let legacyPeripheral = bluetoothService?.peripheral else {
            return
        }

        if bluetoothService?.scannerIsRunning == 1 {
            stopRFID()
        }

        bluetoothService?.byeBluetoothDevice()
        centralManager?.cancelPeripheralConnection(legacyPeripheral)
        bluetoothService?.peripheral = nil
    }

    private func disconnectATIDReader() {
        guard !isATIDDisconnecting else {
            print("ℹ️ ATID disconnect already in progress")
            return
        }

        print("🔴 ATID DISCONNECT")
        isATIDDisconnecting = true

        let reader = atidReader
        let device = atidDevice
        let peripheral = atidPeripheral
        let wasInventoryRunning = atidInventoryRunning

        // Clear local references before invoking the SDK. Its callbacks can be
        // synchronous, so they must never see a partially disconnected reader.
        atidInventoryRunning = false
        atidReader = nil
        atidReaderReady = false
        atidDevice = nil
        atidPeripheral = nil
        pendingBluetoothIdentifier = nil

        if wasInventoryRunning, let reader = reader {
            _ = reader.stop()
        }

        if let reader = reader {
            reader.disconnect()
        } else if let device = device {
            device.disconnect()
        }

        if let peripheral = peripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }

        isATIDDisconnecting = false

        DispatchQueue.main.async {
            self.updateScannerControls()
            self.mDeviceTableView.reloadData()
        }
    }

    private func startATIDInventory() {
        guard let reader = atidReader,
              isATIDRFIDConnected else {
            print("❌ ATID START: reader is not ready")
            return
        }

        recentRFIDReads.removeAll()

        // EAReader.inventory() can wait for an SDK response. Never call it
        // on the main thread or the Play/Pause button will appear frozen.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.atidInventoryRunning = true
            self.updateScannerControls()
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self, weak reader] in
            guard let self = self, let reader = reader else { return }

            let result = reader.inventory()
            print("📡 ATID INVENTORY START result =", result)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if result != ResultNoError {
                    self.atidInventoryRunning = false
                    print("❌ ATID inventory failed result =", result)
                }
                self.updateScannerControls()
            }
        }
    }

    private func stopATIDInventory() {
        guard let reader = atidReader else {
            atidInventoryRunning = false
            updateScannerControls()
            return
        }

        // Update the UI immediately so Pause changes back to Play without
        // waiting for the SDK stop response. The SDK call itself is moved
        // off the main thread because it can also wait for a response packet.
        atidInventoryRunning = false
        recentRFIDReads.removeAll()
        updateScannerControls()

        DispatchQueue.global(qos: .userInitiated).async { [weak self, weak reader] in
            guard let self = self, let reader = reader else { return }
            let result = reader.stop()
            print("🛑 ATID INVENTORY STOP result =", result)

            DispatchQueue.main.async { [weak self] in
                self?.updateScannerControls()
            }
        }
    }

    private func handleATIDTag(_ rawTag: String, rssi: Float, phase: Float) {
        let raw = rawTag
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        guard !raw.isEmpty else { return }

        // ATID readTagResult returns PC + EPC in Hex format.
        // Try PC+EPC and EPC-only forms, plus ASCII-from-hex.
        var candidates: [String] = [raw]

        if raw.count > Int(TAG_PC_LENGTH),
           raw.count % 2 == 0,
           raw.allSatisfy({ $0.isHexDigit }) {
            
            let epcOnly = String(raw.dropFirst(Int(TAG_PC_LENGTH)))
            
            if !epcOnly.isEmpty {
                candidates.append(epcOnly)
            }
        }

        func asciiFromHex(_ value: String) -> String? {
            guard value.count % 2 == 0 else { return nil }

            var output = ""
            var index = value.startIndex

            while index < value.endIndex {
                let next = value.index(index, offsetBy: 2)
                let byteString = String(value[index..<next])

                guard let byte = UInt8(byteString, radix: 16),
                      byte >= 32,
                      byte <= 126 else {
                    return nil
                }

                output.append(Character(UnicodeScalar(byte)))
                index = next
            }

            return output.isEmpty ? nil : output
        }

        let snapshot = candidates
        for candidate in snapshot {
            if let decoded = asciiFromHex(candidate) {
                candidates.append(decoded.uppercased())
            }
        }

        var uniqueCandidates: [String] = []
        for candidate in candidates {
            let normalized = normalizedStockLookupKey(candidate)
            guard !normalized.isEmpty else { continue }

            if !uniqueCandidates.contains(normalized) {
                uniqueCandidates.append(normalized)
            }
        }

        print("📡 ATID RAW TAG =", raw)
        print("📡 ATID CANDIDATES =", uniqueCandidates)
        print("📡 ATID RSSI =", rssi, "PHASE =", phase)

        if let matched = uniqueCandidates.first(where: { stockMap[$0] != nil }) {
            let now = Date()

            if let lastRead = recentRFIDReads[matched],
               now.timeIntervalSince(lastRead) < rfidReadDebounceInterval {
                print("↩️ Ignore duplicate ATID RFID =", matched)
                return
            }

            recentRFIDReads[matched] = now

            DispatchQueue.main.async {
                if let item = self.stockMap[matched] {
                    let stockID = "\(item["stock_id"] ?? "")"
                    if !stockID.isEmpty && self.mScannedData.contains(stockID) {
                        print("↩️ Ignore already scanned ATID stock =", stockID)
                        return
                    }
                }

                self.getRFIDData(data: matched)
            }
            return
        }

        let fallback = uniqueCandidates.count > 1
            ? uniqueCandidates[1]
            : (uniqueCandidates.first ?? raw)

        let now = Date()
        if let lastRead = recentRFIDReads[fallback],
           now.timeIntervalSince(lastRead) < rfidReadDebounceInterval {
            print("↩️ Ignore duplicate ATID RFID =", fallback)
            return
        }

        recentRFIDReads[fallback] = now

        DispatchQueue.main.async {
            self.getRFIDData(data: fallback)
        }
    }
    #else
    // Simulator stubs: keep the Stock Take UI/buildable without EARfidFramework.
    private func connectATID(_ peripheral: CBPeripheral) {
        print("ℹ️ ATID RFID is unavailable on iOS Simulator")
    }

    private func finishATIDPeripheralConnection(_ peripheral: CBPeripheral) {
        print("ℹ️ ATID RFID is unavailable on iOS Simulator")
    }

    private func disconnectATIDReader() {
        guard !isATIDDisconnecting else { return }
        isATIDDisconnecting = true
        atidInventoryRunning = false
        atidReaderReady = false
        atidPeripheral = nil
        pendingBluetoothIdentifier = nil
        isATIDDisconnecting = false
        updateScannerControls()
        mDeviceTableView.reloadData()
    }

    private func startATIDInventory() {
        print("ℹ️ ATID RFID is unavailable on iOS Simulator")
    }

    private func stopATIDInventory() {
        atidInventoryRunning = false
        updateScannerControls()
    }
    #endif

    func connect(_ peripheral: CBPeripheral) {
     
        if bluetoothService?.isConnected() == true {
            if bluetoothService?.peripheral == peripheral {
                bluetoothService?.byeBluetoothDevice()
                self.mConnectIcon.image = UIImage(named: "connect_icgrey")
                self.mConnectLabel.textColor = UIColor(named: "theme6A")
                
                CommonClass.showFullLoader(view: self.view)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    CommonClass.stopLoader()
                    if let cbPeripheral = self.bluetoothService?.peripheral {
                        self.centralManager?.cancelPeripheralConnection(cbPeripheral)
                        self.mDeviceTableView.reloadData()
                    }
                })
                
                return
            } else {
                
                self.mConnectIcon.image = UIImage(named: "connect_icgrey")
                self.mConnectLabel.textColor = UIColor(named: "theme6A")
                bluetoothService?.byeBluetoothDevice()
                CommonClass.showFullLoader(view: self.view)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    
                    CommonClass.stopLoader()
                    
                    if let cbPeripheral = self.bluetoothService?.peripheral {
                        self.centralManager?.cancelPeripheralConnection(cbPeripheral)
                    }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    self.bluetoothService?.peripheral = peripheral
                    peripheral.delegate = self
                    self.centralManager?.connect(peripheral)
                    CommonClass.showFullLoader(view: self.view)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: {
                        CommonClass.stopLoader()
                        self.mConnectIcon.image = UIImage(named: "connect_icgreen")
                        self.mConnectLabel.textColor = UIColor(hex: "#1C1B1F")
                        self.mDeviceView.isHidden = true
                        
                    })
                })
                self.mDeviceTableView.reloadData()
                
            }
            
            self.mDeviceTableView.reloadData()
            
        } else {
            bluetoothService?.peripheral = peripheral
            peripheral.delegate = self
            centralManager?.connect(peripheral)
            CommonClass.showFullLoader(view: self.view)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                self.mDeviceView.isHidden = true
                self.mConnectIcon.image = UIImage(named: "connect_icgreen")
                self.mConnectLabel.textColor = UIColor(hex: "#1C1B1F")
                CommonClass.stopLoader()
                
            })
        }
        self.mDeviceTableView.reloadData()
    }
    
    func search() {
        arrPeripheral.removeAll()

        // Keep an already connected Bluetooth reader in the list.
        if let peripheral = bluetoothService?.peripheral {
            if !arrPeripheral.contains(peripheral) {
                arrPeripheral.append(peripheral)
            }

            let exists = devices.contains { device in
                device.type == .bluetooth && device.peripheral == peripheral
            }

            if !exists {
                devices.append(ScanDevice(peripheral: peripheral))
            }
        }

        if let peripheral = atidPeripheral,
           peripheral.state == .connected {
            atidPeripheralIdentifiers.insert(peripheral.identifier)

            if !arrPeripheral.contains(peripheral) {
                arrPeripheral.append(peripheral)
            }

            let exists = devices.contains { device in
                device.type == .bluetooth && device.peripheral == peripheral
            }

            if !exists {
                devices.append(ScanDevice(peripheral: peripheral))
            }
        }

        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }

        // IMPORTANT:
        // CBCentralManager(delegate:) does not guarantee that
        // centralManagerDidUpdateState() will be called again when the
        // manager is already powered on. If it is already poweredOn, start
        // scanning here immediately. This was the reason Connect could open
        // the sheet but never show discovered Bluetooth devices.
        if centralManager?.state == .poweredOn {
            startBluetoothDiscovery()
        }

        updateDeviceEmptyState()
        mDeviceTableView.reloadData()
    }

    private func startBluetoothDiscovery() {
        guard let central = centralManager, central.state == .poweredOn else {
            return
        }

        if central.isScanning {
            central.stopScan()
        }

        let services = [
            bluetoothService?.R5000_SERVICE,
            bluetoothService?.R800_3000_SERVICE
        ].compactMap { $0 }

        // First recover readers that are already connected to iOS.
        if !services.isEmpty {
            let connected = central.retrieveConnectedPeripherals(withServices: services)
            for peripheral in connected {
                addPeripheral(peripheral: peripheral)
            }
        }

        // Then scan for new readers. Do not restrict the service UUID here;
        // addPeripheral() performs the existing supported-reader name filter.
        central.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )

        mScanNowLabel?.text = "Scanning".localizedString

        DispatchQueue.main.asyncAfter(deadline: .now() + ScanPeriod) { [weak self] in
            guard let self = self else { return }
            self.mScanNowLabel?.text = "Scan now".localizedString
            self.centralManager?.stopScan()
            self.mDeviceTableView?.reloadData()
        }
    }
    
    
    func stopScan() {
        if centralManager?.isScanning ?? false {
            centralManager?.stopScan()
        }
        mDeviceTableView.reloadData()
    }
    
    func startScanner() {
        if bluetoothService?.isConnected() ?? false {
            bluetoothService?.sendCmdScannerScanStart()
            bluetoothService?.scannerIsRunning = 2

        }
    }
    func stopScanner() {
        if bluetoothService?.isConnected() ?? false {
            bluetoothService?.sendCmdScannerScanStop()
            bluetoothService?.scannerIsRunning = 0

        }
    }
    
    func startRFID() {
        #if !targetEnvironment(simulator) && canImport(EARfidFramework)
        if isATIDRFIDConnected {
            startATIDInventory()
            return
        }
        #endif

        if bluetoothService?.isConnected() ?? false {
            bluetoothService?.sendCmdInventory(f_s: 0, f_m: 0, to: 0)
            bluetoothService?.scannerIsRunning = 1
        }
    }

    func stopRFID() {
        #if !targetEnvironment(simulator) && canImport(EARfidFramework)
        if isATIDRFIDConnected {
            stopATIDInventory()
            return
        }
        #endif

        if bluetoothService?.isConnected() ?? false {
            bluetoothService?.sendCmdStop()
            bluetoothService?.scannerIsRunning = 0
        }
    }

    var arrMSG : [String] = []
    func completeConnect() {
        arrMSG.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.bluetoothService?.packetClear()
            self.arrMSG.removeAll()
            self.arrMSG.append("MSG_OPEN_INTERFACE1")
            self.arrMSG.append("MSG_GET_FW_VERSION")
            self.arrMSG.append("MSG_GET_SCANNER_TYPE")
            self.arrMSG.append("MSG_SET_DEFAULT")
            self.arrMSG.append("MSG_SET_TAGFOCUS")
            self.bluetoothService?.sendCmdOpenInterface1()
        })
        
       
    }
    
    
    func receiveData() {
        var msg = bluetoothService?.popPacket()
        
        var sentMsg = ""
        while msg != nil {
            sentMsg = ""
            if arrMSG.count > 0 {
                sentMsg = arrMSG[0]

                if msg?.contains(find: "$>") == true {
                    arrMSG.removeFirst()
                    
                    sendNextMsg()
                }
            }
            switch sentMsg {
            case "MSG_GET_SCANNER_TYPE":
                if let msg = msg, msg.starts(with: "ok,"),
                   let scannerType = Int(msg.substring(from: 3)) {
                    bluetoothService?.scannerType = scannerType
                }
                break
            case "MSG_GET_FW_VERSION":
                if let msg = msg, msg.starts(with: "ok,") {
                    bluetoothService?.firmwareVer = msg.substring(from: 3)
                }
                break
            case "MSG":
                break
            default:
                break
            }
            if let msg = msg {
                if msg.starts(with: "^") ||
                    msg.starts(with: "$") ||
                    msg.starts(with: "ok") ||
                    msg.starts(with: "err") ||
                    msg.starts(with: "end") ||
                    msg.starts(with: ",") ||
                    msg.contains(find: ",e="){
                    if msg.starts(with: "err_scan=") { //no scanner
                        bluetoothService?.scannerType = 0
                    }
                    else if msg.starts(with: "ok,ver=") { // firmwareVersion
                        bluetoothService?.firmwareVer = msg.split(usingRegex: "=")[1]
                    }
                    else if msg.starts(with: "err_tag=") || msg.starts(with: "err_op=") { // read/write acc error
              
                    }
                    else if msg.starts(with: "ok,e=") { // write success

                    }
                    else if msg.contains(",e=") { // read success

                    }
                    else if msg.starts(with: "end=0,w") {

                    }
                    else if msg.starts(with: "ok,") {
                        
                    }
                    else if msg.starts(with: "$trigger=") {
                        if msg.starts(with: "$trigger=0") {
                            
                            bluetoothService?.scannerIsRunning = 0
                            stopRFID()
                            
                        } else if msg.starts(with: "$trigger=1") {
                            
                            bluetoothService?.scannerIsRunning = 1
                            startRFID()
                            
                        } else if msg.starts(with: "$trigger=2") {
                            bluetoothService?.scannerIsRunning = 0
                            stopScanner()
                        } else if msg.starts(with: "$trigger=3") {
                            bluetoothService?.scannerIsRunning = 2
                            startScanner()
                        }
                    }
                    else if msg.starts(with: "$online=0") || msg.starts(with: "$pwr=0") {
                        
                    }
                    else if msg.starts(with: "end") {
                        if msg.contains(find: "sc.start") {
                        } else if msg.contains(find: ",i") {
                      
                        }
                    }
                    else if msg.starts(with: "err") {
                        
                    }
                    else if msg.starts(with: "^") {
                        
                    }
                } else if bluetoothService?.scannerIsRunning != 0 { // rfid, barcode data
                    if  bluetoothService?.scannerIsRunning == 1 {

                        addData(msg)
                        
                    } else if bluetoothService?.scannerIsRunning == 2 {
                        
                        addDataScanner(msg)
                        
                    }
                }
            }
            msg = bluetoothService?.popPacket()
        }
    }
    
    func addData(_ data: String) {
        var time = "", rssi = "", bctype = ""
        var data = data
        if data.contains(find: ",t=") {
            time = data.split(usingRegex: ",")[1]
            if time.contains(find: ",s=") {
                time = time.split(usingRegex: ",")[0]
            }
            time = time.replace(target: "t=", withString: "")
            if data.contains(find: ",s=") {
                rssi = data.split(usingRegex: ",")[2].replace(target: "s=", withString: "")
            }
            data = data.split(usingRegex: ",")[0]
        } else if data.contains(find: ",s=") {
            rssi = data.split(usingRegex: ",")[1].replace(target: "s=", withString: "")
            data = data.split(usingRegex: ",")[0]
        } else if data.contains(find: ",z=") { // barcode
            return
        }
        
        if data.isEmpty {
            return
        }
        getRFIDData(data: data.hexToString())
        
    }
   
    func addDataScanner(_ data: String) {
        var time = "", rssi = "", bctype = ""
        var data = data
        if data.contains(find: ",t=") {
            time = data.split(usingRegex: ",")[1]
            if time.contains(find: ",s=") {
                time = time.split(usingRegex: ",")[0]
            }
            time = time.replace(target: "t=", withString: "")
            if data.contains(find: ",s=") {
                rssi = data.split(usingRegex: ",")[2].replace(target: "s=", withString: "")
            }
            data = data.split(usingRegex: ",")[0]
        } else if data.contains(find: ",s=") {
            rssi = data.split(usingRegex: ",")[1].replace(target: "s=", withString: "")
            data = data.split(usingRegex: ",")[0]
        } else if data.contains(find: ",z=") {
            bctype = data.split(usingRegex: ",")[1].replace(target: "z=", withString: "")
            data = data.split(usingRegex: ",")[0]
            if data.isEmpty {
                return
            }
        }
     
        getRFIDData(data: data)
        
    }
    func sendNextMsg() {
        let msg = arrMSG.count > 0 ? arrMSG[0] : ""
        switch msg {
        case "MSG_GET_FW_VERSION":
            bluetoothService?.sendGetVersion()
            break
        case "MSG_GET_SCANNER_TYPE":
            bluetoothService?.sendGetScannerType()
            break
        case "MSG_SET_DEFAULT":
            bluetoothService?.sendSetDefaultParameter()
            break
        case "MSG_SET_POWER":
            bluetoothService?.sendSettingTxPower(power: 0)
            break
        case "MSG_SET_TX_CYCLE":
            bluetoothService?.sendSettingTxCycle(on: 40, off: 140)
            break
        case "MSG_SET_INVENTORY_PARAM":
            bluetoothService?.sendInventoryParam(session: 1, q: 5, m_ab: 0)
            break
        case "MSG_SET_TAGFOCUS":
            bluetoothService?.sendCmdRfidTagFocus(enable: 0)
            break
        default:
            break
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unsupported:
            self.centralManager = nil
            self.bluetoothService?.peripheral = nil
            break
        case .unauthorized:
            self.centralManager = nil
            self.bluetoothService?.peripheral = nil
            break
        case .poweredOff:
            self.centralManager = nil
            self.bluetoothService?.peripheral = nil
            break
        case .poweredOn:
            // Start discovery as soon as CoreBluetooth reports poweredOn.
            // This also covers the first Connect tap, when CBCentralManager
            // was created moments earlier.
            startBluetoothDiscovery()
            break
        default:
            self.centralManager = nil
            self.bluetoothService?.peripheral = nil
            break
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        addPeripheral(peripheral: peripheral)
    }
    func addPeripheral(peripheral: CBPeripheral) {
        let alreadyInArray = arrPeripheral.contains {
            $0.identifier == peripheral.identifier
        }

        guard let name = peripheral.name, !alreadyInArray else {
            return
        }

        if isATIDReaderName(name) {
            atidPeripheralIdentifiers.insert(peripheral.identifier)
            arrPeripheral.append(peripheral)

            let exists = devices.contains {
                $0.type == .bluetooth &&
                $0.peripheral?.identifier == peripheral.identifier
            }

            if !exists {
                devices.append(ScanDevice(peripheral: peripheral))
            }

            print("🟢 ATID Reader discovered =", name,
                  peripheral.identifier.uuidString)

            updateDeviceEmptyState()
            mDeviceTableView.reloadData()
            return
        }

        // Existing reader discovery remains unchanged.
        if let service = bluetoothService {
            if name.starts(with: service.HQ_UHF_READER) ||
                name.starts(with: service.TSS900_UHF_READER) ||
                name.starts(with: service.DOTR900_UHF_READER) ||
                name.starts(with: service.DOTR800_UHF_READER) ||
                name.starts(with: service.G2W_UHF_READER) ||
                name.starts(with: service.TSS2000_UHF_READER) ||
                name.starts(with: service.DOT2000_UHF_READER) ||
                name.starts(with: service.DOTR3000_UHF_READER) ||
                name.starts(with: service.TSS3000_UHF_READER) ||
                name.starts(with: service.RF800_UHF_READER) ||
                name.starts(with: service.DOTR5000_UHF_READER) {

                arrPeripheral.append(peripheral)

                let exists = devices.contains {
                    $0.type == .bluetooth &&
                    $0.peripheral?.identifier == peripheral.identifier
                }

                if !exists {
                    devices.append(ScanDevice(peripheral: peripheral))
                }

                updateDeviceEmptyState()
                mDeviceTableView.reloadData()
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        central.stopScan()

        if isATIDPeripheral(peripheral) {
            print("🟢 ATID CoreBluetooth connected =", peripheral.name ?? "Unknown")

            atidPeripheral = peripheral

            #if !targetEnvironment(simulator) && canImport(EARfidFramework)
            // Build the EARfidFramework bridge once only. Creating it again
            // for the same connection restarts its initialization sequence.
            finishATIDPeripheralConnection(peripheral)

            pendingBluetoothIdentifier = peripheral.identifier
            DispatchQueue.main.async {
                self.updateScannerControls()
                self.mDeviceTableView.reloadData()
            }
            #else
            print("❌ EARfidFramework is not linked to this target.")
            #endif
            return
        }

        // Existing reader connection remains unchanged.
        if peripheral == self.bluetoothService?.peripheral {
            prevPeripheral = peripheral
            self.bluetoothService?.reset()
            peripheral.delegate = self
            peripheral.discoverServices([
                self.bluetoothService?.R5000_SERVICE,
                self.bluetoothService?.R800_3000_SERVICE,
                self.bluetoothService?.R800_3000_TSERVICE
            ].compactMap { $0 })
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        print("❌ Bluetooth connection failed =", error?.localizedDescription ?? "Unknown error")
        deviceConnectionTimeout?.cancel()
        deviceConnectionTimeout = nil
        pendingBluetoothIdentifier = nil

        if peripheral == bluetoothService?.peripheral {
            bluetoothService?.peripheral = nil
        }

        DispatchQueue.main.async {
            self.updateScannerControls()
            self.mDeviceTableView.reloadData()
            CommonClass.showSnackBar(message: "Unable to connect to device")
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if isATIDPeripheral(peripheral) {
            print("🔴 ATID disconnected =", peripheral.name ?? "Unknown")

            if atidPeripheral?.identifier == peripheral.identifier {
                atidInventoryRunning = false
                isATIDDisconnecting = false

                #if !targetEnvironment(simulator) && canImport(EARfidFramework)
                atidReader = nil
                atidReaderReady = false
                atidDevice = nil
                #endif

                atidPeripheral = nil
                pendingBluetoothIdentifier = nil
            }

            DispatchQueue.main.async {
                self.updateScannerControls()
                self.mDeviceTableView.reloadData()
            }
            return
        }

        if peripheral == self.bluetoothService?.peripheral {
            self.bluetoothService?.peripheral = nil
        }

        deviceConnectionTimeout?.cancel()
        deviceConnectionTimeout = nil
        pendingBluetoothIdentifier = nil
        DispatchQueue.main.async {
            self.updateScannerControls()
            self.mDeviceTableView.reloadData()
        }
    }

    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services,
           let bluetoothService = self.bluetoothService,
           peripheral == self.bluetoothService?.peripheral {
            
            if let r5000Service = services.first(where: { $0.uuid == bluetoothService.R5000_SERVICE }) {

                peripheral.discoverCharacteristics([bluetoothService.R5000_RX, bluetoothService.R5000_TX], for: r5000Service)
                
            } else {
                for service in services {

                    if service.uuid == bluetoothService.R5000_SERVICE ||
                        service.uuid == bluetoothService.R800_3000_SERVICE ||
                        service.uuid == bluetoothService.R800_3000_TSERVICE {

                        //Now kick off discovery of characteristics
                        peripheral.discoverCharacteristics(nil, for: service)
                        
                    }
                }
            }
        }
    }

    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let characteristics = service.characteristics, peripheral == self.bluetoothService?.peripheral {
            for characteristic in characteristics {
               
                completeConnect()
                
                if characteristic.properties.contains(.notify) {
                  
                    self.bluetoothService?.readCharacteristic = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                    if bluetoothService?.writeCharacteristic != nil {
                        completeConnect()
                    }
                } else {
                    self.bluetoothService?.readCharacteristic = nil
                }
                
                if (characteristic.uuid == self.bluetoothService?.R5000_TX && service.uuid == self.bluetoothService?.R5000_SERVICE) || (characteristic.uuid == self.bluetoothService?.R800_3000_TX && service.uuid == self.bluetoothService?.R800_3000_TSERVICE) {
                    if characteristic.properties.contains(.notify) {
                        
                        self.bluetoothService?.readCharacteristic = characteristic
                        peripheral.setNotifyValue(true, for: characteristic)
                        if bluetoothService?.writeCharacteristic != nil {
                            completeConnect()
                        }
                    } else {
                        self.bluetoothService?.readCharacteristic = nil
                    }
                } else if (characteristic.uuid == self.bluetoothService?.R5000_RX && service.uuid == self.bluetoothService?.R5000_SERVICE) || (characteristic.uuid == self.bluetoothService?.R800_3000_RX && service.uuid == self.bluetoothService?.R800_3000_SERVICE) {
                    if characteristic.properties.contains(.write) ||  characteristic.properties.contains(.writeWithoutResponse) {
                       
                        self.bluetoothService?.writeCharacteristic = characteristic
                        if bluetoothService?.readCharacteristic != nil {
                            completeConnect()
                        }
                    } else {
                        self.bluetoothService?.writeCharacteristic = nil
                    }
                    
                }
            }
            
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Error Writing... \(error?.localizedDescription ?? "")")
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("Error Writing : \(error?.localizedDescription ?? "")")
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let val = characteristic.value, let str = String(data: val, encoding: .utf8) {

        }
        
        switch characteristic.uuid {
        case self.bluetoothService?.R5000_TX:
            if characteristic.service?.uuid == self.bluetoothService?.R5000_SERVICE {
                self.bluetoothService?.pushPacket(data: characteristic.value)
            }
            break
        case self.bluetoothService?.R800_3000_TX2:
            
            if characteristic.service?.uuid == self.bluetoothService?.R800_3000_TSERVICE {
                self.bluetoothService?.pushPacket(data: characteristic.value)
                
            }
            break
        default:
            print("didUpdateValues: " + characteristic.uuid.uuidString + characteristic.description)
        }
        
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let val = characteristic.value, let str = String(data: val, encoding: .utf8) {

        }
        switch characteristic.uuid {
        case self.bluetoothService?.R5000_TX:
            if characteristic.service?.uuid == self.bluetoothService?.R5000_SERVICE {
                self.bluetoothService?.pushPacket(data: characteristic.value)
            }
            break
        case self.bluetoothService?.R800_3000_TX:
            if characteristic.service?.uuid == self.bluetoothService?.R800_3000_TSERVICE {
                self.bluetoothService?.pushPacket(data: characteristic.value)
            }
            break
        default:
            print("didUpdateNotificationStateFor: " + characteristic.uuid.uuidString + characteristic.description)
        }
    }
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if collectionView == self.mItemCollectionView {
            count = mItemsData.count
            
        }else if collectionView == self.mCollectCollectionView {
            count = mCollectionData.count
            
            
        }else if collectionView == self.mMetalCollectionView {
            count = mMetalsData.count
            
        }else if collectionView == self.mLocationCollectionView {
            count = mLocationsData.count
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        if collectionView == self.mItemCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? ItemCell else {
                return UICollectionViewCell()
            }
            
            if let mData = mItemsData[indexPath.row] as? NSDictionary {
                
                cells.mItemName.text = mData.value(forKey: "name") as? String
                if let mItemsDataId = mData.value(forKey: "_id") as? String {
                    cells.mItemName.backgroundColor = mItemsId.contains(mItemsDataId) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor = mItemsId.contains(mItemsDataId) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
            }
            cells.layoutSubviews()
            cell = cells
        } else if collectionView == self.mCollectCollectionView {
            
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionCell else {
                return UICollectionViewCell()
            }
            
            if let mData = mCollectionData[indexPath.row] as? NSDictionary {
                
                cells.mCollectionName.text = mData.value(forKey: "name") as? String
                if let mCollectionDataId = mData.value(forKey: "_id") as? String {
                    cells.mCollectionName.backgroundColor = mCollectionId.contains(mCollectionDataId) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor = mCollectionId.contains(mCollectionDataId) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
            
            }
            cells.layoutSubviews()
            cell = cells
            
        } else if collectionView == self.mMetalCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "MetalCell", for: indexPath) as? MetalCell else {
                return UICollectionViewCell()
            }
            
            if let mData = mMetalsData[indexPath.row] as? NSDictionary {
                cells.mMetalName.text = mData.value(forKey: "name") as? String
                if let mMetalsDataId = mData.value(forKey: "_id") as? String {
                    cells.mMetalName.backgroundColor = mMetalsId.contains(mMetalsDataId) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor = mMetalsId.contains(mMetalsDataId) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
                
            }
            cells.layoutSubviews()
            cell = cells
            
        } else if collectionView == self.mLocationCollectionView {
            guard let cells = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationCell", for: indexPath) as? LocationCell else {
                return UICollectionViewCell()
            }
            
            if let mData = mLocationsData[indexPath.row] as? NSDictionary {
                cells.mLocationName.text = mData.value(forKey: "name") as? String
                
                if let mLocationDataId = mData.value(forKey: "_id") as? String {
                    cells.mLocationName.backgroundColor = mLocationsId.contains(mLocationDataId) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                    cells.backgroundColor = mLocationsId.contains(mLocationDataId) ? #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1) : #colorLiteral(red: 0.8078431373, green: 0.9333333333, blue: 0.9254901961, alpha: 1)
                }
               
            }
            cells.layoutSubviews()
            cell = cells
            
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.mLocationCollectionView {
            
            if let mData = mLocationsData[indexPath.row] as? NSDictionary {
                if let mLocationsDataId = mData.value(forKey: "id") as? String {
                    if mLocationsId.contains(mLocationsDataId) {
                        mLocationsId = mLocationsId.filter {$0 != mLocationsDataId }
                    }else{
                        mLocationsId.append(mLocationsDataId)
                    }
                }
                
            }
            self.mLocationCollectionView.reloadData()
            
        }
        
        if collectionView == self.mMetalCollectionView {
            
            if let mData = mMetalsData[indexPath.row] as? NSDictionary {
                if let mMetalsDataId = mData.value(forKey: "id") as? String {
                    if mMetalsId.contains(mMetalsDataId) {
                        mMetalsId = mMetalsId.filter {$0 != mMetalsDataId }
                    }else{
                        mMetalsId.append(mMetalsDataId)
                    }
                }
            }
            self.mMetalCollectionView.reloadData()
            
        }
        
        if collectionView == self.mItemCollectionView {
            
            if let mData = mItemsData[indexPath.row] as? NSDictionary {
                if let mItemsDataId = mData.value(forKey: "id") as? String {
                    if mItemsId.contains(mItemsDataId) {
                        mItemsId = mItemsId.filter {$0 != mItemsDataId }
                    }else{
                        mItemsId.append(mItemsDataId)
                    }
                }
            }
            self.mItemCollectionView.reloadData()
            
        }
        if collectionView == self.mCollectCollectionView {
            
            if let mData = mCollectionData[indexPath.row] as? NSDictionary {
                if let mCollectionDataId = mData.value(forKey: "id") as? String {
                    if mCollectionId.contains(mCollectionDataId) {
                        mCollectionId = mCollectionId.filter {$0 != mCollectionDataId }
                    }else{
                        mCollectionId.append(mCollectionDataId)
                    }
                }
            }
            self.mCollectCollectionView.reloadData()
        }
   
    }

    
    @IBAction func mClearAllFilters(_ sender: Any) {
        
        self.mItemsId.removeAll()
        self.mCollectionId.removeAll()
        self.mMetalsId.removeAll()
        self.mStonesId.removeAll()
        self.mLocationsId.removeAll()
        self.mSizeId.removeAll()
        self.mItemCollectionView.reloadData()
        self.mCollectCollectionView.reloadData()
        self.mMetalCollectionView.reloadData()

        self.mLocationCollectionView.reloadData()

        
        self.mScannedStocks.text = "0"
        self.mUnscannedStocks.text = "0"
        self.mConflictStocks.text = "0"
        self.mSCANNED = NSMutableArray()
        self.mUNSCANNED = NSMutableArray()
        self.mCONFLICT = [String]()
        self.mUnknownStocks.text = "0"
        
        self.mScannedData = [String]()
        self.mScannedSKU = [String]()
        self.mScannedCount = [Int]()
        self.mUnscannedData = [String]()
        self.mConflictData = [String]()
        self.mInventoryData = NSArray()
        self.mStatusData = NSMutableArray()
        self.mSCANNED = NSMutableArray()
        self.mUNSCANNED = NSMutableArray()
        
        self.mSAVESCANNED = NSMutableArray()
        self.mSAVEUNSCANNED = NSMutableArray()
        self.mCONFLICT = [String]()
        self.FINALCONFLICT = [String]()
        
        mGetInventoryDataStock(key:  "")
        
    }
    
    @IBAction func mSelectAllItems(_ sender: UIButton) {
        
        if sender.isSelected {
            sender.isSelected = false
            
            sender.setTitle("Select All".localizedString, for: .normal)
            mItemsId.removeAll()
            
            mItemCollectionView.reloadData()
            
        }else{
            
            sender.isSelected = true
            mItemsId.removeAll()
            
            for (index, _) in self.mItemsData.enumerated(){
                if let mData = mItemsData[index] as? NSDictionary, let id = mData.value(forKey: "_id") as? String {
                    mItemsId.append(id)
                }
            }
            sender.setTitle("Deselect".localizedString, for: .normal)
            mItemCollectionView.reloadData()
            
        }
    }

    @IBAction func mSelectAllCollection(_ sender: UIButton) {
        
        
        if sender.isSelected {
            sender.isSelected = false
            
            sender.setTitle("Select All".localizedString, for: .normal)
            mCollectionId.removeAll()
            
            mCollectCollectionView.reloadData()
            
        }else{
            sender.setTitle("Deselect".localizedString, for: .normal)
            sender.isSelected = true
            mCollectionId.removeAll()
            
            
            for (index, _) in self.mCollectionData.enumerated(){
                if let mData = mCollectionData[index] as? NSDictionary, let id = mData.value(forKey: "id") as? String {
                    mCollectionId.append(id)
                }
            }
            mCollectCollectionView.reloadData()
            
        }
    }
  
    
    @IBAction func mSelectAllMetals(_ sender: UIButton) {
        
        
        if sender.isSelected {
            sender.isSelected = false
            
            sender.setTitle("Select All".localizedString, for: .normal)
            mMetalsId.removeAll()
            
            mMetalCollectionView.reloadData()
            
        }else{
            sender.setTitle("Deselect".localizedString, for: .normal)
            sender.isSelected = true
            mMetalsId.removeAll()
            
            
            for (index, _) in self.mMetalsData.enumerated(){
                
                if let mData = mMetalsData[index] as? NSDictionary, let id = mData.value(forKey: "id") as? String {
                    mMetalsId.append(id)
                }
            }
            mMetalCollectionView.reloadData()
            
        }
    }
    
    @IBAction func mSelectAllLocation(_ sender: UIButton) {
        
        
        if sender.isSelected {
            sender.isSelected = false
            
            sender.setTitle("Select All".localizedString, for: .normal)
            mLocationsId.removeAll()
            
            mLocationCollectionView.reloadData()
            
        }else{
            
            sender.isSelected = true
            sender.setTitle("Deselect".localizedString, for: .normal)
            mLocationsId.removeAll()
            
            
            for (index, _) in self.mLocationsData.enumerated(){
                if let mData = mLocationsData[index] as? NSDictionary, let id = mData.value(forKey: "id") as? String {
                    mLocationsId.append(id)
                }
            }
            mLocationCollectionView.reloadData()
            
        }
    }

    @IBAction func mSaveData(_ sender: Any) {
        
    }
    
    @IBAction func mSearchStock(_ sender: UITextField) {
        
    }
    
//    func mGetScanResults() {
//        print("mGetScanResults")
//        var isUnknown = true
//        for i in mStatusData {
//            if let mValue = i as? NSMutableDictionary,
//               let sku = mValue.value(forKey: "SKU") as? String,
//               let stockID = mValue.value(forKey: "stock_id") as? String,
//               let poQtyString = mValue.value(forKey: "po_QTY") as? String,
//               let poQty = Int(poQtyString) {
//
//                let searchKey = mSearchStock.text
//                print("mGetScanResults searchKey: \(searchKey ?? "") == sku: \(sku) || searchKey: \(searchKey ?? "") == stockID: \(stockID)")
//                if searchKey == sku || searchKey == stockID {
//                    // Manual/Search duplicate -> Conflict.
//                    // MANUAL is a display-only marker; API payload stays unchanged.
//                    if mScannedData.contains(stockID) {
//                        print("⚠️ MANUAL CONFLICT =", stockID)
//
//                        let manualConflictKey = "\(stockID)|MANUAL"
//                        if !mCONFLICT.contains(where: {
//                            $0.replacingOccurrences(of: "|MANUAL", with: "") == stockID
//                        }) {
//                            mCONFLICT.append(manualConflictKey)
//
//                            let conflictItem = NSMutableDictionary()
//                            conflictItem["SKU"] = sku
//                            conflictItem["stock_id"] = stockID
//                            conflictItem["po_QTY"] = "\(poQty)"
//                            conflictItem["_id"] = "\(mValue.value(forKey: "_id") ?? "")"
//                            conflictItem["location_id"] = "\(mValue.value(forKey: "location_id") ?? "")"
//                            mCONFLICTARRAY.add(conflictItem)
//                        }
//
//                        isUnknown = false
//                        continue
//                    }
//
//                    if !mScannedData.contains(stockID) {
//                        mScannedData.append(stockID)
//                        mScannedCount.append(poQty)
//                        let items = uniqueElementsFrom(array: mScannedData)
//                        mScannedData = items
//                        mScannedStocks.text = "\(mScannedCount.reduce(0, {$0 + $1}))"
//                        let mUnsCount = (Int(mTotalStocks.text ?? "0") ?? 0) - (Int(mScannedStocks.text ?? "0") ?? 0)
//                        mUnscannedStocks.text = "\(mUnsCount)"
//                        mSCANNED.add(mValue)
//
//                        let mData = NSMutableDictionary()
//                        mData.setValue(stockID, forKey: "stock_id")
//                        mData.setValue(poQty, forKey: "po_QTY")
////                        if let productDetails = mData["product_details"] as? NSDictionary {
////
////                            mData.setValue(
////                                "\(productDetails["po_QTY"] ?? "0")",
////                                forKey: "po_QTY"
////                            )
////
////                        } else {
////
////                            mData.setValue(
////                                "\(mData["po_QTY"] ?? "0")",
////                                forKey: "po_QTY"
////                            )
////                        }
//                        mData.setValue(sku, forKey: "SKU")
//                        mData.setValue("\(mValue.value(forKey: "_id") ?? "")", forKey: "_id")
//                        mData.setValue("\(mValue.value(forKey: "location_id") ?? "")", forKey: "location_id")
//
//                        mSAVESCANNED.add(mData)
//                    }
//                    isUnknown = false
//                }
//            }
//        }
//
//        if isUnknown {
//
//            let mUnknowdNewData = NSMutableDictionary()
//            mUnknowdNewData.setValue(mSearchStock.text ?? "", forKey: "SKU")
//            mUnknowdNewData.setValue(mSearchStock.text ?? "", forKey: "stock_id")
//            mUnknowdNewData.setValue("", forKey: "po_QTY")
//            mUnknowdNewData.setValue("", forKey: "_id")
//            mUnknowdNewData.setValue("", forKey: "location_id")
//            self.mUNKNOWNARRAY.add(mUnknowdNewData)
//
//            // Manual/Search unknown -> show stocktake_ic_manualadd.
//            let manualUnknownKey = "\(mSearchStock.text ?? "")UKN|MANUAL"
//            if !mCONFLICT.contains(where: {
//                $0.replacingOccurrences(of: "|MANUAL", with: "") == "\(mSearchStock.text ?? "")UKN"
//            }) {
//                mCONFLICT.append(manualUnknownKey)
//            }
//            let items = uniqueElementsFrom(array: mCONFLICT)
//            mCONFLICT = items
//
//        }
//
//        mStatus()
//
//    }
    
    func mGetScanResults(searchText: String? = nil, showPopup: Bool = true) {
        print("mGetScanResults")

        // Use the explicit scan value when this call comes from the camera.
        // Otherwise use the text entered by the user in the Search field.
        let rawSearchText = searchText ?? mSearchStock.text ?? ""
        let searchKey = normalizedStockLookupKey(rawSearchText)
        guard !searchKey.isEmpty else { return }

        // A conflict is reserved exclusively for stock returned by sold_data.
        // Check this first because sold stock is not part of the active
        // inventory list and therefore cannot be found through stockMap.
        if let soldItem = soldStockItem(for: searchKey) {
            recordSoldConflict(soldItem, lookupKey: searchKey, source: "manual")

            if showPopup {
                showManualStockTakeResult(
                    .conflictWithStockID(
                        sku: "\(soldItem["SKU"] ?? searchKey)",
                        stockID: "\(soldItem["stock_id"] ?? searchKey)"
                    )
                )
            }
            return
        }

        for rawItem in mInventoryData {
            guard let item = rawItem as? NSDictionary else { continue }

            let sku = "\(item["SKU"] ?? "")"
            let stockID = "\(item["stock_id"] ?? "")"

            guard searchKey == normalizedStockLookupKey(sku)
                    || searchKey == normalizedStockLookupKey(stockID) else {
                continue
            }

            let poQty = numericValue(item["po_QTY"] ?? item["qty"] ?? item["quantity"])

            // A repeated scan is ignored. It must not become a Conflict.
            if mScannedData.contains(stockID) {
                return
            }

            // Scan Found.
            mScannedData.append(stockID)
            mScannedCount.append(Int(poQty))
            mScannedData = uniqueElementsFrom(array: mScannedData)

            let scannedDisplayData = NSMutableDictionary(dictionary: item)
            scannedDisplayData.setValue("manual", forKey: "scan_source")
            mSCANNED.add(scannedDisplayData)

            let saveData = NSMutableDictionary()
            saveData.setValue(stockID, forKey: "stock_id")
            saveData.setValue(Int(poQty), forKey: "po_QTY")
            saveData.setValue(sku, forKey: "SKU")
            saveData.setValue("\(item["_id"] ?? "")", forKey: "_id")
            saveData.setValue("\(item["location_id"] ?? "")", forKey: "location_id")
            if let weight = item["weight"] {
                saveData.setValue(weight, forKey: "weight")
            }
            saveData.setValue("manual", forKey: "scan_source")
            mSAVESCANNED.add(saveData)

            mStatus()

            if showPopup {
                let imageURL = ["main_image", "images", "image"]
                    .compactMap { key -> String? in
                        guard let value = item[key] as? String, !value.isEmpty else { return nil }
                        return value
                    }
                    .first

                showManualStockTakeResult(
                    .correct(
                        sku: sku.isEmpty ? searchKey : sku,
                        stockID: stockID,
                        imageURL: imageURL
                    )
                )
            }
            return
        }

        // The item is not known by the current Stock Take data. Keep the
        // physical value as the stock ID, but deliberately leave SKU empty:
        // an Unknown item has no reliable SKU. This lets the API distinguish
        // it from a sold Conflict, which always carries the known SKU.
        recordUnknownStock(stockID: searchKey, source: "manual")

        if showPopup {
            showManualStockTakeResult(.noData(code: searchKey))
        }
    }

    private func showManualStockTakeResult(_ result: CommonScannerScanResult) {
        manualResultPopupToken = UUID()
        let token = manualResultPopupToken

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.manualResultPopupView?.removeFromSuperview()
            self.manualResultPopupView = nil

            guard let windowScene = self.view.window?.windowScene ??
                    UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first(where: { $0.activationState == .foregroundActive }),
                  let window = windowScene.windows.first(where: { $0.isKeyWindow })
            else {
                return
            }

            let popup = UIView()
            popup.translatesAutoresizingMaskIntoConstraints = false
            popup.backgroundColor = .white
            popup.layer.cornerRadius = 8
            popup.layer.masksToBounds = false

            // Figma: X 0 / Y 4 / Blur 10 / Spread 0 / rgba(79,79,79,0.10)
            popup.layer.shadowColor = UIColor(red: 79/255, green: 79/255, blue: 79/255, alpha: 1).cgColor
            popup.layer.shadowOpacity = 0.10
            popup.layer.shadowRadius = 5
            popup.layer.shadowOffset = CGSize(width: 0, height: 4)

            window.addSubview(popup)
            self.manualResultPopupView = popup

            let horizontalPadding: CGFloat = 12
            let iconSize: CGFloat = 16
            let gap: CGFloat = 8

            let skuFont = UIFont.systemFont(ofSize: 12, weight: .regular)
            let stockFont = UIFont.systemFont(ofSize: 12, weight: .regular)
            let separatorFont = UIFont.systemFont(ofSize: 12, weight: .regular)

            func makeTextWidth(_ text: String, font: UIFont) -> CGFloat {
                return (text as NSString).size(withAttributes: [.font: font]).width
            }

            func addInlineResult(iconName: String, sku: String, stockID: String) {
                let iconView = UIImageView(image: UIImage(named: iconName))
                iconView.translatesAutoresizingMaskIntoConstraints = false
                iconView.contentMode = .scaleAspectFit
                popup.addSubview(iconView)

                let skuLabel = UILabel()
                skuLabel.translatesAutoresizingMaskIntoConstraints = false
                skuLabel.text = sku
                skuLabel.textColor = UIColor(hex: "#222222")
                skuLabel.font = skuFont
                skuLabel.numberOfLines = 1
                skuLabel.lineBreakMode = .byClipping
                skuLabel.adjustsFontSizeToFitWidth = true
                skuLabel.minimumScaleFactor = 0.65
                skuLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
                popup.addSubview(skuLabel)

                let separator = UILabel()
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.text = "·"
                separator.textColor = UIColor(hex: "#A0A0A0")
                separator.font = separatorFont
                separator.textAlignment = .center
                popup.addSubview(separator)

                let stockLabel = UILabel()
                stockLabel.translatesAutoresizingMaskIntoConstraints = false
                stockLabel.text = stockID
                stockLabel.textColor = UIColor(hex: "#777777")
                stockLabel.font = stockFont
                stockLabel.numberOfLines = 1
                stockLabel.lineBreakMode = .byClipping
                stockLabel.adjustsFontSizeToFitWidth = true
                stockLabel.minimumScaleFactor = 0.65
                stockLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
                popup.addSubview(stockLabel)

                NSLayoutConstraint.activate([
                    iconView.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: horizontalPadding),
                    iconView.centerYAnchor.constraint(equalTo: popup.centerYAnchor),
                    iconView.widthAnchor.constraint(equalToConstant: iconSize),
                    iconView.heightAnchor.constraint(equalToConstant: iconSize),

                    skuLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: gap),
                    skuLabel.centerYAnchor.constraint(equalTo: popup.centerYAnchor),

                    separator.leadingAnchor.constraint(equalTo: skuLabel.trailingAnchor, constant: 7),
                    separator.centerYAnchor.constraint(equalTo: popup.centerYAnchor),
                    separator.widthAnchor.constraint(equalToConstant: 8),

                    stockLabel.leadingAnchor.constraint(equalTo: separator.trailingAnchor, constant: 7),
                    stockLabel.centerYAnchor.constraint(equalTo: popup.centerYAnchor),
                    stockLabel.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -horizontalPadding)
                ])

                // Hug the content, capped only by the screen width.
                let contentWidth =
                    horizontalPadding * 2 +
                    iconSize + gap +
                    makeTextWidth(sku, font: skuFont) +
                    7 + 8 + 7 +
                    makeTextWidth(stockID, font: stockFont)

                // Give the labels their full intrinsic width whenever the
                // complete text fits on screen. UILabel is explicitly set to
                // .byClipping above, so it can never replace text with "…".
                let availableWidth = max(0, window.bounds.width - 32)
                let totalWidth = min(contentWidth + 1, availableWidth)

                NSLayoutConstraint.activate([
                    popup.widthAnchor.constraint(equalToConstant: totalWidth),
                    popup.heightAnchor.constraint(equalToConstant: 32),
                    popup.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                    popup.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 8)
                ])
            }

            switch result {
            case let .correct(sku, stockID, _):
                addInlineResult(
                    iconName: "stocktake_ic_scan",
                    sku: sku,
                    stockID: stockID
                )

            case let .conflictWithStockID(sku, stockID):
                addInlineResult(
                    iconName: "stocktake_ic_conflict",
                    sku: sku,
                    stockID: stockID
                )

            case let .conflict(code):
                let iconView = UIImageView(image: UIImage(named: "stocktake_ic_conflict"))
                iconView.translatesAutoresizingMaskIntoConstraints = false
                iconView.contentMode = .scaleAspectFit
                popup.addSubview(iconView)

                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = code
                label.textColor = UIColor(hex: "#777777")
                label.font = stockFont
                label.lineBreakMode = .byClipping
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.70
                label.setContentCompressionResistancePriority(.required, for: .horizontal)
                popup.addSubview(label)

                let width = horizontalPadding * 2 + iconSize + gap + makeTextWidth(code, font: stockFont)

                NSLayoutConstraint.activate([
                    popup.widthAnchor.constraint(
                        equalToConstant: min(max(width, 120), window.bounds.width - 32)
                    ),
                    popup.heightAnchor.constraint(equalToConstant: 32),
                    popup.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                    popup.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 8),

                    iconView.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: horizontalPadding),
                    iconView.centerYAnchor.constraint(equalTo: popup.centerYAnchor),
                    iconView.widthAnchor.constraint(equalToConstant: iconSize),
                    iconView.heightAnchor.constraint(equalToConstant: iconSize),

                    label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: gap),
                    label.centerYAnchor.constraint(equalTo: popup.centerYAnchor),
                    label.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -horizontalPadding)
                ])

            case .noData:
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = "No search results found"
                label.textColor = UIColor(hex: "#333333")
                label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                label.textAlignment = .center
                label.numberOfLines = 1
                label.lineBreakMode = .byClipping
                label.adjustsFontSizeToFitWidth = false
                popup.addSubview(label)

                // Keep the complete message visible.
                // Do not use a fixed 150pt width because it clips the last
                // characters on smaller iPhones.
                let message = "No search results found"
                let messageWidth = (message as NSString).size(
                    withAttributes: [.font: label.font as Any]
                ).width
                let popupWidth = min(
                    messageWidth + (horizontalPadding * 2),
                    window.bounds.width - 32
                )

                NSLayoutConstraint.activate([
                    popup.widthAnchor.constraint(equalToConstant: popupWidth),
                    popup.heightAnchor.constraint(equalToConstant: 32),
                    popup.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                    popup.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 8),

                    label.leadingAnchor.constraint(equalTo: popup.leadingAnchor, constant: horizontalPadding),
                    label.trailingAnchor.constraint(equalTo: popup.trailingAnchor, constant: -horizontalPadding),
                    label.centerYAnchor.constraint(equalTo: popup.centerYAnchor)
                ])
            }

            window.bringSubviewToFront(popup)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self, weak popup] in
                guard let self = self,
                      self.manualResultPopupToken == token,
                      let popup = popup else { return }

                UIView.animate(withDuration: 0.15, animations: {
                    popup.alpha = 0
                }, completion: { _ in
                    guard self.manualResultPopupToken == token else { return }
                    popup.removeFromSuperview()
                    if self.manualResultPopupView === popup {
                        self.manualResultPopupView = nil
                    }
                })
            }
        }
    }

    func getRFIDData(data: String) {

        // FINAL SAFETY NET:
        // Never compare the RAW Zebra encoded value with stock_id/SKU.
        // Decode first, then normalize, then lookup.
        let decodedData = decodeZebraStockScanValue(data)
        let lookupKey = normalizedStockLookupKey(decodedData)

        print("========== STOCK TAKE LOOKUP ==========")
        print("RAW     =", data)
        print("DECODED =", decodedData)
        print("LOOKUP  =", lookupKey)
        print("=======================================")

        guard !lookupKey.isEmpty else { return }

        // Conflict has one source of truth: sold_data from the Stock Take API.
        if let soldItem = soldStockItem(for: lookupKey) {
            recordSoldConflict(soldItem, lookupKey: lookupKey, source: "rfid")
            showManualStockTakeResult(
                .conflictWithStockID(
                    sku: "\(soldItem["SKU"] ?? lookupKey)",
                    stockID: "\(soldItem["stock_id"] ?? lookupKey)"
                )
            )
            return
        }

        // O(1) lookup. The map contains stock_id/SKU plus any RFID/EPC aliases.
        guard let item = stockMap[lookupKey] else {

            print("UNKNOWN RFID =", lookupKey)
            recordUnknownStock(stockID: lookupKey, source: "rfid")
            // RFID Unknown -> Popup เดียวกับ Manual Search
            showManualStockTakeResult(.noData(code: lookupKey))
            return
        }

        let stockID = "\(item["stock_id"] ?? "")"
        let sku = "\(item["SKU"] ?? "")"
        let poQty = Int("\(item["po_QTY"] ?? "0")") ?? 0

        print("========== RFID MATCH ==========")
        print("Searching =", data)
        print("SKU =", sku)
        print("stockID =", stockID)
        print("===============================")
        // A repeated scan is ignored. Only a sold item may be a Conflict.
        if mScannedData.contains(stockID) {
            return
        }
        if !mScannedData.contains(stockID) {

            print("Append Stock =", stockID)

            mScannedData.append(stockID)
            mScannedCount.append(poQty)

            mScannedData = uniqueElementsFrom(array: mScannedData)

            mScannedStocks.text = "\(mScannedCount.reduce(0, +))"

            let total = Int(mTotalStocks.text ?? "0") ?? 0
            let scanned = Int(mScannedStocks.text ?? "0") ?? 0

            mUnscannedStocks.text = "\(max(0, total - scanned))"

            let scannedItem = NSMutableDictionary()

            scannedItem["SKU"] = sku
            scannedItem["stock_id"] = stockID
            scannedItem["po_QTY"] = "\(poQty)"
            scannedItem["_id"] = "\(item["_id"] ?? "")"
            scannedItem["location_id"] = "\(item["location_id"] ?? "")"
            if let weight = item["weight"] {
                scannedItem["weight"] = weight
            }

            mSCANNED.add(scannedItem)
            mSAVESCANNED.add(scannedItem)

            print("Scanned =", mScannedData.count)
        }

        mPowerView.isHidden = true
        mPowerIcon.image = UIImage(named: "power_icgrey")
        mPowerLabel?.textColor = UIColor(named: "theme6A")

        mStatus()

        // RFID Correct -> Popup เดียวกับ Manual Search
        let imageURL = ["main_image", "images", "image"]
            .compactMap { key -> String? in
                guard let value = item[key] as? String, !value.isEmpty else {
                    return nil
                }
                return value
            }
            .first

        showManualStockTakeResult(
            .correct(
                sku: sku.isEmpty ? lookupKey : sku,
                stockID: stockID,
                imageURL: imageURL
            )
        )
    }
//    func getRFIDData(data: String){
//        if !Thread.isMainThread {
//
//                DispatchQueue.main.async {
//                    self.getRFIDData(data: data)
//                }
//
//                return
//            }
//        print("getRFIDData: \(data)")
//        print("Searching =", data)
//
//        let result = mInventoryData.filter {
//            ($0 as? NSDictionary)?["stock_id"] as? String == data
//        }
//
//        print("Found =", result.count)
//        var mUnknown = true
//        for i in mStatusData {
//
//            if let mValue = i as? NSMutableDictionary {
//
//                let sku = "\(mValue.value(forKey: "SKU") ?? "")"
//                let stockID = "\(mValue.value(forKey: "stock_id") ?? "")"
//                let poQty = Int("\(mValue.value(forKey: "po_QTY") ?? "0")") ?? 0
//
//                if !data.isEmpty {
//
//                    let searchKey = data
//
//                    print("========== RFID MATCH ==========")
//                    print("Searching =", searchKey)
//                    print("Reader =", searchKey)
//                    print("SKU =", sku)
//                    print("stockID =", stockID)
//                    print("MATCH SKU =", searchKey == sku)
//                    print("MATCH STOCK =", searchKey == stockID)
//                    print("===============================")
//                    if searchKey == sku || searchKey == stockID {
//                        if !mScannedData.contains(stockID){
//                            print("Append Stock =", stockID)
//                            mScannedData.append(stockID)
//                            print("mScannedData =", mScannedData)
//                            mScannedCount.append(poQty)
//                            let items = uniqueElementsFrom(array: mScannedData)
//                            mScannedData = items
//                            mScannedStocks.text = "\(mScannedCount.reduce(0, {$0 + $1}))"
//                            let mUnsCount = (Int(mTotalStocks.text ?? "0") ?? 0) - (Int(mScannedStocks.text ?? "0") ?? 0)
//                            mUnscannedStocks.text = "\(mUnsCount)"
//                            mSCANNED.add(mValue)
//
//                            print("mScannedStocks.text = \(String(describing: mScannedStocks.text))")
//                            print("mUnscannedStocks.text = \(String(describing: mUnscannedStocks.text))")
//                            print("mScannedData = \(mScannedData)")
//                            print("mUnsCount = \(mUnsCount)")
//                            print("mValue = \(mValue)")
//                            let mData = NSMutableDictionary()
//                            mData.setValue(stockID, forKey: "stock_id")
//                            mData.setValue(poQty, forKey: "po_QTY")
//                            mData.setValue(sku, forKey: "SKU")
//                            mData.setValue("\(mValue.value(forKey: "_id") ?? "")", forKey: "_id")
//                            mData.setValue("\(mValue.value(forKey: "location_id") ?? "")", forKey: "location_id")
//
//                            mSAVESCANNED.add(mData)
//                        }
//                        mUnknown = false
//                    }else{
//
//                    }
//
//                }
//            }
//        }
//
//        if mUnknown {
//            let mUnknowdNewData = NSMutableDictionary()
//            mUnknowdNewData.setValue(mSearchStock.text ?? "", forKey: "SKU")
//            mUnknowdNewData.setValue(mSearchStock.text ?? "", forKey: "stock_id")
//            mUnknowdNewData.setValue("", forKey: "po_QTY")
//            mUnknowdNewData.setValue("", forKey: "_id")
//            mUnknowdNewData.setValue("", forKey: "location_id")
//            self.mUNKNOWNARRAY.add(mUnknowdNewData)
//
//
//            mCONFLICT.append(mSearchStock.text ?? "" + "UKN")
//            let items = uniqueElementsFrom(array: mCONFLICT)
//            mCONFLICT = items
//        }
//
//
//        mPowerView.isHidden = true
//        mPowerIcon.image = UIImage(named: "power_icgrey")
//        mPowerLabel.textColor =  UIColor(named: "theme6A")
//        mStatus()
//    }
    
    func mStatus() {
        print("mStatus Main =", Thread.isMainThread)

        mUNSCANNED = NSMutableArray()
        mSAVEUNSCANNED = NSMutableArray()

        var mCONF = [String]()
        var mUNK = [String]()

        FINALCONFLICT.removeAll()

        if mCONFLICT.count > 0 {

            for i in 0..<mCONFLICT.count {

                FINALCONFLICT.append(
                    mCONFLICT[i].trimmingCharacters(
                        in: CharacterSet(charactersIn: "0123456789").inverted
                    )
                )

                FINALCONFLICT = uniqueElementsFrom(array: FINALCONFLICT)

                if mCONFLICT[i].contains("UKN") {
                    mUNK.append(mCONFLICT[i])
                } else {
                    mCONF.append(mCONFLICT[i])
                }
            }
        }

        mConflictStocks.text = "\(mCONF.count)"
        mUnknownStocks.text = "\(mUNK.count)"

        //----------------------------------------------------
        // Build UNSCANNED LIST ONLY
        //----------------------------------------------------

        for i in mStatusData {

            guard let mValue = i as? NSDictionary else {
                continue
            }

            let stockID = "\(mValue.value(forKey: "stock_id") ?? "")"

            if !mScannedData.contains(stockID) {

                let mData = NSMutableDictionary()

                mData.setValue(stockID, forKey: "stock_id")
                mData.setValue(mValue.value(forKey: "po_QTY"), forKey: "po_QTY")
                mData.setValue(mValue.value(forKey: "SKU") ?? "", forKey: "SKU")
                mData.setValue(mValue.value(forKey: "_id") ?? "", forKey: "_id")
                mData.setValue(mValue.value(forKey: "location_id") ?? "", forKey: "location_id")
                if let weight = mValue.value(forKey: "weight") {
                    mData.setValue(weight, forKey: "weight")
                }

                mUNSCANNED.add(mValue)
                mSAVEUNSCANNED.add(mData)
            }
        }

        //----------------------------------------------------
        // Update Summary
        //----------------------------------------------------

        mScannedStocks.text = "\(mScannedCount.reduce(0,+))"

        let total = Int(mTotalStocks.text ?? "0") ?? 0
        let scanned = Int(mScannedStocks.text ?? "0") ?? 0

        mUnscannedStocks.text = "\(max(total - scanned, 0))"

        print("========== STATUS ==========")
        print("Total =", total)
        print("Scanned =", scanned)
        print("Unscanned =", max(total - scanned, 0))
        print("ScannedData =", mScannedData)
        print("============================")
        updateReferenceSummaryCards()
    }
//    func mStatus(){
//        mUNSCANNED = NSMutableArray()
//        mSAVEUNSCANNED = NSMutableArray()
//
//        var mCONF = [String]()
//        var mUNK = [String]()
//
//
//        if mCONFLICT.count > 0 {
//            for i in 0...mCONFLICT.count - 1 {
//
//                FINALCONFLICT.append(mCONFLICT[i].trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted))
//                let items = uniqueElementsFrom(array: FINALCONFLICT)
//                FINALCONFLICT = items
//                if mCONFLICT[i].contains("UKN") {
//                    mUNK.append(mCONFLICT[i])
//                }else{
//                    mCONF.append(mCONFLICT[i])
//                }
//            }
//            mConflictStocks.text = "\(mCONF.count)"
//            mUnknownStocks.text = "\(mUNK.count)"
//
//        }
//
//        for i in mStatusData {
//            if let mValue = i as? NSDictionary,
//               let stockID = mValue.value(forKey: "stock_id") as? String,
//               let poQtyString = mValue.value(forKey: "po_QTY") as? String,
//               let poQty = Int(poQtyString),
//               !mScannedData.contains(stockID) {
//
//                let mData = NSMutableDictionary()
//                mData.setValue(stockID, forKey: "stock_id")
////                mData.setValue(poQty, forKey: "po_QTY")
//                mData.setValue(mValue.value(forKey: "po_QTY"), forKey: "po_QTY")
//                mData.setValue(mValue.value(forKey: "SKU") as? String ?? "", forKey: "SKU")
//                mData.setValue(mValue.value(forKey: "_id") as? String ?? "", forKey: "po_product_id")
//                mData.setValue(mValue.value(forKey: "location_id") as? String ?? "", forKey: "location_id")
////                print("mSAVEUNSCANNED mData = \(mData)")
//                print("mSAVEUNSCANNED SKU = \(mValue.value(forKey: "SKU"))")
//                print("mSAVEUNSCANNED stockID = \(stockID)")
//
//
//                if !mScannedData.contains(stockID) {
//
//                    mScannedData.append(stockID)
//
//                    mScannedCount.append(poQty)
//
//                    mScannedStocks.text = "\(mScannedCount.reduce(0,+))"
//                    print("Scanned Label =", mScannedStocks.text ?? "")
//                    let unscanned =
//                        (Int(mTotalStocks.text ?? "0") ?? 0)
//                        - (Int(mScannedStocks.text ?? "0") ?? 0)
//
//                    mUnscannedStocks.text = "\(unscanned)"
//
//                    mSCANNED.add(mValue)
//
//                    mSAVESCANNED.add(mData)
////                    mSAVEUNSCANNED.add(mData)
////                    mUNSCANNED.add(mValue)
//                }
//            }
//        }
//    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        mSearchStock.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        mSearchStock.resignFirstResponder()
        mGetScanResults()
    }
    
    @IBAction func mHideDeviceView(_ sender: Any) {
        mDeviceView.isHidden = true
        pendingZebraReaderID = nil
        pendingBluetoothIdentifier = nil
        mDeviceTableView.reloadData()
        syncReferenceOverlayVisibility()
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
    
    @IBAction func mOpenScanner(_ sender: Any) {
        mStartQRcode()
    }
    
    
    @IBAction func mStart(_ sender: UIButton) {
        // Ignore rapid repeated Play/Pause taps. This is intentionally kept
        // at the scanner entry point so both the reference Play button and
        // any existing storyboard button are protected by the same guard.
        let now = Date()
        if let blockedUntil = scannerToggleBlockedUntil, now < blockedUntil {
            print("⏳ STOCK TAKE PLAY/PAUSE IGNORED - scanner command is still settling.")
            return
        }

        scannerToggleBlockedUntil = now.addingTimeInterval(scannerToggleDebounceInterval)
        sender.isEnabled = false
        referencePlayButton?.isEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + scannerToggleDebounceInterval) { [weak self] in
            guard let self = self else { return }
            self.scannerToggleBlockedUntil = nil
            self.updateScannerControls()
        }

        if isStoppedState {
            print("⛔ STOCK TAKE PLAY DISABLED - press Clear to start a new session.")
            sender.isSelected = false
            updateScannerControls()
            return
        }

        guard isAnyRFIDConnected else {
            sender.isSelected = false
            updateScannerControls()
            return
        }

        view.endEditing(true)
        mPowerView.isHidden = true

        if isZebraRFIDConnected {
            recentRFIDReads.removeAll()

            if ZebraRFIDService.shared.isInventoryRunning {
                print("🛑 ZEBRA RFID STOP")
                ZebraRFIDService.shared.stopInventory()
                canStopAfterPause = true
                isStoppedState = false

                // Immediately refresh the footer so Stop becomes disabled/grey
                // as soon as Pause is pressed.
                self.updateScannerControls()
            } else {
                canStopAfterPause = false
                isStoppedState = false
                print("▶️ ZEBRA RFID START")
                // Start directly. startScan() currently adds a 0.5s delay,
                // which can cause Pause to be followed by an unwanted restart.
                ZebraRFIDService.shared.startInventory()

                DispatchQueue.main.async {
                    self.updateScannerControls()
                }
            }
            return
        }

        #if !targetEnvironment(simulator) && canImport(EARfidFramework)
        if isATIDRFIDConnected {
            recentRFIDReads.removeAll()

            if atidInventoryRunning {
                print("🛑 ATID RFID STOP")
                stopATIDInventory()
                canStopAfterPause = true
                isStoppedState = false
            } else {
                print("▶️ ATID RFID START")
                canStopAfterPause = false
                isStoppedState = false
                startATIDInventory()
            }

            DispatchQueue.main.async {
                self.updateScannerControls()
            }
            return
        }
        #endif

        if bluetoothService?.scannerIsRunning == 1 {
            stopRFID()
            canStopAfterPause = true
            isStoppedState = false
        } else {
            canStopAfterPause = false
            isStoppedState = false
            startRFID()
        }

        DispatchQueue.main.async {
            self.updateScannerControls()
        }
    }

    @IBAction func mScanNow(_ sender: UIButton) {
        
        if centralManager?.isScanning ?? false {
            self.mScanNowLabel.text = "Scan now".localizedString
            stopScan()
        } else {
            self.mScanNowLabel.text = "Scanning".localizedString
            search()
        }
        
    }
    
    // MARK: - Reference bottom sheets

    private func makeSheetCloseButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = UIColor(hex: "#222222")
        button.widthAnchor.constraint(equalToConstant: 28).isActive = true
        button.heightAnchor.constraint(equalToConstant: 28).isActive = true
        return button
    }

    private func hideLegacyOverlayViewsForReferenceSheet() {
        // These are storyboard-era full-screen/container views. They must stay
        // hidden while the programmatic Stock Take reference UI is displayed.
        // In particular, mDeviceView can contain the old 2x2 colored device
        // screen, which must NEVER appear behind the Device bottom sheet.
        mDeviceView?.isHidden = true
        mPowerView?.isHidden = true
        referencePowerSheet?.isHidden = true
        mSearchDeviceView?.isHidden = true
        mScannerView?.isHidden = true
        mScannerCamView?.isHidden = true
        mStartScannView?.isHidden = true
        mFilterView?.isHidden = true
    }

    private func showReferenceDeviceSheet() {
        if referenceDeviceSheet == nil {
            let sheet = UIView()
            sheet.translatesAutoresizingMaskIntoConstraints = false
            sheet.backgroundColor = .systemBackground
            sheet.layer.cornerRadius = 8
            sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            sheet.clipsToBounds = true
            view.addSubview(sheet)
            referenceDeviceSheet = sheet

            let handle = UIView()
            handle.translatesAutoresizingMaskIntoConstraints = false
            handle.backgroundColor = UIColor(hex: "#D2D2D2")
            handle.layer.cornerRadius = 2
            sheet.addSubview(handle)

            let title = UILabel()
            title.translatesAutoresizingMaskIntoConstraints = false
            title.text = "Device"
            title.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            title.textColor = UIColor(hex: "#333333")
            sheet.addSubview(title)

            let close = makeSheetCloseButton()
            close.addTarget(self, action: #selector(closeReferenceDeviceSheet), for: .touchUpInside)
            sheet.addSubview(close)

            if let table = mDeviceTableView {
                table.removeFromSuperview()
                table.translatesAutoresizingMaskIntoConstraints = false
                table.backgroundColor = .clear
                table.separatorStyle = .none
                sheet.addSubview(table)
                NSLayoutConstraint.activate([
                    table.leadingAnchor.constraint(equalTo: sheet.leadingAnchor),
                    table.trailingAnchor.constraint(equalTo: sheet.trailingAnchor),
                    table.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12),
                    table.bottomAnchor.constraint(equalTo: sheet.bottomAnchor)
                ])
            }

            // Empty state is part of the sheet itself so the icon/text stay
            // centered exactly like the reference image.
            let empty = UIView()
            empty.translatesAutoresizingMaskIntoConstraints = false
            empty.backgroundColor = .clear
            sheet.addSubview(empty)
            referenceDeviceEmptyStateView = empty

            let icon = UIImageView(
                image: UIImage(systemName: "antenna.radiowaves.left.and.right.slash")
            )
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.tintColor = UIColor(hex: "#868686")
            icon.contentMode = .scaleAspectFit
            empty.addSubview(icon)

            let message = UILabel()
            message.translatesAutoresizingMaskIntoConstraints = false
            message.text = "Device not found"
            message.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            message.textColor = UIColor(hex: "#222222")
            message.textAlignment = .center
            empty.addSubview(message)

            let subtitle = UILabel()
            subtitle.translatesAutoresizingMaskIntoConstraints = false
            subtitle.text = "Please check your connection and try again."
            subtitle.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            subtitle.textColor = UIColor(hex: "#868686")
            subtitle.textAlignment = .center
            empty.addSubview(subtitle)

            NSLayoutConstraint.activate([
                sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                sheet.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                sheet.heightAnchor.constraint(equalToConstant: 319),

                handle.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 12),
                handle.centerXAnchor.constraint(equalTo: sheet.centerXAnchor),
                handle.widthAnchor.constraint(equalToConstant: 40),
                handle.heightAnchor.constraint(equalToConstant: 4),

                title.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 16),
                title.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 34),

                close.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -16),
                close.centerYAnchor.constraint(equalTo: title.centerYAnchor),

                empty.leadingAnchor.constraint(equalTo: sheet.leadingAnchor),
                empty.trailingAnchor.constraint(equalTo: sheet.trailingAnchor),
                empty.topAnchor.constraint(equalTo: title.bottomAnchor),
                empty.bottomAnchor.constraint(equalTo: sheet.bottomAnchor),

                icon.centerXAnchor.constraint(equalTo: empty.centerXAnchor),
                icon.topAnchor.constraint(equalTo: empty.topAnchor, constant: 48),
                icon.widthAnchor.constraint(equalToConstant: 36),
                icon.heightAnchor.constraint(equalToConstant: 36),

                message.centerXAnchor.constraint(equalTo: empty.centerXAnchor),
                message.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10),
                message.leadingAnchor.constraint(greaterThanOrEqualTo: empty.leadingAnchor, constant: 20),
                message.trailingAnchor.constraint(lessThanOrEqualTo: empty.trailingAnchor, constant: -20),

                subtitle.centerXAnchor.constraint(equalTo: empty.centerXAnchor),
                subtitle.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 4),
                subtitle.leadingAnchor.constraint(greaterThanOrEqualTo: empty.leadingAnchor, constant: 20),
                subtitle.trailingAnchor.constraint(lessThanOrEqualTo: empty.trailingAnchor, constant: -20)
            ])
        }

        referenceDeviceSheet?.isHidden = false
        view.bringSubviewToFront(referenceDeviceSheet!)
        updateDeviceEmptyState()
        mDeviceTableView?.reloadData()
        syncReferenceOverlayVisibility()
    }

    @objc private func closeReferenceDeviceSheet() {
        referenceDeviceSheet?.isHidden = true
        deviceDiscoveryTimer?.invalidate()
        deviceDiscoveryTimer = nil
        syncReferenceOverlayVisibility()
        updateScannerControls()
    }

    private func showReferencePowerNoDeviceSheet() {
        if referencePowerNoDeviceSheet == nil {
            let sheet = UIView()
            sheet.translatesAutoresizingMaskIntoConstraints = false
            sheet.backgroundColor = .systemBackground
            sheet.layer.cornerRadius = 10
            sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            sheet.clipsToBounds = true
            view.addSubview(sheet)
            referencePowerNoDeviceSheet = sheet

            let handle = UIView()
            handle.translatesAutoresizingMaskIntoConstraints = false
            handle.backgroundColor = UIColor(hex: "#D2D2D2")
            handle.layer.cornerRadius = 2
            sheet.addSubview(handle)

            let title = UILabel()
            title.translatesAutoresizingMaskIntoConstraints = false
            title.text = "Power"
            title.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            title.textColor = UIColor(hex: "#333333")
            sheet.addSubview(title)

            let close = makeSheetCloseButton()
            close.addTarget(self, action: #selector(closeReferencePowerNoDeviceSheet), for: .touchUpInside)
            sheet.addSubview(close)

            let imageView = UIImageView(image: UIImage(systemName: "antenna.radiowaves.left.and.right.slash"))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.tintColor = UIColor(hex: "#868686")
            imageView.contentMode = .scaleAspectFit
            sheet.addSubview(imageView)

            let message = UILabel()
            message.translatesAutoresizingMaskIntoConstraints = false
            message.text = "No Device Connected"
            message.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            message.textColor = UIColor(hex: "#222222")
            message.textAlignment = .center
            sheet.addSubview(message)

            let subtitle = UILabel()
            subtitle.translatesAutoresizingMaskIntoConstraints = false
            subtitle.text = "Please check your connection and try again."
            subtitle.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            subtitle.textColor = UIColor(hex: "#868686")
            subtitle.textAlignment = .center
            sheet.addSubview(subtitle)

            NSLayoutConstraint.activate([
                sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                sheet.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                sheet.heightAnchor.constraint(equalToConstant: 300),
                handle.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 12),
                handle.centerXAnchor.constraint(equalTo: sheet.centerXAnchor),
                handle.widthAnchor.constraint(equalToConstant: 40),
                handle.heightAnchor.constraint(equalToConstant: 4),
                title.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 16),
                title.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 34),
                close.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -16),
                close.centerYAnchor.constraint(equalTo: title.centerYAnchor),
                imageView.centerXAnchor.constraint(equalTo: sheet.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 48),
                imageView.widthAnchor.constraint(equalToConstant: 36),
                imageView.heightAnchor.constraint(equalToConstant: 36),
                message.centerXAnchor.constraint(equalTo: sheet.centerXAnchor),
                message.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
                subtitle.centerXAnchor.constraint(equalTo: sheet.centerXAnchor),
                subtitle.topAnchor.constraint(equalTo: message.bottomAnchor, constant: 4)
            ])
        }

        referencePowerNoDeviceSheet?.isHidden = false
        view.bringSubviewToFront(referencePowerNoDeviceSheet!)
        syncReferenceOverlayVisibility()
    }

    @objc private func closeReferencePowerNoDeviceSheet() {
        referencePowerNoDeviceSheet?.isHidden = true
        if let powerButton = referenceBottomButtons["Power"] {
            powerButton.isSelected = false
        }
        syncReferenceOverlayVisibility()
        updateScannerControls()
    }

    @IBAction func mConnect(_ sender: UIButton) {
        view.endEditing(true)

        // Close/hide every legacy storyboard overlay first. The reference UI is
        // already on screen; Connect must ONLY add the bottom sheet on top of it.
        hideLegacyOverlayViewsForReferenceSheet()
        referencePowerNoDeviceSheet?.isHidden = true
        mDeviceView.isHidden = true

        pendingZebraReaderID = nil
        pendingBluetoothIdentifier = nil
        deviceDiscoveryTimer?.invalidate()
        deviceDiscoveryTimer = nil

        // Always show the reference Device bottom sheet. The old storyboard
        // Device/Connect view is intentionally kept hidden because its layout
        // is full-screen and does not match the supplied reference.
        showReferenceDeviceSheet()

        let alreadyConnected = isAnyRFIDConnected

        if !alreadyConnected {
            // Do NOT clear the cached Zebra reader/device list here.
            // When returning from Home, the iOS/Zebra SDK may already know
            // the paired reader while the async discovery callback has not
            // fired again yet. Clearing `devices` at this point made the
            // Connect sheet appear empty.
            var cachedReaders = readers

            let availableReaders = ZebraRFIDService.shared.availableReaders
            for reader in availableReaders {
                if !cachedReaders.contains(where: {
                    $0.getReaderID() == reader.getReaderID()
                }) {
                    cachedReaders.append(reader)
                }
            }

            let sdkReaders = ZebraRFIDService.shared.getActualDeviceList()
            for reader in sdkReaders {
                if !cachedReaders.contains(where: {
                    $0.getReaderID() == reader.getReaderID()
                }) {
                    cachedReaders.append(reader)
                }
            }

            readers = cachedReaders

            // Keep cached Zebra devices and merge fresh Bluetooth devices.
            for reader in readers {
                let exists = devices.contains {
                    $0.type == .zebra &&
                    $0.zebraReader?.getReaderID() == reader.getReaderID()
                }
                if !exists {
                    devices.append(ScanDevice(reader: reader))
                }
            }

            arrPeripheral.removeAll()
            mDeviceTableView.reloadData()
            updateDeviceEmptyState()

            // Start both supported discovery paths.
            search()
            ZebraRFIDService.shared.dumpAccessories()
            ZebraRFIDService.shared.startDiscovery()

            // Zebra's discovery is asynchronous. The SDK log shows that the
            // MFi accessory is added after startDiscovery(), so do not treat
            // an initial availableReaders == 0 as "no device". Give the SDK
            // a short window to raise zebraReaderChanged.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                guard let self = self else { return }

                let discovered = ZebraRFIDService.shared.availableReaders
                print("🦓 Delayed reader check =", discovered.count)

                for reader in discovered {
                    let exists = self.devices.contains {
                        $0.type == .zebra &&
                        $0.zebraReader?.getReaderID() == reader.getReaderID()
                    }
                    if !exists {
                        self.readers.append(reader)
                        self.devices.append(ScanDevice(reader: reader))
                    }
                }

                self.updateDeviceEmptyState()
                self.mDeviceTableView.reloadData()
            }

            // Some Zebra SDK versions populate availableReaders first and
            // update the actual-device list shortly afterwards. Refresh both
            // sources immediately so the Device sheet does not stay empty
            // while waiting for a notification.
            let availableZebraReaders = ZebraRFIDService.shared.availableReaders
            for reader in availableZebraReaders {
                let exists = self.devices.contains {
                    $0.type == .zebra &&
                    $0.zebraReader?.getReaderID() == reader.getReaderID()
                }
                if !exists {
                    self.devices.append(ScanDevice(reader: reader))
                }
            }
            self.updateDeviceEmptyState()
            self.mDeviceTableView.reloadData()

            deviceDiscoveryTimer = Timer.scheduledTimer(
                withTimeInterval: ScanPeriod + 0.5,
                repeats: false
            ) { [weak self] _ in
                guard let self = self else { return }
                self.deviceDiscoveryTimer = nil

                let discovered = ZebraRFIDService.shared.getActualDeviceList()
                if !discovered.isEmpty {
                    self.readers = discovered
                    ZebraRFIDService.shared.availableReaders = discovered

                    for reader in discovered {
                        let exists = self.devices.contains {
                            $0.type == .zebra &&
                            $0.zebraReader?.getReaderID() == reader.getReaderID()
                        }

                        if !exists {
                            self.devices.append(ScanDevice(reader: reader))
                        }
                    }
                }

                self.updateDeviceEmptyState()
                self.mDeviceTableView.reloadData()
                self.syncReferenceOverlayVisibility()
            }
        } else {
            // Keep the connected reader visible with the green checkmark.
            if ZebraRFIDService.shared.isConnected {
                let zebraReaders = ZebraRFIDService.shared.getActualDeviceList()
                if !zebraReaders.isEmpty {
                    readers = zebraReaders
                    ZebraRFIDService.shared.availableReaders = zebraReaders
                }

                for reader in readers {
                    let exists = devices.contains {
                        $0.type == .zebra &&
                        $0.zebraReader?.getReaderID() == reader.getReaderID()
                    }
                    if !exists {
                        devices.append(ScanDevice(reader: reader))
                    }
                }
            }

            updateDeviceEmptyState()
            mDeviceTableView.reloadData()
        }

        sender.isSelected = true
        syncReferenceOverlayVisibility()
        updateScannerControls()
    }


    @IBAction func mHome(_ sender: Any) {
        
        self.navigationController?.popViewController(animated:true)
    }
    
    
    @IBAction func mTotalScanned(_ sender: Any) {
        if mTotalStocks.text != "0" {
            if let mTotalStock = storyBoard.instantiateViewController(withIdentifier: "TotalStock") as? TotalStock {
                mTotalStock.mType = "Total"
                print("StockTakePage mTotalScanned \(mStatusData)")
                mTotalStock.mTotalStockData = mStatusData
                
                mTotalStock.mCount = mTotalStocks.text ?? "0"
                self.navigationController?.pushViewController(mTotalStock, animated:true)
            }
        }
        
    }
    @IBAction func mScanned(_ sender: Any) {
        
        if mScannedStocks.text != "0" {
            
            if let mTotalStock = storyBoard.instantiateViewController(withIdentifier: "TotalStock") as? TotalStock {
                mTotalStock.mType = "Scanned"
                mTotalStock.mTotalStockData = mSCANNED
                mTotalStock.mCount = mScannedStocks.text ?? "0"
                self.navigationController?.pushViewController(mTotalStock, animated:true)
            }
        }
    }
    @IBAction func mUnscanned(_ sender: Any) {
        
        if mUnscannedStocks.text != "0" {
            if let mTotalStock = storyBoard.instantiateViewController(withIdentifier: "TotalStock") as? TotalStock {
                mTotalStock.mType = "Unscanned"
                mTotalStock.mTotalStockData = mUNSCANNED
                mTotalStock.mCount = mUnscannedStocks.text ?? "0"
                self.navigationController?.pushViewController(mTotalStock, animated:true)
            }
        }
    }
    
    @IBAction func mConflictUnknown(_ sender: Any) {
        let conflictCount = Int(mConflictStocks.text ?? "0") ?? 0
        guard conflictCount > 0 else { return }

        if let mConflictUnknownStock = storyBoard.instantiateViewController(
            withIdentifier: "ConflictUnknownStock"
        ) as? ConflictUnknownStock {

            // IMPORTANT:
            // Explicitly set the mode before pushing the controller.
            // This prevents Conflict/Unknown from opening the wrong mode.
            mConflictUnknownStock.displayMode = .conflict
            mConflictUnknownStock.mConflictData = mCONFLICT

            // Keep mCONFLICT unchanged for internal logic/API purposes.
            // Build separate display data so the Conflict screen can show:
            // SKU    Stock ID
            // instead of: StockID|DUPLICATE
            mConflictUnknownStock.mConflictDisplayData = mCONFLICT.compactMap { conflictKey in
                let stockID = conflictKey
                    .components(separatedBy: "|")
                    .first?
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

                guard !stockID.isEmpty else { return nil }

                return mCONFLICTARRAY
                    .compactMap { $0 as? NSDictionary }
                    .first(where: {
                        "\($0.value(forKey: "stock_id") ?? "")" == stockID
                    })
                    .map {
                        [
                            "SKU": "\($0.value(forKey: "SKU") ?? "")",
                            "stock_id": "\($0.value(forKey: "stock_id") ?? "")",
                            "scan_source": "\($0.value(forKey: "scan_source") ?? "")"
                        ]
                    }
            }

            mConflictUnknownStock.mCount = mConflictStocks.text ?? "0"

            print("➡️ OPEN CONFLICT")
            print("   conflictCount =", conflictCount)
            print("   sourceData =", mCONFLICT)

            self.navigationController?.pushViewController(
                mConflictUnknownStock,
                animated: true
            )
        }
    }

    @IBAction func mUnknownTags(_ sender: Any) {
        let unknownCount = Int(mUnknownStocks.text ?? "0") ?? 0
        guard unknownCount > 0 else { return }

        if let mConflictUnknownStock = storyBoard.instantiateViewController(
            withIdentifier: "ConflictUnknownStock"
        ) as? ConflictUnknownStock {

            // IMPORTANT:
            // Unknown MUST open in .unknown mode.
            // Previously displayMode was left at its default (.conflict),
            // so the Unknown card could open the Conflict mode.
            mConflictUnknownStock.displayMode = .unknown
            mConflictUnknownStock.mConflictData = mCONFLICT
            mConflictUnknownStock.mCount = "\(unknownCount)"

            print("➡️ OPEN UNKNOWN")
            print("   unknownCount =", unknownCount)
            print("   sourceData =", mCONFLICT)

            self.navigationController?.pushViewController(
                mConflictUnknownStock,
                animated: true
            )
        }
    }

    @IBAction func mRefresh(_ sender: Any) {
        let running = bluetoothService?.scannerIsRunning == 1 || ZebraRFIDService.shared.isInventoryRunning || atidInventoryRunning

        if running {
            // Stop ends the current scan session. Play is disabled until Clear.
            print("🛑 STOCK TAKE STOP")
            isStoppedState = true
            canStopAfterPause = false

            if ZebraRFIDService.shared.isInventoryRunning {
                ZebraRFIDService.shared.stopInventory()
            }

            #if !targetEnvironment(simulator) && canImport(EARfidFramework)
            if atidInventoryRunning {
                stopATIDInventory()
            }
            #endif

            if bluetoothService?.scannerIsRunning == 1 {
                stopRFID()
            }

            recentRFIDReads.removeAll()
            updateScannerControls()
            return
        }

        // After a successful save, Clear starts a new session immediately.
        // If there is unsaved/failed-save data, confirm before clearing it.
        print("shouldConfirmClearingWithoutSave")
        if shouldConfirmClearingWithoutSave() {
            
            showClearWithoutSavingConfirmation()
        } else {
            print("clearStockTakeResults")
//            showClearWithoutSavingConfirmation()
            clearStockTakeResults()
        }
    }

    private func clearStockTakeResults() {
        guard !isSaveInProgress else { return }
        canStopAfterPause = false
        isStoppedState = false
        hasSuccessfulSave = false
        hasSaveFailed = false

        mScannedStocks.text = "0"
        mUnscannedStocks.text = mTotalStocks.text ?? "0"
        mConflictStocks.text = "0"
        mUnknownStocks.text = "0"

        mScannedData.removeAll()
        mScannedSKU.removeAll()
        mScannedCount.removeAll()
        mUnscannedData.removeAll()
        mConflictData.removeAll()

        mSCANNED.removeAllObjects()
        mUNSCANNED.removeAllObjects()
        mSAVESCANNED.removeAllObjects()
        mSAVEUNSCANNED.removeAllObjects()
        mCONFLICTARRAY.removeAllObjects()
        mUNKNOWNARRAY.removeAllObjects()
        mCONFLICT.removeAll()
        FINALCONFLICT.removeAll()

        recentRFIDReads.removeAll()
        updateScannerControls()
        mStatus()
    }

    private func updatePowerSheetState() {
        let connected = isAnyRFIDConnected
        let teal = UIColor(hex: "#00A38D")
        let trackGray = UIColor(hex: "#D2D2D2")
        let textGray = UIColor(hex: "#868686")

        // Reference slider styling.
        mPowerSlider?.minimumTrackTintColor = teal
        mPowerSlider?.maximumTrackTintColor = trackGray
        mFrequencySlider?.minimumTrackTintColor = teal
        mFrequencySlider?.maximumTrackTintColor = trackGray

        if connected {
            powerEmptyStateView?.removeFromSuperview()
            powerEmptyStateView = nil

            mPowerSlider?.isHidden = false
            mFrequencySlider?.isHidden = false
            mPowerValue?.isHidden = false
            mFrequency?.isHidden = false
            mPowerpLABEL?.isHidden = false
            mPowerLABEL?.isHidden = false
            mFrequencyLABEL?.isHidden = false

            if isZebraRFIDConnected {
                _ = ZebraRFIDService.shared.refreshCurrentPower()
                let minPower = ZebraRFIDService.shared.minPower
                let maxPower = ZebraRFIDService.shared.maxPower
                let currentPower = ZebraRFIDService.shared.currentPower
                let range = max(1, maxPower - minPower)
                let normalized = Float(
                    max(
                        0,
                        min(
                            1,
                            Double(currentPower - minPower) / Double(range)
                        )
                    )
                )
                mPowerSlider?.setValue(normalized, animated: false)
                mPowerValue?.text = "\(currentPower) / \(maxPower)"
            } else {
                mPowerSlider?.setValue(0.5, animated: false)
                mPowerValue?.text = "50%"
            }
            mFrequencySlider?.setValue(0.0, animated: false)
            mFrequency?.text = "0%"

            mPowerValue?.textColor = .label
            mFrequency?.textColor = .label
            mPowerLABEL?.textColor = .label
            mPowerpLABEL?.textColor = .label
            mFrequencyLABEL?.textColor = .label
            return
        }

        // No reader connected: show only the empty state.
        mPowerSlider?.isHidden = true
        mFrequencySlider?.isHidden = true
        mPowerValue?.isHidden = true
        mFrequency?.isHidden = true
        mPowerpLABEL?.isHidden = true
        mPowerLABEL?.isHidden = true
        mFrequencyLABEL?.isHidden = true

        if powerEmptyStateView == nil {
            let container = UIView()
            container.backgroundColor = .clear
            container.translatesAutoresizingMaskIntoConstraints = false

            let imageView = UIImageView(
                image: UIImage(systemName: "antenna.radiowaves.left.and.right.slash")
            )
            imageView.tintColor = UIColor(hex: "#868686")
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false

            let title = UILabel()
            title.text = "No Device Connected"
            title.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            title.textColor = UIColor(hex: "#222222")
            title.textAlignment = .center
            title.translatesAutoresizingMaskIntoConstraints = false

            let subtitle = UILabel()
            subtitle.text = "Please check your connection and try again."
            subtitle.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            subtitle.textColor = textGray
            subtitle.textAlignment = .center
            subtitle.numberOfLines = 2
            subtitle.translatesAutoresizingMaskIntoConstraints = false

            let stack = UIStackView(arrangedSubviews: [imageView, title, subtitle])
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 10
            stack.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(stack)

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 36),
                imageView.heightAnchor.constraint(equalToConstant: 36),
                stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                stack.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: 5),
                stack.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 20),
                stack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -20)
            ])

            mPowerView.addSubview(container)
            NSLayoutConstraint.activate([
                container.topAnchor.constraint(equalTo: mPowerView.topAnchor, constant: 45),
                container.leadingAnchor.constraint(equalTo: mPowerView.leadingAnchor),
                container.trailingAnchor.constraint(equalTo: mPowerView.trailingAnchor),
                container.bottomAnchor.constraint(equalTo: mPowerView.bottomAnchor)
            ])

            powerEmptyStateView = container
        }
    }

    @IBAction func mPower(_ sender: UIButton) {
        // Use the same reference Power sheet from both the storyboard action
        // and the programmatic bottom-bar action.
        print("mPower")
        if referencePowerSheet?.isHidden == false {
            closeReferencePowerSheet()
        } else {
            showReferencePowerSheet()
        }
    }

    private func makeReferenceSlider() -> UISlider {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.minimumTrackTintColor = UIColor(hex: "#51C7C2")
        slider.maximumTrackTintColor = UIColor(hex: "#D9D9D9")
        slider.setThumbImage(makeReferenceSliderThumb(), for: .normal)
        slider.setThumbImage(makeReferenceSliderThumb(), for: .highlighted)
        return slider
    }

    private func makeReferenceSliderThumb() -> UIImage {
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }

        let rect = CGRect(origin: .zero, size: size).insetBy(dx: 2, dy: 2)
        UIColor.white.setFill()
        UIBezierPath(ovalIn: rect).fill()
        UIColor(white: 0.88, alpha: 1).setStroke()
        let path = UIBezierPath(ovalIn: rect)
        path.lineWidth = 1
        path.stroke()

        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }

    private func makeReferencePowerIcon() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "stocktake_ic_backlight"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor(hex: "#333333")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private func makeFrequencyCountryMenu() -> UIMenu {
        let readerRegions = ZebraRFIDService.shared.supportedRegulatoryRegions()
        if !readerRegions.isEmpty {
            var actions: [UIAction] = [
                UIAction(title: "Thailand (TH)") { [weak self] _ in
                    self?.selectFrequencyCountry("TH")
                }
            ]
            actions.append(contentsOf: readerRegions.map { region in
                let title = region.name.isEmpty ? region.code : "\(region.name) (\(region.code))"
                return UIAction(title: title) { [weak self] _ in
                    self?.selectFrequencyCountry(region.code)
                }
            })
            return UIMenu(title: "Select RFID Region", options: [.displayInline], children: actions)
        }

        // The generic country list is used only while disconnected. Once a
        // reader is connected, offer its own allowed regulatory regions above.
        let locale = Locale.current
        let codes = Locale.isoRegionCodes.sorted {
            let left = locale.localizedString(forRegionCode: $0) ?? $0
            let right = locale.localizedString(forRegionCode: $1) ?? $1
            return left.localizedCaseInsensitiveCompare(right) == .orderedAscending
        }

        let actions: [UIAction] = codes.map { code in
            let countryName = locale.localizedString(forRegionCode: code) ?? code
            return UIAction(title: "\(countryName) (\(code))") { [weak self] _ in
                self?.selectFrequencyCountry(code)
            }
        }

        return UIMenu(title: "Select Country", options: [.displayInline], children: actions)
    }

    private func selectFrequencyCountry(_ code: String) {
        referenceFrequencySelector?.setTitle(code, for: .normal)
        UserDefaults.standard.set(code, forKey: "StockTakeRFIDFrequencyCountry")

        let success = ZebraRFIDService.shared.setRegulatoryRegion(code)
        print("🌍 RFID country =", code, "success =", success)
        guard success else {
            CommonClass.showSnackBar(message: "Unable to set RFID region")
            return
        }

        updateScannerControls()
        CommonClass.showSnackBar(message: "RFID region set to \(code)")
    }

    private func showReferencePowerSheet() {
        print("showReferencePowerSheet")
        hideLegacyOverlayViewsForReferenceSheet()
        referenceDeviceSheet?.isHidden = true
        referencePowerNoDeviceSheet?.isHidden = true
        mPowerView?.isHidden = true

        if isZebraRFIDConnected {
            _ = ZebraRFIDService.shared.refreshCurrentPower()
        }

        if referencePowerSheet == nil {
            let sheet = UIView()
            sheet.translatesAutoresizingMaskIntoConstraints = false
            sheet.backgroundColor = .white
            sheet.layer.cornerRadius = 12
            sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            sheet.clipsToBounds = true
            view.addSubview(sheet)
            referencePowerSheet = sheet

            let handle = UIView()
            handle.translatesAutoresizingMaskIntoConstraints = false
            handle.backgroundColor = UIColor(hex: "#D5D5D5")
            handle.layer.cornerRadius = 2
            sheet.addSubview(handle)

            let title = UILabel()
            title.translatesAutoresizingMaskIntoConstraints = false
            title.text = "RFID Settings"
            title.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            title.textColor = UIColor(hex: "#333333")
            sheet.addSubview(title)

            let close = makeSheetCloseButton()
            close.addTarget(self, action: #selector(closeReferencePowerSheet), for: .touchUpInside)
            sheet.addSubview(close)

            let powerLabel = UILabel()
            powerLabel.translatesAutoresizingMaskIntoConstraints = false
            powerLabel.text = "Power"
            powerLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            powerLabel.textColor = UIColor(hex: "#333333")
            sheet.addSubview(powerLabel)

            let powerValue = UILabel()
            powerValue.translatesAutoresizingMaskIntoConstraints = false
            powerValue.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            powerValue.textColor = UIColor(hex: "#868686")
            powerValue.textAlignment = .right
            sheet.addSubview(powerValue)

            let powerLow = makeReferencePowerIcon()
            let powerHigh = makeReferencePowerIcon()
            sheet.addSubview(powerLow)
            sheet.addSubview(powerHigh)

            let powerSlider = makeReferenceSlider()
            powerSlider.addTarget(
                self,
                action: #selector(referencePowerSliderChanged(_:)),
                for: .valueChanged
            )
            sheet.addSubview(powerSlider)

            let frequencyLabel = UILabel()
            frequencyLabel.translatesAutoresizingMaskIntoConstraints = false
            frequencyLabel.text = "Frequency"
            frequencyLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            frequencyLabel.textColor = UIColor(hex: "#333333")
            sheet.addSubview(frequencyLabel)

            let frequencySelector = UIButton(type: .system)
            frequencySelector.translatesAutoresizingMaskIntoConstraints = false
            frequencySelector.setTitle("Select region", for: .normal)
            frequencySelector.setTitleColor(UIColor(hex: "#4C89E8"), for: .normal)
            frequencySelector.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            frequencySelector.contentHorizontalAlignment = .left
            frequencySelector.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            frequencySelector.tintColor = UIColor(hex: "#333333")
            frequencySelector.semanticContentAttribute = .forceRightToLeft
            frequencySelector.contentHorizontalAlignment = .leading
            frequencySelector.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
            frequencySelector.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
            frequencySelector.accessibilityLabel = "RFID regulatory region"
            frequencySelector.showsMenuAsPrimaryAction = true
            frequencySelector.menu = makeFrequencyCountryMenu()
            sheet.addSubview(frequencySelector)

            referencePowerSlider = powerSlider
            referenceFrequencySlider = nil
            referencePowerValueLabel = powerValue
            referenceFrequencyValueLabel = nil
            referenceFrequencySelector = frequencySelector

            NSLayoutConstraint.activate([
                sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                sheet.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                sheet.heightAnchor.constraint(equalToConstant: 330),

                handle.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 12),
                handle.centerXAnchor.constraint(equalTo: sheet.centerXAnchor),
                handle.widthAnchor.constraint(equalToConstant: 40),
                handle.heightAnchor.constraint(equalToConstant: 4),

                title.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 20),
                title.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 34),

                close.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -16),
                close.centerYAnchor.constraint(equalTo: title.centerYAnchor),
                close.widthAnchor.constraint(equalToConstant: 28),
                close.heightAnchor.constraint(equalToConstant: 28),

                powerLabel.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 20),
                powerLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 34),

                powerValue.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -20),
                powerValue.centerYAnchor.constraint(equalTo: powerLabel.centerYAnchor),

                powerSlider.topAnchor.constraint(equalTo: powerLabel.bottomAnchor, constant: 18),
                powerSlider.leadingAnchor.constraint(equalTo: powerLow.trailingAnchor, constant: 18),
                powerSlider.trailingAnchor.constraint(equalTo: powerHigh.leadingAnchor, constant: -18),
                powerSlider.heightAnchor.constraint(equalToConstant: 30),

                powerLow.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 28),
                powerLow.centerYAnchor.constraint(equalTo: powerSlider.centerYAnchor),
                powerLow.widthAnchor.constraint(equalToConstant: 20),
                powerLow.heightAnchor.constraint(equalToConstant: 20),

                powerHigh.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -28),
                powerHigh.centerYAnchor.constraint(equalTo: powerSlider.centerYAnchor),
                powerHigh.widthAnchor.constraint(equalToConstant: 20),
                powerHigh.heightAnchor.constraint(equalToConstant: 20),

                frequencyLabel.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 20),
                frequencyLabel.topAnchor.constraint(equalTo: powerSlider.bottomAnchor, constant: 34),

                frequencySelector.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 20),
                frequencySelector.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -20),
                frequencySelector.topAnchor.constraint(equalTo: frequencyLabel.bottomAnchor, constant: 12),
                frequencySelector.heightAnchor.constraint(equalToConstant: 36)
            ])
        }

        let minPower = ZebraRFIDService.shared.minPower
        let maxPower = ZebraRFIDService.shared.maxPower
        let currentPower = ZebraRFIDService.shared.currentPower
        let range = max(1, maxPower - minPower)

        let normalized = Float(
            max(
                0,
                min(
                    1,
                    Double(currentPower - minPower) / Double(range)
                )
            )
        )

        referencePowerSlider?.minimumValue = 0
        referencePowerSlider?.maximumValue = 1
        referencePowerSlider?.setValue(normalized, animated: false)
        referencePowerValueLabel?.text = "\(currentPower) / \(maxPower)"
        let selectedCountry = UserDefaults.standard.string(forKey: "StockTakeRFIDFrequencyCountry") ?? "TH"
        referenceFrequencySelector?.setTitle(selectedCountry, for: .normal)
        referenceFrequencySelector?.menu = makeFrequencyCountryMenu()

        referencePowerSheet?.isHidden = false
        view.bringSubviewToFront(referencePowerSheet!)
        syncReferenceOverlayVisibility()
        updateScannerControls()
    }

    @objc private func closeReferencePowerSheet() {
        print("closeReferencePowerSheet")
        referencePowerSheet?.isHidden = true
        if let powerButton = referenceBottomButtons["Power"] {
            powerButton.isSelected = false
        }
        syncReferenceOverlayVisibility()
        updateScannerControls()
    }

    @objc private func referencePowerSliderChanged(_ sender: UISlider) {
        let minPower = ZebraRFIDService.shared.minPower
        let maxPower = ZebraRFIDService.shared.maxPower
        let range = max(1, maxPower - minPower)

        let requestedPower = minPower + Int32(
            (Double(range) * Double(sender.value)).rounded()
        )

        let success = ZebraRFIDService.shared.setPowerValue(requestedPower)
        let actualPower = ZebraRFIDService.shared.currentPower

        let normalized = Float(
            max(
                0,
                min(
                    1,
                    Double(actualPower - minPower) / Double(range)
                )
            )
        )

        sender.setValue(normalized, animated: false)
        referencePowerValueLabel?.text = "\(actualPower) / \(maxPower)"

        print(
            "🦓 Power slider =",
            requestedPower,
            "actual =",
            actualPower,
            "success =",
            success
        )
    }


    @IBAction func mMore(_ sender: UIButton) {
        // Save is disabled during Pause according to the reference flow.
        if canStopAfterPause {
            print("⛔ STOCK TAKE SAVE DISABLED - session is paused.")
            updateScannerControls()
            return
        }

        guard !isSaveInProgress && !hasSuccessfulSave else { return }

        let scannedQty = Int(mScannedStocks.text ?? "0") ?? 0
        let conflictQty = Int(mConflictStocks.text ?? "0") ?? 0
        let unknownQty = Int(mUnknownStocks.text ?? "0") ?? 0
        let hasSaveableData = scannedQty > 0 || conflictQty > 0 || unknownQty > 0

        guard hasSaveableData else {
            mMoreIcon.image = UIImage(named: "save_icg")
            mMoreLabel.textColor = UIColor(named: "theme6A")
            self.showStockTakeResultMessage(success: false, message: "No Data Scanned!")
            updateScannerControls()
            return
        }

        isSaveInProgress = true


        showSaveToastLoading()
        hasSaveFailed = false
        hasSuccessfulSave = false
        print("🔥 STOCK TAKE SAVE START")
        print("🔥 STOCK TAKE SCANNED QTY = \(scannedQty)")
        mMoreIcon.image = UIImage(named: "save_icg")
        mMoreLabel.textColor = UIColor(named: "theme6A")
        updateScannerControls()

        // Save always stops the reader first so the payload cannot change
        // while the request is in flight.
        if ZebraRFIDService.shared.isInventoryRunning {
            ZebraRFIDService.shared.stopInventory()
        }
        if bluetoothService?.scannerIsRunning == 1 {
            stopRFID()
        }

        getVoucherID()
    }

    private func startSaveIndicator() {
        saveActivityIndicator?.removeFromSuperview()

        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = UIColor(named: "themeColor") ?? .systemTeal
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()

        mMoreIcon.superview?.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: mMoreIcon.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: mMoreIcon.centerYAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 24),
            indicator.heightAnchor.constraint(equalToConstant: 24)
        ])

        saveActivityIndicator = indicator
    }

    private func stopSaveIndicator(success: Bool) {
        saveActivityIndicator?.stopAnimating()
        saveActivityIndicator?.removeFromSuperview()
        saveActivityIndicator = nil

        isSaveInProgress = false
        
        mMoreIcon.image = UIImage(named: success ? "save_icg" : "save_ic")
        mMoreLabel.textColor = UIColor(named: success ? "theme6A" : "themeColor")
        updateScannerControls()
    }

    @objc
    func mTimerForButton(){
        
        mItemsId = [String]()
        mMetalsId = [String]()
        mCollectionId = [String]()
        mStonesId = [String]()
        mSizeId = [String]()
        mStatusId = [String]()
        mLocationsId = [String]()
        mMinPrices = ""
        mMaxPrices = ""
        self.mScannedStocks.text = "0"
        self.mUnscannedStocks.text = "0"
        self.mConflictStocks.text = "0"
        self.mSCANNED = NSMutableArray()
        self.mUNSCANNED = NSMutableArray()
        self.mCONFLICTARRAY = NSMutableArray()
        self.mUNKNOWNARRAY = NSMutableArray()
        self.mCONFLICT = [String]()
        self.mUnknownStocks.text = "0"
        
        self.mScannedData = [String]()
        self.mScannedSKU = [String]()
        self.mScannedCount = [Int]()
        self.mUnscannedData = [String]()
        self.mConflictData = [String]()
        self.mInventoryData = NSArray()
        self.mStatusData = NSMutableArray()
        self.mSCANNED = NSMutableArray()
        self.mUNSCANNED = NSMutableArray()
        
        self.mSAVESCANNED = NSMutableArray()
        self.mSAVEUNSCANNED = NSMutableArray()
        self.mCONFLICTARRAY = NSMutableArray()
        self.mUNKNOWNARRAY = NSMutableArray()
        self.mCONFLICT = [String]()
        self.FINALCONFLICT = [String]()

        mScannedData = [String]()
        mScannedSKU = [String]()
        mScannedCount = [Int]()
        mUnscannedData = [String]()
        mConflictData = [String]()
        mInventoryData = NSArray()
        mStatusData = NSMutableArray()
        mSCANNED = NSMutableArray()
        mUNSCANNED = NSMutableArray()
        mRefreshIcon.image = UIImage(named: "refresh_icgrey")
        mRefreshLabel.textColor =  UIColor(named: "theme6A")
        mScannedStocks.text = "0"
        mUnscannedStocks.text = "0"
        mConflictStocks.text = "0"
        
        mUnknownStocks.text = "0"
        self.mGetInventoryDataStock(key: "")
        
        self.mTimer.invalidate()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        return arrPeripheral.count
        return devices.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceItems") as? DeviceItems else {
            return UITableViewCell()
        }

        let device = devices[indexPath.row]

        switch device.type {
        case .bluetooth:
            let id = device.peripheral?.identifier.uuidString ?? ""

            let connected: Bool
            if let peripheral = device.peripheral, isATIDPeripheral(peripheral) {
                connected = isATIDRFIDConnected &&
                    atidPeripheral?.identifier == peripheral.identifier
            } else {
                connected = device.peripheral == bluetoothService?.peripheral &&
                    bluetoothService?.isConnected() == true
            }

            let loading = pendingBluetoothIdentifier == device.peripheral?.identifier && !connected

            cell.configure(
                name: device.name,
                id: id,
                connected: connected,
                loading: loading
            )

        case .zebra:
            let readerID = device.zebraReader?.getReaderID()
            let id = device.zebraReader?.getReaderSerialNumber() ?? ""
            let connected = ZebraRFIDService.shared.isConnected &&
                ZebraRFIDService.shared.currentReaderID == readerID
            let loading = pendingZebraReaderID == readerID && !connected

            cell.configure(
                name: device.name,
                id: id,
                connected: connected,
                loading: loading
            )
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        connect(arrPeripheral[indexPath.row])
        let device = devices[indexPath.row]

        switch device.type {
            
        case .bluetooth:

            if let peripheral = device.peripheral {
                pendingBluetoothIdentifier = peripheral.identifier
                startDeviceConnectionTimeout()
                mDeviceTableView.reloadData()

                if isATIDPeripheral(peripheral) {
                    if isATIDRFIDConnected {
                        if atidPeripheral?.identifier == peripheral.identifier {
                            disconnectATIDReader()
                        } else {
                            disconnectATIDReader()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                self.connectATID(peripheral)
                            }
                        }
                    } else if bluetoothService?.isConnected() == true {
                        #if !targetEnvironment(simulator)
                            disconnectLegacyBluetoothReader()
                        #endif
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            self.connectATID(peripheral)
                        }
                    } else if ZebraRFIDService.shared.isConnected ||
                                ZebraRFIDService.shared.currentReaderID != -1 {
                        ZebraRFIDService.shared.disconnect()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            self.connectATID(peripheral)
                        }
                    } else {
                        connectATID(peripheral)
                    }
                } else {
                    // Existing reader behavior remains unchanged.
                    if isATIDRFIDConnected {
                        disconnectATIDReader()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            self.connect(peripheral)
                        }
                    } else {
                        connect(peripheral)
                    }
                }
            }

        case .zebra:

            guard let reader = device.zebraReader else {
                return
            }

            pendingZebraReaderID = reader.getReaderID()
            startDeviceConnectionTimeout()
            mDeviceTableView.reloadData()

            if isATIDRFIDConnected {
                disconnectATIDReader()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    ZebraRFIDService.shared.connect(
                        readerID: reader.getReaderID()
                    )
                }
                return
            }

            if ZebraRFIDService.shared.isConnected {

                if ZebraRFIDService.shared.currentReaderID == reader.getReaderID() {

                    print("Disconnect Reader")

                    ZebraRFIDService.shared.disconnect()

                } else {

                    print("Switch Reader")

                    ZebraRFIDService.shared.disconnect()

                    // The service clears local state before terminating the
                    // previous BLE session, so a short handoff is sufficient.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {

                        ZebraRFIDService.shared.connect(
                            readerID: reader.getReaderID()
                        )
                    }
                }

            } else {

                ZebraRFIDService.shared.connect(
                    readerID: reader.getReaderID()
                )
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.updateScannerControls()
            self.mDeviceTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
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
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            found(code: stringValue)
        }
        dismiss(animated: true)
    }
    
    func found(code: String) {
        print("found code = \(code)")

        // Camera scans must follow exactly the same rules as keyboard and
        // RFID scans: only sold_data produces Conflict; all unmatched values
        // are Unknown and therefore have an empty SKU in the save payload.
        mGetScanResults(searchText: code, showPopup: true)
    }
    
//    func found(code: String) {
//        print("found code = \(code)")
//        var mUnknown = true
//        for i in mStatusData {
//
//            if let mValue = i as? NSMutableDictionary,
//               let sku = mValue.value(forKey: "SKU") as? String,
//               let stockID = mValue.value(forKey: "stock_id") as? String,
//               let poQtyString = mValue.value(forKey: "po_QTY") as? String,
//               let poQty = Int(poQtyString) {
//
//                if !code.isEmpty {
//                    let searchKey = code
//                    if searchKey == sku || searchKey == stockID {
//                        // Camera duplicate -> Conflict.
//                        // Camera/manual entries use stocktake_ic_manualadd.
//                        if mScannedData.contains(stockID) {
//                            print("⚠️ CAMERA CONFLICT =", stockID)
//
//                            let manualConflictKey = "\(stockID)|MANUAL"
//                            if !mCONFLICT.contains(where: {
//                                $0.replacingOccurrences(of: "|MANUAL", with: "") == stockID
//                            }) {
//                                mCONFLICT.append(manualConflictKey)
//
//                                let conflictItem = NSMutableDictionary()
//                                conflictItem["SKU"] = sku
//                                conflictItem["stock_id"] = stockID
//                                conflictItem["po_QTY"] = "\(poQty)"
//                                conflictItem["_id"] = "\(mValue.value(forKey: "_id") ?? "")"
//                                conflictItem["location_id"] = "\(mValue.value(forKey: "location_id") ?? "")"
//                                mCONFLICTARRAY.add(conflictItem)
//                            }
//
//                            mUnknown = false
//                            continue
//                        }
//
//                        if !mScannedData.contains(stockID){
//                            mScannedData.append(stockID)
//                            mScannedCount.append(poQty)
//                            let items = uniqueElementsFrom(array: mScannedData)
//                            mScannedData = items
//                            mScannedStocks.text = "\(mScannedCount.reduce(0, {$0 + $1}))"
//                            let mUnsCount = (Int(mTotalStocks.text ?? "0") ?? 0) - (Int(mScannedStocks.text ?? "0") ?? 0)
//                            mUnscannedStocks.text = "\(mUnsCount)"
//                            mSCANNED.add(mValue)
//
//                            let mData = NSMutableDictionary()
//                            mData.setValue(stockID, forKey: "stock_id")
//                            mData.setValue(poQty, forKey: "po_QTY")
//                            mData.setValue(sku, forKey: "SKU")
//                            mData.setValue("\(mValue.value(forKey: "_id") ?? "")", forKey: "_id")
//                            mData.setValue("\(mValue.value(forKey: "location_id") ?? "")", forKey: "location_id")
//
//                            mSAVESCANNED.add(mData)
//                        }
//                        mUnknown = false
//                    }else{
//
//                    }
//                }
//            }
//        }
//
//        if mUnknown {
//            let mUnknowdNewData = NSMutableDictionary()
//            mUnknowdNewData.setValue(code, forKey: "SKU")
//            mUnknowdNewData.setValue(code, forKey: "stock_id")
//            mUnknowdNewData.setValue("", forKey: "po_QTY")
//            mUnknowdNewData.setValue("", forKey: "_id")
//            mUnknowdNewData.setValue("", forKey: "location_id")
//            self.mUNKNOWNARRAY.add(mUnknowdNewData)
//
//            // Camera unknown -> show stocktake_ic_manualadd.
//            let manualUnknownKey = "\(code)UKN|MANUAL"
//            if !mCONFLICT.contains(where: {
//                $0.replacingOccurrences(of: "|MANUAL", with: "") == "\(code)UKN"
//            }) {
//                mCONFLICT.append(manualUnknownKey)
//            }
//            let items = uniqueElementsFrom(array: mCONFLICT)
//            mCONFLICT = items
//        }
//
//        if captureSession != nil {
//            captureSession.startRunning()
//        }
//        mStatus()
//
//    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Zebra scanner decoding

    /// Decode a Zebra hex-encoded stock ID before doing any inventory lookup.
    ///
    /// Zebra RFID currently does this inside ZebraRFIDService:
    ///     decodeFromHex(epc) ?? epc
    /// and then uses the decoded value when it is a numeric 1-12 digit stock ID.
    /// Barcode callbacks, however, arrive here as raw strings, so StockTakePage
    /// must apply the same rule before checking SKU / stock_id.
    ///
    /// Examples:
    ///     "32323231323931" -> "2221291"
    ///     "2212291"        -> "2212291" (already plain text)
    ///     invalid/non-hex   -> original value
    private func decodeZebraStockScanValue(_ rawValue: String) -> String {
        let raw = rawValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        guard !raw.isEmpty else { return "" }

        // Already a normal numeric stock_id: keep it exactly as-is.
        if raw.range(of: #"^\d{1,12}$"#, options: .regularExpression) != nil {
            print("🦓 Zebra Plain Format =", raw)
            return raw
        }

        // Zebra's encoded stock format is ASCII stored as HEX.
        // Example:
        // 000000000002D3232313132390000
        //       2D = "-" marker
        //       32 32 31 31 32 39 = "221129"
        //       00 = padding
        //
        // ZebraRFIDService.decodeFromHex() removes the 00 padding and
        // converts HEX bytes to ASCII. The leading "-" must then be removed.
        if var decoded = ZebraRFIDService.shared.decodeFromHex(raw) {
            decoded = decoded
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if decoded.hasPrefix("-") {
                decoded.removeFirst()
            }

            if decoded.range(of: #"^\d{1,12}$"#, options: .regularExpression) != nil {
                print("🦓 Zebra DECODE SUCCESS")
                print("🦓 RAW     =", raw)
                print("🦓 DECODED =", decoded)
                return decoded
            }
        }

        // Do not silently convert arbitrary text.
        // Return the original value for old/non-encoded tags.
        print("🦓 Zebra Plain/Old Format =", raw)
        return raw
    }

    private func normalizedStockLookupKey(_ value: String) -> String {
        return value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
            .replacingOccurrences(of: " ", with: "")
    }

    /// Finds a sold item by its physical stock identifier. SKU is only used
    /// when exactly one sold item has that SKU, avoiding false conflicts for
    /// products that have multiple stock records under the same SKU.
    private func soldStockItem(for lookupKey: String) -> NSDictionary? {
        let key = normalizedStockLookupKey(lookupKey)
        guard !key.isEmpty else { return nil }

        // The Stock Take API has used more than one Stock ID spelling. Match
        // the physical Stock ID only; _id is retained as a final fallback for
        // older responses that did not include a dedicated stock-id field.
        let exactKeys = [
            "stock_id", "stockId", "stockID", "StockId", "Stock ID",
            "stock_code", "stockCode", "_id", "id"
        ]
        if let exactMatch = stockTakeSoldData.first(where: { item in
            exactKeys.contains { field in
                normalizedStockLookupKey("\(item[field] ?? "")") == key
            }
        }) {
            return exactMatch
        }

        let skuMatches = stockTakeSoldData.filter {
            normalizedStockLookupKey("\($0["SKU"] ?? $0["sku"] ?? "")") == key
        }
        return skuMatches.count == 1 ? skuMatches.first : nil
    }

    /// Adds a conflict only for an item explicitly supplied in sold_data.
    private func recordSoldConflict(_ soldItem: NSDictionary, lookupKey: String, source: String) {
        let sku = "\(soldItem["SKU"] ?? soldItem["sku"] ?? lookupKey)"
        let stockID = "\(soldItem["stock_id"] ?? soldItem["stockId"] ?? soldItem["stockID"] ?? soldItem["StockId"] ?? soldItem["stock_code"] ?? soldItem["stockCode"] ?? lookupKey)"
        let conflictKey = stockID + "|SOLD"

        if !mCONFLICT.contains(conflictKey) {
            mCONFLICT.append(conflictKey)

            let conflictItem = NSMutableDictionary(dictionary: soldItem)
            conflictItem["SKU"] = sku
            conflictItem["stock_id"] = stockID
            conflictItem["po_QTY"] = "0"
            conflictItem["scan_source"] = source
            mCONFLICTARRAY.add(conflictItem)
        }

        mStatus()
    }

    /// Adds an unmatched physical tag/code as an Unknown record. There is no
    /// reliable SKU for this category, so SKU must remain empty rather than
    /// duplicating stock_id. Conflict records are kept separate in
    /// mCONFLICTARRAY and always contain the SKU from sold_data.
    private func recordUnknownStock(stockID: String, source: String) {
        let normalizedStockID = normalizedStockLookupKey(stockID)
        guard !normalizedStockID.isEmpty else { return }

        let unknownKey = normalizedStockID + "|UKN"
        guard !mCONFLICT.contains(unknownKey) else { return }

        let unknownItem = NSMutableDictionary()
        unknownItem["SKU"] = ""
        unknownItem["stock_id"] = normalizedStockID
        unknownItem["po_QTY"] = ""
        unknownItem["_id"] = ""
        unknownItem["location_id"] = ""
        unknownItem["scan_source"] = source

        mUNKNOWNARRAY.add(unknownItem)
        mCONFLICT.append(unknownKey)
        mStatus()
    }

    private func addStockLookupKey(_ key: String, item: NSDictionary) {
        let normalized = normalizedStockLookupKey(key)
        guard !normalized.isEmpty else { return }
        stockMap[normalized] = item
    }

    private func rebuildStockMap(_ data: [NSDictionary]) {
        stockMap.removeAll()

        let possibleRFIDKeys = [
            "rfid", "RFID", "rfid_id", "RFID_ID",
            "rfid_tag", "RFID_TAG", "rfid_code", "RFID_CODE",
            "epc", "EPC", "epc_id", "EPC_ID",
            "tag_id", "TAG_ID", "tag", "TAG"
        ]

        for item in data {
            addStockLookupKey("\(item["stock_id"] ?? "")", item: item)
            addStockLookupKey("\(item["SKU"] ?? "")", item: item)

            for key in possibleRFIDKeys {
                if let value = item[key] as? String {
                    addStockLookupKey(value, item: item)
                } else if let value = item[key] {
                    addStockLookupKey("\(value)", item: item)
                }
            }

            // Some API versions put RFID/EPC under product_details.
            if let details = item["product_details"] as? NSDictionary {
                for key in possibleRFIDKeys {
                    if let value = details[key] as? String {
                        addStockLookupKey(value, item: item)
                    } else if let value = details[key] {
                        addStockLookupKey("\(value)", item: item)
                    }
                }
            }
        }

        print("📦 Stock lookup map count =", stockMap.count)
        print("📦 Stock lookup keys =", Array(stockMap.keys.prefix(20)))
    }

    func mGetInventoryDataStock(key: String) {
        let params: [String: Any] = [
            "price": ["min": mMinPrices, "max": mMaxPrices],
            "item": mItemsId,
            "collection": mCollectionId,
            "location": mLocationsId,
            "metal": mMetalsId,
            "stone": mStonesId,
            "size": mSizeId,
        ]
        
        print("mGetInventoryDataStock params: \(params)")
        let urlPath = mGetStockTake
        
        
        guard Reachability.isConnectedToNetwork() else {
            CommonClass.showSnackBar(message: "No Internet Connection")
            return
        }
        
        CommonClass.showFullLoader(view: self.view)
        let startTime = CFAbsoluteTimeGetCurrent()
        mGetData(url: urlPath, headers: sGisHeaders, params: params) { response, status in
            CommonClass.stopLoader()
            print("mGetInventoryDataStock response: \(response)")
            
            guard status else {
                self.hasSuccessfulSave = false
                self.hasSaveFailed = true
                self.stopSaveIndicator(success: false)
                self.showStockTakeResultMessage(success: false, message: "Save Failed. Please try again.")
//                CommonClass.showSnackBar(message: "Save Failed. Please try again.")
                return
            }
            
            if let mCode = response.value(forKey: "code") as? Int, mCode == 403 {
                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                return
            }
            
            if let code = response.value(forKey: "code") as? Int, code == 200 {
                let apiTotalQty = response.value(forKey: "total_qty")
                let apiTotalWeight = response.value(forKey: "total_weight")
                let apiTotalSold = response.value(forKey: "total_sold")

                self.stockTakeTotalWeightG = self.numericValue(apiTotalWeight)
                self.stockTakeTotalSold = self.numericValue(apiTotalSold)

                if let soldData = response.value(forKey: "sold_data") as? [NSDictionary] {
                    self.stockTakeSoldData = soldData
                } else {
                    self.stockTakeSoldData = []
                }

                self.hasStockTakeAPISummary = true

                print("========== STOCK TAKE API SUMMARY ==========")
                print("STOCK TAKE API SUMMARY total_qty = \(apiTotalQty ?? "nil")")
                print("STOCK TAKE API SUMMARY total_weight = \(self.stockTakeTotalWeightG)")
                print("STOCK TAKE API SUMMARY total_sold = \(self.stockTakeTotalSold)")
                print("============================================")
                
                if let mData = response.value(forKey: "data") as? [NSDictionary] {
                    print("mGetInventoryDataStock self.mInventoryData: \(mData)")
                    self.mInventoryData = mData as NSArray
                    self.rebuildStockMap(mData)
                    
                    var arr = [NSMutableDictionary]()
                    var totalPoQty = 0
                    var unscannedPoQty = 0
                    var unscannedData = [NSDictionary]()
                    
                    for data in mData {
                        if let SKU = data["SKU"] as? String,
                           let stock_id = data["stock_id"] as? String,
                           let poQty = Int("\(data["po_QTY"] ?? "0")"),
                           let _id = data["_id"] as? String,
                           let location_id = data["location_id"] as? String {
                            
                            let poQtyString = "\(data["po_QTY"] ?? "0")"
                            
                            let mData = NSMutableDictionary()
                            mData.setValue(SKU, forKey: "SKU")
                            mData.setValue(stock_id, forKey: "stock_id")
                            mData.setValue(poQtyString, forKey: "po_QTY")
                            mData.setValue(_id, forKey: "_id")
                            mData.setValue(location_id, forKey: "location_id")

                            // Preserve API per-item weight in mStatusData so
                            // Scanned / Unscanned summary weights are not zero.
                            if let weight = data["weight"] {
                                mData.setValue(weight, forKey: "weight")
                            }
                            
                            arr.append(mData)
                            
                            totalPoQty += poQty
                            if poQty != 0 {
                                unscannedPoQty += poQty
                                unscannedData.append(data)
                            }
                        }
                    }
                    
                   
                    DispatchQueue.main.async {
                        self.mStatusData.removeAllObjects()
                        self.mStatusData.addObjects(from: arr)
//#if DEBUG

//                    let testIDs = [
//                        "2210867",
//                        "2210868",
//                        "2210869",
//                        "2210870",
//                        "2210871"
//                    ]
//
//                    for id in testIDs {
//
//                        let item = NSMutableDictionary()
//
//                        item["stock_id"] = id
//                        item["po_QTY"] = "1"
//                        item["SKU"] = "TEST"
//                        item["_id"] = UUID().uuidString
//                        item["location_id"] = "TEST"
//
//                        self.mStatusData.add(item)
//                    }

//#endif
                        self.mTotalStocks.text = "\(totalPoQty)"
                        self.mUnscannedStocks.text = "\(unscannedPoQty)"
                        self.updateReferenceSummaryCards()
                        self.mUNSCANNED.removeAllObjects()
                        self.mUNSCANNED.addObjects(from: unscannedData)
                        
                        print("Test Count before =", self.mStatusData.count)
//                        let testIDs = [
//                            "2210867",
//                            "2210868",
//                            "2210869",
//                            "2210870",
//                            "2210871"
//                        ]

//                        for id in testIDs {
//
//                            let item = NSMutableDictionary()
//
//                            item["stock_id"] = id
//                            item["po_QTY"] = "1"
//                            item["SKU"] = "TEST"
//                            item["_id"] = UUID().uuidString
//                            item["location_id"] = "TEST"
//
//                            self.mStatusData.add(item)
//
//                        }

                        print("Test Count After =", self.mStatusData.count)
                        
                        print("mStatusData Count =", self.mStatusData.count)
                        print("mInventoryData Count =", self.mInventoryData.count)
                        
                        let exist = self.mStatusData.contains {
                            guard let dict = $0 as? NSDictionary else { return false }
                            return "\(dict["stock_id"] ?? "")" == "2210867"
                        }

                        print("2210867 Exists =", exist)
                        
                        for item in self.mStatusData {

                            if let dict = item as? NSDictionary {

                                if "\(dict["stock_id"] ?? "")" == "2210867" {

                                    print("FOUND IN STATUS DATA")
                                }
                            }
                        }
                        
                    }
                } else {
                    // Handle case where response.value(forKey: "data") is empty
                 
                    DispatchQueue.main.async {
                        self.mStatusData.removeAllObjects()
                        self.mTotalStocks.text = "0"
                        self.mUnscannedStocks.text = "0"
                        self.mUNSCANNED.removeAllObjects()
                        self.updateReferenceSummaryCards()
                    }
                }
            } else {
                if let error = response.value(forKey: "error") as? String, error == "Authorization has been expired" {
                    CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                } else {
                    CommonClass.showSnackBar(message: "Error! \(response.value(forKey: "code") ?? "Unknown Error")")
                }
            }
        }
    }
    
    
    /// The Stock Take PDF renders its `Conflict/Unknown` section from the
    /// `unknown` payload bucket. A conflict is still distinguishable because
    /// it has a SKU, while a genuinely unknown scan always has an empty SKU.
    /// Keep the two in-memory collections separate for the app UI, then merge
    /// them only when saving the report.
    private func conflictUnknownSavePayload() -> NSMutableArray {
        let combinedItems = NSMutableArray()

        for source in [mUNKNOWNARRAY, mCONFLICTARRAY] {
            for case let item as NSDictionary in source {
                combinedItems.add(NSMutableDictionary(dictionary: item))
            }
        }

        return combinedItems
    }

    func mUploadStocksSave(voucherId: String){
        
        
        let mPriceData = NSMutableDictionary()
        mPriceData.setValue(mMinPrices, forKey: "min")
        mPriceData.setValue(mMaxPrices, forKey: "max")
        mFilterData.setValue(mPriceData, forKey: "price")
        mFilterData.setValue(mItemsId, forKey: "item")
        mFilterData.setValue(mCollectionId, forKey: "collection")
        mFilterData.setValue(mLocationsId, forKey: "location")
        mFilterData.setValue(mMetalsId, forKey: "metal")
        mFilterData.setValue(mStonesId, forKey: "stone")
        mFilterData.setValue(mSizeId, forKey: "size")
        
        let urlPath =  mUploadStocks
        
        let combinedConflictUnknown = conflictUnknownSavePayload()
        print("🔥 STOCK TAKE CONFLICT/UNKNOWN SAVE COUNT = \\(combinedConflictUnknown.count)")

        let  mParams:[String:Any] = [
            "unscanned":mSAVEUNSCANNED,
            "scanned":mSAVESCANNED,
            "unknown":combinedConflictUnknown,
            // Avoid duplicate rows in a report that reads the unified bucket.
            "conflict":[] as [Any],
            "total_scanned_qty":Int(mScannedStocks.text ?? "") ?? 0,
            "total_unscanned_qty":Int(mUnscannedStocks.text ?? "") ?? 0,
            "conflict_qty":Int(mConflictStocks.text ?? "") ?? 0,
            // This quantity belongs to the unified Conflict/Unknown report
            // bucket and must match the number of rows sent above.
            "unknown_qty": combinedConflictUnknown.count,
            "voucher_id":voucherId,
            "filter":mFilterData]
        

        print("StockTakeCreate Payload = \(mParams)")
        if Reachability.isConnectedToNetwork() == true {
            // Save must freeze RFID input so the payload cannot change mid-request.
            if ZebraRFIDService.shared.isInventoryRunning {
                print("🛑 Stop Zebra inventory before Save")
                ZebraRFIDService.shared.stopInventory()
            }

            #if !targetEnvironment(simulator) && canImport(EARfidFramework)
            if atidInventoryRunning {
                print("🛑 Stop ATID inventory before Save")
                stopATIDInventory()
            }
            #endif

            recentRFIDReads.removeAll()
            updateScannerControls()
                        AF.request(urlPath, method:.post,parameters:mParams,encoding: JSONEncoding.default, headers: sGisHeaders2).responseJSON
            { response in
                self.mMoreIcon.image = UIImage(named: "save_icg")
                self.mMoreLabel.textColor =  UIColor(named: "theme6A")
                
                
                CommonClass.stopLoader()
                
                guard response.error == nil else {
                    self.hasSuccessfulSave = false
                    self.hasSaveFailed = true
                    self.stopSaveIndicator(success: false)
                    self.showStockTakeResultMessage(success: false, message: "Save Failed. Please try again.")
                    return
                }
                
                guard let jsonData = response.data else {
                    self.hasSuccessfulSave = false
                    self.hasSaveFailed = true
                    self.stopSaveIndicator(success: false)
                    self.showStockTakeResultMessage(success: false, message: "Save Failed. Please try again.")
                    return
                }
                
                let json = try? JSONSerialization.jsonObject(with: jsonData, options: [])
                
                guard let jsonResult = json as? NSDictionary else {
                    self.hasSuccessfulSave = false
                    self.hasSaveFailed = true
                    self.stopSaveIndicator(success: false)
                    self.showStockTakeResultMessage(success: false, message: "Save Failed. Please try again.")
                    return
                }
                
                // JSONSerialization can bridge numeric values as NSNumber,
                // so read the API code safely as Int / NSNumber / String.
                let rawCode = jsonResult["code"]
                let responseCode: Int? = {
                    if let value = rawCode as? Int { return value }
                    if let value = rawCode as? NSNumber { return value.intValue }
                    if let value = rawCode as? String { return Int(value) }
                    return nil
                }()

                print("🔥 STOCK TAKE SAVE RESPONSE = \(jsonResult)")
                print("🔥 STOCK TAKE SAVE CODE = \(responseCode.map(String.init) ?? "nil")")

                if responseCode == 200 {
                    // Keep the current result visible exactly like the design
                    // screen. Only stop the reader and reset the transient RFID
                    // de-duplication cache.
                    self.recentRFIDReads.removeAll()
                    self.updateScannerControls()
                    self.hasSuccessfulSave = true
                    self.hasSaveFailed = false
                    self.stopSaveIndicator(success: true)

                    // Always show a visible confirmation after the API confirms
                    // the save.
                    let successMessage = (jsonResult["message"] as? String)?.isEmpty == false
                        ? (jsonResult["message"] as? String)!
                        : "Save Successful"
                    print("self.showStockTakeResultMessage")
                    self.showStockTakeResultMessage(
                        success: true,
                        message: "Save Successful"
                    )
                    print("CommonClass.showSnackBar(message: successMessage)")
//                    CommonClass.showSnackBar(message: successMessage)
                } else {
                    if let error = jsonResult.value(forKey: "error") as? String,
                       error == "Authorization has been expired" {
                        self.stopSaveIndicator(success: false)
                        CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                    } else {
                        self.hasSuccessfulSave = false
                        self.hasSaveFailed = true
                        self.stopSaveIndicator(success: false)
                        self.showStockTakeResultMessage(
                            success: false,
                            message: "Save Failed. Please try again."
                        )
//                        CommonClass.showSnackBar(message: "Save Failed. Please try again.")
                    }
                }
                
                
            }
        }else{
            hasSuccessfulSave = false
            hasSaveFailed = true
            stopSaveIndicator(success: false)
            showStockTakeResultMessage(success: false, message: "No Internet Connection")
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
    
    private func hasStockTakeData() -> Bool {
        let scanned = Int(mScannedStocks?.text ?? "0") ?? 0
        let conflict = Int(mConflictStocks?.text ?? "0") ?? 0
        let unknown = Int(mUnknownStocks?.text ?? "0") ?? 0
        let unscanned = Int(mUnscannedStocks?.text ?? "0") ?? 0
        // The initial session already contains the full unscanned inventory.
        // Only actual scan/result changes should trigger the unsaved-data warning.
        return scanned > 0 || conflict > 0 || unknown > 0
    }

    private func shouldConfirmLeavingWithoutSave() -> Bool {
        guard hasStockTakeData() else { return false }
        return !hasSuccessfulSave && !isSaveInProgress
    }

    private func shouldConfirmClearingWithoutSave() -> Bool {
        guard hasStockTakeData() else { return false }
        return !hasSuccessfulSave && !isSaveInProgress
    }

    private func showLeaveWithoutSavingConfirmation() {

        DispatchQueue.main.async { [weak self] in

            guard let self = self else { return }

            // หา Key Window
            guard let windowScene = self.view.window?.windowScene ??
                    UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first(where: { $0.activationState == .foregroundActive })
            else {
                print("❌ Cannot find window scene")
                return
            }

            guard let window = windowScene.windows.first(where: {
                $0.isKeyWindow
            }) else {
                print("❌ Cannot find key window")
                return
            }

            // ป้องกัน popup ซ้ำ
            if window.viewWithTag(98765) != nil {
                return
            }

            // =========================================================
            // OVERLAY
            // =========================================================

            let overlay = UIView()
            overlay.tag = 98765
            overlay.translatesAutoresizingMaskIntoConstraints = false
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.55)
            overlay.alpha = 0

            window.addSubview(overlay)

            NSLayoutConstraint.activate([
                overlay.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                overlay.topAnchor.constraint(equalTo: window.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])

            // =========================================================
            // POPUP
            // =========================================================

            let popup = UIView()
            popup.translatesAutoresizingMaskIntoConstraints = false
            popup.backgroundColor = .white
            popup.layer.cornerRadius = 8
            popup.clipsToBounds = true

            overlay.addSubview(popup)

            // =========================================================
            // TITLE
            // =========================================================

            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = "Leave without saving?"
            titleLabel.textAlignment = .center
            titleLabel.textColor = UIColor(
                red: 0.08,
                green: 0.12,
                blue: 0.20,
                alpha: 1
            )
            titleLabel.font = UIFont.systemFont(
                ofSize: 14,
                weight: .medium
            )

            popup.addSubview(titleLabel)

            // =========================================================
            // MESSAGE
            // =========================================================

            let messageLabel = UILabel()
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.text = """
            Unsaved stock take data will be lost.
            Do you want to leave this page?
            """
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 2
            messageLabel.textColor = UIColor(
                red: 0.38,
                green: 0.42,
                blue: 0.50,
                alpha: 1
            )
            messageLabel.font = UIFont.systemFont(
                ofSize: 12,
                weight: .regular
            )

            popup.addSubview(messageLabel)

            // =========================================================
            // CANCEL BUTTON
            // =========================================================

            let cancelButton = UIButton(type: .system)
            cancelButton.translatesAutoresizingMaskIntoConstraints = false

            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.setTitleColor(
                UIColor(
                    red: 0.15,
                    green: 0.20,
                    blue: 0.28,
                    alpha: 1
                ),
                for: .normal
            )

            cancelButton.titleLabel?.font =
                UIFont.systemFont(ofSize: 14)

            cancelButton.backgroundColor = .white
            cancelButton.layer.cornerRadius = 7
            cancelButton.layer.borderWidth = 1
            cancelButton.layer.borderColor =
                UIColor(
                    red: 0.78,
                    green: 0.81,
                    blue: 0.87,
                    alpha: 1
                ).cgColor

            popup.addSubview(cancelButton)

            // =========================================================
            // CLEAR BUTTON
            // =========================================================

            let clearButton = UIButton(type: .system)
            clearButton.translatesAutoresizingMaskIntoConstraints = false

            clearButton.setTitle("Leave", for: .normal)
            clearButton.setTitleColor(.white, for: .normal)

            clearButton.titleLabel?.font =
                UIFont.systemFont(
                    ofSize: 14,
                    weight: .medium
                )

            clearButton.backgroundColor = UIColor(
                red: 1.0,
                green: 0.31,
                blue: 0.34,
                alpha: 1
            )

            clearButton.layer.cornerRadius = 7

            popup.addSubview(clearButton)

            // =========================================================
            // CONSTRAINTS
            // =========================================================

            NSLayoutConstraint.activate([

                // Popup
                popup.centerXAnchor.constraint(
                    equalTo: overlay.centerXAnchor
                ),

                popup.centerYAnchor.constraint(
                    equalTo: overlay.centerYAnchor
                ),

                popup.widthAnchor.constraint(
                    equalToConstant: 320
                ),

                popup.heightAnchor.constraint(
                    equalToConstant: 168
                ),

                // Title
                titleLabel.topAnchor.constraint(
                    equalTo: popup.topAnchor,
                    constant: 24
                ),

                titleLabel.leadingAnchor.constraint(
                    equalTo: popup.leadingAnchor,
                    constant: 12
                ),

                titleLabel.trailingAnchor.constraint(
                    equalTo: popup.trailingAnchor,
                    constant: -12
                ),

                titleLabel.heightAnchor.constraint(
                    equalToConstant: 20
                ),

                // Message
                messageLabel.topAnchor.constraint(
                    equalTo: titleLabel.bottomAnchor,
                    constant: 7
                ),

                messageLabel.leadingAnchor.constraint(
                    equalTo: popup.leadingAnchor,
                    constant: 12
                ),

                messageLabel.trailingAnchor.constraint(
                    equalTo: popup.trailingAnchor,
                    constant: -12
                ),

                messageLabel.heightAnchor.constraint(
                    equalToConstant: 36
                ),

                // Cancel
                cancelButton.leadingAnchor.constraint(
                    equalTo: popup.leadingAnchor,
                    constant: 20
                ),

                cancelButton.bottomAnchor.constraint(
                    equalTo: popup.bottomAnchor,
                    constant: -24
                ),

                cancelButton.widthAnchor.constraint(
                    equalToConstant: 136
                ),

                cancelButton.heightAnchor.constraint(
                    equalToConstant: 40
                ),

                // Clear
                clearButton.trailingAnchor.constraint(
                    equalTo: popup.trailingAnchor,
                    constant: -20
                ),

                clearButton.bottomAnchor.constraint(
                    equalTo: popup.bottomAnchor,
                    constant: -24
                ),

                clearButton.widthAnchor.constraint(
                    equalToConstant: 136
                ),

                clearButton.heightAnchor.constraint(
                    equalToConstant: 40
                )
            ])

            // =========================================================
            // CANCEL
            // =========================================================

            cancelButton.addAction(
                UIAction { _ in

                    UIView.animate(
                        withDuration: 0.15,
                        animations: {
                            overlay.alpha = 0
                        },
                        completion: { _ in
                            overlay.removeFromSuperview()
                        }
                    )
                },
                for: .touchUpInside
            )

            // =========================================================
            // CLEAR
            // =========================================================

            clearButton.addAction(
                UIAction { [weak self] _ in

                    guard let self = self else {
                        overlay.removeFromSuperview()
                        return
                    }

                    UIView.animate(
                        withDuration: 0.15,
                        animations: {
                            overlay.alpha = 0
                        },
                        completion: { _ in

                            overlay.removeFromSuperview()

                            self.clearStockTakeResults()
                            self.navigationController?.popViewController(animated: true)
                        }
                    )
                },
                for: .touchUpInside
            )

            // =========================================================
            // SHOW
            // =========================================================

            window.bringSubviewToFront(overlay)

            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .curveEaseOut
            ) {
                overlay.alpha = 1
            }
        }
    }
//    private func showLeaveWithoutSavingConfirmation() {
//        let alert = UIAlertController(
//            title: "Leave without saving?",
//            message: "Unsaved stock take data will be lost. Do you want to leave anyway?",
//            preferredStyle: .alert
//        )
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        alert.addAction(UIAlertAction(title: "Leave", style: .destructive) { [weak self] _ in
//            self?.navigationController?.popViewController(animated: true)
//        })
//
//        present(alert, animated: true)
//    }

    private func showClearWithoutSavingConfirmation() {

        DispatchQueue.main.async { [weak self] in

            guard let self = self else { return }

            // หา Key Window
            guard let windowScene = self.view.window?.windowScene ??
                    UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first(where: { $0.activationState == .foregroundActive })
            else {
                print("❌ Cannot find window scene")
                return
            }

            guard let window = windowScene.windows.first(where: {
                $0.isKeyWindow
            }) else {
                print("❌ Cannot find key window")
                return
            }

            // ป้องกัน popup ซ้ำ
            if window.viewWithTag(98765) != nil {
                return
            }

            // =========================================================
            // OVERLAY
            // =========================================================

            let overlay = UIView()
            overlay.tag = 98765
            overlay.translatesAutoresizingMaskIntoConstraints = false
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.55)
            overlay.alpha = 0

            window.addSubview(overlay)

            NSLayoutConstraint.activate([
                overlay.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                overlay.topAnchor.constraint(equalTo: window.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])

            // =========================================================
            // POPUP
            // =========================================================

            let popup = UIView()
            popup.translatesAutoresizingMaskIntoConstraints = false
            popup.backgroundColor = .white
            popup.layer.cornerRadius = 8
            popup.clipsToBounds = true

            overlay.addSubview(popup)

            // =========================================================
            // TITLE
            // =========================================================

            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = "Clear data without saving?"
            titleLabel.textAlignment = .center
            titleLabel.textColor = UIColor(
                red: 0.08,
                green: 0.12,
                blue: 0.20,
                alpha: 1
            )
            titleLabel.font = UIFont.systemFont(
                ofSize: 14,
                weight: .medium
            )

            popup.addSubview(titleLabel)

            // =========================================================
            // MESSAGE
            // =========================================================

            let messageLabel = UILabel()
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.text = """
            Unsaved stock take data will be lost.
            A new session will start.
            """
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 2
            messageLabel.textColor = UIColor(
                red: 0.38,
                green: 0.42,
                blue: 0.50,
                alpha: 1
            )
            messageLabel.font = UIFont.systemFont(
                ofSize: 12,
                weight: .regular
            )

            popup.addSubview(messageLabel)

            // =========================================================
            // CANCEL BUTTON
            // =========================================================

            let cancelButton = UIButton(type: .system)
            cancelButton.translatesAutoresizingMaskIntoConstraints = false

            cancelButton.setTitle("Cancel", for: .normal)
            cancelButton.setTitleColor(
                UIColor(
                    red: 0.15,
                    green: 0.20,
                    blue: 0.28,
                    alpha: 1
                ),
                for: .normal
            )

            cancelButton.titleLabel?.font =
                UIFont.systemFont(ofSize: 14)

            cancelButton.backgroundColor = .white
            cancelButton.layer.cornerRadius = 7
            cancelButton.layer.borderWidth = 1
            cancelButton.layer.borderColor =
                UIColor(
                    red: 0.78,
                    green: 0.81,
                    blue: 0.87,
                    alpha: 1
                ).cgColor

            popup.addSubview(cancelButton)

            // =========================================================
            // CLEAR BUTTON
            // =========================================================

            let clearButton = UIButton(type: .system)
            clearButton.translatesAutoresizingMaskIntoConstraints = false

            clearButton.setTitle("Clear", for: .normal)
            clearButton.setTitleColor(.white, for: .normal)

            clearButton.titleLabel?.font =
                UIFont.systemFont(
                    ofSize: 14,
                    weight: .medium
                )

            clearButton.backgroundColor = UIColor(
                red: 1.0,
                green: 0.31,
                blue: 0.34,
                alpha: 1
            )

            clearButton.layer.cornerRadius = 7

            popup.addSubview(clearButton)

            // =========================================================
            // CONSTRAINTS
            // =========================================================

            NSLayoutConstraint.activate([

                // Popup
                popup.centerXAnchor.constraint(
                    equalTo: overlay.centerXAnchor
                ),

                popup.centerYAnchor.constraint(
                    equalTo: overlay.centerYAnchor
                ),

                popup.widthAnchor.constraint(
                    equalToConstant: 320
                ),

                popup.heightAnchor.constraint(
                    equalToConstant: 168
                ),

                // Title
                titleLabel.topAnchor.constraint(
                    equalTo: popup.topAnchor,
                    constant: 24
                ),

                titleLabel.leadingAnchor.constraint(
                    equalTo: popup.leadingAnchor,
                    constant: 12
                ),

                titleLabel.trailingAnchor.constraint(
                    equalTo: popup.trailingAnchor,
                    constant: -12
                ),

                titleLabel.heightAnchor.constraint(
                    equalToConstant: 20
                ),

                // Message
                messageLabel.topAnchor.constraint(
                    equalTo: titleLabel.bottomAnchor,
                    constant: 7
                ),

                messageLabel.leadingAnchor.constraint(
                    equalTo: popup.leadingAnchor,
                    constant: 12
                ),

                messageLabel.trailingAnchor.constraint(
                    equalTo: popup.trailingAnchor,
                    constant: -12
                ),

                messageLabel.heightAnchor.constraint(
                    equalToConstant: 36
                ),

                // Cancel
                cancelButton.leadingAnchor.constraint(
                    equalTo: popup.leadingAnchor,
                    constant: 20
                ),

                cancelButton.bottomAnchor.constraint(
                    equalTo: popup.bottomAnchor,
                    constant: -24
                ),

                cancelButton.widthAnchor.constraint(
                    equalToConstant: 136
                ),

                cancelButton.heightAnchor.constraint(
                    equalToConstant: 40
                ),

                // Clear
                clearButton.trailingAnchor.constraint(
                    equalTo: popup.trailingAnchor,
                    constant: -20
                ),

                clearButton.bottomAnchor.constraint(
                    equalTo: popup.bottomAnchor,
                    constant: -24
                ),

                clearButton.widthAnchor.constraint(
                    equalToConstant: 136
                ),

                clearButton.heightAnchor.constraint(
                    equalToConstant: 40
                )
            ])

            // =========================================================
            // CANCEL
            // =========================================================

            cancelButton.addAction(
                UIAction { _ in

                    UIView.animate(
                        withDuration: 0.15,
                        animations: {
                            overlay.alpha = 0
                        },
                        completion: { _ in
                            overlay.removeFromSuperview()
                        }
                    )
                },
                for: .touchUpInside
            )

            // =========================================================
            // CLEAR
            // =========================================================

            clearButton.addAction(
                UIAction { [weak self] _ in

                    guard let self = self else {
                        overlay.removeFromSuperview()
                        return
                    }

                    UIView.animate(
                        withDuration: 0.15,
                        animations: {
                            overlay.alpha = 0
                        },
                        completion: { _ in

                            overlay.removeFromSuperview()

                            self.clearStockTakeResults()
                        }
                    )
                },
                for: .touchUpInside
            )

            // =========================================================
            // SHOW
            // =========================================================

            window.bringSubviewToFront(overlay)

            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .curveEaseOut
            ) {
                overlay.alpha = 1
            }
        }
    }
//    private func showClearWithoutSavingConfirmation() {
//        print("showClearWithoutSavingConfirmation")
//        let alert = UIAlertController(
//            title: "Clear data without saving?",
//            message: "Unsaved stock take data will be lost. Do you want to clear it?",
//            preferredStyle: .alert
//        )
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
//            self?.clearStockTakeResults()
//        })
//        print("present(alert, animated: true)")
//        present(alert, animated: true)
//    }

    private func showSaveToastLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.saveProgressTimer?.cancel()
            self.saveProgressTimer = nil
            self.saveProgressWidthConstraint = nil
            self.saveProgressView = nil
            self.resultToastView?.removeFromSuperview()
            self.resultToastView = nil
            self.saveBlockingOverlay?.removeFromSuperview()
            self.saveBlockingOverlay = nil

            guard let windowScene = self.view.window?.windowScene ??
                    UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first(where: { $0.activationState == .foregroundActive }),
                  let window = windowScene.windows.first(where: { $0.isKeyWindow })
            else {
                return
            }

            // Block the entire Stock Take UI while Save is running.
            // The overlay is intentionally transparent enough to keep the page visible,
            // but it receives touches so menu/search/back/clear buttons cannot be tapped.
            let blockingOverlay = UIControl()
            blockingOverlay.translatesAutoresizingMaskIntoConstraints = false
            blockingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.28)
            blockingOverlay.isUserInteractionEnabled = true
            window.addSubview(blockingOverlay)

            NSLayoutConstraint.activate([
                blockingOverlay.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                blockingOverlay.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                blockingOverlay.topAnchor.constraint(equalTo: window.topAnchor),
                blockingOverlay.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])

            self.saveBlockingOverlay = blockingOverlay

            let toast = UIView()
            toast.translatesAutoresizingMaskIntoConstraints = false
            toast.backgroundColor = .white
            toast.layer.cornerRadius = 8
            toast.layer.masksToBounds = false
            toast.layer.shadowColor = UIColor(
                red: 79/255, green: 79/255, blue: 79/255, alpha: 1
            ).cgColor
            toast.layer.shadowOpacity = 0.10
            toast.layer.shadowRadius = 5
            toast.layer.shadowOffset = CGSize(width: 0, height: 4)
            window.addSubview(toast)
            window.bringSubviewToFront(toast)

            let icon = UIImageView()
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.image = UIImage(systemName: "checkmark")
            icon.tintColor = .white
            icon.backgroundColor = UIColor(
                red: 0.03, green: 0.72, blue: 0.63, alpha: 1
            )
            icon.layer.cornerRadius = 13
            icon.clipsToBounds = true
            icon.contentMode = .center
            toast.addSubview(icon)

            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Save Successful"
            label.textColor = UIColor(hex: "#555555")
            label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            label.numberOfLines = 1
            toast.addSubview(label)

            // IMPORTANT:
            // The green progress line is initially invisible (0 px).
            // It grows from left -> right exactly once.
            let progress = UIView()
            progress.translatesAutoresizingMaskIntoConstraints = false
            progress.backgroundColor = UIColor(
                red: 0.03, green: 0.72, blue: 0.63, alpha: 1
            )
            toast.addSubview(progress)

            let widthConstraint = progress.widthAnchor.constraint(equalToConstant: 0)

            NSLayoutConstraint.activate([
                toast.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                toast.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 8),
                toast.widthAnchor.constraint(equalToConstant: 360),
                toast.heightAnchor.constraint(equalToConstant: 53),

                icon.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: 14),
                icon.centerYAnchor.constraint(equalTo: toast.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 26),
                icon.heightAnchor.constraint(equalToConstant: 26),

                label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
                label.centerYAnchor.constraint(equalTo: toast.centerYAnchor),
                label.trailingAnchor.constraint(equalTo: toast.trailingAnchor, constant: -14),

                progress.leadingAnchor.constraint(equalTo: toast.leadingAnchor),
                progress.bottomAnchor.constraint(equalTo: toast.bottomAnchor),
                widthConstraint,
                progress.heightAnchor.constraint(equalToConstant: 3)
            ])

            self.resultToastView = toast
            self.saveProgressView = progress
            self.saveProgressWidthConstraint = widthConstraint

            window.bringSubviewToFront(toast)
            toast.layoutIfNeeded()

            // Start with NO green line.
            widthConstraint.constant = 0
            toast.layoutIfNeeded()

            // One pass only. While the API is running, the line advances
            // smoothly toward the end; it is never reset/repeated.
            // The completion handler in showStockTakeResultMessage() will
            // force it to 100% when the actual Save response arrives.
            let estimatedDuration: TimeInterval = 3.0
            widthConstraint.constant = 360

            UIView.animate(
                withDuration: estimatedDuration,
                delay: 0,
                options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction],
                animations: {
                    toast.layoutIfNeeded()
                },
                completion: { [weak self, weak toast] _ in
                    // Do not create another cycle. If the API is still running,
                    // leave the bar full and wait for the real Save response.
                    guard let self = self, let toast = toast else { return }
                    if self.isSaveInProgress && self.resultToastView === toast {
                        widthConstraint.constant = 360
                        toast.layoutIfNeeded()
                    }
                }
            )
        }
    }


    private func showStockTakeResultMessage(success: Bool, message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // When Save finishes, force the green bar to reach the right edge
            // first, then replace the loading toast with the final result.
            let finishAndRender: () -> Void = { [weak self] in
                guard let self = self else { return }

                self.saveProgressTimer?.cancel()
                self.saveProgressTimer = nil
                self.saveProgressWidthConstraint = nil
                self.saveProgressView = nil

                self.resultToastView?.removeFromSuperview()
                self.resultToastView = nil

                // Re-enable the page only after the Save loading/result transition is complete.
                self.saveBlockingOverlay?.removeFromSuperview()
                self.saveBlockingOverlay = nil

                guard let windowScene = self.view.window?.windowScene ??
                        UIApplication.shared.connectedScenes
                            .compactMap({ $0 as? UIWindowScene })
                            .first(where: { $0.activationState == .foregroundActive }),
                      let window = windowScene.windows.first(where: { $0.isKeyWindow })
                else {
                    return
                }

                let toast = UIView()
                toast.translatesAutoresizingMaskIntoConstraints = false
                toast.backgroundColor = .white
                toast.layer.cornerRadius = 8
                toast.layer.masksToBounds = false
                toast.layer.shadowColor = UIColor(
                    red: 79/255, green: 79/255, blue: 79/255, alpha: 1
                ).cgColor
                toast.layer.shadowOpacity = 0.10
                toast.layer.shadowRadius = 5
                toast.layer.shadowOffset = CGSize(width: 0, height: 4)
                window.addSubview(toast)

                let icon = UIImageView()
                icon.translatesAutoresizingMaskIntoConstraints = false
                icon.image = UIImage(systemName: success ? "checkmark" : "xmark")
                icon.tintColor = .white
                icon.backgroundColor = success
                    ? UIColor(red: 0.03, green: 0.72, blue: 0.63, alpha: 1)
                    : UIColor(red: 1.0, green: 0.32, blue: 0.34, alpha: 1)
                icon.layer.cornerRadius = 13
                icon.clipsToBounds = true
                icon.contentMode = .center
                toast.addSubview(icon)

                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = success
                    ? "Save Successful"
                    : "Save Failed. Please try again."
                label.textColor = UIColor(hex: "#555555")
                label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
                label.numberOfLines = 1
                toast.addSubview(label)

                NSLayoutConstraint.activate([
                    toast.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                    toast.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 8),
                    toast.widthAnchor.constraint(equalToConstant: 360),
                    toast.heightAnchor.constraint(equalToConstant: 53),

                    icon.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: 14),
                    icon.centerYAnchor.constraint(equalTo: toast.centerYAnchor),
                    icon.widthAnchor.constraint(equalToConstant: 26),
                    icon.heightAnchor.constraint(equalToConstant: 26),

                    label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
                    label.centerYAnchor.constraint(equalTo: toast.centerYAnchor),
                    label.trailingAnchor.constraint(equalTo: toast.trailingAnchor, constant: -14)
                ])

                self.resultToastView = toast
                window.bringSubviewToFront(toast)

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self, weak toast] in
                    guard let self = self, let toast = toast else { return }

                    UIView.animate(withDuration: 0.2, animations: {
                        toast.alpha = 0
                    }, completion: { _ in
                        toast.removeFromSuperview()
                        if self.resultToastView === toast {
                            self.resultToastView = nil
                        }
                    })
                }
            }

            guard let progress = self.saveProgressView,
                  let widthConstraint = self.saveProgressWidthConstraint,
                  let loadingToast = self.resultToastView
            else {
                finishAndRender()
                return
            }

            // The real Save response has arrived:
            // finish the SAME one-shot bar to 100%, then show final state.
            widthConstraint.constant = 360

            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction],
                animations: {
                    loadingToast.layoutIfNeeded()
                },
                completion: { _ in
                    progress.removeFromSuperview()
                    finishAndRender()
                }
            )
        }
    }

//    private func showStockTakeResultMessage(success: Bool, message: String) {
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//
//                print("📢 SHOW STOCK TAKE RESULT MESSAGE")
//                print("📢 success =", success)
//                print("📢 message =", message)
//
//                let title = success ? "Success" : "Error"
//
//                let alert = UIAlertController(
//                    title: title,
//                    message: message,
//                    preferredStyle: .alert
//                )
//
//                alert.addAction(
//                    UIAlertAction(title: "OK", style: .default)
//                )
//
//                // Make sure the alert is presented from the currently visible
//                // Stock Take view controller.
//                if let presented = self.presentedViewController {
//                    presented.present(alert, animated: true)
//                } else {
//                    self.present(alert, animated: true)
//                }
//            }
//        }
    
//    private func showStockTakeResultMessage(success: Bool, message: String) {
//            DispatchQueue.main.async {
//                let color = success
//                    ? UIColor.systemGreen
//                    : UIColor.systemRed
//
//                let background = success
//                    ? UIColor(red: 0.93, green: 1.0, blue: 0.91, alpha: 1.0)
//                    : UIColor(red: 1.0, green: 0.93, blue: 0.93, alpha: 1.0)
//
//                let toast = UIView()
//                toast.backgroundColor = background
//                toast.layer.cornerRadius = 5
//                toast.layer.borderWidth = 1
//                toast.layer.borderColor = color.cgColor
//                toast.translatesAutoresizingMaskIntoConstraints = false
//                toast.tag = 99123
//                toast.alpha = 1.0
//                toast.isUserInteractionEnabled = false
//
//                let label = UILabel()
//                label.text = message
//                label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
//                label.textColor = color
//                label.textAlignment = .center
//                label.translatesAutoresizingMaskIntoConstraints = false
//
//                toast.addSubview(label)
//
//                // Put the result message on the navigation controller view so it is
//                // above every Stock Take overlay (header/search/summary/bottom).
//                // The API callback can come from a background queue, so everything
//                // remains inside this main-queue block.
//                // UIViewController.view is an implicitly-unwrapped optional in this
//                // project, so unwrap it before using addSubview / constraints.
//                guard let hostView = self.view else {
//                    print("❌ showStockTakeResultMessage: host view is nil")
//                    return
//                }
//
//                hostView.addSubview(toast)
//                hostView.bringSubviewToFront(toast)
//                self.resultToastView?.removeFromSuperview()
//                self.resultToastView = toast
//
//                NSLayoutConstraint.activate([
//                    toast.topAnchor.constraint(equalTo: hostView.safeAreaLayoutGuide.topAnchor, constant: 8),
//                    toast.centerXAnchor.constraint(equalTo: hostView.centerXAnchor),
//                    toast.widthAnchor.constraint(greaterThanOrEqualToConstant: success ? 126 : 206),
//                    toast.heightAnchor.constraint(equalToConstant: 40),
//                    label.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: 12),
//                    label.trailingAnchor.constraint(equalTo: toast.trailingAnchor, constant: -12),
//                    label.topAnchor.constraint(equalTo: toast.topAnchor),
//                    label.bottomAnchor.constraint(equalTo: toast.bottomAnchor)
//                ])
//
//                UIView.animate(withDuration: 0.2) {
//                    toast.alpha = 1.0
//                }
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//                    UIView.animate(withDuration: 0.2, animations: {
//                        toast.alpha = 0
//                    }, completion: { [weak self] _ in
//                        toast.removeFromSuperview()
//                        if self?.resultToastView === toast {
//                            self?.resultToastView = nil
//                        }
//                    })
//                }
//            }
//        }

    func getVoucherID(){
        let params:[String: Any] = [
            "query":"{\n        vouchers(group: \"Stock_Take\") {\n          id\n          name \n      }\n        }",
            "variables":"{}"
        ]

        mGetData(url: mInventoryGrapQlUrl, headers: sGisHeaders, params: params) { response, status in
//            CommonClass.stopLoader()

            guard status else {
                self.hasSuccessfulSave = false
                self.hasSaveFailed = true
                self.stopSaveIndicator(success: false)
                self.showStockTakeResultMessage(
                    success: false,
                    message: "Save Failed. Please try again."
                )
                return
            }

            print("🔥 STOCK TAKE VOUCHER RESPONSE = \(response)")

            // Support both NSDictionary and Swift Dictionary because the
            // shared mGetData helper may return either bridged type.
            var voucherId: String?

            if let dataDictionary = response["data"] as? [String: Any],
               let vouchersArray = dataDictionary["vouchers"] as? [[String: Any]],
               let firstVoucher = vouchersArray.first {
                voucherId = firstVoucher["id"] as? String
            } else if let dataDictionary = response["data"] as? NSDictionary,
                      let vouchersArray = dataDictionary["vouchers"] as? [NSDictionary],
                      let firstVoucher = vouchersArray.first {
                voucherId = firstVoucher["id"] as? String
            }

            if let voucherId = voucherId, !voucherId.isEmpty {
                print("🔥 STOCK TAKE VOUCHER ID = \(voucherId)")
                self.mUploadStocksSave(voucherId: voucherId)
            } else {
                print("❌ STOCK TAKE VOUCHER ID NOT FOUND")
                self.hasSuccessfulSave = false
                self.hasSaveFailed = true
                self.stopSaveIndicator(success: false)
                self.showStockTakeResultMessage(
                    success: false,
                    message: "Save Failed. Please try again."
                )
            }
        }
    }

    //UI Element
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
    //UI Element
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
    //Filter and remove duplicate item from array.
    func uniqueElementsFrom(array:[String]) -> [String] {
        
        var set = Set<String>()
        let result = array.filter {
            
            guard !set.contains($0)  else { return  false }
            
            set.insert($0)
            return true
        }
        
        return result
    }
    
    
    func mGetFilterData(){
        
        let urlPath =  mGetInventoryFilter

        
        if Reachability.isConnectedToNetwork() == true {
            AF.request(urlPath, method:.post, headers: sGisHeaders2).responseJSON
            { response in
                
                guard response.error == nil else {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    return
                }
                
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
                        
                        if let mItems = mData.value(forKey: "item_name") as? NSArray {
                            if mItems.count > 0 {
                                self.mItemsData = mItems
                                self.mItemCollectionView.reloadData()
                            }
                        }
                        
                        if let mMetal = mData.value(forKey: "Metal") as? NSArray {
                            if mMetal.count > 0 {
                                self.mMetalsData = mMetal
                                self.mMetalCollectionView.reloadData()
                            }
                        }
                        
                        if let mLocation = mData.value(forKey: "location_name") as? NSArray {
                            if mLocation.count > 0 {
                                self.mLocationsData = mLocation
                                self.mLocationCollectionView.reloadData()
                            }
                        }
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
            CommonClass.showSnackBar(message: "No Internet Connection")
        }
        
        
    }
    
    
    
}

extension Array where Element : Hashable{
    
    
    func removingDuplicates() -> [Element]
    {
        
        var addedDict = [Element:Bool]()
        return filter {
            addedDict.updateValue(true,forKey:$0) == nil
        }
    }
    
    
    mutating func removingDuplicates() {
        
        self = self.removingDuplicates()
    }
}

extension String {
    
    func hexToString()->String{
        
        var finalString = ""
        let chars = Array(self)
        
        for count in stride(from: 0, to: chars.count - 1, by: 2){
            let firstDigit =  Int.init("\(chars[count])", radix: 16) ?? 0
            let lastDigit = Int.init("\(chars[count + 1])", radix: 16) ?? 0
            let decimal = firstDigit * 16 + lastDigit
            let decimalString = String(format: "%c", decimal) as String
            finalString.append(decimalString.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted)
            )
        }
        return finalString
        
        
        
    }
    
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .init(rawValue: 0))
    }
   
}

extension DataProtocol {
    func hexEncodedString(uppercase: Bool = false) -> String {
        return self.map {
            if $0 < 16 {
                return "0" + String($0, radix: 16, uppercase: uppercase)
            } else {
                return String($0, radix: 16, uppercase: uppercase)
            }
        }.joined()
    }
}
extension Data {
    func hexEncodedStrings() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 1
        
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

#if !targetEnvironment(simulator) && canImport(EARfidFramework)
// MARK: - ATID Reader SDK delegates

extension StockTakePage: EADeviceInitializeDelegate, EAReaderDelegate {

    func didCompleteInitialize(_ error: Error!) {
        if let error = error {
            print("❌ ATID device initialize failed =", error.localizedDescription)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.atidReader = nil
                self.atidReaderReady = false
                self.atidDevice = nil
                self.atidInventoryRunning = false
                self.updateScannerControls()
                self.mDeviceTableView.reloadData()
            }
            return
        }

        guard !isATIDDisconnecting, let device = atidDevice else {
            print("❌ ATID initialize completed without EADeviceBluetoothLe")
            return
        }

        print("🟢 ATID EADevice initialized =", device.name() ?? "Unknown")

        // Creating EAReader is asynchronous. Do not run any SDK property
        // calls that may wait for a response on the main queue.
        // EADeviceBluetoothLe must use the standard device initializer. This
        // matches ATID's BLE sample: the BT initializer can connect at the
        // CoreBluetooth layer but fail before readerInitialized is delivered.
        guard let reader = EAReader(
            device: device,
            // The ATID SDK can invoke readerInitialized while this initializer
            // is still returning, so the callback itself adopts the reader.
            delegate: self
        ) else {
            print("❌ ATID EAReader could not be created")
            disconnectATIDReader()
            CommonClass.showSnackBar(message: "Unable to initialize AT388 reader")
            return
        }
        atidReader = reader
        atidReaderReady = false
        atidInventoryRunning = false
        pendingBluetoothIdentifier = nil

        print("🟢 ATID EAReader created; waiting for readerInitialized callback")

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.mDeviceView.isHidden = true
            self.updateScannerControls()
            self.mDeviceTableView.reloadData()
        }
    }

    func readerInitialized(_ reader: EAReader) {
        print("🟢 ATID readerInitialized callback")

        guard !isATIDDisconnecting,
              atidPeripheral != nil else {
            print("ℹ️ Ignore stale ATID readerInitialized callback")
            return
        }

        // EAReader can notify its delegate synchronously from initWithDevice.
        // At that point atidReader has not yet been assigned by
        // didCompleteInitialize, so adopt the callback reader instead of
        // discarding a valid connected session.
        atidReader = reader

        // setTagDataType() must finish before inventory begins, but serial
        // number and firmware are diagnostic-only. Do not make the customer
        // wait for those extra BLE round trips before marking AT388 ready.
        DispatchQueue.global(qos: .userInitiated).async { [weak self, weak reader] in
            guard let self = self, let reader = reader else { return }

            reader.setTagDataType(TAG_DATA_TYPE_HEX)

            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                      !self.isATIDDisconnecting,
                      self.atidPeripheral != nil else { return }
                self.atidReader = reader
                self.atidReaderReady = true
                self.atidConnectionFailed = false
                self.atidInventoryRunning = false
                self.pendingBluetoothIdentifier = nil
                self.deviceConnectionTimeout?.cancel()
                self.deviceConnectionTimeout = nil
                self.mDeviceView.isHidden = true
                print("🟢 ATID READER READY - Play enabled")
                self.updateScannerControls()
                self.mDeviceTableView.reloadData()
            }

            // Diagnostics must never block the connection UI.
            let serial = reader.serialNumber ?? ""
            let firmware = reader.firmwareVersion() ?? ""
            print("🟢 ATID serial =", serial)
            print("🟢 ATID firmware =", firmware)
        }
    }

    func changedActionState(_ action: CommandType) {
        switch action {
        case CommandInventory:
            atidInventoryRunning = true
        case CommandStop:
            atidInventoryRunning = false
        default:
            break
        }

        DispatchQueue.main.async {
            self.updateScannerControls()
        }
    }

    func readTagResult(_ tag: String, rssi: Float, phase: Float) {
        handleATIDTag(tag, rssi: rssi, phase: phase)
    }

    func deviceStateChange(_ error: ResultType) {
        print("ℹ️ ATID device state change =", error)

        // A CoreBluetooth connection is not enough for AT388. The reader
        // must also be in the ATID interactive BLE protocol. Without it the
        // SDK reports ResultNotConnected followed by ResultTimeout and never
        // calls readerInitialized. End that incomplete session immediately
        // so the user can correct the device mode and reconnect, rather than
        // leaving the row in a loading state until the generic timeout fires.
        guard !isATIDDisconnecting,
              !atidReaderReady,
              !atidConnectionFailed else { return }

        if error == ResultNotConnected || error == ResultTimeout {
            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                      !self.isATIDDisconnecting,
                      !self.atidReaderReady,
                      !self.atidConnectionFailed else { return }

                self.atidConnectionFailed = true
                self.deviceConnectionTimeout?.cancel()
                self.deviceConnectionTimeout = nil
                print("❌ ATID RFID protocol handshake failed =", error)
                self.disconnectATIDReader()
                CommonClass.showSnackBar(
                    message: "AT388: set BTH BLE and Interactive-BTH mode, then reconnect"
                )
            }
        }
    }

    func updateDeviceState(_ error: ResultType) {
        print("ℹ️ ATID device state =", error)
    }
}
#endif
