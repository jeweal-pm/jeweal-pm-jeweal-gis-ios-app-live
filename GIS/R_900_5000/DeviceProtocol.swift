//
//  DeviceProtocol.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 28/11/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import Foundation

class DeviceProtocol {
    static let NULL_1 : [UInt8] = [0x0d, 0x0a]
    static let NULL_2 : [UInt8] = [0x0d]
    static let OPEN_INTERFACE_1 : [UInt8] = [0x0d, 0x0a, 0x0d, 0x0a, 0x0d, 0x0a, 0x0d, 0x0a]
    static let OPEN_INTERFACE_2 : [UInt8] = [0x0d, 0x0d, 0x0d, 0x0d, 0x0d, 0x0d, 0x0d, 0x0d]

    static let CMD_BYE = "bye"
    
    static let SKIP_PARAM = 0xffffffff
    static var N_TYPE = 1
    
    static let CMD_INVENT = "i"
    static let CMD_STOP = "s"
    static let CMD_GET_VERSION = "ver"
    static let CMD_SET_DEF_PARAM = "default"
    static let CMD_GET_PARAM = "g"
    static let CMD_SEL_MASK = "m"
    
    static let CMD_INVENT_PARAM = "iparam"
    static let CMD_SET_TX_POWER = "txp"
    static let CMD_GET_MAX_POWER = "maxp"
    static let CMD_SET_TX_CYCLE = "txc"
    static let CMD_CHANGE_CH_STATE = "chs"
    static let CMD_SET_LINK_PROFILE = "linkp"
    static let CMD_SET_COUNTRY = "cc"
    static let CMD_GET_COUNTRY_CAP = "ccap"
    static let CMD_READ_TAG_MEM = "r"
    static let CMD_WRITE_TAG_MEM = "w"
    static let CMD_KILL_TAG = "kill"
    static let CMD_LOCK_TAG_MEM = "lock"
    static let CMD_SET_LOCK_TAG_MEM = "lockperm"
    static let CMD_PAUSE_TX = "pause"
    static let CMD_HEART_BEAT = "online"
    static let CMD_STATUS_REPORT = "alert"
    static let CMD_INVENT_REPORT_FORMAT = "ireport"
    static let CMD_INVENT_REPORT_EXT_FORMAT = "ireport.ext"
    static let CMD_SYSTEM_TIME = "time"
    static let CMD_DISLINK = "bye"

    static let CMD_UPLOAD_TAG_DATA = "br.upl"
    static let CMD_CLEAR_TAG_DATA = "br.clrlist"
    static let CMD_ALERT_READER_STATUS = "br.alert"
    static let CMD_GET_STATUS_WORD = "br.sta"
    static let CMD_SET_BUZZER_VOL = "br.vol"
    static let CMD_BEEP = "br.beep"
    static let CMD_SET_AUTO_POWER_OFF_DELAY = "br.autooff"
    static let CMD_GET_BATT_LEVEL = "br.batt"
    static let CMD_REPORT_BATT_STATE = "br.reportbatt"
    static let CMD_TURN_READER_OFF = "br.off"
    static let CMD_READER_PROPRIETARY = "br.bt.config"
    //<--eric 2013.10.18
    static let CMD_GET_BT_MAC_ADDRESS = "br.bt.mac"
    //--> eric 2013.10.18

    /* expanded command */
    /* COMMON */
    static let CMD_GET_BT_NAME = "br.bt.name"
    static let CMD_CLEAR_REPORT = "clr"
    static let CMD_GET_HW_BOARD_VERSION = "bdif"
    static let CMD_GET_OEM_INFO = "oemif"
    static let CMD_GET_LOCAL_DATA_COUNT = "br.taglist"
    static let CMD_VIBRATION = "br.vib"

    /* UHF RFID */
    static let CMD_RFID_SET_TAGFOCUS = "rf.tagfocus"
    static let CMD_RFID_SET_FASTID = "rf.fastid"
    static let CMD_RFID_TAG_SINGLE_SEARCH = "rf.ss"
    static let CMD_RFID_TAG_MULTI_SEARCH = "rf.ms"
    static let CMD_RFID_TAG_WILDCARD_SEARCH = "rf.ws"
    static let CMD_RFID_TAG_MULTI_SEARCH_GET_LIST = "rf.gsl"
    static let CMD_RFID_TAG_MULTI_SEARCH_SET_LIST = "rf.ssl"
    static let CMD_RFID_TAG_MULTI_SEARCH_CLEAR_LIST = "rf.csl"
    static let CMD_RFID_TAG_BLOCK_WRITE = "rf.bw"
    static let CMD_RFID_TAG_BLOCK_ERASE = "rf.be"
    static let CMD_RFID_SET_DATA_FORMAT = "rf.data"
    static let CMD_RFID_SET_FIX_DATA_FORMAT = "rf.fixdata"
    static let CMD_RFID_SET_PREFIX = "rf.prefix"
    static let CMD_RFID_SET_SUFFIX1 = "rf.suffix1"
    static let CMD_RFID_SET_SUFFIX2 = "rf.suffix2"
    static let CMD_SET_OUTPUT_DATA_LCD = "rf.invlcdoff"

    /* Scanner */
    static let CMD_SCANNER_GET_TYPE = "sc.type"
    static let CMD_SCANNER_GET_VERSION = "sc.ver"
    static let CMD_SCANNER_SCAN_START = "sc.start"
    static let CMD_SCANNER_SCAN_STOP = "sc.stop"
    static let CMD_SCANNER_PARAMETER = "sc.param"
    static let CMD_SCANNER_DEFAULT = "sc.default"
    static let CMD_SCANNER_OPCODE_1DSYMBOLOGIES = "0"
    static let CMD_SCANNER_OPCODE_2DSYMBOLOGIES = "1"
    static let CMD_SCANNER_OPCODE_UPCEAN = "2"
    static let CMD_SCANNER_OPCODE_ISBN = "3"
    static let CMD_SCANNER_OPCODE_CODE128 = "4"
    static let CMD_SCANNER_OPCODE_ISBT = "5"
    static let CMD_SCANNER_OPCODE_CODE39 = "6"
    static let CMD_SCANNER_OPCODE_CODE93 = "7"
    static let CMD_SCANNER_OPCODE_CODE11 = "8"
    static let CMD_SCANNER_OPCODE_INTERLEAVED2OF5 = "9"
    static let CMD_SCANNER_OPCODE_DISCRETE2OF5 = "10"
    static let CMD_SCANNER_OPCODE_CODABAR = "11"
    static let CMD_SCANNER_OPCODE_MSI = "12"
    static let CMD_SCANNER_OPCODE_MATRIX2OF5 = "13"
    static let CMD_SCANNER_OPCODE_GS1DATABAR = "14"
    static let CMD_SCANNER_OPCODE_POSTALCODE = "15"
    static let CMD_SCANNER_OPCODE_COMPOSITE = "16"
    static let CMD_SCANNER_OPCODE_MICROPDF417 = "17"
    static let CMD_SCANNER_OPCODE_MACROPDF = "18"
    static let CMD_SCANNER_OPCODE_DATAMATRIX = "19"
    static let CMD_SCANNER_OPCODE_SCANNING_PREFERENCES = "20"
    static let CMD_SCANNER_OPCODE_DATA_FORMAT = "21"
    static let CMD_SCANNER_OPCODE_REDUNDANCYNSECURITY = "22"
    static let CMD_SCANNER_OPCODE_DELIMITER = "23"

    /*IC Gauge command*/
    static let CMD_GET_BATT_LIFE = "br.battcheck"
    /*Battery Charging command*/
    static let CMD_GET_BATT_CHARGING = "br.charge"
    
    class func setType(_ type: Int) {
        DeviceProtocol.N_TYPE = type
    }
    class func getTypeSize() -> Int {
        return DeviceProtocol.N_TYPE == 1 ? 2 : 1
    }
    class func getDelimeter() -> String {
        return DeviceProtocol.N_TYPE == 1 ? "\r\n" : "\r"
    }
    class func getType() -> [UInt8] {
        return DeviceProtocol.N_TYPE == 1 ? DeviceProtocol.NULL_1 : DeviceProtocol.NULL_2
    }
    class func makeProtocol(_ cmd: String, _ param: [Int]? = nil) -> Data {
        var result = cmd
        if let param = param {
            for p in param {
                result = "\(result),\(p != DeviceProtocol.SKIP_PARAM ? "\(p)" : "" )"
            }
        }
        result = "\(result)\(getDelimeter())"
        return result.data(using: .utf8)!
    }
    class func makeProtocol(_ cmd: String, param: [Int]? = nil, param1: String?, param2: String?) -> Data {
        var result = cmd
        if let param = param {
            for p in param {
                result = "\(result),\(p != DeviceProtocol.SKIP_PARAM ? "\(p)" : "" )"
            }
        }
        result = "\(result),\(param1 ?? ""),\(param2 ?? "")"
        result = "\(result)\(getDelimeter())"
        return result.data(using: .utf8)!
    }

    class func makeProtocol(_ cmd: String, paramS: [String?]?) -> Data {
        var result = cmd
        if let param = paramS {
            for p in param {
                result = "\(result),\(p ?? "" )"
            }
        }
        result = "\(result)\(getDelimeter())"
        return result.data(using: .utf8)!
    }
    class func makeProtocol(_ cmd: String, param: [Int]?, options: [String?]? = nil, param2 : [Int]? = nil) -> Data {
        var result = cmd
        if let param = param {
            for p in param {
                result = "\(result),\(p != DeviceProtocol.SKIP_PARAM ? "\(p)" : "" )"
            }
        }
        if let param = options {
            for p in param {
                result = "\(result),\(p ?? "" )"
            }
        }
        if let param = param2 {
            for p in param {
                result = "\(result),\(p != DeviceProtocol.SKIP_PARAM ? "\(p)" : "" )"
            }
        }
        result = "\(result)\(getDelimeter())"
        return result.data(using: .utf8)!
    }
    class func makeProtocol(_ cmd: String, param: [Int]?, option: String? = nil, param2: [Int]? = nil) -> Data {
        var result = cmd
        if let param = param {
            for p in param {
                result = "\(result),\(p != DeviceProtocol.SKIP_PARAM ? "\(p)" : "" )"
            }
        }
        result = "\(result),\(option ?? "")"
        if let param = param2 {
            for p in param {
                result = "\(result),\(p != DeviceProtocol.SKIP_PARAM ? "\(p)" : "" )"
            }
        }
        result = "\(result)\(getDelimeter())"
        return result.data(using: .utf8)!
    }
    class func makeProtocol(_ cmd: String, option: String? = nil, param: [Int]? = nil) -> Data {
        var result = cmd
        result = "\(result),\(option ?? "")"
        if let param = param {
            for p in param {
                result = "\(result),\(p != DeviceProtocol.SKIP_PARAM ? "\(p)" : "" )"
            }
        }
        result = "\(result)\(getDelimeter())"
        return result.data(using: .utf8)!
    }
}
