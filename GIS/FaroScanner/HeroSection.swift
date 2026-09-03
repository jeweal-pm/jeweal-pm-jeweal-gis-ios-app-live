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
    var showContent: Bool

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
                .opacity(showContent ? 1 : 0)
                .offset(
                    y:showContent ? 0 : 30
                )

            Text("""
Use Quick Search for instant results, or tell faro AI about
your ideal jewelry to receive personalized recommendations.
""")
                .font(.system(size:14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal,24)
                .padding(.top,20)
                .opacity(showContent ? 1 : 0)
                .offset(
                    y:showContent ? 0 : 15
                )

        }

    }

}
