//
//  HeroSection.swift
//  GIS
//
//  Created by Jeweal on 5/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//


import SwiftUI

struct HeroSection: View {

    var showLogo: Bool
    var showTitle: Bool
    var showDescription: Bool

    var body: some View {

        VStack(spacing:0){

            Image("faro_icon")
                .resizable()
                .scaledToFit()
                .frame(width:74,height:74)
                .opacity(showLogo ? 1 : 0)
                .scaleEffect(showLogo ? 1 : 0.65)
                .rotationEffect(
                    .degrees(showLogo ? 0 : -12)
                )

            Text("Ask faro anything")
                .font(
                    .custom(
                        "Fraunces72pt-Light",
                        size:24
                    )
                )
                .padding(.top,16)
                .opacity(showTitle ? 1 : 0)
                .offset(
                    y: showTitle ? 0 : 30
                )

            Text("Use Quick Search for instant results, or tell faro AI about\nyour ideal jewelry to receive personalized recommendations.")
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .padding(.horizontal, 12)
                .padding(.top,20)
                .opacity(showDescription ? 1 : 0)
                .offset(
                    y: showDescription ? 0 : 15
                )

        }

    }

}
