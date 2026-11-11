//
//  NFCWriterManager.swift
//  GIS
//
//  NFC Writer feature. Everything under NFCWriter/ is compiled only when the
//  `NFC_WRITER` build flag is set (Build Settings > Swift Compiler - Custom Flags >
//  Active Compilation Conditions, in both Debug and Release). Remove the flag to ship without it.
//

#if NFC_WRITER
import CoreNFC

enum NFCWriteResult {
    case success
    case failure(String)
    case cancelled
}

/// Writes a Text record and a URL record to an NDEF tag using the system "Ready to Scan" sheet.
///
/// Uses `NFCTagReaderSession` (instead of `NFCNDEFReaderSession`) so that any ISO 14443 / ISO 15693 /
/// FeliCa card is detected. A card that cannot be written (e.g. MIFARE Classic access cards) now
/// produces a clear error instead of leaving the scan sheet waiting forever.
final class NFCWriterManager: NSObject, NFCTagReaderSessionDelegate {

    static var isAvailable: Bool { NFCTagReaderSession.readingAvailable }

    private var session: NFCTagReaderSession?
    /// Variants from the most complete to the smallest; the first one that fits the tag is written.
    private var messages = [NFCNDEFMessage]()
    private var completion: ((NFCWriteResult) -> Void)?
    private var pendingFailure: String?
    private var didFinish = false
    private var retryCount = 0
    private let maxRetries = 4

    func write(text: String, url: String, imageURL: URL? = nil, completion: @escaping (NFCWriteResult) -> Void) {
        guard Self.isAvailable else {
            completion(.failure("This device does not support NFC."))
            return
        }

        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)

        // Each variant is smaller than the previous one, so a small tag (e.g. NTAG213, 144 bytes) still gets
        // the link: full = title + link + photo link, then without the photo link, then the bare link.
        var variants = [[NFCNDEFPayload]]()
        let imageRecord: NFCNDEFPayload? = {
            guard let imageURL = imageURL, imageURL.scheme != nil else { return nil }
            return NFCNDEFPayload.wellKnownTypeURIPayload(url: imageURL)
        }()

        if !trimmedURL.isEmpty {
            guard let link = URL(string: trimmedURL), link.scheme != nil,
                  let linkRecord = NFCNDEFPayload.wellKnownTypeURIPayload(url: link) else {
                completion(.failure("Please enter a valid URL."))
                return
            }
            // The link record must come first: iPhone background tag reading only acts on a plain URL record
            // (it ignores Smart Poster), so the link opens even when the app is closed. The text follows it and
            // is shown by the app's own popup when the tag is scanned inside the app.
            let textRecord: NFCNDEFPayload? = trimmedText.isEmpty ? nil : NFCNDEFPayload.wellKnownTypeTextPayload(string: trimmedText, locale: Locale(identifier: "en"))
            let base = [linkRecord] + (textRecord.map { [$0] } ?? [])
            if let imageRecord = imageRecord { variants.append(base + [imageRecord]) }
            variants.append(base)
            if textRecord != nil { variants.append([linkRecord]) }
        } else if !trimmedText.isEmpty,
                  let textRecord = NFCNDEFPayload.wellKnownTypeTextPayload(string: trimmedText, locale: Locale(identifier: "en")) {
            variants.append([textRecord])
        }
        guard !variants.isEmpty else {
            completion(.failure("Nothing to write."))
            return
        }

        guard let newSession = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693],
                                                   delegate: self,
                                                   queue: nil) else {
            completion(.failure("Unable to start the NFC session."))
            return
        }

        messages = variants.map { NFCNDEFMessage(records: $0) }
        self.completion = completion
        pendingFailure = nil
        didFinish = false
        retryCount = 0

        newSession.alertMessage = "Approach to an NFC Tag"
        session = newSession
        newSession.begin()
    }

    /// NDEF Smart Poster ("Sp") holding a URI record and a title Text record.
    private static func smartPoster(title: String, url: URL) -> NFCNDEFPayload? {
        guard let uri = NFCNDEFPayload.wellKnownTypeURIPayload(url: url),
              let text = NFCNDEFPayload.wellKnownTypeTextPayload(string: title, locale: Locale(identifier: "en")) else {
            return nil
        }
        let inner = [uri, text]
        var bytes = Data()
        for (index, record) in inner.enumerated() {
            var header: UInt8 = 0x01 // TNF: NFC Forum well-known type
            if index == 0 { header |= 0x80 } // MB
            if index == inner.count - 1 { header |= 0x40 } // ME
            let short = record.payload.count < 256
            if short { header |= 0x10 } // SR
            bytes.append(header)
            bytes.append(UInt8(record.type.count))
            if short {
                bytes.append(UInt8(record.payload.count))
            } else {
                var length = UInt32(record.payload.count).bigEndian
                bytes.append(Data(bytes: &length, count: 4))
            }
            bytes.append(record.type)
            bytes.append(record.payload)
        }
        return NFCNDEFPayload(format: .nfcWellKnown, type: Data("Sp".utf8), identifier: Data(), payload: bytes)
    }

    private func finish(_ result: NFCWriteResult) {
        guard !didFinish else { return }
        didFinish = true
        let handler = completion
        completion = nil
        messages = []
        session = nil
        DispatchQueue.main.async { handler?(result) }
    }

    /// The card briefly lost contact ("Tag is not connected"): keep the session open and poll again
    /// instead of failing, so the user only has to hold the card steady.
    private func retryIfConnectionLost(_ session: NFCTagReaderSession, _ error: Error) -> Bool {
        let code = (error as? NFCReaderError)?.code
        let lost = code == .readerTransceiveErrorTagNotConnected
            || code == .readerTransceiveErrorTagConnectionLost
            || code == .readerTransceiveErrorTagResponseError
        guard lost, retryCount < maxRetries else { return false }
        retryCount += 1
        session.alertMessage = "Hold your card steady on the top of the iPhone."
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.6) { session.restartPolling() }
        return true
    }

    private func fail(_ session: NFCTagReaderSession, _ reason: String) {
        pendingFailure = reason
        session.invalidate(errorMessage: reason)
    }

    /// The NDEF-capable tag plus a readable card type, or nil when the card cannot hold NDEF data.
    private func ndefTag(from tag: NFCTag) -> (tag: NFCNDEFTag, type: String)? {
        switch tag {
        case .miFare(let mifare):
            let type: String
            switch mifare.mifareFamily {
            case .ultralight: type = "MIFARE Ultralight / NTAG"
            case .plus: type = "MIFARE Plus"
            case .desfire: type = "MIFARE DESFire"
            default: type = "MIFARE"
            }
            return (mifare, type)
        case .iso15693(let tag):
            return (tag, "ISO 15693")
        case .feliCa(let tag):
            return (tag, "FeliCa")
        case .iso7816:
            return nil
        @unknown default:
            return nil
        }
    }

    // MARK: - NFCTagReaderSessionDelegate

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let first = tags.first, !messages.isEmpty else { return }

        if tags.count > 1 {
            session.alertMessage = "More than one tag detected. Please try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { session.restartPolling() }
            return
        }

        guard let (ndef, type) = ndefTag(from: first) else {
            fail(session, "This card type is not supported for writing. Please use an NFC tag such as NTAG213/215/216.")
            return
        }

        session.connect(to: first) { [weak self] error in
            if let error = error {
                if self?.retryIfConnectionLost(session, error) == true { return }
                self?.fail(session, "Unable to connect to the \(type) card. \(error.localizedDescription)")
                return
            }
            ndef.queryNDEFStatus { status, capacity, error in
                if let error = error {
                    if self?.retryIfConnectionLost(session, error) == true { return }
                    self?.fail(session, "This \(type) card cannot be written. \(error.localizedDescription)")
                    return
                }
                switch status {
                case .notSupported:
                    self?.fail(session, "This \(type) card does not support NDEF. Please use an NFC tag such as NTAG213/215/216.")
                    return
                case .readOnly:
                    self?.fail(session, "This \(type) card is read-only.")
                    return
                default:
                    break
                }
                guard let message = self?.messages.first(where: { $0.length <= capacity }) else {
                    self?.fail(session, "The link is too long for this card (capacity \(capacity) bytes). Please use a larger NFC tag such as NTAG215/216.")
                    return
                }
                ndef.writeNDEF(message) { error in
                    if let error = error {
                        if self?.retryIfConnectionLost(session, error) == true { return }
                        self?.fail(session, "Write failed. \(error.localizedDescription)")
                    } else {
                        session.alertMessage = "Write completed."
                        self?.finish(.success)
                        session.invalidate()
                    }
                }
            }
        }
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        if let failure = pendingFailure {
            finish(.failure(failure))
            return
        }
        let code = (error as? NFCReaderError)?.code
        if code == .readerSessionInvalidationErrorUserCanceled {
            finish(.cancelled)
        } else {
            finish(.failure(error.localizedDescription))
        }
    }
}

// MARK: - Reading

struct NFCTagContent {
    let text: String?
    let url: URL?
}

enum NFCReadResult {
    case success(NFCTagContent)
    case failure(String)
    case cancelled
}

/// Reads the Text and URL stored on an NDEF tag (written by `NFCWriterManager`) while the app is open,
/// so the app can show its own popup instead of the system banner.
final class NFCReaderManager: NSObject, NFCNDEFReaderSessionDelegate {

    private var session: NFCNDEFReaderSession?
    private var completion: ((NFCReadResult) -> Void)?
    private var didFinish = false

    func read(completion: @escaping (NFCReadResult) -> Void) {
        guard NFCNDEFReaderSession.readingAvailable else {
            completion(.failure("This device does not support NFC."))
            return
        }
        self.completion = completion
        didFinish = false
        let newSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        newSession.alertMessage = "Approach to an NFC Tag"
        session = newSession
        newSession.begin()
    }

    private func finish(_ result: NFCReadResult) {
        guard !didFinish else { return }
        didFinish = true
        let handler = completion
        completion = nil
        session = nil
        DispatchQueue.main.async { handler?(result) }
    }

    /// Collects the first text and first URL of a message, looking inside Smart Poster records too.
    private static func content(of message: NFCNDEFMessage) -> NFCTagContent {
        var text: String?
        var url: URL?
        func visit(_ records: [NFCNDEFPayload]) {
            for record in records {
                if record.typeNameFormat == .nfcWellKnown, record.type == Data("Sp".utf8),
                   let inner = NFCNDEFMessage(data: record.payload) {
                    visit(inner.records)
                } else if text == nil, let value = record.wellKnownTypeTextPayload().0, !value.isEmpty {
                    text = value
                } else if url == nil, let value = record.wellKnownTypeURIPayload() {
                    url = value
                }
            }
        }
        visit(message.records)
        return NFCTagContent(text: text, url: url)
    }

    private var pendingResult: NFCReadResult?

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        let merged = messages.map(Self.content(of:))
        let text = merged.compactMap { $0.text }.first
        let url = merged.compactMap { $0.url }.first
        if text == nil && url == nil {
            pendingResult = .failure("This NFC tag has no text or link.")
        } else {
            pendingResult = .success(NFCTagContent(text: text, url: url))
        }
        // Close the system "Ready to Scan" sheet now; the result is delivered once it is gone.
        session.invalidate()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        let code = (error as? NFCReaderError)?.code
        if let result = pendingResult {
            pendingResult = nil
            finish(result)
            return
        }
        if code == .readerSessionInvalidationErrorFirstNDEFTagRead { return }
        if code == .readerSessionInvalidationErrorUserCanceled {
            finish(.cancelled)
        } else {
            finish(.failure(error.localizedDescription))
        }
    }
}
#endif
