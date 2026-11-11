//
//  HeroSection.swift
//  GIS
//
//  Created by Jeweal on 5/8/26.
//  Copyright © 2026 Hawkscode. All rights reserved.
//


import SwiftUI
import FirebaseRemoteConfig

struct HeroSection: View {

    var showLogo: Bool
    var showTitle: Bool
    var showDescription: Bool

    /// Decided once when the screen is built; nil outside a festival.
    private let hat = SeasonalHat.current()

    var body: some View {

        VStack(spacing:0){

            ZStack {
                Image("faro_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width:74,height:74)

                if let hat = hat {
                    SeasonalHatView(hat: hat)
                        .frame(width: hat.size.width, height: hat.size.height)
                        .rotationEffect(.degrees(hat.rotationDegrees))
                        .offset(x: hat.offset.width, y: hat.offset.height)
                }
            }
                .frame(width:74,height:74)
                // The hat overflows the icon's top edge; reserve room so a parent doesn't clip it.
                .padding(.top, hat == nil ? 0 : 30)
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

// MARK: - Seasonal hat

/// The festival hats that can sit on the faro logo.
enum SeasonalHat: String {
    case witch
    case santa
    case newYear = "newyear"
    case valentine

    /// Tilt of the decoration (hats lean on the logo corner; Cupid stands upright beside the logo).
    var rotationDegrees: Double {
        switch self {
        case .valentine: return 0
        default: return -40
        }
    }

    /// Size of the decoration.
    var size: CGSize {
        switch self {
        case .valentine:
            let side: CGFloat = 100
            return CGSize(width: side, height: side)
        default: return CGSize(width: 44, height: 40)
        }
    }

    /// Position relative to the center of the 74pt logo.
    var offset: CGSize {
        switch self {
        // Cupid floats at the logo's left and shoots his arrow toward it.
        case .valentine:
            return CGSize(width: -84, height: -10)
        default: return CGSize(width: -37, height: -36)
        }
    }

    /// Which hat to show today (nil = none).
    ///
    /// 1. Firebase Remote Config `seasonal_hat_type` = witch | santa | newyear | valentine | none.
    ///    It is shown inside `seasonal_hat_start_date`...`seasonal_hat_end_date` (yyyy-MM-dd); when those are
    ///    empty the Home animation dates `seasonal_home_lottie_start_date`/`_end_date` are used, and when no dates
    ///    exist at all the hat is simply shown while the type is set.
    /// 2. When `seasonal_hat_type` is empty the built-in calendar below decides, so a hat still appears on the
    ///    usual dates without any Firebase setup.
    static func current(on date: Date = Date()) -> SeasonalHat? {
        let config = RemoteConfig.remoteConfig()
        let type = config["seasonal_hat_type"].stringValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        print("SeasonalHat: type='\(type)' start='\(config["seasonal_hat_start_date"].stringValue)' end='\(config["seasonal_hat_end_date"].stringValue)' source=\(config["seasonal_hat_type"].source.rawValue)")
        if type == "none" { return nil }
        if let hat = SeasonalHat(rawValue: type) {
            func value(_ key: String) -> String {
                config[key].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            var start = value("seasonal_hat_start_date")
            var end = value("seasonal_hat_end_date")
            if start.isEmpty && end.isEmpty {
                start = value("seasonal_home_lottie_start_date")
                end = value("seasonal_home_lottie_end_date")
            }
            return isDate(date, between: start, and: end) ? hat : nil
        }
        return builtIn(on: date)
    }

    /// Fallback calendar (month/day, every year).
    private static func builtIn(on date: Date) -> SeasonalHat? {
        let parts = Calendar.current.dateComponents([.month, .day], from: date)
        guard let month = parts.month, let day = parts.day else { return nil }
        switch (month, day) {
        case (10, 25...31), (11, 1): return .witch
        case (12, 15...25): return .santa
        case (12, 26...31), (1, 1...3): return .newYear
        case (2, 10...14): return .valentine
        default: return nil
        }
    }

    /// Empty bounds mean "no limit" on that side.
    private static func isDate(_ date: Date, between start: String, and end: String) -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.isLenient = false
        formatter.dateFormat = "yyyy-MM-dd"

        let today = Calendar.current.startOfDay(for: date)
        if !start.isEmpty {
            guard let startDate = formatter.date(from: start) else { return false }
            if today < startDate { return false }
        }
        if !end.isEmpty {
            guard let endDate = formatter.date(from: end) else { return false }
            if today > endDate { return false }
        }
        return true
    }
}

private struct SeasonalHatView: View {
    let hat: SeasonalHat

    var body: some View {
        switch hat {
        case .witch: WitchHat()
        case .santa: SantaHat()
        case .newYear: NewYearHat()
        case .valentine: CupidView()
        }
    }
}

private struct SantaHat: View {

    /// A cone whose tip leans to the right, like a floppy Santa hat.
    private struct HatShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let w = rect.width
            let h = rect.height
            path.move(to: CGPoint(x: 0.08 * w, y: h))
            path.addCurve(
                to: CGPoint(x: 0.9 * w, y: 0.12 * h),
                control1: CGPoint(x: 0.1 * w, y: 0.35 * h),
                control2: CGPoint(x: 0.6 * w, y: 0.1 * h)
            )
            path.addCurve(
                to: CGPoint(x: 0.92 * w, y: h),
                control1: CGPoint(x: 0.82 * w, y: 0.45 * h),
                control2: CGPoint(x: 0.95 * w, y: 0.7 * h)
            )
            path.closeSubpath()
            return path
        }
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack(alignment: .topLeading) {
                HatShape()
                    .fill(Color(red: 0.84, green: 0.11, blue: 0.16))
                    .frame(width: w, height: h * 0.8)

                Capsule()
                    .fill(Color.white)
                    .frame(width: w, height: h * 0.26)
                    .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                    .offset(y: h * 0.74)

                Circle()
                    .fill(Color.white)
                    .frame(width: w * 0.26, height: w * 0.26)
                    .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                    .offset(x: w * 0.76, y: -h * 0.02)
            }
        }
    }
}

private struct NewYearHat: View {

    private struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let gold = Color(red: 0.98, green: 0.78, blue: 0.2)
            ZStack(alignment: .topLeading) {
                Triangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [gold, Color(red: 0.95, green: 0.55, blue: 0.15)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: w * 0.8, height: h * 0.9)
                    .offset(x: w * 0.1, y: h * 0.1)

                // Party-hat confetti dots.
                Circle().fill(Color.white).frame(width: w * 0.1, height: w * 0.1).offset(x: w * 0.42, y: h * 0.42)
                Circle().fill(Color(red: 0.4, green: 0.25, blue: 0.7)).frame(width: w * 0.1, height: w * 0.1).offset(x: w * 0.3, y: h * 0.66)
                Circle().fill(Color.white).frame(width: w * 0.1, height: w * 0.1).offset(x: w * 0.58, y: h * 0.7)

                // Pom-pom on the tip.
                Circle()
                    .fill(Color(red: 0.84, green: 0.11, blue: 0.16))
                    .frame(width: w * 0.24, height: w * 0.24)
                    .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                    .offset(x: w * 0.38, y: -h * 0.02)

                Capsule()
                    .fill(Color(red: 0.4, green: 0.25, blue: 0.7))
                    .frame(width: w * 0.9, height: h * 0.14)
                    .offset(x: w * 0.05, y: h * 0.86)
            }
        }
    }
}

/// Valentine's decoration: a single-colour Cupid silhouette flying toward the logo, drawing his bow,
/// drawn in code (original artwork). If a designer image named `cupid_valentine` exists in Assets it is used instead.
private struct CupidView: View {

    /// A shape built from a closure, so each part is filled on its own (no overlap cut-outs).
    private struct Part: Shape {
        let build: (CGRect) -> Path
        func path(in rect: CGRect) -> Path { build(rect) }
    }

    static let artworkName = "cupid_valentine"
    static var hasArtwork: Bool { UIImage(named: artworkName) != nil }

    private let color = Color(red: 0.91, green: 0.14, blue: 0.27)

    var body: some View {
        if Self.hasArtwork {
            Image(Self.artworkName)
                .resizable()
                .scaledToFit()
        } else {
            drawnCupid
        }
    }

    private var drawnCupid: some View {
        GeometryReader { geo in
            let u = geo.size.width
            ZStack {
                // Wing with a heart cut out of it.
                Part { r in
                    var wing = r.wing()
                    wing.addPath(r.heart(0.38, 0.285, 0.085))
                    return wing
                }.fill(color, style: FillStyle(eoFill: true))

                // Head with curly hair, nose and chin.
                Part { r in r.dot(0.575, 0.375, 0.088) }.fill(color)
                Part { r in r.dot(0.515, 0.315, 0.04) }.fill(color)
                Part { r in r.dot(0.565, 0.285, 0.045) }.fill(color)
                Part { r in r.dot(0.615, 0.305, 0.04) }.fill(color)
                Part { r in r.dot(0.655, 0.395, 0.02) }.fill(color)
                Part { r in r.dot(0.635, 0.43, 0.025) }.fill(color)
                Part { r in r.dot(0.505, 0.37, 0.03) }.fill(color)

                // Neck and chubby body.
                Part { r in r.limb([r.pt(0.56, 0.42), r.pt(0.53, 0.48)], width: 0.1) }.fill(color)
                Part { r in
                    var body = Path()
                    body.move(to: r.pt(0.46, 0.43))
                    body.addCurve(to: r.pt(0.60, 0.46), control1: r.pt(0.51, 0.40), control2: r.pt(0.57, 0.41))
                    body.addCurve(to: r.pt(0.55, 0.62), control1: r.pt(0.64, 0.52), control2: r.pt(0.60, 0.58))
                    body.addCurve(to: r.pt(0.47, 0.70), control1: r.pt(0.55, 0.66), control2: r.pt(0.52, 0.69))
                    body.addCurve(to: r.pt(0.34, 0.60), control1: r.pt(0.40, 0.70), control2: r.pt(0.33, 0.66))
                    body.addCurve(to: r.pt(0.46, 0.43), control1: r.pt(0.34, 0.52), control2: r.pt(0.40, 0.45))
                    body.closeSubpath()
                    return body
                }.fill(color)

                // Back leg kicked up behind, front leg hanging.
                Part { r in r.limb([r.pt(0.40, 0.62), r.pt(0.29, 0.66), r.pt(0.25, 0.54)], width: 0.075) }.fill(color)
                Part { r in
                    var foot = Path()
                    foot.move(to: r.pt(0.24, 0.55))
                    foot.addQuadCurve(to: r.pt(0.20, 0.47), control: r.pt(0.20, 0.53))
                    foot.addQuadCurve(to: r.pt(0.30, 0.52), control: r.pt(0.25, 0.46))
                    foot.closeSubpath()
                    return foot
                }.fill(color)
                Part { r in r.limb([r.pt(0.48, 0.68), r.pt(0.52, 0.79), r.pt(0.43, 0.88)], width: 0.078) }.fill(color)
                Part { r in
                    var foot = Path()
                    foot.move(to: r.pt(0.44, 0.86))
                    foot.addQuadCurve(to: r.pt(0.36, 0.94), control: r.pt(0.36, 0.89))
                    foot.addQuadCurve(to: r.pt(0.47, 0.93), control: r.pt(0.42, 0.97))
                    foot.closeSubpath()
                    return foot
                }.fill(color)

                // Arm holding the bow, other hand on the string.
                Part { r in r.limb([r.pt(0.56, 0.47), r.pt(0.66, 0.50), r.pt(0.76, 0.47)], width: 0.055) }.fill(color)
                Part { r in r.dot(0.775, 0.465, 0.035) }.fill(color)
                Part { r in r.limb([r.pt(0.55, 0.46), r.pt(0.56, 0.44)], width: 0.05) }.fill(color)

                // Bow, string and arrow with a heart tip.
                Part { r in
                    var bow = Path()
                    bow.move(to: r.pt(0.72, 0.24))
                    bow.addCurve(to: r.pt(0.77, 0.46), control1: r.pt(0.84, 0.28), control2: r.pt(0.84, 0.40))
                    bow.addCurve(to: r.pt(0.72, 0.68), control1: r.pt(0.84, 0.54), control2: r.pt(0.84, 0.64))
                    return bow
                }.stroke(color, style: StrokeStyle(lineWidth: u * 0.025, lineCap: .round, lineJoin: .round))
                Part { r in
                    var string = Path()
                    string.move(to: r.pt(0.72, 0.24))
                    string.addLine(to: r.pt(0.56, 0.44))
                    string.addLine(to: r.pt(0.72, 0.68))
                    return string
                }.stroke(color, style: StrokeStyle(lineWidth: u * 0.011, lineCap: .round, lineJoin: .round))
                Part { r in
                    var arrow = Path()
                    arrow.move(to: r.pt(0.56, 0.44))
                    arrow.addLine(to: r.pt(0.90, 0.44))
                    return arrow
                }.stroke(color, style: StrokeStyle(lineWidth: u * 0.014, lineCap: .round))
                Part { r in r.heart(0.935, 0.44, 0.075) }.fill(color)

                // Little hearts flying off.
                Part { r in r.heart(0.90, 0.24, 0.06) }.fill(color)
                Part { r in r.heart(0.96, 0.32, 0.07) }.fill(color)
            }
        }
    }
}

private extension CGRect {
    func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: minX + x * width, y: minY + y * height)
    }

    func dot(_ x: CGFloat, _ y: CGFloat, _ radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: minX + (x - radius) * width, y: minY + (y - radius) * height,
                               width: 2 * radius * width, height: 2 * radius * height))
    }

    /// A rounded limb along the given points, `width` as a fraction of the rect width.
    func limb(_ points: [CGPoint], width lineWidth: CGFloat) -> Path {
        var line = Path()
        guard let first = points.first else { return line }
        line.move(to: first)
        points.dropFirst().forEach { line.addLine(to: $0) }
        return line.strokedPath(StrokeStyle(lineWidth: lineWidth * width, lineCap: .round, lineJoin: .round))
    }

    /// The wing: rises from the shoulder up and back to a pointed tip, with feathered lower edge.
    func wing() -> Path {
        var wing = Path()
        wing.move(to: pt(0.49, 0.45))
        wing.addCurve(to: pt(0.46, 0.30), control1: pt(0.50, 0.38), control2: pt(0.50, 0.33))
        wing.addCurve(to: pt(0.24, 0.215), control1: pt(0.44, 0.24), control2: pt(0.32, 0.20))
        wing.addQuadCurve(to: pt(0.30, 0.27), control: pt(0.24, 0.25))
        wing.addQuadCurve(to: pt(0.25, 0.30), control: pt(0.26, 0.28))
        wing.addQuadCurve(to: pt(0.32, 0.345), control: pt(0.26, 0.335))
        wing.addQuadCurve(to: pt(0.30, 0.37), control: pt(0.29, 0.355))
        wing.addQuadCurve(to: pt(0.38, 0.405), control: pt(0.31, 0.40))
        wing.addQuadCurve(to: pt(0.37, 0.43), control: pt(0.36, 0.42))
        wing.addQuadCurve(to: pt(0.49, 0.45), control: pt(0.42, 0.46))
        wing.closeSubpath()
        return wing
    }

    func heart(_ cx: CGFloat, _ cy: CGFloat, _ size: CGFloat) -> Path {
        var heart = Path()
        heart.move(to: pt(cx, cy + 0.45 * size))
        heart.addCurve(to: pt(cx - 0.5 * size, cy - 0.15 * size), control1: pt(cx - 0.1 * size, cy + 0.3 * size), control2: pt(cx - 0.5 * size, cy + 0.15 * size))
        heart.addCurve(to: pt(cx, cy - 0.1 * size), control1: pt(cx - 0.5 * size, cy - 0.5 * size), control2: pt(cx - 0.05 * size, cy - 0.5 * size))
        heart.addCurve(to: pt(cx + 0.5 * size, cy - 0.15 * size), control1: pt(cx + 0.05 * size, cy - 0.5 * size), control2: pt(cx + 0.5 * size, cy - 0.5 * size))
        heart.addCurve(to: pt(cx, cy + 0.45 * size), control1: pt(cx + 0.5 * size, cy + 0.15 * size), control2: pt(cx + 0.1 * size, cy + 0.3 * size))
        heart.closeSubpath()
        return heart
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

#Preview("Cupid") {
    CupidView()
        .frame(width: 240, height: 240)
        .padding()
        .background(Color.white)
}
