//
// Copyright 2025 Element Creations Ltd.
// Copyright 2023-2025 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial.
// Please see LICENSE files in the repository root for full details.
//

import SwiftUI

/// Used to specify the user's app specific appearance preference
enum AppAppearance: CaseIterable, Codable {
    case system
    case dark
    case light
    case forest
    case ocean
        
    var colorPalette: ColorPalette {
        switch self {
        case .system:
            return .system
        case .dark:
            return .dark
        case .light:
            return .light
        case .forest:
            return .forest
        case .ocean:
            return .ocean
        }
    }

    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .forest:
            return .dark
        case .ocean:
            return .light
        case .system:
            return .unspecified
        }
    }
}


struct ColorPalette {
    let accent: Color
    let secondary: Color
}

extension ColorPalette {
    static let system = ColorPalette(accent: .accentColor, secondary: .gray)
    static let dark = ColorPalette(accent: .accentColor, secondary: .gray)
    static let light = ColorPalette(accent: .accentColor, secondary: .gray)
    static let forest = ColorPalette(accent: Color(red: 0.18, green: 0.47, blue: 0.29),
                                        secondary: Color(red: 0.55, green: 0.73, blue: 0.44))
    static let ocean = ColorPalette(accent: Color(red: 0.07, green: 0.44, blue: 0.80),
                                       secondary: Color(red: 0.46, green: 0.75, blue: 0.96))
}
