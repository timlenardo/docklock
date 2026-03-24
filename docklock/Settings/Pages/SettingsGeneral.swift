//
//  SettingsGeneral.swift
//  docklock
//

import ServiceManagement
import SwiftUI

struct SettingsGeneral: View {
    @State private var isLaunchAtStartupEnabled: Bool = SMAppService.mainApp.status == .enabled
    @State private var isUpdating: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        SettingsPageSection(title: "General") {
            launchAtLoginRow
        }
    }

    // MARK: - Launch at Login

    private var launchAtLoginRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundColor(Color(NSColor.systemRed))
            }

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Launch automatically at login")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(NSColor.labelColor))

                    Text("Open DockLock automatically when you log into your computer.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { isLaunchAtStartupEnabled },
                    set: { newValue in
                        Task { await updateLaunchAtStartup(to: newValue) }
                    }
                ))
                .toggleStyle(.switch)
                .disabled(isUpdating)
                .labelsHidden()
            }
        }
    }

    // MARK: - Helpers

    private func updateLaunchAtStartup(to enabled: Bool) async {
        let original = isLaunchAtStartupEnabled
        isUpdating = true
        defer { isUpdating = false }
        errorMessage = nil

        do {
            if enabled {
                try await SMAppService.mainApp.register()
            } else {
                try await SMAppService.mainApp.unregister()
            }
            isLaunchAtStartupEnabled = enabled
        } catch {
            isLaunchAtStartupEnabled = original
            errorMessage = error.localizedDescription
        }
    }
}
