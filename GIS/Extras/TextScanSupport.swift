//
//  TextScanSupport.swift
//  GIS
//
//  "Scan Text" for text fields. When an empty field gets focus, a small "Scan Text"
//  bubble appears above the cursor. Tapping it opens the system camera text scanner
//  (the same one as the keyboard's "Text from Camera") and fills the field with the
//  text the user picks.
//

import AVFoundation
import ObjectiveC
import UIKit

extension UITextField {

    /// Turns on the "Scan Text" bubble for this field. Call it once, e.g. in viewDidLoad.
    /// It only shows when the device can scan text with the camera.
    func enableScanText() {
        guard AVCaptureDevice.default(for: .video) != nil else { return }
        guard objc_getAssociatedObject(self, &ScanTextAssociation.key) == nil else { return }

        if #available(iOS 16.0, *) {
            let callout = ScanTextCallout(field: self)
            objc_setAssociatedObject(self, &ScanTextAssociation.key, callout, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else if #available(iOS 15.0, *) {
            addScanTextButton()
        }
    }

    /// iOS 15 only: the bubble needs iOS 16, so show a small button instead.
    @available(iOS 15.0, *)
    private func addScanTextButton() {
        guard rightView == nil else { return }
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 32, height: 30)
        button.setImage(UIImage(systemName: "text.viewfinder"), for: .normal)
        button.tintColor = #colorLiteral(red: 0.3607843137, green: 0.7803921569, blue: 0.7568627451, alpha: 1)
        button.accessibilityLabel = "Scan Text".localizedString
        button.addAction(UIAction { [weak self] _ in
            self?.becomeFirstResponder()
            self?.captureTextFromCamera(nil)
        }, for: .touchUpInside)
        rightView = button
        rightViewMode = .always
    }
}

private enum ScanTextAssociation {
    static var key: UInt8 = 0
}

/// Shows the "Scan Text" bubble above the cursor when an empty field starts editing.
@available(iOS 16.0, *)
private final class ScanTextCallout: NSObject, UIEditMenuInteractionDelegate {

    private weak var field: UITextField?
    private var interaction: UIEditMenuInteraction?

    init(field: UITextField) {
        self.field = field
        super.init()
        let interaction = UIEditMenuInteraction(delegate: self)
        field.addInteraction(interaction)
        self.interaction = interaction
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fieldDidBeginEditing),
            name: UITextField.textDidBeginEditingNotification,
            object: field
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func fieldDidBeginEditing() {
        // Wait for the keyboard to settle so the bubble lands on the cursor.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.showBubble()
        }
    }

    private func showBubble() {
        guard let field, field.isFirstResponder, (field.text ?? "").isEmpty,
              field.canPerformAction(#selector(UIResponder.captureTextFromCamera(_:)), withSender: nil),
              let start = Optional(field.beginningOfDocument) else { return }
        let caret = field.caretRect(for: start)
        let point = CGPoint(x: caret.midX, y: caret.minY)
        interaction?.presentEditMenu(with: UIEditMenuConfiguration(identifier: nil, sourcePoint: point))
    }

    func editMenuInteraction(
        _ interaction: UIEditMenuInteraction,
        menuFor configuration: UIEditMenuConfiguration,
        suggestedActions: [UIMenuElement]
    ) -> UIMenu? {
        guard let field else { return nil }
        return UIMenu(children: [UIAction.captureTextFromCamera(responder: field, identifier: nil)])
    }
}
