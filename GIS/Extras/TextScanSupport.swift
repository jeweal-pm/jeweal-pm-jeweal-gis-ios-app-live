//
//  TextScanSupport.swift
//  GIS
//
//  "Scan Text" for every text field and text view in the app.
//
//  When an empty field gets focus, a small "Scan Text" bubble appears above the cursor.
//  Tapping it opens the system camera text scanner (the same one as the keyboard's
//  "Text from Camera") and fills the field with the text the user picks.
//
//  Call `ScanText.install()` once at launch. After that no screen needs any code.
//  Skipped automatically: password fields, fields that use a picker or other custom
//  input view, fields that already contain text, and devices without a camera or
//  without camera text scanning. A screen can opt a field out with `isScanTextEnabled = false`.
//

import AVFoundation
import ObjectiveC
import UIKit

enum ScanText {

    private static var isInstalled = false

    /// Starts watching for text fields and text views that begin editing.
    static func install() {
        guard #available(iOS 16.0, *), !isInstalled else { return }
        isInstalled = true
        let center = NotificationCenter.default
        for name in [UITextField.textDidBeginEditingNotification, UITextView.textDidBeginEditingNotification] {
            center.addObserver(forName: name, object: nil, queue: .main) { note in
                guard let view = note.object as? (UIView & UITextInput) else { return }
                ScanText.fieldDidBeginEditing(view)
            }
        }
    }

    @available(iOS 16.0, *)
    private static func fieldDidBeginEditing(_ view: UIView & UITextInput) {
        guard isEligible(view) else { return }
        let callout = (objc_getAssociatedObject(view, &Keys.callout) as? ScanTextCallout) ?? {
            let new = ScanTextCallout(target: view)
            objc_setAssociatedObject(view, &Keys.callout, new, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return new
        }()
        callout.showSoon()
    }

    private static func isEligible(_ view: UIView & UITextInput) -> Bool {
        guard view.isScanTextEnabled else { return false }
        guard AVCaptureDevice.default(for: .video) != nil else { return false }
        if let field = view as? UITextField {
            return !field.isSecureTextEntry && field.inputView == nil
        }
        if let textView = view as? UITextView {
            return !textView.isSecureTextEntry && textView.inputView == nil && textView.isEditable
        }
        return false
    }

    fileprivate enum Keys {
        static var callout: UInt8 = 0
        static var enabled: UInt8 = 0
    }
}

extension UIView {

    /// Set to `false` on a field that should not offer Scan Text. Defaults to `true`.
    var isScanTextEnabled: Bool {
        get { (objc_getAssociatedObject(self, &ScanText.Keys.enabled) as? Bool) ?? true }
        set { objc_setAssociatedObject(self, &ScanText.Keys.enabled, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

/// Shows the "Scan Text" bubble above the cursor of one field.
@available(iOS 16.0, *)
private final class ScanTextCallout: NSObject, UIEditMenuInteractionDelegate {

    private weak var target: (UIView & UITextInput)?
    private var interaction: UIEditMenuInteraction?

    init(target: UIView & UITextInput) {
        self.target = target
        super.init()
        let interaction = UIEditMenuInteraction(delegate: self)
        target.addInteraction(interaction)
        self.interaction = interaction
    }

    func showSoon() {
        // Wait for the keyboard to settle so the bubble lands on the cursor.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.show()
        }
    }

    private func show() {
        guard let target, target.isFirstResponder, !target.hasText,
              target.canPerformAction(#selector(UIResponder.captureTextFromCamera(_:)), withSender: nil)
        else { return }
        let caret = target.caretRect(for: target.beginningOfDocument)
        let point = CGPoint(x: caret.midX, y: caret.minY)
        interaction?.presentEditMenu(with: UIEditMenuConfiguration(identifier: nil, sourcePoint: point))
    }

    func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        menuFor configuration: UIEditMenuConfiguration,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu? {
        guard let target else { return nil }
        return UIMenu(children: [UIAction.captureTextFromCamera(responder: target, identifier: nil)])
    }
}
