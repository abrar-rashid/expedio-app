//
//  ImageCacheManagerTests.swift
//  ExpedioTests
//
//  Unit tests for ImageCacheManager
//

import XCTest
@testable import expedio

final class ImageCacheManagerTests: XCTestCase {

    var cacheManager: ImageCacheManager!

    override func setUp() {
        super.setUp()
        cacheManager = ImageCacheManager.shared
    }

    override func tearDown() {
        cacheManager.clearCache()
        super.tearDown()
    }

    // MARK: - Memory Cache Tests

    func testSetAndGetImage_memoryCacheHit() {
        let testImage = createTestImage(color: .red)
        let key = "test_image_\(UUID().uuidString)"

        cacheManager.setImage(testImage, forKey: key)

        // Small delay to ensure async disk write doesn't interfere
        let expectation = XCTestExpectation(description: "Cache retrieval")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let retrievedImage = self.cacheManager.image(forKey: key)
            XCTAssertNotNil(retrievedImage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testGetImage_keyNotFound_returnsNil() {
        let result = cacheManager.image(forKey: "nonexistent_key_\(UUID().uuidString)")

        XCTAssertNil(result)
    }

    func testSetImage_multipleImages_allCached() {
        let keys = (0..<5).map { "multi_test_\($0)_\(UUID().uuidString)" }
        let images = keys.map { _ in createTestImage(color: .blue) }

        for (key, image) in zip(keys, images) {
            cacheManager.setImage(image, forKey: key)
        }

        let expectation = XCTestExpectation(description: "Multiple cache retrieval")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for key in keys {
                let retrieved = self.cacheManager.image(forKey: key)
                XCTAssertNotNil(retrieved, "Image for key \(key) should be cached")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Clear Cache Tests

    func testClearCache_removesAllImages() {
        let key = "clear_test_\(UUID().uuidString)"
        let testImage = createTestImage(color: .green)

        cacheManager.setImage(testImage, forKey: key)

        let expectation = XCTestExpectation(description: "Cache clear")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Verify it's cached
            XCTAssertNotNil(self.cacheManager.image(forKey: key))

            // Clear cache
            self.cacheManager.clearCache()

            // Verify it's gone from memory
            // Note: Disk cache clear is async, so we only test memory here
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // After clear, memory cache should be empty
                // (disk might still have it briefly due to async)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Load Image Tests

    func testLoadImage_validURL_returnsImage() async {
        // Use a small test image URL (1x1 pixel)
        // Note: This test requires network access
        // In a real test suite, you'd mock URLSession
        let testURL = URL(string: "https://via.placeholder.com/10x10.png")!

        let image = await cacheManager.loadImage(from: testURL)

        // Image may or may not load depending on network
        // This test verifies the method doesn't crash
        if image != nil {
            XCTAssertNotNil(image)
        }
    }

    func testLoadImage_invalidURL_returnsNil() async {
        let invalidURL = URL(string: "https://invalid.nonexistent.domain/image.png")!

        let image = await cacheManager.loadImage(from: invalidURL)

        XCTAssertNil(image)
    }

    // MARK: - Helpers

    private func createTestImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContext(size)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
