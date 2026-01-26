//
//  CategoryBrowseViewModelTests.swift
//  expedioTests
//
//  Unit tests for CategoryBrowseViewModel
//

import XCTest
@testable import expedio

final class CategoryBrowseViewModelTests: XCTestCase {

    // MARK: - Mock Service

    class MockOverpassService: OverpassServiceProtocol {
        var mockPlaces: [OverpassElement] = []
        var mockError: Error?
        var fetchCalled = false
        var lastCity: String?
        var lastCategory: PlaceCategory?

        func fetchPlaces(city: String, category: PlaceCategory) async throws -> [OverpassElement] {
            fetchCalled = true
            lastCity = city
            lastCategory = category
            if let error = mockError {
                throw error
            }
            return mockPlaces
        }

        func fetchNearbyPlaces(latitude: Double, longitude: Double, category: PlaceCategory, radiusMeters: Int) async throws -> [OverpassElement] {
            fetchCalled = true
            lastCategory = category
            if let error = mockError {
                throw error
            }
            return mockPlaces
        }
    }

    // MARK: - Tests

    @MainActor
    func testInit_setsDestination() {
        let destination = Destination(name: "Paris", country: "France", lat: 48.8566, lon: 2.3522)
        let viewModel = CategoryBrowseViewModel(destination: destination)

        XCTAssertEqual(viewModel.destination.name, "Paris")
        XCTAssertEqual(viewModel.destination.country, "France")
    }

    @MainActor
    func testInit_defaultCategoryIsAttraction() {
        let destination = Destination(name: "Paris", country: "France", lat: 48.8566, lon: 2.3522)
        let viewModel = CategoryBrowseViewModel(destination: destination)

        XCTAssertEqual(viewModel.selectedCategory, .attraction)
    }

    @MainActor
    func testLoadPlaces_callsServiceWithCorrectParams() async {
        let destination = Destination(name: "Paris", country: "France", lat: 48.8566, lon: 2.3522)
        let mockService = MockOverpassService()
        let viewModel = CategoryBrowseViewModel(destination: destination, service: mockService)

        viewModel.selectedCategory = .restaurant
        await viewModel.loadPlaces()

        XCTAssertTrue(mockService.fetchCalled)
        XCTAssertEqual(mockService.lastCity, "Paris")
        XCTAssertEqual(mockService.lastCategory, .restaurant)
    }

    @MainActor
    func testLoadPlaces_success_setsPlaces() async {
        let destination = Destination(name: "Paris", country: "France", lat: 48.8566, lon: 2.3522)
        let mockService = MockOverpassService()

        let json = """
        {"type": "node", "id": 1, "lat": 48.85, "lon": 2.35, "tags": {"name": "Test Place", "amenity": "restaurant"}}
        """.data(using: .utf8)!
        let element = try! JSONDecoder().decode(OverpassElement.self, from: json)
        mockService.mockPlaces = [element]

        let viewModel = CategoryBrowseViewModel(destination: destination, service: mockService)
        await viewModel.loadPlaces()

        XCTAssertEqual(viewModel.places.count, 1)
        XCTAssertEqual(viewModel.places.first?.name, "Test Place")
        XCTAssertNil(viewModel.errorMessage)
    }

    @MainActor
    func testLoadPlaces_failure_setsErrorMessage() async {
        let destination = Destination(name: "Paris", country: "France", lat: 48.8566, lon: 2.3522)
        let mockService = MockOverpassService()
        mockService.mockError = OverpassError.serverError(500)

        let viewModel = CategoryBrowseViewModel(destination: destination, service: mockService)
        await viewModel.loadPlaces()

        XCTAssertTrue(viewModel.places.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    @MainActor
    func testLoadPlaces_setsLoadingState() async {
        let destination = Destination(name: "Paris", country: "France", lat: 48.8566, lon: 2.3522)
        let mockService = MockOverpassService()
        let viewModel = CategoryBrowseViewModel(destination: destination, service: mockService)

        // After loadPlaces completes, isLoading should be false
        await viewModel.loadPlaces()
        XCTAssertFalse(viewModel.isLoading)
    }

    @MainActor
    func testCategoryChange_triggersReload() async {
        let destination = Destination(name: "Paris", country: "France", lat: 48.8566, lon: 2.3522)
        let mockService = MockOverpassService()
        let viewModel = CategoryBrowseViewModel(destination: destination, service: mockService)

        // Change category
        viewModel.selectedCategory = .cafe

        // Wait for async reload
        try? await Task.sleep(for: .milliseconds(100))

        XCTAssertTrue(mockService.fetchCalled)
        XCTAssertEqual(mockService.lastCategory, .cafe)
    }
}
