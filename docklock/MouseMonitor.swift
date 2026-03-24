//
//  MouseMonitor.swift
//  docklock
//
//  Created by Timothy Lenardo on 10/27/25.
//

import ApplicationServices
import Cocoa
import Combine

class MouseMonitor: ObservableObject {
    static let shared = MouseMonitor()

    @Published var isLocked: Bool = true {
        didSet { UserDefaults.standard.set(isLocked, forKey: "isLocked") }
    }

    @Published private(set) var blockCount: Int = 0 {
        didSet { UserDefaults.standard.set(blockCount, forKey: "blockCount") }
    }

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let threshold: CGFloat = 3.0
    private(set) var isMonitoring = false

    // MARK: - Counting state
    // A "block" is counted when the cursor stays in the clamped zone for 2+ seconds.
    // After counting, state resets so the cursor must leave and return (or stay another
    // 2 seconds) before another count fires — preventing rapid double-counts.
    private var nearBottomSince: Date? = nil
    private var countTimer: Timer? = nil
    private let countDelay: TimeInterval = 0.5

    private init() {
        if UserDefaults.standard.object(forKey: "isLocked") != nil {
            isLocked = UserDefaults.standard.bool(forKey: "isLocked")
        }
        blockCount = UserDefaults.standard.integer(forKey: "blockCount")
    }

    // MARK: - Permission

    /// Silently checks AX permission and starts monitoring if granted.
    func startMonitoringIfPermitted() {
        if AXIsProcessTrusted() {
            startMonitoring()
        }
    }

    // MARK: - Monitoring

    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        let eventMask: CGEventMask = (1 << CGEventType.mouseMoved.rawValue) |
                                      (1 << CGEventType.leftMouseDragged.rawValue) |
                                      (1 << CGEventType.rightMouseDragged.rawValue) |
                                      (1 << CGEventType.otherMouseDragged.rawValue)

        // Pass self via userInfo so the non-capturing C callback can reach instance state.
        // Safe to use passUnretained because MouseMonitor.shared is never deallocated.
        let userInfo = Unmanaged.passUnretained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { _, _, event, userInfo -> Unmanaged<CGEvent>? in
                guard let userInfo else { return Unmanaged.passUnretained(event) }
                let monitor = Unmanaged<MouseMonitor>.fromOpaque(userInfo).takeUnretainedValue()
                return monitor.handleEvent(event)
            },
            userInfo: userInfo
        ) else {
            print("[DockLock] ❌ Failed to create event tap — missing accessibility permission?")
            isMonitoring = false
            return
        }

        eventTap = tap
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    func stopMonitoring() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            }
        }
        eventTap = nil
        runLoopSource = nil
        isMonitoring = false
        resetNearBottomState()
    }

    func toggleLock() {
        isLocked.toggle()
        if !isLocked { resetNearBottomState() }
    }

    // MARK: - Core Logic

    /// Intercepts the event and clips only the y coordinate if the cursor is within
    /// `threshold` px of the bottom of any screen. x is passed through untouched,
    /// so horizontal drags along the bottom edge remain seamless.
    private func handleEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        guard isLocked else { return Unmanaged.passUnretained(event) }

        // CGEvent uses Quartz coords: origin top-left of primary screen, y increases downward.
        let loc = event.location

        // Convert to Cocoa coords (origin bottom-left, y upward) to compare against NSScreen frames.
        let primaryHeight = NSScreen.screens
            .first(where: { $0.frame.minX == 0 && $0.frame.minY == 0 })?
            .frame.height ?? 0

        let cocoaY = primaryHeight - loc.y

        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(CGPoint(x: loc.x, y: cocoaY)) }) else {
            resetNearBottomState()
            return Unmanaged.passUnretained(event)
        }

        let distanceFromBottom = cocoaY - screen.frame.minY

        if distanceFromBottom < threshold {
            // Clip only y — x is left completely untouched.
            let clippedCocoaY = screen.frame.minY + threshold
            let clippedQuartzY = primaryHeight - clippedCocoaY
            event.location = CGPoint(x: loc.x, y: clippedQuartzY)

            // Start the 2-second count timer on first entry into the zone.
            if nearBottomSince == nil {
                nearBottomSince = Date()
                scheduleCountTimer()
            }
        } else {
            // Cursor left the clamped zone — cancel any pending count.
            resetNearBottomState()
        }

        return Unmanaged.passUnretained(event)
    }

    // MARK: - Count helpers

    private func scheduleCountTimer() {
        countTimer?.invalidate()
        countTimer = Timer.scheduledTimer(withTimeInterval: countDelay, repeats: false) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.blockCount += 1
                // Reset so the cursor must stay another full `countDelay` before counting again.
                self.nearBottomSince = nil
                self.countTimer = nil
            }
        }
        if let countTimer {
            RunLoop.current.add(countTimer, forMode: .common)
        }
    }

    private func resetNearBottomState() {
        countTimer?.invalidate()
        countTimer = nil
        nearBottomSince = nil
    }
}
