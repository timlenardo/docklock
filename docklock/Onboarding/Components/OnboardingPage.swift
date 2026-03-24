//
//  OnboardingPage.swift
//  docklock
//

import SwiftUI

struct OnboardingPage<
    HeaderContent: View,
    BodyContent: View,
    FooterContent: View
>: View {
    // MARK: - Properties

    private let showBack: Bool
    private let onBack: (() -> Void)?
    private let nextButtonText: String
    private let nextDisabled: Bool
    private let onNext: (() -> Void)?

    @ViewBuilder private let headerContent: () -> HeaderContent
    @ViewBuilder private let bodyContent: () -> BodyContent
    @ViewBuilder private let footerContent: () -> FooterContent

    init(
        showBack: Bool = false,
        onBack: (() -> Void)? = nil,
        nextButtonText: String = "Next",
        nextDisabled: Bool = false,
        onNext: (() -> Void)? = nil,
        @ViewBuilder headerContent: @escaping () -> HeaderContent,
        @ViewBuilder bodyContent: @escaping () -> BodyContent = { EmptyView() },
        @ViewBuilder footerContent: @escaping () -> FooterContent = { EmptyView() }
    ) {
        self.showBack = showBack
        self.onBack = onBack
        self.nextButtonText = nextButtonText
        self.nextDisabled = nextDisabled
        self.onNext = onNext
        self.headerContent = headerContent
        self.bodyContent = bodyContent
        self.footerContent = footerContent
    }

    // MARK: - States

    @State private var isHoveredBack = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            contentSection
            footerSection
        }
    }

    // MARK: - Sections

    private var contentSection: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 16) {
                headerContent()
            }
            .padding(.top, 44)

            bodyContent()

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VisualEffectView(material: .hudWindow))
    }

    private var footerSection: some View {
        HStack(alignment: .center, spacing: 0) {
            if showBack {
                backButton
            }

            footerContent()

            Spacer()

            OnboardingNextButton(
                text: nextButtonText,
                disabled: nextDisabled,
                action: { onNext?() }
            )
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .frame(height: 62)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .top
        )
        .background(VisualEffectView(material: .hudWindow))
    }

    // MARK: - Back Button

    private var backButton: some View {
        Button {
            onBack?()
        } label: {
            Text("←")
                .font(.system(size: 15))
                .foregroundColor(Color(NSColor.secondaryLabelColor))
                .frame(width: 25, height: 25)
                .background(isHoveredBack ? Color.secondary.opacity(0.15) : .clear)
                .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHoveredBack = $0 }
    }
}

// MARK: - Next Button

struct OnboardingNextButton: View {
    let text: String
    let disabled: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button {
            if !disabled { action() }
        } label: {
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .frame(height: 40)
                .background(isHovered ? Color.onboardingBlue350 : Color.onboardingBlue400)
                .cornerRadius(9)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(disabled ? 0.4 : 1)
        .allowsHitTesting(!disabled)
        .onHover { isHovered = $0 }
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
}
