//
//  DestinationCard.swift
//  Expedio
//
//  Card component displaying destination with Unsplash image
//

import SwiftUI

struct DestinationCard: View {
    let destination: Destination
    @State private var photo: UnsplashPhoto?
    @State private var isLoading = true

    private let unsplashService = UnsplashService()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section - Color.clear defines layout bounds, image overlays
            Color.clear
                .frame(height: 120)
                .overlay {
                    if let photo = photo {
                        CachedAsyncImage(
                            url: URL(string: photo.urls.small)
                        ) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            placeholderView
                        }
                    } else {
                        placeholderView
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if let photo = photo {
                        CompactUnsplashAttribution(photo: photo)
                            .padding(Theme.Spacing.xs)
                    }
                }
                .clipped()

            // Text section
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(destination.name)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(1)

                Text(destination.country)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(Theme.Spacing.sm)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .task {
            await loadImage()
        }
    }

    private var placeholderView: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Theme.Colors.secondary.opacity(0.3),
                        Theme.Colors.primary.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                if isLoading {
                    ProgressView()
                        .tint(Theme.Colors.primary)
                }
            }
    }

    private func loadImage() async {
        isLoading = true
        defer { isLoading = false }

        do {
            print("🔍 Fetching image for: \(destination.searchQuery)")
            let photos = try await unsplashService.searchPhotos(
                query: destination.searchQuery,
                perPage: 1
            )
            print("✅ Received \(photos.count) photos for \(destination.name)")
            if let firstPhoto = photos.first {
                print("🖼️ Setting photo URL: \(firstPhoto.urls.small)")
                self.photo = firstPhoto
            } else {
                print("⚠️ No photos found for \(destination.name)")
            }
        } catch {
            // Silently fail - show placeholder on error
            // In production, could log to analytics
            print("❌ Failed to load image for \(destination.name): \(error)")
            print("   Error details: \(error.localizedDescription)")
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Theme.Spacing.md) {
        DestinationCard(
            destination: Destination(
                name: "Paris",
                country: "France",
                lat: 48.8566,
                lon: 2.3522
            )
        )
        .frame(width: 160)

        DestinationCard(
            destination: Destination(
                name: "Tokyo",
                country: "Japan",
                lat: 35.6762,
                lon: 139.6503
            )
        )
        .frame(width: 160)
    }
    .padding()
    .background(Theme.Colors.background)
}
