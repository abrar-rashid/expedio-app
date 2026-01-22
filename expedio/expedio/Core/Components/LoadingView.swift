//
//  LoadingView.swift
//  Expedio
//
//  Styled loading indicator using the app's design system
//

import SwiftUI

struct LoadingView: View {
    var message: String? = nil

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .stroke(Theme.Colors.primary.opacity(0.2), lineWidth: 4)
                    .frame(width: 44, height: 44)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        Theme.Colors.primary,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        .linear(duration: 1)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }

            if let message = message {
                Text(message)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ZStack {
        Theme.Colors.background.ignoresSafeArea()
        LoadingView(message: "Searching...")
    }
}
