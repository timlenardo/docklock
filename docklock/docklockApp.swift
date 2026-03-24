//
//  docklockApp.swift
//  docklock
//
//  Created by Timothy Lenardo on 10/27/25.
//

import AppKit
import Combine
import ServiceManagement
import SwiftUI

@main
struct docklockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private let mouseMonitor = MouseMonitor.shared

    private var statusMenuItem: NSMenuItem?
    private var blockCountMenuItem: NSMenuItem?
    private var toggleMenuItem: NSMenuItem?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        statusItem?.menu = buildMenu()

        checkLaunchOnStartup()

        if !UserDefaults.standard.bool(forKey: "onboardingCompleted") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                OnboardingWindowManager.shared.showWindow()
            }
        } else {
            mouseMonitor.startMonitoringIfPermitted()
        }

        updateMenuAndIcon()

        // Keep block count menu item in sync without rebuilding the whole menu.
        mouseMonitor.$blockCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.updateBlockCountMenuItem() }
            .store(in: &cancellables)

        // Pop open the menu on launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.statusItem?.button?.performClick(nil)
        }
    }

    // MARK: - Menu

    @discardableResult
    private func buildMenu() -> NSMenu? {
        let menu = NSMenu()

        // Non-clickable status row
        let status = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        status.isEnabled = false
        status.image = statusDot(locked: mouseMonitor.isLocked)
        statusMenuItem = status
        menu.addItem(status)

        // Block count subtitle
        let countItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        countItem.isEnabled = false
        countItem.attributedTitle = blockCountAttributedString()
        blockCountMenuItem = countItem
        menu.addItem(countItem)

        menu.addItem(.separator())

        // Clickable toggle
        let toggle = NSMenuItem(
            title: toggleTitle,
            action: #selector(toggleLock),
            keyEquivalent: ""
        )
        toggleMenuItem = toggle
        menu.addItem(toggle)

        menu.addItem(.separator())

        menu.addItem(NSMenuItem(
            title: "Settings…",
            action: #selector(openSettings),
            keyEquivalent: ","
        ))

        menu.addItem(NSMenuItem(
            title: "Support DockLock ♡",
            action: #selector(openDonate),
            keyEquivalent: ""
        ))

        menu.addItem(.separator())

        menu.addItem(NSMenuItem(
            title: "Quit DockLock",
            action: #selector(quit),
            keyEquivalent: "q"
        ))

        return menu
    }

    private var statusTitle: String {
        mouseMonitor.isLocked ? "Running" : "Disabled"
    }

    private var toggleTitle: String {
        mouseMonitor.isLocked ? "Disable" : "Enable"
    }

    // MARK: - Actions

    @objc private func toggleLock() {
        mouseMonitor.toggleLock()
        updateMenuAndIcon()
    }

    @objc private func openSettings() {
        SettingsWindowManager.shared.showWindow()
    }

    @objc private func openDonate() {
        NSWorkspace.shared.open(URL(string: "https://buy.stripe.com/00w6oG8d3bdDfFaaFt1B604")!)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - State Updates

    private func updateMenuAndIcon() {
        if let button = statusItem?.button {
            button.image = renderMenuBarIcon(locked: mouseMonitor.isLocked)
        }

        statusMenuItem?.title = statusTitle
        statusMenuItem?.image = statusDot(locked: mouseMonitor.isLocked)
        toggleMenuItem?.title = toggleTitle
        updateBlockCountMenuItem()
    }

    private func updateBlockCountMenuItem() {
        blockCountMenuItem?.attributedTitle = blockCountAttributedString()
    }

    private func blockCountAttributedString() -> NSAttributedString {
        let count = mouseMonitor.blockCount
        let text = count == 1 ? "1 dock jump prevented" : "\(count) dock jumps prevented"
        return NSAttributedString(string: text, attributes: [
            .foregroundColor: NSColor.secondaryLabelColor,
            .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        ])
    }

    /// Draws a 6×6 colored circle — green when active, yellow when inactive.
    /// Mirrors onit-beacon's MenuBarItemBase.drawStatusDot pattern.
    private func statusDot(locked: Bool) -> NSImage {
        let color: NSColor = locked
            ? NSColor(name: nil) { appearance in
                appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
                    ? NSColor(srgbRed: 0x79/255, green: 0xFF/255, blue: 0x92/255, alpha: 1) // Lime400 dark
                    : NSColor(srgbRed: 0x29/255, green: 0xAC/255, blue: 0x42/255, alpha: 1) // Lime400 light
            }
            : NSColor(displayP3Red: 0xFE/255, green: 0xBC/255, blue: 0x2E/255, alpha: 1) // TrafficYellow

        let image = NSImage(size: NSSize(width: 6, height: 6), flipped: false) { rect in
            color.setFill()
            NSBezierPath(ovalIn: rect).fill()
            return true
        }
        image.isTemplate = false
        return image
    }

    /// Loads the SVG directly and lets AppKit render it as a vector at whatever scale the screen needs.
    private func renderMenuBarIcon(locked: Bool, size: CGFloat = 16) -> NSImage? {
        let resourceName = locked ? "docklock_locked" : "docklock_unlocked"
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "svg"),
              let source = NSImage(contentsOf: url)?.copy() as? NSImage else {
            print("[DockLock] ❌ Failed to load \(resourceName).svg from bundle")
            return nil
        }
        source.size = NSSize(width: size, height: size)
        source.isTemplate = true
        return source
    }

    // MARK: - Launch at Login

    private func checkLaunchOnStartup() {
        guard !UserDefaults.standard.bool(forKey: "launchOnStartupRequested") else { return }
        Task {
            do {
                try await SMAppService.mainApp.register()
                UserDefaults.standard.set(true, forKey: "launchOnStartupRequested")
            } catch {
                print("Launch at login registration error: \(error)")
            }
        }
    }
}
