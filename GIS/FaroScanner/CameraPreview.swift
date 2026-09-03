//
//  CameraPreview.swift
//  GIS
//
//  Created by Jeweal on 13/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {

    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {

        let view = PreviewView()

        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill

        return view
    }

    func updateUIView(
        _ uiView: PreviewView,
        context: Context
    ) {
    }

}

final class PreviewView: UIView {

    override class var layerClass: AnyClass {

        AVCaptureVideoPreviewLayer.self

    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {

        layer as! AVCaptureVideoPreviewLayer

    }

}
