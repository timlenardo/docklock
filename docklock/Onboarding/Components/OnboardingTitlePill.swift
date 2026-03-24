//
//  OnboardingTitlePill.swift
//  docklock
//

import SwiftUI

struct OnboardingTitlePill: View {
    let systemIcon: String
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Image(systemName: systemIcon)
                .font(.system(size: 12))
                .foregroundColor(Color.onboardingBlue300)

            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.onboardingBlue300)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(Color.onboardingBlue400.opacity(0.15))
        .clipShape(Capsule())
    }
}
