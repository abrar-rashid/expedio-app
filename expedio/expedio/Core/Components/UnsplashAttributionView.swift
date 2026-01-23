//
//  UnsplashAttributionView.swift
//  Expedio
//
//  Attribution view required by Unsplash API Terms of Service
//  https://unsplash.com/documentation#guidelines--crediting
//

import SwiftUI

struct UnsplashAttributionView: View {
    let photographerName: String
    let photographerUsername: String

    private let appName = "Expedio"

    var body: some View {
        HStack(spacing: 4) {
            Text("Photo by")
            Link(photographerName, destination: photographerURL)
                .underline()
            Text("on")
            Link("Unsplash", destination: unsplashURL)
                .underline()
        }
        .font(Theme.Typography.caption)
        .foregroundColor(Theme.Colors.textSecondary)
    }

    private var photographerURL: URL {
        URL(string: "https://unsplash.com/@\(photographerUsername)?utm_source=\(appName)&utm_medium=referral")!
    }

    private var unsplashURL: URL {
        URL(string: "https://unsplash.com/?utm_source=\(appName)&utm_medium=referral")!
    }
}

// MARK: - Compact Attribution

/// A more compact attribution for use in cards
struct CompactUnsplashAttribution: View {
    let photo: UnsplashPhoto

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "camera.fill")
            Text(photo.user.name)
        }
        .font(Theme.Typography.caption)
        .foregroundColor(.white.opacity(0.9))
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xs)
        .background(.black.opacity(0.5))
        .cornerRadius(Theme.CornerRadius.sm)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        UnsplashAttributionView(
            photographerName: "John Doe",
            photographerUsername: "johndoe"
        )

        ZStack(alignment: .bottomTrailing) {
            Rectangle()
                .fill(Theme.Colors.secondary)
                .frame(height: 150)

            CompactUnsplashAttribution(
                photo: UnsplashPhoto(
                    id: "1",
                    urls: UnsplashURLs(
                        raw: "", full: "", regular: "", small: "", thumb: ""
                    ),
                    user: UnsplashUser(id: "1", name: "Jane Smith", username: "janesmith"),
                    color: nil,
                    description: nil,
                    altDescription: nil
                )
            )
            .padding(Theme.Spacing.sm)
        }
        .cornerRadius(Theme.CornerRadius.md)
    }
    .padding()
}
