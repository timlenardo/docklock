//
//  OnboardingPermissions.swift
//  docklock
//

import ApplicationServices
import SwiftUI

struct OnboardingPermissions: View {
    @Binding var currentStep: OnboardingStep
    @AppStorage("onboardingCompleted") private var onboardingCompleted: Bool = false

    @State private var isAccessibilityGranted: Bool = AXIsProcessTrusted()
    @State private var hasCheckedInitially: Bool = false

    var body: some View {
        OnboardingPage(
            showBack: true,
            onBack: { currentStep = .welcome },
            nextButtonText: "Continue",
            nextDisabled: !isAccessibilityGranted,
            onNext: {
                onboardingCompleted = true
                MouseMonitor.shared.startMonitoring()
                OnboardingWindowManager.shared.closeWindow()
            },
            headerContent: {
                VStack(alignment: .center, spacing: 11) {
                    Text("Permissions")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color(NSColor.labelColor))
                        .multilineTextAlignment(.center)

                    Text("DockLock needs one permission to control\nyour cursor and keep the Dock hidden.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 40)
            },
            bodyContent: {
                VStack(alignment: .leading, spacing: 0) {
                    accessibilityRow
                        .padding(.horizontal, 40)
                        .padding(.top, 40)

                    Divider()
                        .padding(.top, 24)
                        .padding(.horizontal, 40)
                }
            },
            footerContent: {
                Spacer()
            }
        )
        .onAppear {
            isAccessibilityGranted = AXIsProcessTrusted()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                hasCheckedInitially = true
            }
        }
        .task {
            while !Task.isCancelled {
                isAccessibilityGranted = AXIsProcessTrusted()
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
        }
    }

    // MARK: - Permission Row

    private var accessibilityRow: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "accessibility")
                        .font(.system(size: 18))
                        .foregroundColor(Color(NSColor.labelColor))
                        .frame(width: 22, height: 22)

                    Text("Accessibility")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(Color(NSColor.labelColor))

                    Text("Required")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                        .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
                        .cornerRadius(6)
                }

                Text("Allows DockLock to monitor and reposition your cursor to prevent the Dock from appearing.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(NSColor.secondaryLabelColor))
                    .padding(.leading, 30)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            PulsingPermissionButton(
                text: isAccessibilityGranted ? "Granted" : "Grant Access",
                isGranted: isAccessibilityGranted,
                shouldPulse: hasCheckedInitially && !isAccessibilityGranted,
                action: {
                    let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
                    _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
                }
            )
        }
    }

}

// MARK: - Pulsing Permission Button

private struct PulsingPermissionButton: View {
    let text: String
    let isGranted: Bool
    let shouldPulse: Bool
    let action: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var pulseTimer: Timer?
    @State private var isHovered: Bool = false

    var body: some View {
        Button {
            if !isGranted { action() }
        } label: {
            HStack(alignment: .center, spacing: 6) {
                Text(text)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(shouldPulse && !isGranted ? .white : Color(NSColor.labelColor))

                if isGranted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(NSColor.labelColor))
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 37)
            .background(buttonBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isGranted ? Color(NSColor.separatorColor) : Color.clear, lineWidth: 1)
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isGranted)
        .allowsHitTesting(!isGranted)
        .scaleEffect(scale)
        .onChange(of: shouldPulse) { _, newValue in
            if newValue { startPulse() } else { stopPulse() }
        }
        .onAppear { if shouldPulse { startPulse() } }
        .onDisappear { stopPulse() }
        .onHover { isHovered = $0 }
    }

    private var buttonBackground: Color {
        if isGranted { return .clear }
        if shouldPulse {
            return isHovered ? Color.onboardingBlue400.opacity(0.75) : Color.onboardingBlue400
        }
        return isHovered
            ? Color(NSColor.controlBackgroundColor).opacity(0.8)
            : Color(NSColor.controlBackgroundColor).opacity(0.5)
    }

    private func startPulse() {
        stopPulse()
        performPulse()
        pulseTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            performPulse()
        }
    }

    private func stopPulse() {
        pulseTimer?.invalidate()
        pulseTimer = nil
        withAnimation(.easeOut(duration: 0.15)) { scale = 1.0 }
    }

    private func performPulse() {
        withAnimation(.easeOut(duration: 0.12)) { scale = 1.08 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeIn(duration: 0.15)) { scale = 1.0 }
        }
    }
}
