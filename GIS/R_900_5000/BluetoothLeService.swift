//
//  BluetoothLeService.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 28/11/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import Foundation
import CoreBluetooth

enum ScanDeviceType {
    case bluetooth
    case zebra
}

class ScanDevice {

    let type: ScanDeviceType
    let name: String

    let peripheral: CBPeripheral?
    let zebraReader: srfidReaderInfo?

    init(peripheral: CBPeripheral) {
        self.type = .bluetooth
        self.name = peripheral.name ?? "Bluetooth"
        self.peripheral = peripheral
        self.zebraReader = nil
    }

    init(reader: srfidReaderInfo) {
        self.type = .zebra
        self.name = reader.getReaderName() ?? "Zebra"
        self.zebraReader = reader
        self.peripheral = nil
    }
}

class BluetoothLeService {
    var mPacket = "";
    
    var peripheral: CBPeripheral?
    var readCharacteristic : CBCharacteristic?
    var writeCharacteristic : CBCharacteristic?
    
    
    var mSingleTag = true;
    var mUseMask = false;
    var mTimeout = 0;
    var mQuerySelected = true;

    
    let R5000_SERVICE = CBUUID(nsuuid: UUID(uuidString: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")!)
    
    let R5000_RX = CBUUID(nsuuid: UUID(uuidString: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")!)
    
    let R5000_TX = CBUUID(nsuuid: UUID(uuidString: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")!)
  
    let R800_3000_SERVICE = CBUUID(nsuuid: UUID(uuidString: "1D5688DE-866D-3AA4-EC46-A1BDDB37ECF6")!)
    let R800_3000_RX = CBUUID(nsuuid: UUID(uuidString: "99DB0F4B-B2EC-4CF8-BA6E-DD835743758C")!)
    
    let R800_3000_TX = CBUUID(nsuuid: UUID(uuidString: "1D5688DE-866D-3AA4-EC46-A1BDDB37ECF6")!)
    

     let R800_3000_TSERVICE = CBUUID(nsuuid: UUID(uuidString: "1D5688DE-866D-3AA4-EC46-A1BDDB37ECF6")!)
     let R800_3000_TX2 = CBUUID(nsuuid: UUID(uuidString: "99DB0F4B-B2EC-4CF8-BA6E-DD835743758C")!)
  
    let CLIENT_CHARACTERISTIC_CONFIG = CBUUID(nsuuid: UUID(uuidString: "00002902-0000-1000-8000-00805f9b34fb")!)
    
    //R900
    let HQ_UHF_READER          = "HQ_UHF_READER";
    let TSS900_UHF_READER      = "TSS9";
    let DOTR900_UHF_READER     = "BLE SPP";//"DOTR9";
    //R800
    let DOTR800_UHF_READER     = "DOTR800";
    let G2W_UHF_READER         = "RPT";
    let TSS2000_UHF_READER     = "TSS2";
    let DOT2000_UHF_READER     = "DOTR2";
    //R3000
    let DOTR3000_UHF_READER    = "DOTR3";
    let TSS3000_UHF_READER     = "TSS3";
    let RF800_UHF_READER       = "RF8";
    //R5000
    let DOTR5000_UHF_READER    = "R-5000";
    
    var mainVC : StockTakePage?
    
    var firmwareVer = ""
    var scannerType = 0
    var scannerIsRunning = 0 // 0: NO, 1: RFID, 2: Barcode
    
    init(main parent: StockTakePage) {
        self.mainVC = parent
    }
    func isConnected() -> Bool {
        return peripheral != nil
    }
    func reset() {
        mPacket = ""
        firmwareVer = ""
        scannerType = 0
        scannerIsRunning = 0
        writeCharacteristic = nil
        readCharacteristic = nil
    }
    func packetClear() {
        mPacket = ""
    }
    func pushPacket(data: Data?) {
        if let data = data,
           let str = String(data: data, encoding: .utf8){
            mPacket = mPacket + str
            
            mainVC?.receiveData()
        }
    }
    func popPacket() -> String? {
        let delimeter = DeviceProtocol.getDelimeter()
        mPacket = mPacket.removeLeadingSpaces()
        let cmds = mPacket.split(usingRegex: delimeter)
        if !cmds.isEmpty {
            let cmd = cmds[0]
            if cmd.starts(with: "$>") {
                
            }
            else if cmd.count + delimeter.count > mPacket.count {
                return nil
            }
            else if cmd.isEmpty {
                return nil
            }
            mPacket = mPacket.substring(from: cmd.count)
            return cmd.trimmingCharacters(in: .newlines)
        }
        return nil
    }
    
    func sendData(_ data: Data) {
        
        if let writeCharacteristic = writeCharacteristic {

            if let mtu = peripheral?.maximumWriteValueLength(for: .withoutResponse), data.count > mtu {
                data.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
                        let mutRawPointer = UnsafeMutableRawPointer(mutating: u8Ptr)
                        let uploadChunkSize = mtu
                        let totalSize = data.count
                        var offset = 0

                        while offset < totalSize {
                            let chunkSize = offset + uploadChunkSize > totalSize ? totalSize - offset : uploadChunkSize
                            let chunk = Data(bytesNoCopy: mutRawPointer+offset, count: chunkSize, deallocator: Data.Deallocator.none)
                            
                            self.peripheral?.writeValue(chunk, for: writeCharacteristic, type: .withoutResponse)
                            offset += chunkSize
                        }
                    }
                
            } else {
                self.peripheral?.writeValue(data, for: writeCharacteristic, type: .withoutResponse)
            }
        }
    }
    func byeBluetoothDevice() {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_BYE))
    }

    func sendCmdOpenInterface1() {
        sendData(Data(DeviceProtocol.OPEN_INTERFACE_1))
    }
    
    func sendCmdInventory(f_s: Int,f_m: Int, to: Int) {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_INVENT, [f_s, f_m, to]))
    }

    func sendCmdStop() {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_STOP))
    }
    func sendCmdSelectMask(n: Int, bits: Int, mem: Int, b_offset: Int, pattern: String, target: Int, action: Int) {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_SEL_MASK, param: [n, bits, mem, b_offset], option: pattern, param2: [target, action]))
    }
    
    func sendInventoryParam(session: Int, q: Int, m_ab: Int) {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_INVENT_PARAM,
                [session, q, m_ab]))
    }
    
    func setOpMode(singleTag: Bool, useMask: Bool, timeout: Int, querySelected: Bool) {
        mSingleTag = singleTag
        mUseMask = useMask
        mTimeout = timeout
        mQuerySelected = querySelected
    }

    func sendReadTag(w_count: Int, mem: Int, w_offset: Int, ACS_PWD: String) {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_READ_TAG_MEM,
                                             param: [w_count, mem, w_offset],
                                             option: ACS_PWD,
                                             param2: [mSingleTag ? 1 : 0, mUseMask ? (mQuerySelected ? 3 : 2) : 0, mTimeout]))
    }

    func sendWriteTag(w_count: Int, mem: Int, w_offset: Int, ACS_PWD: String, wordPattern: String) {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_WRITE_TAG_MEM,
                                             param: [w_count, mem, w_offset],
                                             options: [wordPattern, ACS_PWD],
                                             param2: [mSingleTag ? 1 : 0, mUseMask ? (mQuerySelected ? 3 : 2) : 0, mTimeout]))
    }
    func sendGetVersion() {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_GET_VERSION))
    }

    func sendSetDefaultParameter()
    {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_SET_DEF_PARAM))
    }

    func sendGettingParameter(cmd: String, p: String) {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_GET_PARAM, paramS: [cmd, p]))
    }

    func sendSettingTxPower(power: Int) {
        if (power == -1) {
            sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_SET_TX_POWER + ",-1"))
        } else {
            sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_SET_TX_POWER, [power]))
        }
    }

    func sendGetMaxPower() {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_GET_MAX_POWER))
    }

    func sendSettingTxCycle(on: Int, off: Int) {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_SET_TX_CYCLE, [on, off]))
    }
    
    func sendSetRFIDDataFormat(index: Int) {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_RFID_SET_DATA_FORMAT, [index]))
    }

    func sendSetRFIDFixDataFormat(index: Int) {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_RFID_SET_FIX_DATA_FORMAT, [index]))
    }
    /* Scanner */
    func sendGetScannerType() {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_SCANNER_GET_TYPE))
    }

    func sendGetScannerVersion() {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_SCANNER_GET_VERSION))
    }

    func sendCmdScannerScanStart() {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_SCANNER_SCAN_START))
    }

    func sendCmdScannerScanStop() {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_SCANNER_SCAN_STOP))
    }

    func sendCmdScannerSetDefault() {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_SCANNER_DEFAULT))
    }
    func sendCmdRfidTagFocus(enable: Int) {
        sendData(DeviceProtocol.makeProtocol(DeviceProtocol.CMD_RFID_SET_TAGFOCUS, [enable]));
    }
}


extension String {
    func removeLeadingSpaces() -> String {
        guard let index = firstIndex(where: {!CharacterSet(charactersIn: String($0)).isSubset(of: .newlines)}) else {
            return self
        }
        return String(self[index...])
    }
}
