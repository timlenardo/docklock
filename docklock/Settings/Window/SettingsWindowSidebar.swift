//
//  SettingsWindowSidebar.swift
//  docklock
//

import SwiftUI

struct SettingsWindowSidebar: View {
    @Binding var selectedPage: SettingsPage

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(SettingsPage.allCases, id: \.self) { page in
                        SidebarButton(page: page, isSelected: selectedPage == page) {
                            selectedPage = page
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
            }
        }
        .padding(.top, 50)
        .frame(width: 224)
        .frame(maxHeight: .infinity)
        .background(VisualEffectView(material: .sidebar))
        .overlay(
            Rectangle()
                .fill(Color(NSColor.separatorColor))
                .frame(width: 1)
                .frame(maxHeight: .infinity),
            alignment: .trailing
        )
    }
}

// MARK: - Sidebar Button

private struct SidebarButton: View {
    let page: SettingsPage
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button {
            action()
        } label: {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: page.systemIcon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(page.iconBackground)
                    .cornerRadius(5)

                Text(page.name)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(NSColor.labelColor))

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        isSelected
                            ? Color(NSColor.selectedContentBackgroundColor).opacity(0.35)
                            : (isHovered ? Color(NSColor.labelColor).opacity(0.06) : .clear)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovered = $0 }
        .animation(.easeInOut(duration: 0.1), value: isHovered)
    }
}
