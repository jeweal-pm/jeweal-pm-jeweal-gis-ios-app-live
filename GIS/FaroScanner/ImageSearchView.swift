//
//  ImageSearchView.swift
//  GIS
//

import SwiftUI
import AVFoundation
import UIKit

struct ImageSearchView: View {

    @Environment(\.dismiss)
    private var dismiss

    @StateObject
    private var camera = CameraManager()

    let onImageSelected: (UIImage) -> Void

    // =============================================================
    // PHOTO LIBRARY
    // =============================================================

    @State
    private var showPhotoLibrary = false

    // =============================================================
    // CAMERA CAPTURE
    // =============================================================

    @State
    private var isCapturingPhoto = false

    var body: some View {

        GeometryReader { geometry in

            let cameraHeight = geometry.size.height * 0.64
            let libraryWidth = max(0, geometry.size.width - 32)
            let gridSpacing: CGFloat = 2
            let cellWidth = max(0, (libraryWidth - (gridSpacing * 2)) / 3)
            let gridHeight = (cellWidth * 3) + (gridSpacing * 2)
            let libraryContentHeight = 68 + 14 + gridHeight + 16

            ZStack(alignment: .top) {

                // =================================================
                // CAMERA
                // =================================================

                ZStack {

                    FaroCameraPreview(
                        session: camera.session
                    )
                    .frame(
                        width: geometry.size.width,
                        height: cameraHeight
                    )
                    .clipped()

                    // ---------------------------------------------
                    // PROCESSING
                    // ---------------------------------------------

                    if isCapturingPhoto {

                        VStack {

                            Spacer()

                            HStack(spacing: 8) {

                                ProgressView()
                                    .progressViewStyle(
                                        CircularProgressViewStyle(
                                            tint: .white
                                        )
                                    )

                                Text("Processing image...")
                                    .font(
                                        .system(
                                            size: 15,
                                            weight: .medium
                                        )
                                    )
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Color.black.opacity(0.55)
                            )
                            .clipShape(
                                Capsule()
                            )

                            Spacer()
                                .frame(height: 120)
                        }
                        .allowsHitTesting(false)
                    }


                }
                .frame(
                    width: geometry.size.width,
                    height: cameraHeight,
                    alignment: .top
                )

                // =================================================
                // LIBRARY SCROLL LAYER
                // =================================================
                //
                // The ScrollView starts at the top of the screen,
                // but its first item is transparent and has the same
                // height as the camera. This keeps the original
                // layout unchanged at rest.
                //
                // When the user scrolls upward, the white Library
                // section moves over the camera instead of being
                // trapped below it. The scroll position is therefore
                // retained naturally by SwiftUI.
                //
                ScrollView(.vertical, showsIndicators: false) {

                    // Reserve the camera area. The shutter is deliberately
                    // outside this ScrollView so it never rides up the page
                    // when the Library is scrolled.
                    Color.clear
                    .frame(
                        width: geometry.size.width,
                        height: cameraHeight
                    )

                    VStack(spacing: 0) {

                        // =================================================
                        // LIBRARY HEADER
                        // =================================================

                        HStack {

                            Text("Library")
                                .font(
                                    .system(
                                        size: 17,
                                        weight: .regular
                                    )
                                )
                                .foregroundColor(.black)

                            Spacer()

                            Button {

                                openPhotoLibrary()

                            } label: {

                                Text("View all")
                                    .font(
                                        .system(
                                            size: 15,
                                            weight: .regular
                                        )
                                    )
                                    .foregroundColor(
                                        Color.gray.opacity(0.55)
                                    )
                                    .frame(
                                        minWidth: 72,
                                        minHeight: 44
                                    )
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                            .zIndex(100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .frame(
                            width: geometry.size.width,
                            height: 68,
                            alignment: .center
                        )
                        .background(Color.white)
                        .zIndex(100)

                        // =================================================
                        // RECENT PHOTOS
                        // =================================================

                        RecentLibraryView { image in

                            camera.stopCamera()

                            onImageSelected(image)

                            dismiss()
                        }
                        .padding(.horizontal, 16)
                        .frame(
                            width: geometry.size.width,
                            height: gridHeight,
                            alignment: .top
                        )
                        .background(Color.white)
                        .clipped()

                        Color.white
                            .frame(
                                width: geometry.size.width,
                                height: 16
                            )
                    }
                    .frame(
                        width: geometry.size.width,
                        height: libraryContentHeight,
                        alignment: .top
                    )
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    alignment: .top
                )
                .clipped()

                // Keep the shutter anchored to the camera, independent of
                // the library scroll offset.
                VStack {
                    Spacer()
                    Button {
                        guard !isCapturingPhoto else { return }
                        isCapturingPhoto = true
                        takePhoto()
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 6)
                                .frame(width: 78, height: 78)
                            if isCapturingPhoto {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                    .scaleEffect(1.15)
                            } else {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 62, height: 62)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isCapturingPhoto)
                    .padding(.bottom, 28)
                }
                .frame(width: geometry.size.width, height: cameraHeight)
                .zIndex(1500)

                // =================================================
                // CLOSE CONTROL
                // Keep only the close button fixed above the Library
                // ScrollView. The shutter button now scrolls with the
                // Library so it cannot be covered by the white panel.
                // =================================================
                HStack {
                    Spacer()

                    Button {
                        camera.stopCamera()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(.gray)
                            .frame(width: 48, height: 48)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 18)
                .padding(.trailing, 18)
                .frame(
                    width: geometry.size.width,
                    height: 66,
                    alignment: .top
                )
                .zIndex(2000)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .top
            )
            .background(Color.white)
        }

        // =========================================================
        // FULL SCREEN PHOTO LIBRARY
        // =========================================================

        .fullScreenCover(
            isPresented: $showPhotoLibrary
        ) {

            PhotoLibraryPicker(
                isPresented: $showPhotoLibrary
            ) { image in

                camera.stopCamera()

                onImageSelected(image)

                dismiss()
            }
            .ignoresSafeArea()
        }

        // =========================================================
        // START CAMERA
        // =========================================================

        .onAppear {

            camera.startCamera()
        }

        // =========================================================
        // STOP CAMERA
        // =========================================================

        .onDisappear {

            camera.stopCamera()
        }
    }

    // =============================================================
    // OPEN PHOTO LIBRARY
    // =============================================================

    private func openPhotoLibrary() {

        camera.stopCamera()

        showPhotoLibrary = true
    }

    // =============================================================
    // TAKE PHOTO
    // =============================================================

    private func takePhoto() {

        guard camera.session.isRunning else {

            isCapturingPhoto = false

            print(
                "Camera session is not running"
            )

            return
        }

        let delegate =
            FaroImageCaptureDelegate { image in

                DispatchQueue.main.async {

                    isCapturingPhoto = false

                    camera.stopCamera()

                    onImageSelected(image)

                    dismiss()
                }
            } onError: {

                DispatchQueue.main.async {

                    isCapturingPhoto = false
                }
            }

        camera.takePhoto(
            delegate: delegate
        )
    }
}


// =================================================================
// PHOTO LIBRARY PICKER
// =================================================================
//
// ใช้ UIImagePickerController โดยตรง
// ไม่ใช้ PhotosPicker
//
// ผลลัพธ์:
// - View all กดได้
// - เปิด Photo Library แบบเต็มจอ
// - เลือกรูปแล้วส่ง UIImage กลับทันที
// =================================================================

private struct PhotoLibraryPicker:
    UIViewControllerRepresentable {

    @Binding
    var isPresented: Bool

    let onImageSelected:
        (UIImage) -> Void


    // =============================================================
    // COORDINATOR
    // =============================================================

    func makeCoordinator() -> Coordinator {

        Coordinator(
            isPresented: $isPresented,
            onImageSelected: onImageSelected
        )
    }


    // =============================================================
    // CREATE PICKER
    // =============================================================

    func makeUIViewController(
        context: Context
    ) -> UIImagePickerController {

        let picker =
            UIImagePickerController()

        picker.sourceType =
            .photoLibrary

        picker.delegate =
            context.coordinator

        picker.allowsEditing =
            false

        picker.modalPresentationStyle =
            .fullScreen

        return picker
    }


    // =============================================================
    // UPDATE
    // =============================================================

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {
        // ไม่ต้องทำอะไร
    }


    // =============================================================
    // COORDINATOR
    // =============================================================

    final class Coordinator:
        NSObject,
        UINavigationControllerDelegate,
        UIImagePickerControllerDelegate {

        @Binding
        var isPresented: Bool

        let onImageSelected:
            (UIImage) -> Void


        init(
            isPresented: Binding<Bool>,
            onImageSelected:
                @escaping (UIImage) -> Void
        ) {

            _isPresented =
                isPresented

            self.onImageSelected =
                onImageSelected

            super.init()
        }


        // =========================================================
        // SELECT IMAGE
        // =========================================================

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info:
                [UIImagePickerController.InfoKey: Any]
        ) {

            let image =
                info[.originalImage]
                    as? UIImage

            picker.dismiss(
                animated: true
            ) { [weak self] in

                guard let self else {
                    return
                }

                self.isPresented = false

                guard let image else {
                    return
                }

                self.onImageSelected(
                    image
                )
            }
        }


        // =========================================================
        // CANCEL
        // =========================================================

        func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {

            picker.dismiss(
                animated: true
            ) { [weak self] in

                self?.isPresented = false
            }
        }
    }
}


// =================================================================
// CAMERA PREVIEW
// =================================================================

private struct FaroCameraPreview:
    UIViewRepresentable {

    let session:
        AVCaptureSession


    func makeUIView(
        context: Context
    ) -> FaroCameraPreviewView {

        let view =
            FaroCameraPreviewView()

        view.backgroundColor =
            .black

        view.previewLayer.session =
            session

        view.previewLayer.videoGravity =
            .resizeAspectFill

        return view
    }


    func updateUIView(
        _ uiView: FaroCameraPreviewView,
        context: Context
    ) {

        uiView.previewLayer.session =
            session

        uiView.previewLayer.videoGravity =
            .resizeAspectFill
    }
}


// =================================================================
// CAMERA PREVIEW VIEW
// =================================================================

private final class FaroCameraPreviewView:
    UIView {

    override class var layerClass:
        AnyClass {

        AVCaptureVideoPreviewLayer.self
    }


    var previewLayer:
        AVCaptureVideoPreviewLayer {

        layer as!
            AVCaptureVideoPreviewLayer
    }


    override func layoutSubviews() {

        super.layoutSubviews()

        previewLayer.frame =
            bounds
    }
}


// =================================================================
// PHOTO CAPTURE DELEGATE
// =================================================================

private final class FaroImageCaptureDelegate:
    NSObject,
    AVCapturePhotoCaptureDelegate {

    private let completion:
        (UIImage) -> Void

    private let errorCompletion:
        () -> Void


    init(
        completion:
            @escaping (UIImage) -> Void,

        onError:
            @escaping () -> Void
    ) {

        self.completion =
            completion

        self.errorCompletion =
            onError

        super.init()
    }


    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo:
            AVCapturePhoto,
        error: Error?
    ) {

        // ---------------------------------------------------------
        // ERROR
        // ---------------------------------------------------------

        if let error {

            print(
                "Photo capture error:",
                error.localizedDescription
            )

            errorCompletion()

            return
        }


        // ---------------------------------------------------------
        // IMAGE DATA
        // ---------------------------------------------------------

        guard
            let data =
                photo.fileDataRepresentation(),

            let image =
                UIImage(data: data)

        else {

            print(
                "Unable to create UIImage"
            )

            errorCompletion()

            return
        }


        // ---------------------------------------------------------
        // SUCCESS
        // ---------------------------------------------------------

        completion(
            image
        )
    }
}
