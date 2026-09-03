//
//  ImagePicker.swift
//  GIS
//
//  Created by Jeweal on 13/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//


import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {

    @Binding
    var image: UIImage?

    var sourceType: UIImagePickerController.SourceType

    func makeCoordinator() -> Coordinator {

        Coordinator(self)

    }

    func makeUIViewController(
        context: Context
    ) -> UIImagePickerController {

        let picker = UIImagePickerController()

        picker.delegate = context.coordinator
        picker.sourceType = sourceType

        return picker

    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {
    }

    class Coordinator:
        NSObject,
        UINavigationControllerDelegate,
        UIImagePickerControllerDelegate {

        let parent: ImagePicker

        init(_ parent: ImagePicker) {

            self.parent = parent

        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {

            parent.image = info[.originalImage] as? UIImage

            picker.dismiss(animated: true)

        }

        func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {

            picker.dismiss(animated: true)

        }

    }

}
