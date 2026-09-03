//
//  FaroFont.swift
//  GIS
//

import SwiftUI

enum FaroFont {
    static func regular(_ size: CGFloat) -> Font {
        .custom("segoe_regular", size: size)
    }

    static func semibold(_ size: CGFloat) -> Font {
        .custom("segoe_semibold", size: size)
    }

    static func bold(_ size: CGFloat) -> Font {
        .custom("segoe_bold", size: size)
    }

    static func italic(_ size: CGFloat) -> Font {
        .custom("segoe_italic", size: size)
    }
}
