//
//  OnboardingWindowManager.swift
//  docklock
//

import AppKit
import SwiftUI

@MainActor
class OnboardingWindowManager: NSObject, NSWindowDelegate {
    static let shared = OnboardingWindowManager()

    private var window: NSWindow?

    func showWindow() {
        if let existing = window {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let hosting = NSHostingView(rootView: OnboardingWindowView())
        hosting.layer?.cornerRadius = 22
        hosting.layer?.masksToBounds = true

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 858, height: 506),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        win.titlebarAppearsTransparent = true
        win.titleVisibility = .hidden
        win.isMovableByWindowBackground = true
        win.backgroundColor = .clear
        win.contentView = hosting
        win.isReleasedWhenClosed = false
        win.delegate = self
        win.center()
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.window = win
    }

    func closeWindow() {
        window?.close()
        window = nil
    }

    // MARK: - NSWindowDelegate

    func windowWillClose(_ notification: Notification) {
        window = nil
    }
}
