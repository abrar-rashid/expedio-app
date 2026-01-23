//
//  CachedAsyncImage.swift
//  Expedio
//
//  Async image loading with memory and disk caching
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var loadedImage: UIImage?
    @State private var isLoading = false

    var body: some View {
        Group {
            if let image = loadedImage {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .onAppear {
                        loadImageIfNeeded()
                    }
            }
        }
    }

    private func loadImageIfNeeded() {
        guard !isLoading, loadedImage == nil, let url = url else { return }

        isLoading = true

        Task {
            if let image = await ImageCacheManager.shared.loadImage(from: url) {
                await MainActor.run {
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.loadedImage = image
                    }
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Convenience Initializers

extension CachedAsyncImage where Placeholder == Color {
    /// Initialize with a simple color placeholder
    init(url: URL?, @ViewBuilder content: @escaping (Image) -> Content) {
        self.url = url
        self.content = content
        self.placeholder = { Color.gray.opacity(0.2) }
    }
}

extension CachedAsyncImage where Content == Image, Placeholder == Color {
    /// Initialize with default image content and color placeholder
    init(url: URL?) {
        self.url = url
        self.content = { $0 }
        self.placeholder = { Color.gray.opacity(0.2) }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        CachedAsyncImage(
            url: URL(string: "https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=400")
        ) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(Theme.Colors.secondary.opacity(0.3))
                .overlay {
                    ProgressView()
                }
        }
        .frame(width: 300, height: 200)
        .cornerRadius(Theme.CornerRadius.md)

        Text("Paris, France")
            .font(Theme.Typography.headline)
    }
    .padding()
}
