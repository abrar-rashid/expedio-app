//
//  Theme.swift
//  Expedio
//
//  Design system with soft pastel colors and Playfair Display typography
//

import SwiftUI

enum Theme {
    // MARK: - Colors (Soft Pastels)
    enum Colors {
        static let background = Color(hex: "FDF8F4")    // Warm cream
        static let surface = Color(hex: "FFFFFF")       // Cards
        static let primary = Color(hex: "7C9885")       // Sage green
        static let secondary = Color(hex: "B8A9C9")     // Soft lavender
        static let textPrimary = Color(hex: "2D3436")   // Headlines
        static let textSecondary = Color(hex: "636E72") // Body text
        static let accent = Color(hex: "E8B4B8")        // Dusty rose
    }

    // MARK: - Typography
    enum Typography {
        // Headers and Titles - Playfair Display (serif)
        static let largeTitle = Font.custom("PlayfairDisplay-Regular", size: 34, relativeTo: .largeTitle)
        static let title = Font.custom("PlayfairDisplay-Regular", size: 28, relativeTo: .title)
        static let title2 = Font.custom("PlayfairDisplay-Regular", size: 22, relativeTo: .title2)
        static let title3 = Font.custom("PlayfairDisplay-Regular", size: 20, relativeTo: .title3)
        static let headline = Font.custom("PlayfairDisplay-Regular", size: 17, relativeTo: .headline)

        // Body Text - SF Pro (system font)
        static let body = Font.system(size: 17)
        static let callout = Font.system(size: 16)
        static let subheadline = Font.system(size: 15)
        static let footnote = Font.system(size: 13)
        static let caption = Font.system(size: 12)
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
