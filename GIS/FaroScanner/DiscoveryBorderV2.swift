//
//  DiscoveryBorderV2.swift
//  GIS
//
//  Created by Jeweal on 12/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//

import SwiftUI

struct DiscoveryBorderV2: View {

    let cornerRadius: CGFloat

//    @State
//    private var rotation: Double = 0
    
    private var glowGradient: Gradient {

        Gradient(

            stops: [

                .init(color: .clear, location: 0.00),

                .init(
                    color: Color(
                        red:0.47,
                        green:1,
                        blue:0.94
                    ).opacity(0.25),
                    location:0.02
                ),

                .init(
                    color: Color(
                        red:0.47,
                        green:1,
                        blue:0.94
                    ),
                    location:0.05
                ),
                .init(
                    color: Color(
                        red:0.47,
                        green:1,
                        blue:0.94
                    ).opacity(0.15),
                    location:0.56
                ),

                .init(
                    color: Color(
                        red:0.47,
                        green:1,
                        blue:0.94
                    ).opacity(0.40),
                    location:0.61
                ),

                .init(
                    color: Color(
                        red:0.47,
                        green:1,
                        blue:0.94
                    ),
                    location:0.67
                ),

                .init(
                    color: Color(
                        red:0.46,
                        green:0.74,
                        blue:1
                    ),
                    location:0.72
                ),

                .init(
                    color: Color(
                        red:0.70,
                        green:0.47,
                        blue:1
                    ),
                    location:0.77
                ),

                .init(
                    color: Color(
                        red:0.70,
                        green:0.47,
                        blue:1
                    ).opacity(0.40),
                    location:0.83
                ),

                .init(color: .clear, location: 0.90),
                .init(
                    color: Color(
                        red:0.47,
                        green:1,
                        blue:0.94
                    ),
                    location:0.95
                ),

                .init(
                    color: Color(
                        red:0.47,
                        green:1,
                        blue:0.94
                    ).opacity(0.25),
                    location:0.98
                ),

                .init(color: .clear, location:1.00)

            ]

        )

    }
    
    
    var body: some View {

        RoundedRectangle(
            cornerRadius: cornerRadius
        )
        .stroke(
            Color.gray.opacity(0.12),
            lineWidth: 1
        )

        .overlay {

            TimelineView(.periodic(from: .now, by: 1.0 / 60.0)) { timeline in

                let seconds = timeline.date.timeIntervalSinceReferenceDate

//                let rotation = seconds * 90
                let rotation = seconds * 35

                ZStack {
                    
                    
                    //----------------------------------
                    // Glow Layer
                    //----------------------------------

                    AngularGradient(
                        gradient: glowGradient,
                        center: .center,
                        startAngle: .degrees(rotation),
                        endAngle: .degrees(rotation + 360)
                    )
                    .rotationEffect(
                        .degrees(rotation)
                    )
                    .mask(
                        RoundedRectangle(
                            cornerRadius: cornerRadius
                        )
                        .stroke(
                            lineWidth: 6
                        )
                    )
                    .blur(radius: 2.5)
                    .opacity(0.45)

                    //----------------------------------
                    // Main Line
                    //----------------------------------

                    Text("\(Int(rotation))")
                            .foregroundColor(.red)
                    
                    AngularGradient(
                        gradient: glowGradient,
                        center: .center,
                        startAngle: .degrees(rotation),
                        endAngle: .degrees(rotation + 360)
                    )
                    .rotationEffect(
                        .degrees(rotation)
                    )
                    .mask(
                        RoundedRectangle(
                            cornerRadius: cornerRadius
                        )
                        .stroke(
                            lineWidth: 2.8
                        )
                    )
                    .blur(radius: 0.25)
                    .shadow(
                        color: .cyan.opacity(0.45),
                        radius: 4
                    )
                    .shadow(
                        color: .blue.opacity(0.22),
                        radius: 10
                    )
                    .shadow(
                        color: .purple.opacity(0.28),
                        radius: 20
                    )

                }
//                .drawingGroup()

            }

        }
//        .onAppear {
//
//            withAnimation(
//
//                .linear(duration: 1.7)
//                .repeatForever(
//                    autoreverses: false
//                )
//                .repeatForever(
//                    autoreverses:false
//                )
//
//            ) {
//
//                rotation = 360
//
//            }
//
//        }
    }
    
    

}
