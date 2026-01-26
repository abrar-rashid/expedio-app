//
//  HomeView.swift
//  Expedio
//
//  Popular destinations homepage with grid layout
//

import SwiftUI

struct HomeView: View {
    private let columns = [
        GridItem(.flexible(), spacing: Theme.Spacing.md),
        GridItem(.flexible(), spacing: Theme.Spacing.md)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    // Header section
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("Popular Destinations")
                            .font(Theme.Typography.title)
                            .foregroundColor(Theme.Colors.textPrimary)

                        Text("Explore the world's most amazing cities")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, Theme.Spacing.sm)

                    // Destinations grid
                    LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
                        ForEach(Destination.popular) { destination in
                            NavigationLink(value: destination) {
                                DestinationCard(destination: destination)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                }
                .padding(.bottom, Theme.Spacing.lg)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Destination.self) { destination in
                CategoryBrowseView(destination: destination)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
