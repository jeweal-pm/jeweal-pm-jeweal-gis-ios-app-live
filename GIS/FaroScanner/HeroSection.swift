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

            ZStack {
                Image("faro_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width:74,height:74)

                WitchHat()
                    .frame(width: 44, height: 40)
                    .rotationEffect(.degrees(-40))
                    .offset(x: -37, y: -36)
            }
                .frame(width:74,height:74)
                // The hat overflows the icon's top edge; reserve room so a parent doesn't clip it.
                .padding(.top, 30)
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

private struct WitchHat: View {

    private struct Cone: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let w = rect.width
            let h = rect.height
            path.move(to: CGPoint(x: 0.2 * w, y: h))
            path.addCurve(
                to: CGPoint(x: 0.78 * w, y: 0.04 * h),
                control1: CGPoint(x: 0.32 * w, y: 0.55 * h),
                control2: CGPoint(x: 0.5 * w, y: 0.2 * h)
            )
            path.addCurve(
                to: CGPoint(x: 0.8 * w, y: h),
                control1: CGPoint(x: 0.74 * w, y: 0.4 * h),
                control2: CGPoint(x: 0.8 * w, y: 0.7 * h)
            )
            path.closeSubpath()
            return path
        }
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let hatColor = Color(red: 0.27, green: 0.13, blue: 0.42)
            ZStack(alignment: .topLeading) {
                Cone()
                    .fill(hatColor)
                    .frame(width: w, height: h * 0.8)

                Rectangle()
                    .fill(Color(red: 0.95, green: 0.55, blue: 0.1))
                    .frame(width: w * 0.58, height: h * 0.13)
                    .offset(x: w * 0.21, y: h * 0.58)

                Capsule()
                    .fill(hatColor)
                    .frame(width: w, height: h * 0.24)
                    .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                    .offset(y: h * 0.76)
            }
        }
    }
}
