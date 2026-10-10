//  StockIdDecoder.swift
//  GIS
//
//  Ported from C# RfidBridge.Net48.StockIdDecoder
//  Decodes stock_id from RFID EPC hex (JW GIS template3 encodeToHex + 32-nibble padding).

import Foundation

struct StockIdDecodeResult {
    let success: Bool
    let decodeStatus: String
    let epcHex: String?
    let stockId: String?
    let rawDecoded: String?
    let decodeWarning: String?

    static func ok(epcHex: String, stockId: String, decodeWarning: String? = nil) -> StockIdDecodeResult {
        return StockIdDecodeResult(
            success: true,
            decodeStatus: "ok",
            epcHex: epcHex,
            stockId: stockId,
            rawDecoded: nil,
            decodeWarning: decodeWarning
        )
    }

    static func fail(status: String, epcHex: String?, rawDecoded: String? = nil) -> StockIdDecodeResult {
        return StockIdDecodeResult(
            success: false,
            decodeStatus: status,
            epcHex: epcHex,
            stockId: nil,
            rawDecoded: rawDecoded,
            decodeWarning: nil
        )
    }
}

enum StockIdDecoder {

    private static let legacyMarkerHex = "2D"
    private static let fdPrefixHex = "FD"
    private static let minAsciiTextHexLength = 6
    private static let minInteriorZeroRunLength = 8
    private static let encodeToHexFieldNibbleLength = 32

    // ^[A-Za-z0-9]{1,16}$
    private static func isValidStockIdFormat(_ value: String) -> Bool {
        guard !value.isEmpty, value.count <= 16 else { return false }
        return value.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber) }
    }

    // MARK: - Public API

    static func tryDecode(_ epc: String) -> StockIdDecodeResult {
        let trimmed = epc.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .fail(status: "invalid_epc", epcHex: nil)
        }

        let epcHex = normalizeEpcHex(trimmed)
        guard !epcHex.isEmpty else {
            return .fail(status: "invalid_epc", epcHex: nil)
        }

        var candidates: [StockIdDecodeResult] = []

        // Legacy "-" marker (0x2D after zero padding)
        if let markerRange = epcHex.range(of: legacyMarkerHex, options: .caseInsensitive) {
            let markerIndex = epcHex.distance(from: epcHex.startIndex, to: markerRange.lowerBound)
            if isLegacyDashMarker(epcHex, markerIndex: markerIndex) {
                if let r = tryDecodeFromMarker(epcHex, markerIndex: markerIndex), r.success {
                    candidates.append(r)
                }
            }
        }

        if let r = tryDecodeFromEncodeToHexField(epcHex), r.success {
            candidates.append(r)
        }
        if let r = tryDecodeFromPaddedPayload(epcHex), r.success {
            candidates.append(r)
        }
        if let r = tryDecodeFromInteriorZeroPadding(epcHex), r.success {
            candidates.append(r)
        }
        if let r = tryDecodeEmbeddedAsciiTextHex(epcHex), r.success {
            candidates.append(r)
        }

        if let best = selectBestCandidate(candidates) {
            return best
        }

        return .fail(status: "invalid_format", epcHex: epcHex)
    }

    /// Convenience: returns decoded stock ID or nil.
    static func decode(_ epc: String) -> String? {
        let result = tryDecode(epc)
        return result.success ? result.stockId : nil
    }

    // MARK: - Normalize

    static func normalizeEpcHex(_ epc: String) -> String {
        var trimmed = epc.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("0x") || trimmed.hasPrefix("0X") {
            trimmed = String(trimmed.dropFirst(2))
        }

        var result = ""
        result.reserveCapacity(trimmed.count)
        for ch in trimmed {
            if ch.isHexDigit {
                result.append(ch.uppercased())
            }
        }
        return result
    }

    // MARK: - Candidate selection

    private static func selectBestCandidate(_ candidates: [StockIdDecodeResult]) -> StockIdDecodeResult? {
        guard !candidates.isEmpty else { return nil }
        return candidates
            .sorted { a, b in
                let aLen = a.stockId?.count ?? 0
                let bLen = b.stockId?.count ?? 0
                if aLen != bLen { return aLen > bLen }
                return (a.stockId ?? "") > (b.stockId ?? "")
            }
            .first
    }

    // MARK: - Legacy dash marker

    private static func isLegacyDashMarker(_ epcHex: String, markerIndex: Int) -> Bool {
        guard markerIndex >= 2 else { return false }
        let prefix = epcHex.prefix(markerIndex)
        return prefix.allSatisfy { $0 == "0" }
    }

    private static func tryDecodeFromMarker(_ epcHex: String, markerIndex: Int) -> StockIdDecodeResult? {
        let payloadStart = markerIndex + 2
        let hexPayload = extractAsciiTextHexRun(epcHex, startIndex: payloadStart)
        return finishDecode(epcHex: epcHex, hexPayload: hexPayload)
    }

    // MARK: - Padded payload (leading zeros then ASCII)

    private static func tryDecodeFromPaddedPayload(_ epcHex: String) -> StockIdDecodeResult? {
        guard let payloadStart = findPaddedPayloadStart(epcHex) else { return nil }
        let hexPayload = extractAsciiTextHexRun(epcHex, startIndex: payloadStart)
        return finishDecode(epcHex: epcHex, hexPayload: hexPayload)
    }

    private static func findPaddedPayloadStart(_ epcHex: String) -> Int? {
        var index = 0
        if epcHex.hasPrefix(fdPrefixHex) || epcHex.hasPrefix("fd") || epcHex.hasPrefix("Fd") {
            index = 2
        }
        guard index < epcHex.count else { return nil }

        let chars = Array(epcHex)
        guard chars[index] == "0" else { return nil }

        while index < chars.count && chars[index] == "0" {
            index += 1
        }
        return index < chars.count ? index : nil
    }

    // MARK: - encodeToHex field (32-nibble windows)

    private static func tryDecodeFromEncodeToHexField(_ epcHex: String) -> StockIdDecodeResult? {
        var best: StockIdDecodeResult?

        for window in getEncodeToHexWindows(epcHex) {
            if let candidate = tryDecodeEncodeToHexWindow(epcHex: epcHex, window: window), candidate.success {
                if best == nil || (candidate.stockId?.count ?? 0) > (best?.stockId?.count ?? 0) {
                    best = candidate
                }
            }
        }
        return best
    }

    private static func getEncodeToHexWindows(_ epcHex: String) -> [String] {
        guard !epcHex.isEmpty else { return [] }

        if epcHex.count <= encodeToHexFieldNibbleLength {
            return [epcHex]
        }

        var windows: [String] = []

        if epcHex.hasPrefix("FD") {
            let afterFd = String(epcHex.dropFirst(2))
            if !afterFd.isEmpty {
                let end = min(encodeToHexFieldNibbleLength, afterFd.count)
                windows.append(String(afterFd.prefix(end)))
            }
        }

        // Last 32 nibbles
        windows.append(String(epcHex.suffix(encodeToHexFieldNibbleLength)))
        return windows
    }

    private static func tryDecodeEncodeToHexWindow(epcHex: String, window: String) -> StockIdDecodeResult? {
        guard !window.isEmpty else { return nil }

        let chars = Array(window)
        var payloadStart = 0
        while payloadStart < chars.count && chars[payloadStart] == "0" {
            payloadStart += 1
        }
        guard payloadStart < chars.count else { return nil }

        let maxNibbles = chars.count - payloadStart
        let hexPayload = extractAsciiTextHexRun(window, startIndex: payloadStart, maxNibbles: maxNibbles)
        return finishDecode(epcHex: epcHex, hexPayload: hexPayload)
    }

    // MARK: - Interior zero padding

    private static func tryDecodeFromInteriorZeroPadding(_ epcHex: String) -> StockIdDecodeResult? {
        var best: StockIdDecodeResult?
        let chars = Array(epcHex)
        var zeroRun = 0

        for i in 0..<chars.count {
            if chars[i] == "0" {
                zeroRun += 1
                continue
            }
            if zeroRun >= minInteriorZeroRunLength {
                addInteriorCandidate(epcHex: epcHex, payloadStart: i, best: &best)
            }
            zeroRun = 0
        }
        if zeroRun >= minInteriorZeroRunLength {
            addInteriorCandidate(epcHex: epcHex, payloadStart: chars.count, best: &best)
        }
        return best
    }

    private static func addInteriorCandidate(epcHex: String, payloadStart: Int, best: inout StockIdDecodeResult?) {
        let hexPayload = extractAsciiTextHexRun(epcHex, startIndex: payloadStart)
        guard hexPayload.count >= 4 else { return }
        guard let candidate = finishDecode(epcHex: epcHex, hexPayload: hexPayload), candidate.success else { return }
        if best == nil || (candidate.stockId?.count ?? 0) > (best?.stockId?.count ?? 0) {
            best = candidate
        }
    }

    // MARK: - Embedded ASCII text scan

    private static func tryDecodeEmbeddedAsciiTextHex(_ epcHex: String) -> StockIdDecodeResult? {
        var best: StockIdDecodeResult?

        for start in 0..<epcHex.count {
            let hexPayload = extractAsciiTextHexRun(epcHex, startIndex: start)
            guard hexPayload.count >= minAsciiTextHexLength else { continue }

            guard let candidate = finishDecode(epcHex: epcHex, hexPayload: hexPayload), candidate.success else { continue }
            if best == nil || (candidate.stockId?.count ?? 0) > (best?.stockId?.count ?? 0) {
                best = candidate
            }
        }
        return best
    }

    // MARK: - Core helpers

    private static func extractAsciiTextHexRun(_ hex: String, startIndex: Int, maxNibbles: Int = Int.max) -> String {
        let chars = Array(hex)
        let limit = min(chars.count, startIndex + maxNibbles)
        var result = ""

        var i = startIndex
        while i + 1 < limit {
            let pair = String(chars[i]) + String(chars[i + 1])
            guard let value = UInt8(pair, radix: 16) else { break }
            guard isAsciiAlphaNumericByte(value) else { break }
            result += pair
            i += 2
        }
        return result
    }

    private static func isAsciiAlphaNumericByte(_ value: UInt8) -> Bool {
        // 0-9: 0x30-0x39, A-Z: 0x41-0x5A, a-z: 0x61-0x7A
        return (value >= 0x30 && value <= 0x39) ||
               (value >= 0x41 && value <= 0x5A) ||
               (value >= 0x61 && value <= 0x7A)
    }

    private static func decodeHexString(_ encoded: String) -> String? {
        guard !encoded.isEmpty, encoded.count % 2 == 0 else { return nil }

        let chars = Array(encoded)
        var decoded = ""
        var i = 0
        while i + 1 < chars.count {
            let pair = String(chars[i]) + String(chars[i + 1])
            guard let value = UInt8(pair, radix: 16) else { return nil }
            decoded.append(Character(UnicodeScalar(value)))
            i += 2
        }
        return decoded
    }

    private static func normalizeStockId(_ decoded: String) -> String? {
        var trimmed = decoded.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if trimmed.hasPrefix("-") {
            trimmed = String(trimmed.dropFirst())
        }
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func finishDecode(epcHex: String, hexPayload: String) -> StockIdDecodeResult? {
        guard !hexPayload.isEmpty else { return nil }
        guard let rawDecoded = decodeHexString(hexPayload) else { return nil }
        guard let stockId = normalizeStockId(rawDecoded), isValidStockIdFormat(stockId) else { return nil }

        let warning = detectShortEpcRead(epcHex: epcHex)
        return .ok(epcHex: epcHex, stockId: stockId, decodeWarning: warning)
    }

    private static func detectShortEpcRead(epcHex: String) -> String? {
        if epcHex.count >= encodeToHexFieldNibbleLength {
            return nil
        }
        return "epc_read_short"
    }
}
