//
//  SettingsWindowPages.swift
//  docklock
//

import SwiftUI

struct SettingsWindowPages: View {
    @Binding var selectedPage: SettingsPage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(selectedPage.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(NSColor.labelColor))

                switch selectedPage {
                case .general:
                    SettingsGeneral()
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
