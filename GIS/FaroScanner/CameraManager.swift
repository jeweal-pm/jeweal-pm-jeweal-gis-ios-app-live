//
//  CameraManager.swift
//  GIS
//

import AVFoundation
import SwiftUI

final class CameraManager: NSObject, ObservableObject {

    let session = AVCaptureSession()

    private let output = AVCapturePhotoOutput()

    private let sessionQueue = DispatchQueue(
        label: "com.faro.camera.session",
        qos: .userInitiated
    )

    private var isConfigured = false

    // เก็บ delegate ไว้จนกว่าการถ่ายรูปจะเสร็จ
    private var photoDelegate: AVCapturePhotoCaptureDelegate?

    override init() {
        super.init()
    }

    // MARK: - Start Camera

    func startCamera() {

        sessionQueue.async { [weak self] in

            guard let self else {
                return
            }

            if !self.isConfigured {
                self.configureCamera()
            }

            guard self.isConfigured else {
                return
            }

            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    // MARK: - Configure Camera

    private func configureCamera() {

        guard !isConfigured else {
            return
        }

        session.beginConfiguration()

        session.sessionPreset = .photo

        // ---------------------------------------------
        // CAMERA INPUT
        // ---------------------------------------------

        guard
            let camera = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            )
        else {

            session.commitConfiguration()

            print("❌ Back camera unavailable")

            return
        }

        guard
            let input = try? AVCaptureDeviceInput(
                device: camera
            )
        else {

            session.commitConfiguration()

            print("❌ Unable to create camera input")

            return
        }

        guard session.canAddInput(input) else {

            session.commitConfiguration()

            print("❌ Cannot add camera input")

            return
        }

        session.addInput(input)

        // ---------------------------------------------
        // PHOTO OUTPUT
        // ---------------------------------------------

        guard session.canAddOutput(output) else {

            session.commitConfiguration()

            print("❌ Cannot add photo output")

            return
        }

        session.addOutput(output)

        if output.isHighResolutionCaptureEnabled == false {
            output.isHighResolutionCaptureEnabled = true
        }

        // ใช้คุณภาพภาพสูงสำหรับการส่งเข้า Search
        if #available(iOS 13.0, *) {
            output.maxPhotoQualityPrioritization = .quality
        }

        session.commitConfiguration()

        isConfigured = true

        print("✅ Camera configured")
    }

    // MARK: - Stop Camera

    func stopCamera() {

        sessionQueue.async { [weak self] in

            guard let self else {
                return
            }

            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    // MARK: - Take Photo

    func takePhoto(
        delegate: AVCapturePhotoCaptureDelegate
    ) {

        // เก็บ delegate ไว้ก่อน
        photoDelegate = delegate

        sessionQueue.async { [weak self] in

            guard let self else {
                return
            }

            // -----------------------------------------
            // ต้อง configure ก่อน
            // -----------------------------------------

            if !self.isConfigured {
                self.configureCamera()
            }

            guard self.isConfigured else {

                print("❌ Camera is not configured")

                self.photoDelegate = nil

                return
            }

            // -----------------------------------------
            // ต้องให้ session กำลังทำงาน
            // -----------------------------------------

            if !self.session.isRunning {

                print("⚠️ Camera was not running - starting now")

                self.session.startRunning()
            }

            guard self.session.isRunning else {

                print("❌ Camera session could not start")

                self.photoDelegate = nil

                return
            }

            // -----------------------------------------
            // PHOTO SETTINGS
            // -----------------------------------------

            let settings: AVCapturePhotoSettings

            if output.availablePhotoCodecTypes.contains(
                .jpeg
            ) {

                settings = AVCapturePhotoSettings(
                    format: [
                        AVVideoCodecKey:
                            AVVideoCodecType.jpeg
                    ]
                )

            } else {

                settings = AVCapturePhotoSettings()
            }

            if output.isHighResolutionCaptureEnabled {
                settings.isHighResolutionPhotoEnabled = true
            }

            if #available(iOS 13.0, *) {
                settings.photoQualityPrioritization = .quality
            }

            // -----------------------------------------
            // CAPTURE
            // -----------------------------------------

            print("📸 Capturing photo...")

            self.output.capturePhoto(
                with: settings,
                delegate: delegate
            )
        }
    }
}
