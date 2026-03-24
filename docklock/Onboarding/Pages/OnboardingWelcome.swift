//
//  OnboardingWelcome.swift
//  docklock
//

import SwiftUI

struct OnboardingWelcome: View {
    @Binding var currentStep: OnboardingStep

    var body: some View {
        OnboardingPage(
            nextButtonText: "Get Started",
            onNext: { currentStep = .permissions },
            headerContent: {
                OnboardingTitlePill(systemIcon: "lock.fill", text: "DockLock")

                VStack(alignment: .center, spacing: 11) {
                    Text("Keep Your Dock Hidden")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color(NSColor.labelColor))
                        .multilineTextAlignment(.center)

                    Text("Stop the Dock from appearing accidentally\nwhen you need to stay in the zone.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 40)
            },
            bodyContent: {
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(
                        icon: "cursorarrow.motionlines",
                        title: "Mouse detection",
                        description: "Blocks the cursor from reaching the Dock zone"
                    )
                    FeatureRow(
                        icon: "dock.rectangle",
                        title: "Stays hidden",
                        description: "The Dock stays out of sight even when you move to the bottom"
                    )
                    FeatureRow(
                        icon: "menubar.rectangle",
                        title: "Menu bar control",
                        description: "Toggle locking on and off from the menu bar anytime"
                    )
                }
                .padding(.top, 36)
                .padding(.horizontal, 80)
            }
        )
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color.onboardingBlue300)
                .frame(width: 28, alignment: .center)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(NSColor.labelColor))

                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(NSColor.secondaryLabelColor))
            }
        }
    }
}
