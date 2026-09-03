//
//  ZebraRFIDService.swift
//  GIS
//
//  Created by Jeweal on 24/7/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import Foundation
import ExternalAccessory
import CoreBluetooth
import ZebraScannerFramework


//class ZebraRFIDService: NSObject, srfidISdkApiDelegate {
class ZebraRFIDService: NSObject,
                        srfidISdkApiDelegate,
                        ISbtSdkApiDelegate {
    
    private(set) var isConnected = false
    private(set) var isInventoryRunning = false
    private(set) var currentPower: Int32 = 0
    private(set) var minPower: Int32 = 0
    private(set) var maxPower: Int32 = 300
    
    func sbtEventScannerAppeared(_ availableScanner: SbtScannerInfo!) {
        
    }
    
    func sbtEventScannerDisappeared(_ scannerID: Int32) {
        
    }
    
    func sbtEventCommunicationSessionEstablished(_ activeScanner: SbtScannerInfo!) {
        print("sbtEventCommunicationSessionEstablished")
        print("CONNECTED")
    }
    
    func sbtEventCommunicationSessionTerminated(_ scannerID: Int32) {
        
    }
    
    func sbtEventBarcode(_ barcodeData: String!, barcodeType: Int32, fromScanner scannerID: Int32) {
        print("📦 Barcode =", barcodeData ?? "")

            NotificationCenter.default.post(
                name: .zebraBarcodeRead,
                object: barcodeData
            )
    }
    
    func sbtEventBarcodeData(_ barcodeData: Data!, barcodeType: Int32, fromScanner scannerID: Int32) {
        let text = String(data: barcodeData, encoding: .utf8) ?? ""

            print("📦 Barcode Data =", text)

            NotificationCenter.default.post(
                name: .zebraBarcodeRead,
                object: text
            )
    }
    
    func sbtEventFirmwareUpdate(_ fwUpdateEventObj: FirmwareUpdateEvent!) {
        
    }
    
    func sbtEventImage(_ imageData: Data!, fromScanner scannerID: Int32) {
        
    }
    
    func sbtEventVideo(_ videoFrame: Data!, fromScanner scannerID: Int32) {
        
    }
        
    
    private(set) var currentReaderID: Int32 = -1
    
    var availableReaders = [srfidReaderInfo]()
    private var isPickerShowing = false
    private var hasRequestedPickerForCurrentDiscovery = false
    private var isDiscoveryEnabled = false
    
    func showPicker() {

        guard !isPickerShowing else {
            print("⚠️ Picker already showing")
            return
        }
        isPickerShowing = true

        print("Before Picker")

        DispatchQueue.main.async {
            print(Thread.isMainThread)
            print("Before Picker")

            EAAccessoryManager.shared().showBluetoothAccessoryPicker(withNameFilter: nil) { [weak self] error in

                self?.isPickerShowing = false
                print("Picker Callback")

                if let error = error {
                    print("❌ Picker Error =", error)
                } else {
                    print("✅ Picker Success")
                    // Do not poll getAvailableReadersList() here. The Zebra SDK
                    // will notify us through srfidEventReaderAppeared after the
                    // accessory connection is established. Polling at this point
                    // can start a second manual discovery while automatic
                    // discovery is already running.
                    print("📡 Picker selected - waiting for Zebra reader callback")
                }
            }

            print("After Picker")
        }

        print("After Picker")
    }
    
    func decodeFromHex(_ hex: String) -> String? {
        print("decodeFromHex hex = \(hex)")
        var value = hex

        while value.hasPrefix("00") {
            value.removeFirst(2)
        }

        while value.hasSuffix("00") {
            value.removeLast(2)
        }

        guard value.count % 2 == 0 else {
            return nil
        }
        print("VALUE =", value)

        var result = ""

        var index = value.startIndex

        while index < value.endIndex {

            let next = value.index(index, offsetBy: 2)

            let byte = String(value[index..<next])
            
            guard
                let ascii = UInt8(byte, radix: 16),
                ascii >= 32,
                ascii <= 126
            else {
                return nil
            }
            print("BYTE =", byte)
            print("ASCII =", ascii)

            result.append(Character(UnicodeScalar(ascii)))

            index = next
        }

        return result
    }
    
    func connectFirstAvailableReader() {
        
        let readers = getActualDeviceList()

//        var readers: NSMutableArray?
//
//        sdkApi?.srfidGetAvailableReadersList(&readers)
//
//        if readers == nil || readers?.count == 0 {
//
//            sdkApi?.srfidGetActiveReadersList(&readers)
//        }
//
//        guard
//            let list = readers,
//            list.count > 0
//        else {
//
//            print("No Reader")
//
//            return
//        }
//
//        print("Reader Count =", list.count)
//
//        for item in list {
//
//            guard let reader = item as? srfidReaderInfo else {
//
//                continue
//            }
//
//            print("--------------------------------")
//            print("Reader =", reader.getReaderName() ?? "")
//            print("ReaderID =", reader.getReaderID())
//            print("Active =", reader.isActive())
//
//            connect(readerID: reader.getReaderID())
//
//            break
//        }
    }
    
    func dumpAccessories() {

        let accessories = EAAccessoryManager.shared().connectedAccessories

        print("Accessory Count =", accessories.count)

        for item in accessories {

            print("------------------")
            print(item.name)
            print(item.manufacturer)
            print(item.modelNumber)
            print(item.serialNumber)
            print(item.protocolStrings)
        }
    }
    
    func getActualDeviceList() -> [srfidReaderInfo] {

        let work = { [weak self] () -> [srfidReaderInfo] in
            guard let self = self, let sdk = self.sdkApi else {
                print("❌ Zebra SDK is nil")
                return []
            }

            // Zebra expects the caller to allocate these output arrays.
            let availableArray = NSMutableArray()
            let activeArray = NSMutableArray()

            var available: NSMutableArray? = availableArray
            var active: NSMutableArray? = activeArray

            let availableResult = sdk.srfidGetAvailableReadersList(&available)
            let activeResult = sdk.srfidGetActiveReadersList(&active)

            print("GetAvailableReaders Result =", availableResult.rawValue)
            print("Available Readers =", available?.count ?? 0)
            print("GetActiveReaders Result =", activeResult.rawValue)
            print("Active Readers =", active?.count ?? 0)

            var result: [srfidReaderInfo] = []

            for item in available ?? [] {
                if let reader = item as? srfidReaderInfo {
                    result.append(reader)
                    print("Available Reader:", reader.getReaderName() ?? "", "ID:", reader.getReaderID())
                }
            }

            for item in active ?? [] {
                guard let reader = item as? srfidReaderInfo else { continue }

                if !result.contains(where: {
                    $0.getReaderID() == reader.getReaderID()
                }) {
                    result.append(reader)
                }

                print("Active Reader:", reader.getReaderName() ?? "", "ID:", reader.getReaderID())
            }

            return result
        }

        if readerDiscoveryQueue.getSpecific(key: Self.readerDiscoveryQueueKey) != nil {
            return work()
        }

        return readerDiscoveryQueue.sync(execute: work)
    }

    /// Refresh the Zebra reader list.
    /// The RFD40 accessory is discovered asynchronously on iOS, so the SDK
    /// list can legitimately be empty immediately after detection is enabled.
    @discardableResult
    func refreshReaderList() -> [srfidReaderInfo] {

        let discovered = getActualDeviceList()

        if !discovered.isEmpty {
            let update = { [weak self] in
                guard let self = self else { return }

                for reader in discovered {
                    let exists = self.availableReaders.contains {
                        $0.getReaderID() == reader.getReaderID()
                    }

                    if !exists {
                        self.availableReaders.append(reader)
                    }
                }

                print(
                    "📡 Zebra refresh - SDK =",
                    discovered.count,
                    "cached =",
                    self.availableReaders.count
                )

                NotificationCenter.default.post(
                    name: .zebraReaderChanged,
                    object: nil
                )
            }

            if Thread.isMainThread {
                update()
            } else {
                DispatchQueue.main.async(execute: update)
            }
        } else {
            print("📡 Zebra refresh - SDK = 0 cached =", availableReaders.count)
        }

        return discovered.isEmpty ? availableReaders : discovered
    }

    func startDiscovery() {

        print("🔍 Start Discovery")

        guard sdkApi != nil else {
            print("❌ Zebra SDK is nil - discovery cannot start")
            return
        }

        // IMPORTANT: srfidGetAvailableReadersList() triggers Zebra's manual
        // LE discovery internally. Do not call it while automatic available
        // reader detection is already running. That was the source of:
        // "Failed to start requested manual discovery".
        if isDiscoveryEnabled {
            print("ℹ️ Zebra discovery already enabled - skip duplicate discovery")
            return
        }

        let srfidGetSdkVersion = sdkApi?.srfidGetSdkVersion()
        print("srfidGetSdkVersion = \(String(describing: srfidGetSdkVersion))")

        let result = sdkApi?.srfidEnableAvailableReadersDetection(true)
        print("EnableDetection =", result as Any)

        if result?.rawValue == 0 {
            isDiscoveryEnabled = true
        }

        // Do NOT call getActualDeviceList()/refreshReaderList() here.
        // Zebra will deliver readers asynchronously through
        // srfidEventReaderAppeared().
        if !availableReaders.isEmpty {
            print("📡 Cached Zebra readers =", availableReaders.count)
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .zebraReaderChanged,
                    object: self.availableReaders
                )
            }
        } else {
            print("📡 Waiting for Zebra reader callback...")
        }

        // Do not automatically open Apple's accessory picker. The picker is
        // only for pairing/connecting an accessory and is not the same thing
        // as Zebra's reader discovery list. It also caused Code=2/resultFailed
        // in the current flow while the SDK was already discovering.
        // Keep showPicker() available for an explicit user action if needed.

        var log: NSString?
        let logResult = sdkApi?.srfidRetrieveDebugLog(&log)

        print("DebugLog Result =", logResult as Any)
        print("DebugLog =")
        print(log ?? "")
    }

    
    func connect(readerID: Int32) {

        print("========== CONNECT ==========")
        print(Thread.callStackSymbols)
        print("ReaderID =", readerID)

//        if currentReaderID == readerID {
//            print("Already Connected")
//            return
//        }
        if isConnected {
                print("Already Connected")
                return
            }

        let result = sdkApi?.srfidEstablishCommunicationSession(readerID)

        print("Establish Result =", result as Any)

        switch result {

        case SRFID_RESULT_SUCCESS:
            currentReaderID = readerID
            print("SUCCESS")

        case SRFID_RESULT_FAILURE:
            print("FAILURE")

        case SRFID_RESULT_INVALID_PARAMS:
            print("INVALID PARAM")

        case SRFID_RESULT_RESPONSE_ERROR:
            print("RESPONSE ERROR")

        default:
            print("OTHER =", String(describing: result))
        }
    }

    func disconnect() {

        stopInventory()

        sdkApi?.srfidTerminateCommunicationSession(currentReaderID)

        isConnected = false
        isInventoryRunning = false
        currentReaderID = -1
        scannedTags.removeAll()
        NotificationCenter.default.post(name: .zebraConnectionChanged, object: false)

        print("Disconnected")
    }

    func startScan() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.startInventory()
                }
    }
    
    func startInventory() {

        guard isConnected, currentReaderID != -1 else {
            print("❌ RFID start blocked: reader not connected")
            return
        }

        if isInventoryRunning {
            print("⚠️ RFID inventory already running")
            return
        }

        let report = srfidReportConfig()
        report.setIncPC(true)
        report.setIncRSSI(true)
        report.setIncTagSeenCount(true)

        let access = srfidAccessConfig()
        access.setDoSelect(false)
        let inventoryPower = Int16(
            max(
                Int32(Int16.min),
                min(Int32(Int16.max), currentPower)
            )
        )
        access.setPower(inventoryPower)

        var message: NSString?

        let result = sdkApi?.srfidStartInventory(
            currentReaderID,
            aMemoryBank: SRFID_MEMORYBANK_NONE,
            aReportConfig: report,
            aAccessConfig: access,
            aStatusMessage: &message
        )

        print("Inventory Result =", result?.rawValue ?? -1)
        print("Status =", message ?? "")

        if result == SRFID_RESULT_SUCCESS {
            isInventoryRunning = true
            scannedTags.removeAll()
            NotificationCenter.default.post(name: .zebraInventoryChanged, object: true)
        }
    }

    func stopInventory() {

        guard currentReaderID != -1 else {
            isInventoryRunning = false
            return
        }

        var status: NSString?

        let result = sdkApi?.srfidStopInventory(
            currentReaderID,
            aStatusMessage: &status
        )

        print("Stop Inventory =", result as Any)
        isInventoryRunning = false
        NotificationCenter.default.post(name: .zebraInventoryChanged, object: false)
    }

    /// Apply the RFID regulatory region/country code selected in the Power sheet.
    ///
    /// `srfidRegulatoryConfig.regionCode` is exposed by Zebra's Objective-C
    /// SDK, but some Swift SDK headers do not import that property correctly.
    /// Use KVC here so the same SDK property can be set without a Swift
    /// compile-time member lookup error.
    @discardableResult
    func setRegulatoryRegion(_ regionCode: String) -> Bool {
        let code = regionCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !code.isEmpty else { return false }

        guard isConnected, currentReaderID != -1 else {
            print("⚠️ Zebra region not applied: reader disconnected =", code)
            return false
        }

        let config = srfidRegulatoryConfig()

        // ZebraRFD.m sets: config.regionCode = regionCode.
        // The Swift generated interface in this project does not expose
        // `regionCode` as a Swift member, so set the same Objective-C
        // property through KVC.
        config.setValue(code, forKey: "regionCode")

        var status: NSString?
        let result = sdkApi?.srfidSetRegulatoryConfig(
            currentReaderID,
            aRegulatoryConfig: config,
            aStatusMessage: &status
        )

        let success = result == SRFID_RESULT_SUCCESS
        print("🌍 Zebra Region =", code, "result =", result?.rawValue ?? -1, "status =", status ?? "")
        return success
    }

    func setPowerValue(_ requestedPower: Int32) -> Bool {
        let power = max(minPower, min(maxPower, requestedPower))

        guard isConnected, currentReaderID != -1 else {
            currentPower = power
            print("⚠️ Zebra power stored while disconnected =", power)
            return false
        }

        var antenna: srfidAntennaConfiguration?
        var status: NSString?

        let getResult = sdkApi?.srfidGetAntennaConfiguration(
            currentReaderID,
            aAntennaConfiguration: &antenna,
            aStatusMessage: &status
        )

        guard getResult == SRFID_RESULT_SUCCESS, let antenna = antenna else {
            print("❌ Get Zebra antenna config failed =", status ?? "")
            return false
        }

        let powerValue = Int16(
            max(
                Int32(Int16.min),
                min(Int32(Int16.max), power)
            )
        )

        antenna.setPower(powerValue)

        let setResult = sdkApi?.srfidSetAntennaConfiguration(
            currentReaderID,
            aAntennaConfiguration: antenna,
            aStatusMessage: &status
        )

        let success = setResult == SRFID_RESULT_SUCCESS

        if success {
            currentPower = power
        } else {
            print("❌ Set Zebra antenna power failed =", status ?? "")
        }

        print(
            "🦓 Zebra Power =",
            power,
            "(range", minPower, "...", maxPower, ")",
            "result =",
            setResult?.rawValue ?? -1
        )

        return success
    }

    /// Existing callers can still use percentage.
    /// The reader is programmed with the real antenna power value.
    @discardableResult
    func setPowerPercent(_ percent: Int) -> Bool {
        let clampedPercent = max(0, min(100, percent))
        let range = maxPower - minPower
        let power = minPower + Int32(
            (Double(range) * Double(clampedPercent) / 100.0).rounded()
        )

        return setPowerValue(power)
    }

    /// Read the current antenna power from the connected Zebra reader.
    @discardableResult
    func refreshCurrentPower() -> Int32 {
        guard isConnected, currentReaderID != -1 else {
            return currentPower
        }

        var antenna: srfidAntennaConfiguration?
        var status: NSString?

        let result = sdkApi?.srfidGetAntennaConfiguration(
            currentReaderID,
            aAntennaConfiguration: &antenna,
            aStatusMessage: &status
        )

        guard result == SRFID_RESULT_SUCCESS, let antenna = antenna else {
            print("⚠️ Cannot read current Zebra power =", status ?? "")
            return currentPower
        }

        let value = Int32(antenna.getPower())
        currentPower = max(minPower, min(maxPower, value))

        print("🦓 Current Zebra Power =", currentPower, "/", maxPower)
        return currentPower
    }


    func srfidEventReaderAppeared(_ availableReader: srfidReaderInfo!) {

        guard let reader = availableReader else {
            print("⚠️ Reader Appeared but reader is nil")
            return
        }

        availableReaders.removeAll {
            $0.getReaderID() == reader.getReaderID()
        }

        availableReaders.append(reader)

        print("📡 Reader Appeared")
        print("Reader Name =", reader.getReaderName() ?? "")
        print("Reader ID =", reader.getReaderID())
        print("Available Reader Count =", availableReaders.count)

        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .zebraReaderChanged,
                object: reader
            )
        }
    }
    
    func srfidEventReaderDisappeared(_ readerID: Int32) {
        availableReaders.removeAll { $0.getReaderID() == readerID }
        print("Reader Disappeared =", readerID)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .zebraReaderChanged, object: readerID)
        }
    }
    
    func srfidEventCommunicationSessionEstablished(_ activeReader: srfidReaderInfo!) {
        print("SessionEstablished")
        print("CONNECTED")
        isConnected = true
        currentReaderID = activeReader.getReaderID()
        isInventoryRunning = false
        scannedTags.removeAll()
        NotificationCenter.default.post(name: .zebraConnectionChanged, object: true)
        
        var activeReaders: NSMutableArray?

        let result = sdkApi?.srfidGetActiveReadersList(&activeReaders)

        print("GetActiveReaders =", result?.rawValue ?? -1)
        print("ActiveReaders =", activeReaders ?? [])

        // Read the supported antenna power range. Zebra reports power in 0.1 dBm units.
        var capabilities: srfidReaderCapabilitiesInfo?
        var capabilityStatus: NSString?
        let capabilityResult = sdkApi?.srfidGetReaderCapabilitiesInfo(
            currentReaderID,
            aReaderCapabilitiesInfo: &capabilities,
            aStatusMessage: &capabilityStatus
        )

        if capabilityResult == SRFID_RESULT_SUCCESS, let capabilities = capabilities {
            minPower = Int32(capabilities.getMinPower())
            maxPower = Int32(capabilities.getMaxPower())
            currentPower = maxPower
            print("Zebra Power Range =", minPower, "...", maxPower)
            _ = refreshCurrentPower()
        } else {
            currentPower = maxPower
            print("⚠️ Cannot read Zebra power range:", capabilityStatus ?? "")
        }

        let asciiResult = sdkApi?.srfidEstablishAsciiConnection(currentReaderID)

        print("ASCII =", asciiResult?.rawValue ?? -1)

        print(
            "Responds Read =",
            self.responds(to: #selector(srfidEventReadNotify(_:aTagData:)))
        )
//        let tagConfig = srfidTagReportConfig()
//
//        tagConfig.setIncPC(true)
//        tagConfig.setIncRSSI(true)
//        tagConfig.setIncTagSeenCount(true)
//        tagConfig.setIncFirstSeenTime(false)
//        tagConfig.setIncLastSeenTime(false)
//        tagConfig.setIncPhase(false)
//        tagConfig.setIncChannelIdx(false)

//        var message: NSString?
//
//        let result = sdkApi?.srfidSetTagReportConfiguration(
//            currentReaderID,
//            aTagReportConfig: tagConfig,
//            aStatusMessage: &message
//        )
//
//        print("SetTagReport =", result?.rawValue ?? -1)
//        print("TagReport Status =", message ?? "")
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.startInventory()
//        }
        print("Reader =", activeReader.getReaderName() ?? "")
        print("ReaderID =", activeReader.getReaderID())
        print("Connected : \(activeReader?.getReaderName() ?? "")")
    }
    
    func srfidEventCommunicationSessionTerminated(_ readerID: Int32) {
        print("srfidEventCommunicationSessionTerminated")
        print("DISCONNECTED")
        isConnected = false
        isInventoryRunning = false
        currentReaderID = -1
        scannedTags.removeAll()
        NotificationCenter.default.post(name: .zebraConnectionChanged, object: false)
        print(readerID)
    }
    
    private var scannedTags = Set<String>()

    func srfidEventReadNotify(_ readerID: Int32, aTagData tagData: srfidTagData!) {
        print("🔥 READ CALLBACK")
        print("🔥🔥🔥 READ EVENT")
        guard let epc = tagData.getTagId(), !epc.isEmpty else {
                return
            }

            // Ignore old/wrong tags
//            if epc.uppercased().hasPrefix("E280") {
//                print("❌ Ignore EPC =", epc)
//                return
//            }

            if scannedTags.contains(epc) {
                return
            }

            var value = decodeFromHex(epc) ?? epc
            
            if value.first == "-" {
                value.removeFirst()
            }
        
            scannedTags.insert(value)

            print("POST =", value)

            NotificationCenter.default.post(
                name: .zebraTagRead,
                object: value
            )
    }
    
//    func encodeToHex(stockId) {
//      const str = String(stockId).trim();
//      if (!/^[0-9]{1,12}$/.test(str)) {
//        throw new Error('stock_id must be numeric 1-12 digits');
//      }
//      const asciiHex = str
//        .split('')
//        .map((ch) => ch.charCodeAt(0).toString(16).padStart(2, '0'))
//        .join('')
//        .toUpperCase();
//      const digitCount = str.length;
//      return asciiHex
//        .padStart(RFID_ENCODE_FIELD_NIBBLES - digitCount, '0')
//        .padEnd(RFID_ENCODE_FIELD_NIBBLES, '0')
//        .toUpperCase();
//    }
    
    func srfidEventStatusNotify(
        _ readerID: Int32,
        aEvent event: SRFID_EVENT_STATUS,
        aNotification notificationData: Any!
    ) {

        print("========== STATUS ==========")
        print("Reader =", readerID)
        print("Event =", event.rawValue)
        print("Notification =", notificationData as Any)
        print("============================")
    }
    
    func srfidEventProximityNotify(_ readerID: Int32, aProximityPercent proximityPercent: Int32) {
        print("srfidEventProximityNotify")
    }
    
    func srfidEventMultiProximityNotify(_ readerID: Int32, aTagData tagData: srfidTagData!) {
        print("srfidEventMultiProximityNotify")
    }
    
    func srfidEventTriggerNotify(_ readerID: Int32, aTriggerEvent triggerEvent: SRFID_TRIGGEREVENT) {
        
        print("srfidEventTriggerNotify")
        print("TRIGGER =", triggerEvent.rawValue)
        print("readerID = \(readerID)")
    }
    
    func srfidEventBatteryNotity(_ readerID: Int32, aBatteryEvent batteryEvent: srfidBatteryEvent!) {
        print("srfidEventBatteryNotity")
    }
    
    func srfidEventWifiScan(_ readerID: Int32, wlanSCanObject wlanScanObject: srfidWlanScanList!) {
        print("srfidEventWifiScan")
    }
    
    func srfidEventIOTSatusNotity(_ readerID: Int32, aIOTStatusEvent iotStatusEvent: srfidIOTStatusEvent!) {
        print("srfidEventIOTSatusNotity")
    }
    
    func srfidEventConnectedInterfaceNotity(_ readerID: Int32, aConnectedInterfaceEvent connectedInterfaceEvent: sfidConnectedInterfaceEvent!) {
        print("srfidEventConnectedInterfaceNotity")
    }
    
    
    static let shared = ZebraRFIDService()
    
    private var sdkApi: srfidISdkApi?

    // Zebra reader-list discovery should run off the main thread.
    private let readerDiscoveryQueue = DispatchQueue(
        label: "com.gis.zebra.rfid.readerDiscovery",
        qos: .userInitiated
    )
    private static let readerDiscoveryQueueKey = DispatchSpecificKey<Void>()

    @objc
    private func accessoryConnected(_ notification: Notification) {

        print("EAAccessoryDidConnect")

        guard !isConnected else {
            print("Skip Discovery (already connected)")
            return
        }

        startDiscovery()
    }

    @objc
    private func accessoryDisconnected(_ notification: Notification) {

        print("EAAccessoryDidDisconnect")
    }
    
    override init() {
        super.init()
        
        EAAccessoryManager.shared().registerForLocalNotifications()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessoryConnected(_:)),
            name: .EAAccessoryDidConnect,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accessoryDisconnected(_:)),
            name: .EAAccessoryDidDisconnect,
            object: nil
        )
        print("sdkApi =", sdkApi as Any)
        sdkApi = srfidSdkFactory.createRfidSdkApiInstance()
        
        let debug = sdkApi?.srfidEnableDebugLog()
        print("Debug =", debug as Any)
        sdkApi?.srfidSetDelegate(self)
        print("Delegate =", self)
        let result = sdkApi?.srfidSetOperationalMode(Int32(SRFID_OPMODE_ALL))
        print("Mode =", result as Any)
        // Reader Events
        let result1 = sdkApi?.srfidSubsribe(
            forEvents: Int32(
                SRFID_EVENT_READER_APPEARANCE |
                SRFID_EVENT_READER_DISAPPEARANCE |
                SRFID_EVENT_SESSION_ESTABLISHMENT |
                SRFID_EVENT_SESSION_TERMINATION
            )
        )
        print("Subscribe Reader =", result1 as Any)

        // Read / Status
        let result2 = sdkApi?.srfidSubsribe(
            forEvents: Int32(
                SRFID_EVENT_MASK_READ |
                SRFID_EVENT_MASK_STATUS |
                SRFID_EVENT_MASK_STATUS_OPERENDSUMMARY
            )
        )
        print("Subscribe Read =", result2 as Any)

        // Temperature / Power / Database
        let result3 = sdkApi?.srfidSubsribe(
            forEvents: Int32(
                SRFID_EVENT_MASK_TEMPERATURE |
                SRFID_EVENT_MASK_POWER |
                SRFID_EVENT_MASK_DATABASE
            )
        )
        print("Subscribe Temp =", result3 as Any)

        // Proximity
        let result4 = sdkApi?.srfidSubsribe(
            forEvents: Int32(
                SRFID_EVENT_MASK_PROXIMITY
            )
        )
        print("Subscribe Proximity =", result4 as Any)

        // Trigger
        let result5 = sdkApi?.srfidSubsribe(
            forEvents: Int32(
                SRFID_EVENT_MASK_TRIGGER
            )
        )
        print("Subscribe Trigger =", result5 as Any)

        // Battery
        let result6 = sdkApi?.srfidSubsribe(
            forEvents: Int32(
                SRFID_EVENT_MASK_BATTERY
            )
        )
        print("Subscribe Battery =", result6 as Any)

        // Multi Proximity
        let result7 = sdkApi?.srfidSubsribe(
            forEvents: Int32(
                SRFID_EVENT_MASK_MULTI_PROXIMITY
            )
        )
        print("Subscribe MultiProximity =", result7 as Any)

        // WLAN Scan
        let result8 = sdkApi?.srfidSubsribe(
            forEvents: Int32(
                SRFID_EVENT_MASK_WLAN_SCAN
            )
        )
        print("Subscribe WLAN =", result8 as Any)

        // IoT Status
        let result9 = sdkApi?.srfidSubsribe(
            forEvents: Int32(
                SRFID_EVENT_MASK_IOT_STATUS
            )
        )
        print("Subscribe IoT =", result9 as Any)

        // Connected Interface
        let result10 = sdkApi?.srfidSubsribe(
            forEvents: Int32(
                SRFID_EVENT_MASK_CONNECTED_INTERFACE
            )
        )
        print("Subscribe Interface =", result10 as Any)

        let detection = sdkApi?.srfidEnableAvailableReadersDetection(true)
        print("Detection =", detection as Any)

//        var readers = NSMutableArray()
//
//            let listResult = sdkApi?.srfidGetAvailableReadersList(&readers)
//
//            print("List Result =", listResult as Any)
//            print("Readers =", readers)
        
        sdkApi?.srfidEnableAutomaticSessionReestablishment(true)
        

        print("✅ Zebra SDK Ready")
    }
    
    
    
}

extension ZebraRFIDService {}

extension Notification.Name {
    static let zebraBarcodeRead = Notification.Name("zebraBarcodeRead")
    static let zebraTagRead = Notification.Name("zebraTagRead")
    static let zebraConnectionChanged = Notification.Name("zebraConnectionChanged")
    static let zebraInventoryChanged = Notification.Name("zebraInventoryChanged")
    static let zebraReaderChanged = Notification.Name("zebraReaderChanged")
}
