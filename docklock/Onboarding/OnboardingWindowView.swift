//
//  OnboardingWindowView.swift
//  docklock
//

import SwiftUI

enum OnboardingStep: Equatable {
    case welcome
    case permissions
}

struct OnboardingWindowView: View {
    @State private var currentStep: OnboardingStep = .welcome

    var body: some View {
        ZStack {
            switch currentStep {
            case .welcome:
                OnboardingWelcome(currentStep: $currentStep)
                    .transition(.opacity)
            case .permissions:
                OnboardingPermissions(currentStep: $currentStep)
                    .transition(.opacity)
            }
        }
        .frame(width: 858, height: 506)
        .animation(.easeInOut(duration: 0.2), value: currentStep)
    }
}
