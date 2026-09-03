//
//  DiscoveryGlow.swift
//  GIS
//
//  Created by Jeweal on 12/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

//import SwiftUI
//
//struct DiscoveryGlow: View {
//
//    let cornerRadius: CGFloat
//
//    @State
//    private var phase: CGFloat = 0
//
//    var body: some View {
//
//        TimelineView(.animation) { timeline in
//            
//
//            Canvas { context, size in
//
//                let date = timeline.date
//                let angle = date.timeIntervalSinceReferenceDate * 120
//
//
//                context.translateBy(
//                    x: size.width / 2,
//                    y: size.height / 2
//                )
//
//                context.rotate(
//                    by: .degrees(angle)
//                )
//
//                context.translateBy(
//                    x: -size.width / 2,
//                    y: -size.height / 2
//                )
//
//                let rect = CGRect(
//                    origin: .zero,
//                    size: size
//                )
//
//                let path = Path(
//                    RoundedRectangle(
//                        cornerRadius: cornerRadius
//                    )
//                    .path(in: rect)
//                )
//
//                context.stroke(
//                    path,
//                    with: .linearGradient(
//                        Gradient(colors: [
//
//                            .clear,
//
//                            Color(
//                                red:0.46,
//                                green:1,
//                                blue:0.95
//                            ),
//
//                            Color(
//                                red:0.44,
//                                green:0.72,
//                                blue:1
//                            ),
//
//                            Color(
//                                red:0.71,
//                                green:0.48,
//                                blue:1
//                            ),
//
//                            .clear
//
//                        ]),
//                        startPoint: CGPoint(
//                            x:0,
//                            y:0
//                        ),
//                        endPoint: CGPoint(
//                            x:size.width,
//                            y:0
//                        )
//                    ),
//                    style: StrokeStyle(
//                        lineWidth:2.2,
//                        lineCap:.round
//                    )
//                )
//
//            }
//
//        }
//
//    }
//
//}
