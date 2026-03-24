//
//  SettingsWindowView.swift
//  docklock
//

import SwiftUI

struct SettingsWindowView: View {
    @State private var selectedPage: SettingsPage = .general

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            SettingsWindowSidebar(selectedPage: $selectedPage)
            SettingsWindowPages(selectedPage: $selectedPage)
        }
        .frame(width: 750, height: 640)
        .background(VisualEffectView(material: .hudWindow))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .ignoresSafeArea()
    }
}
