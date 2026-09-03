//
//  PhotoCaptureDelegate.swift
//  GIS
//
//  Created by Jeweal on 16/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import UIKit
import AVFoundation

final class PhotoCaptureDelegate:
NSObject,
AVCapturePhotoCaptureDelegate {

    let completion:(UIImage)->Void

    init(
        completion:@escaping (UIImage)->Void
    ){

        self.completion = completion

    }

    func photoOutput(

        _ output: AVCapturePhotoOutput,

        didFinishProcessingPhoto photo: AVCapturePhoto,

        error: Error?

    ){

        guard

            let data = photo.fileDataRepresentation(),

            let image = UIImage(data:data)

        else{

            return

        }

        completion(image)

    }

}
