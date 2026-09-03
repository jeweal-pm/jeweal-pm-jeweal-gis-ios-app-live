//
//  RecentLibraryView.swift
//  GIS
//
//  Created by Jeweal on 13/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import Photos
import SwiftUI

struct RecentLibraryView: View {

    @State
    private var images:[LibraryThumbnail] = []
    
    let onSelect: (UIImage)->Void

    var body: some View {

        GeometryReader { geometry in

            let spacing: CGFloat = 2
            let cellWidth = max(0, (geometry.size.width - (spacing * 2)) / 3)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: spacing),
                    GridItem(.flexible(), spacing: spacing),
                    GridItem(.flexible(), spacing: spacing)
                ],
                spacing: spacing
            ) {

                ForEach(images) { item in

                    Button {

                        // Keep the selected image tied to this exact cell.
                        onSelect(item.image)

                    } label: {

                        ZStack {

                            Image(uiImage: item.image)
                                .resizable()
                                .scaledToFill()
                                .frame(
                                    width: cellWidth,
                                    height: cellWidth
                                )
                                .clipped()

                        }
                        .frame(
                            width: cellWidth,
                            height: cellWidth
                        )
                        .contentShape(Rectangle())

                    }
                    .buttonStyle(.plain)
                    .frame(
                        width: cellWidth,
                        height: cellWidth
                    )
                    .contentShape(Rectangle())
                    .id(item.id)
                }
            }
            .frame(
                width: geometry.size.width,
                alignment: .top
            )
        }
        .onAppear {

            loadPhotos()

        }

    }

    
    func loadPhotos() {

        PHPhotoLibrary.requestAuthorization { status in

            guard status == .authorized || status == .limited else {
                return
            }

            let options = PHFetchOptions()

            options.sortDescriptors = [
                NSSortDescriptor(
                    key: "creationDate",
                    ascending: false
                )
            ]

            options.fetchLimit = 9

            let assets = PHAsset.fetchAssets(
                with: .image,
                options: options
            )

            let manager = PHCachingImageManager()

            var result: [LibraryThumbnail?] = Array(
                repeating: nil,
                count: assets.count
            )

            let requestOptions = PHImageRequestOptions()
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.isSynchronous = true

            assets.enumerateObjects { asset, index, _ in

                manager.requestImage(
                    for: asset,
                    targetSize: CGSize(width: 300, height: 300),
                    contentMode: .aspectFill,
                    options: requestOptions
                ) { image, _ in

                    if let image {
                        result[index] = LibraryThumbnail(
                            image: image
                        )
                    }

                }

            }

            DispatchQueue.main.async {

                self.images = result.compactMap { $0 }

            }

        }

    }
    
    
//    func loadPhotos(){
//
//        PHPhotoLibrary.requestAuthorization { status in
//
//            guard status == .authorized || status == .limited else {
//
//                return
//
//            }
//
//            let options = PHFetchOptions()
//
//            options.sortDescriptors = [
//                NSSortDescriptor(
//                    key: "creationDate",
//                    ascending: false
//                )
//            ]
//
//            let assets = PHAsset.fetchAssets(
//                with: .image,
//                options: options
//            )
//
//            let manager = PHCachingImageManager()
//
//            var result:[LibraryThumbnail] = []
//            
//            let group = DispatchGroup()
//
//            assets.enumerateObjects { asset, _, stop in
//
//                if result.count == 9 {
//
//                    stop.pointee = true
//
//                }
//                
//                group.enter()
//
//                manager.requestImage(
//                    for: asset,
//                    targetSize: CGSize(
//                        width:300,
//                        height:300
//                    ),
//                    contentMode:.aspectFill,
//                    options:nil
//                ){ image,_ in
//
//                    
//                    if let image {
//
//                        result.append(
//                            LibraryThumbnail(
//                                image: image
//                            )
//                        )
//
//                    }
//
//                    group.leave()
//
//                }
//
//            }
//            
//            group.notify(queue: .main) {
//
//                self.images = result.compactMap { $0 }
//
//            }
//
//        }
//
//    }

}
