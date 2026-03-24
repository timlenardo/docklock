//
//  OnboardingStyles.swift
//  docklock
//

import AppKit
import SwiftUI

// MARK: - Visual Effect View

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material

    init(material: NSVisualEffectView.Material = .hudWindow) {
        self.material = material
    }

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
    }
}

// MARK: - Color Extensions

extension Color {
    static let onboardingBlue300 = Color(red: 0.51, green: 0.69, blue: 1.0)
    static let onboardingBlue350 = Color(red: 0.36, green: 0.59, blue: 0.98)
    static let onboardingBlue400 = Color(red: 0.22, green: 0.49, blue: 0.96)
}
