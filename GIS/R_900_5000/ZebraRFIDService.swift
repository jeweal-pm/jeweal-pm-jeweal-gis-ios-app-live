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

    // Product decision: the Thailand option uses the reader's KHM profile on
    // this RFD40 firmware, because this SKU does not expose a THA profile.
    private let thailandDisplayCode = "TH"
    private let thailandReaderRegionCode = "KHM"
    
    private(set) var isConnected = false
    private(set) var isInventoryRunning = false
    private(set) var currentPower: Int32 = 0
    private(set) var minPower: Int32 = 0
    // RFD40 uses a 0...200 power range. Keep that safe value until the SDK
    // has returned the actual reader capabilities; some MFi sessions return
    // an empty capability response immediately after connecting.
    private(set) var maxPower: Int32 = 200
    
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
    private(set) var isConnecting = false
    private var connectingReaderID: Int32 = -1
    // Region settings are stored by the reader.  Keep this only as a session
    // optimisation so Play does not resend the same configuration repeatedly.
    private var configuredRegulatoryReaderID: Int32 = -1
    // A successful establish call only means that the Bluetooth transport is
    // open. RFD40 still needs a short time before capability/region commands
    // can be accepted by the RFID service.
    private var isReaderReadyForCommands = false
    // The RFD40 RFID commands use Zebra's ASCII channel after the Bluetooth
    // communication session is established. Without it, startInventory
    // returns SRFID_RESULT_ASCII_CONNECTION_REQUIRED (9).
    private var isASCIIConnectionReady = false
    private var pendingInventoryStart = false
    private var inventoryStartRetryCount = 0
    private var readerReadinessWorkItem: DispatchWorkItem?
    
    var availableReaders = [srfidReaderInfo]()
    private var isPickerShowing = false
    private var hasRequestedPickerForCurrentDiscovery = false
    private var isDiscoveryEnabled = false
    private var discoveryRetryWorkItem: DispatchWorkItem?
    private var discoveryAttempt = 0
    private var isUsingOperationalModeFallback = false
    
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
            // Calling srfidGetAvailableReadersList while automatic detection
            // is on starts a *second* manual BLE discovery.  The RFD40 SDK
            // then rejects it with "Failed to start requested manual
            // discovery", which can leave the Device sheet empty.
            let activeArray = NSMutableArray()
            var active: NSMutableArray? = activeArray
            let activeResult = sdk.srfidGetActiveReadersList(&active)
            print("GetActiveReaders Result =", activeResult.rawValue)
            print("Active Readers =", active?.count ?? 0)

            // The appearance callback is the source of truth while
            // automatic discovery is running.  Preserve it here so UI
            // refreshes never interrupt the active BLE discovery session.
            var result = self.availableReaders

            if !self.isDiscoveryEnabled {
                let availableArray = NSMutableArray()
                var available: NSMutableArray? = availableArray
                let availableResult = sdk.srfidGetAvailableReadersList(&available)

                print("GetAvailableReaders Result =", availableResult.rawValue)
                print("Available Readers =", available?.count ?? 0)

                for item in available ?? [] {
                    if let reader = item as? srfidReaderInfo,
                       !result.contains(where: { $0.getReaderID() == reader.getReaderID() }) {
                        result.append(reader)
                        print("Available Reader:", reader.getReaderName() ?? "", "ID:", reader.getReaderID())
                    }
                }
            } else {
                print("ℹ️ Zebra automatic discovery active - using callback cache")
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
            scheduleDiscoveryFallbackIfNeeded()
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

    /// Retry automatic BLE discovery once if the SDK did not report a reader.
    /// This is deliberately bounded: it recovers from the SDK's occasional
    /// stale discovery session without spinning forever or spamming the reader.
    private func scheduleDiscoveryFallbackIfNeeded() {
        discoveryRetryWorkItem?.cancel()

        guard availableReaders.isEmpty, discoveryAttempt == 0 else { return }

        let retry = DispatchWorkItem { [weak self] in
            guard let self = self,
                  !self.isConnected,
                  self.availableReaders.isEmpty,
                  self.discoveryAttempt == 0 else { return }

            self.discoveryAttempt = 1
            self.isDiscoveryEnabled = false
            _ = self.sdkApi?.srfidEnableAvailableReadersDetection(false)
            // If the reader is not reported through its primary MFi path,
            // make one compatible all-transport fallback attempt instead of
            // leaving the device sheet permanently empty.
            self.isUsingOperationalModeFallback = true
            let modeResult = self.sdkApi?.srfidSetOperationalMode(Int32(SRFID_OPMODE_ALL))
            print("🔄 Zebra reader not reported yet - retrying with compatible mode =", modeResult as Any)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.startDiscovery()
            }
        }

        discoveryRetryWorkItem = retry
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: retry)
    }

    
    func connect(readerID: Int32) {

        print("========== CONNECT ==========")
        print(Thread.callStackSymbols)
        print("ReaderID =", readerID)

        if isConnected {
            print("Already Connected")
            return
        }

        guard !isConnecting else {
            print("Connect already in progress for reader =", connectingReaderID)
            return
        }

        guard let sdkApi = sdkApi else {
            print("❌ Zebra SDK is unavailable")
            return
        }

        // The SDK completes some BLE session work asynchronously. Track this
        // request so repeated taps cannot start competing connections.
        isConnecting = true
        connectingReaderID = readerID

        let result = sdkApi.srfidEstablishCommunicationSession(readerID)

        print("Establish Result =", result as Any)

        switch result {

        case SRFID_RESULT_SUCCESS:
            // Some Zebra readers acknowledge a BLE session but delay (or in
            // some firmware versions omit) the session-established delegate
            // callback. Treat the successful SDK response as a usable
            // connection so Stock Take enables Play and routes it to Zebra
            // inventory instead of falling through to the legacy scanner.
            currentReaderID = readerID
            isConnected = true
            isConnecting = false
            connectingReaderID = -1
            isInventoryRunning = false
            isReaderReadyForCommands = false
            isASCIIConnectionReady = false
            scheduleReaderReadinessCheck(for: readerID)
            NotificationCenter.default.post(name: .zebraConnectionChanged, object: true)
            print("SUCCESS")

        case SRFID_RESULT_FAILURE:
            isConnecting = false
            connectingReaderID = -1
            print("FAILURE")

        case SRFID_RESULT_INVALID_PARAMS:
            isConnecting = false
            connectingReaderID = -1
            print("INVALID PARAM")

        case SRFID_RESULT_RESPONSE_ERROR:
            isConnecting = false
            connectingReaderID = -1
            print("RESPONSE ERROR")

        default:
            isConnecting = false
            connectingReaderID = -1
            print("OTHER =", String(describing: result))
        }
    }

    func disconnect() {
        let readerID = currentReaderID != -1 ? currentReaderID : connectingReaderID
        guard readerID != -1 else {
            isConnected = false
            isInventoryRunning = false
            isConnecting = false
            connectingReaderID = -1
            scannedTags.removeAll()
            NotificationCenter.default.post(name: .zebraConnectionChanged, object: false)
            return
        }

        if isInventoryRunning {
            stopInventory()
        }

        // The SDK can invoke its termination callback synchronously. Reset
        // local state first so a repeated Disconnect cannot use an invalid ID.
        isConnected = false
        isInventoryRunning = false
        isConnecting = false
        isReaderReadyForCommands = false
        isASCIIConnectionReady = false
        pendingInventoryStart = false
        inventoryStartRetryCount = 0
        readerReadinessWorkItem?.cancel()
        currentReaderID = -1
        connectingReaderID = -1
        configuredRegulatoryReaderID = -1
        scannedTags.removeAll()

        sdkApi?.srfidTerminateCommunicationSession(readerID)
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

        // Do not send RFID configuration commands during the transport-only
        // phase. The SDK otherwise returns empty power/region information
        // even though the connection callback has already fired.
        guard isReaderReadyForCommands else {
            pendingInventoryStart = true
            print("⏳ Zebra reader is still preparing RFID commands")
            return
        }

        guard isASCIIConnectionReady else {
            pendingInventoryStart = true
            print("⏳ Zebra ASCII channel is still preparing")
            return
        }

        // On RFD40 connected through MFi, this SDK version can return no
        // supported-region list even after the RFID service is ready. Do not
        // disable Play solely because that optional query fails: the reader
        // itself still validates its configured regulatory region when the
        // inventory command is sent. We never apply an arbitrary region.
        if !ensureRegulatoryRegion() {
            print("⚠️ Zebra region query unavailable; trying inventory with the reader's existing region")
        }

        inventoryStartRetryCount = 0

        let report = srfidReportConfig()
        report.setIncPC(true)
        report.setIncRSSI(true)
        report.setIncTagSeenCount(true)

        let access = srfidAccessConfig()
        access.setDoSelect(false)
        // Never rely on a stale/default value when capability discovery was
        // unavailable. Once capabilities are available, retain the exact
        // maximum reported by this reader (for example, 200 or 270).
        let supportedMaximum: Int32 = max(0, maxPower)
        let inventoryPower = Int16(
            max(
                0,
                min(supportedMaximum, currentPower)
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

    /// Marks the reader ready only after its RFID service has had time to
    /// initialise. The same check is scheduled from the establish result as
    /// a fallback because some RFD40 firmware delays the delegate callback.
    private func scheduleReaderReadinessCheck(for readerID: Int32) {
        readerReadinessWorkItem?.cancel()

        let work = DispatchWorkItem { [weak self] in
            guard let self = self,
                  self.isConnected,
                  self.currentReaderID == readerID else { return }

            self.isReaderReadyForCommands = true
            print("✅ Zebra RFID service ready for commands")

            if self.pendingInventoryStart {
                self.pendingInventoryStart = false
                self.startInventory()
            }
        }

        readerReadinessWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25, execute: work)
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
    /// The code must be one returned by the connected Zebra reader.
    @discardableResult
    func setRegulatoryRegion(_ regionCode: String) -> Bool {
        let requestedCode = regionCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !requestedCode.isEmpty else { return false }
        let code = requestedCode == thailandDisplayCode ? thailandReaderRegionCode : requestedCode

        guard isConnected, currentReaderID != -1 else {
            print("⚠️ Zebra region not applied: reader disconnected =", code)
            return false
        }

        return applyRegulatoryRegion(code)
    }

    /// These values come directly from the reader; Zebra regulatory regions
    /// are not interchangeable with generic ISO country codes.
    func supportedRegulatoryRegions() -> [(code: String, name: String)] {
        guard isConnected, currentReaderID != -1 else { return [] }

        var regions: NSMutableArray? = NSMutableArray()
        var status: NSString?
        let result = sdkApi?.srfidGetSupportedRegions(
            currentReaderID,
            aSupportedRegions: &regions,
            aStatusMessage: &status
        )

        guard result == SRFID_RESULT_SUCCESS,
              let readerRegions = regions as? [srfidRegionInfo] else {
            print("❌ Cannot get Zebra supported regions for Power menu =", status ?? "")
            return []
        }

        return readerRegions.compactMap { region in
            let code = (region.getRegionCode() ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !code.isEmpty else { return nil }
            let name = (region.getRegionName() ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            return (code: code, name: name)
        }
        .sorted { $0.code.localizedCaseInsensitiveCompare($1.code) == .orderedAscending }
    }

    /// Ensures that a reader has a regulatory region before inventory starts.
    /// Only a region returned by this exact reader is ever applied.
    private func ensureRegulatoryRegion() -> Bool {
        guard isConnected, currentReaderID != -1 else { return false }

        if configuredRegulatoryReaderID == currentReaderID {
            return true
        }

        // Zebra's Objective-C SDK expects an allocated output object. Passing
        // nil is reported as SRFID_RESULT_INVALID_PARAMS (4) on RFD40.
        var config: srfidRegulatoryConfig? = srfidRegulatoryConfig()
        var status: NSString?
        let configResult = sdkApi?.srfidGetRegulatoryConfig(
            currentReaderID,
            aRegulatoryConfig: &config,
            aStatusMessage: &status
        )

        if configResult == SRFID_RESULT_SUCCESS,
           let currentCode = config?.getRegionCode()?.trimmingCharacters(in: .whitespacesAndNewlines),
           !currentCode.isEmpty,
           currentCode.caseInsensitiveCompare("NA") != .orderedSame {
            configuredRegulatoryReaderID = currentReaderID
            print("🌍 Zebra regulatory region already configured =", currentCode)
            return true
        }

        var supportedRegions: NSMutableArray? = NSMutableArray()
        status = nil
        let regionsResult = sdkApi?.srfidGetSupportedRegions(
            currentReaderID,
            aSupportedRegions: &supportedRegions,
            aStatusMessage: &status
        )

        guard regionsResult == SRFID_RESULT_SUCCESS,
              let regions = supportedRegions as? [srfidRegionInfo],
              !regions.isEmpty else {
            print("❌ Cannot get Zebra supported regions =", status ?? "")
            return false
        }

        let supportedDescriptions = regions.map {
            "\($0.getRegionCode() ?? "") (\($0.getRegionName() ?? ""))"
        }
        print("🌍 Zebra supported regions =", supportedDescriptions)

        guard let selectedCode = matchingSupportedRegionCode(in: regions) else {
            print("⚠️ No supported Zebra region matches the saved/device country")
            return false
        }

        return applyRegulatoryRegion(selectedCode)
    }

    /// Finds a matching code from values the reader reports.  It intentionally
    /// never falls back to an arbitrary country/region, which could violate
    /// local RFID rules.
    private func matchingSupportedRegionCode(in regions: [srfidRegionInfo]) -> String? {
        let savedCode = UserDefaults.standard.string(forKey: "StockTakeRFIDFrequencyCountry")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() }
        let deviceCode = Locale.current.regionCode?.uppercased()
        let preferredCodes = [savedCode, deviceCode].compactMap { $0 }.filter { !$0.isEmpty }

        for code in preferredCodes {
            if code == thailandDisplayCode,
               let thailandFallback = regions.first(where: {
                   ($0.getRegionCode() ?? "").caseInsensitiveCompare(thailandReaderRegionCode) == .orderedSame
               }) {
                return thailandFallback.getRegionCode()
            }

            if let match = regions.first(where: {
                ($0.getRegionCode() ?? "").caseInsensitiveCompare(code) == .orderedSame
            }) {
                return match.getRegionCode()
            }
        }

        // Some Zebra firmware exposes a country name instead of its ISO code.
        for code in preferredCodes {
            guard let countryName = Locale(identifier: "en_US").localizedString(forRegionCode: code) else { continue }
            if let match = regions.first(where: {
                ($0.getRegionName() ?? "").caseInsensitiveCompare(countryName) == .orderedSame
            }) {
                return match.getRegionCode()
            }
        }

        return nil
    }

    @discardableResult
    private func applyRegulatoryRegion(_ regionCode: String) -> Bool {
        let code = regionCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty, isConnected, currentReaderID != -1 else { return false }

        var channels: NSMutableArray? = NSMutableArray()
        var hoppingConfigurable = ObjCBool(false)
        var status: NSString?
        let infoResult = sdkApi?.srfidGetRegionInfo(
            currentReaderID,
            aRegionCode: code,
            aSupportedChannels: &channels,
            aHoppingConfigurable: &hoppingConfigurable,
            aStatusMessage: &status
        )

        guard infoResult == SRFID_RESULT_SUCCESS else {
            print("❌ Cannot read Zebra region info =", code, status ?? "")
            return false
        }

        let config = srfidRegulatoryConfig()
        // Keep KVC for these Objective-C SDK properties. Some versions of
        // Zebra's Swift interface do not expose the setters as Swift members.
        config.setValue(code, forKey: "regionCode")

        // Zebra's SDK only accepts enabled channels for regions that support
        // hopping. This mirrors Zebra's sample implementation.
        if hoppingConfigurable.boolValue, let channels = channels {
            config.setValue(channels, forKey: "enabledChannelsList")
        }

        status = nil
        let setResult = sdkApi?.srfidSetRegulatoryConfig(
            currentReaderID,
            aRegulatoryConfig: config,
            aStatusMessage: &status
        )

        let success = setResult == SRFID_RESULT_SUCCESS
        if success {
            configuredRegulatoryReaderID = currentReaderID
        }
        print("🌍 Zebra region applied =", code, "result =", setResult?.rawValue ?? -1, "status =", status ?? "")
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
        discoveryRetryWorkItem?.cancel()
        discoveryAttempt = 0

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
        if connectingReaderID == readerID {
            isConnecting = false
            connectingReaderID = -1
        }
        print("Reader Disappeared =", readerID)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .zebraReaderChanged, object: readerID)
        }
    }
    
    func srfidEventCommunicationSessionEstablished(_ activeReader: srfidReaderInfo!) {
        guard let activeReader = activeReader else {
            isConnected = false
            isInventoryRunning = false
            isConnecting = false
            currentReaderID = -1
            connectingReaderID = -1
            NotificationCenter.default.post(name: .zebraConnectionChanged, object: false)
            return
        }

        print("SessionEstablished")
        print("CONNECTED")
        isConnected = true
        isConnecting = false
        currentReaderID = activeReader.getReaderID()
        connectingReaderID = -1
        configuredRegulatoryReaderID = -1
        isInventoryRunning = false
        isReaderReadyForCommands = false
        isASCIIConnectionReady = false
        inventoryStartRetryCount = 0
        scannedTags.removeAll()
        NotificationCenter.default.post(name: .zebraConnectionChanged, object: true)
        scheduleReaderReadinessCheck(for: currentReaderID)
        
        var activeReaders: NSMutableArray? = NSMutableArray()

        let result = sdkApi?.srfidGetActiveReadersList(&activeReaders)

        print("GetActiveReaders =", result?.rawValue ?? -1)
        print("ActiveReaders =", activeReaders ?? [])

        // Read the supported antenna power range. Zebra reports power in 0.1 dBm units.
        var capabilities: srfidReaderCapabilitiesInfo? = srfidReaderCapabilitiesInfo()
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
            // The MFi reader sometimes does not answer this immediately. Use
            // the known safe RFD40 ceiling rather than the old 300 default.
            maxPower = min(maxPower, 200)
            currentPower = max(minPower, min(maxPower, currentPower))
            print("⚠️ Cannot read Zebra power range:", capabilityStatus ?? "")
        }

        // RFD40 inventory commands require the reader's ASCII channel. A
        // successful Bluetooth session alone is not sufficient; otherwise
        // srfidStartInventory returns error 9 (ASCII connection required).
        let asciiResult = sdkApi?.srfidEstablishAsciiConnection(currentReaderID)
        isASCIIConnectionReady = asciiResult == SRFID_RESULT_SUCCESS
        print("ASCII Result =", asciiResult?.rawValue ?? -1)

        if !isASCIIConnectionReady {
            print("⚠️ Zebra ASCII channel was not ready after session establishment")
        }

        if isASCIIConnectionReady, isReaderReadyForCommands, pendingInventoryStart {
            pendingInventoryStart = false
            startInventory()
        }

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
        print("Connected : \(activeReader.getReaderName() ?? "")")
    }
    
    func srfidEventCommunicationSessionTerminated(_ readerID: Int32) {
        print("srfidEventCommunicationSessionTerminated")
        print("DISCONNECTED")
        isConnected = false
        isInventoryRunning = false
        isConnecting = false
        isReaderReadyForCommands = false
        isASCIIConnectionReady = false
        pendingInventoryStart = false
        inventoryStartRetryCount = 0
        readerReadinessWorkItem?.cancel()
        currentReaderID = -1
        connectingReaderID = -1
        configuredRegulatoryReaderID = -1
        scannedTags.removeAll()
        NotificationCenter.default.post(name: .zebraConnectionChanged, object: false)
        print(readerID)
    }
    
    private var scannedTags = Set<String>()

    func srfidEventReadNotify(_ readerID: Int32, aTagData tagData: srfidTagData!) {
        print("🔥 READ CALLBACK")
        print("🔥🔥🔥 READ EVENT")
        guard let tagData = tagData,
              let epc = tagData.getTagId(), !epc.isEmpty else {
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
        // This RFD40 is reported by iOS as an EAAccessory with Zebra's MFi
        // protocols (com.zebra.scanner.SSI / rfd8X00_easytext). Starting in
        // BTLE-only mode disables that MFi transport, so no reader callback
        // arrives and Play remains disabled. Use its actual MFi transport;
        // startDiscovery() still has one ALL-mode fallback for other models.
        let result = sdkApi?.srfidSetOperationalMode(Int32(SRFID_OPMODE_MFI))
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
    static let zebraRegionRequired = Notification.Name("zebraRegionRequired")
}
