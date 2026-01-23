//
//  ImageCacheManager.swift
//  Expedio
//
//  Two-tier image cache: memory (NSCache) + disk (file system)
//

import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()

    // MARK: - Memory Cache

    private let memoryCache = NSCache<NSString, UIImage>()

    // MARK: - Disk Cache

    private let fileManager = FileManager.default
    private lazy var cacheDirectory: URL = {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDir = urls[0].appendingPathComponent("ImageCache", isDirectory: true)
        try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        return cacheDir
    }()

    // MARK: - Configuration

    private let maxMemoryCacheCount = 50
    private let maxDiskCacheAgeSeconds: TimeInterval = 60 * 60 * 24 * 7 // 7 days

    // MARK: - Init

    private init() {
        memoryCache.countLimit = maxMemoryCacheCount

        // Clean old disk cache on launch
        cleanExpiredDiskCache()
    }

    // MARK: - Public API

    /// Get image from cache (memory first, then disk)
    func image(forKey key: String) -> UIImage? {
        let cacheKey = sanitizedKey(key)

        // Check memory cache first
        if let memoryImage = memoryCache.object(forKey: cacheKey as NSString) {
            return memoryImage
        }

        // Check disk cache
        if let diskImage = loadFromDisk(key: cacheKey) {
            // Promote to memory cache
            memoryCache.setObject(diskImage, forKey: cacheKey as NSString)
            return diskImage
        }

        return nil
    }

    /// Store image in both memory and disk cache
    func setImage(_ image: UIImage, forKey key: String) {
        let cacheKey = sanitizedKey(key)

        // Store in memory
        memoryCache.setObject(image, forKey: cacheKey as NSString)

        // Store on disk asynchronously
        Task.detached(priority: .background) { [weak self] in
            self?.saveToDisk(image: image, key: cacheKey)
        }
    }

    /// Load image from URL with caching
    func loadImage(from url: URL) async -> UIImage? {
        let key = url.absoluteString

        // Check cache first
        if let cached = image(forKey: key) {
            return cached
        }

        // Download
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }

            // Cache the downloaded image
            setImage(image, forKey: key)
            return image
        } catch {
            return nil
        }
    }

    /// Clear all cached images
    func clearCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Private Disk Operations

    private func sanitizedKey(_ key: String) -> String {
        // Create a safe filename from the URL
        key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? key
    }

    private func diskURL(for key: String) -> URL {
        cacheDirectory.appendingPathComponent(key)
    }

    private func loadFromDisk(key: String) -> UIImage? {
        let url = diskURL(for: key)
        guard fileManager.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }

    private func saveToDisk(image: UIImage, key: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let url = diskURL(for: key)
        try? data.write(to: url)
    }

    private func cleanExpiredDiskCache() {
        Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }

            let resourceKeys: Set<URLResourceKey> = [.contentModificationDateKey]
            guard let enumerator = self.fileManager.enumerator(
                at: self.cacheDirectory,
                includingPropertiesForKeys: Array(resourceKeys)
            ) else { return }

            let expirationDate = Date().addingTimeInterval(-self.maxDiskCacheAgeSeconds)

            for case let fileURL as URL in enumerator {
                guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                      let modificationDate = resourceValues.contentModificationDate else {
                    continue
                }

                if modificationDate < expirationDate {
                    try? self.fileManager.removeItem(at: fileURL)
                }
            }
        }
    }
}
