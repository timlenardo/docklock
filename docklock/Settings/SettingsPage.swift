//
//  SettingsPage.swift
//  docklock
//

import SwiftUI

enum SettingsPage: String, CaseIterable, Equatable {
    case general

    var name: String {
        switch self {
        case .general: return "General"
        }
    }

    var systemIcon: String {
        switch self {
        case .general: return "gearshape.fill"
        }
    }

    var iconBackground: Color {
        switch self {
        case .general: return Color(NSColor.systemGray)
        }
    }
}
