//  ATIDTextStreamParser.swift
//  GIS
//
//  The AT388 (BLE) streams tags as ASCII text, one record per line:
//
//      ~eT40000000000000002D323231313232300000\r\n
//
//  `~eT` is followed by the tag payload in hex text. BLE delivers the stream in
//  20-byte notifications, so a record is usually split across notifications.
//  Records must therefore be reassembled by line, never decoded per notification.

import Foundation

struct ATIDTextStreamParser {

    private static let tagPrefix = "~eT"
    private static let maxBufferedBytes = 4096

    private var buffer = Data()

    mutating func reset() {
        buffer.removeAll(keepingCapacity: false)
    }

    /// Appends a BLE notification and returns the payload (hex text, uppercase) of every
    /// tag record that is now complete. Status lines (e.g. `~As...`) and the partial line
    /// seen when the stream starts mid-record are ignored.
    mutating func feed(_ data: Data) -> [String] {
        buffer.append(data)

        // Lost line terminators must not make the buffer grow forever.
        if buffer.count > Self.maxBufferedBytes {
            buffer.removeAll(keepingCapacity: false)
            return []
        }

        var payloads: [String] = []
        while let newline = buffer.firstIndex(of: 0x0A) {
            let lineData = buffer[buffer.startIndex..<newline]
            buffer.removeSubrange(buffer.startIndex...newline)

            let line = String(decoding: lineData, as: UTF8.self)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard line.hasPrefix(Self.tagPrefix) else { continue }

            let hex = line.dropFirst(Self.tagPrefix.count)
                .uppercased()
                .filter { $0.isHexDigit }
            if hex.count >= 8 {
                payloads.append(String(hex))
            }
        }
        return payloads
    }

    /// True when every byte is plain ASCII, i.e. the notification belongs to the text
    /// stream and not to a binary `0xA0` frame.
    static func isTextChunk(_ data: Data) -> Bool {
        !data.isEmpty && data.allSatisfy { $0 < 0x80 }
    }
}
