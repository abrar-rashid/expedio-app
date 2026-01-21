//
//  ContentView.swift
//  Expedio
//
//  Placeholder view for Phase 1 testing
//  Will be replaced with TabView in Phase 6
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()

            VStack(spacing: Theme.Spacing.lg) {
                Text("Expedio")
                    .font(Theme.Typography.largeTitle)
                    .foregroundColor(Theme.Colors.textPrimary)

                Text("Travel Itinerary App")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.textSecondary)

                // Demo of card style
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Phase 1: Design System")
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.textPrimary)

                    Text("Theme, colors, and typography configured")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .padding(Theme.Spacing.md)
                .cardStyle()
                .padding(.horizontal, Theme.Spacing.md)

                // Demo of button style
                Button("Get Started") {
                    // No action yet
                }
                .primaryButtonStyle()
            }
        }
    }
}

#Preview {
    ContentView()
}
