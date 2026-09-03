//
//  BackspaceTextField.swift
//  GIS
//
//  Created by Jeweal on 9/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI

final class BackspaceUITextField: UITextField {

    var onDeleteBackwardWhenEmpty: (() -> Void)?

    override func deleteBackward() {

        if text?.isEmpty ?? true {

            onDeleteBackwardWhenEmpty?()

        }

        super.deleteBackward()

    }

}

struct BackspaceTextField: UIViewRepresentable {

    @Binding var text: String

    var placeholder: String

    var onDeleteBackwardWhenEmpty: () -> Void

    class Coordinator: NSObject, UITextFieldDelegate {

        var parent: BackspaceTextField

        init(_ parent: BackspaceTextField) {

            self.parent = parent

        }

        @objc
        func textChanged(
            _ sender: UITextField
        ) {

            parent.text = sender.text ?? ""

        }

    }

    func makeCoordinator() -> Coordinator {

        Coordinator(self)

    }

    func makeUIView(
        context: Context
    ) -> BackspaceUITextField {

        let textField = BackspaceUITextField()

        textField.delegate = context.coordinator

        textField.placeholder = placeholder

        textField.font = UIFont.systemFont(ofSize: 16)

        textField.borderStyle = .none

        textField.returnKeyType = .search

        textField.onDeleteBackwardWhenEmpty = onDeleteBackwardWhenEmpty

        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textChanged(_:)),
            for: .editingChanged
        )

        return textField

    }
    
    func updateUIView(
        _ uiView: BackspaceUITextField,
        context: Context
    ) {

        if uiView.text != text {

            uiView.text = text

        }

    }

}
