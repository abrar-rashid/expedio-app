//
//  SearchViewModelTests.swift
//  ExpedioTests
//
//  Unit tests for SearchViewModel debounce and search behavior
//

import XCTest
@testable import expedio

final class SearchViewModelTests: XCTestCase {

    // MARK: - Mock Service

    class MockNominatimService: NominatimServiceProtocol {
        var searchResult: Result<[NominatimPlace], Error> = .success([])
        var searchCallCount = 0
        var lastQuery: String?

        func searchPlaces(query: String) async throws -> [NominatimPlace] {
            searchCallCount += 1
            lastQuery = query
            switch searchResult {
            case .success(let places): return places
            case .failure(let error): throw error
            }
        }
    }

    // MARK: - Tests

    func testInitialState_isEmpty() {
        let viewModel = SearchViewModel(service: MockNominatimService())

        XCTAssertTrue(viewModel.places.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.searchText, "")
    }

    func testSearchText_emptyString_clearsPlaces() async throws {
        let mockService = MockNominatimService()
        let viewModel = SearchViewModel(service: mockService)

        viewModel.searchText = ""
        try await Task.sleep(for: .milliseconds(100))

        XCTAssertTrue(viewModel.places.isEmpty)
        XCTAssertEqual(mockService.searchCallCount, 0)
    }

    func testSearchText_whitespaceOnly_doesNotSearch() async throws {
        let mockService = MockNominatimService()
        let viewModel = SearchViewModel(service: mockService)

        viewModel.searchText = "   "
        try await Task.sleep(for: .milliseconds(600))

        XCTAssertEqual(mockService.searchCallCount, 0)
    }

    func testSearchText_validQuery_performsSearchAfterDebounce() async throws {
        let mockPlace = NominatimPlace(
            placeId: 1, lat: "48.85", lon: "2.35",
            displayName: "Paris", category: nil, type: nil
        )
        let mockService = MockNominatimService()
        mockService.searchResult = .success([mockPlace])

        let viewModel = SearchViewModel(service: mockService)
        viewModel.searchText = "Paris"

        try await Task.sleep(for: .milliseconds(600))

        XCTAssertEqual(mockService.searchCallCount, 1)
        XCTAssertEqual(mockService.lastQuery, "Paris")
        XCTAssertEqual(viewModel.places.count, 1)
    }

    func testSearchText_rapidChanges_onlySearchesOnce() async throws {
        let mockService = MockNominatimService()
        let viewModel = SearchViewModel(service: mockService)

        viewModel.searchText = "P"
        viewModel.searchText = "Pa"
        viewModel.searchText = "Par"
        viewModel.searchText = "Pari"
        viewModel.searchText = "Paris"

        try await Task.sleep(for: .milliseconds(600))

        XCTAssertEqual(mockService.searchCallCount, 1)
        XCTAssertEqual(mockService.lastQuery, "Paris")
    }

    func testSearchText_serviceError_setsErrorMessage() async throws {
        let mockService = MockNominatimService()
        mockService.searchResult = .failure(NetworkError.serverError(500))

        let viewModel = SearchViewModel(service: mockService)
        viewModel.searchText = "Test"

        try await Task.sleep(for: .milliseconds(600))

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.places.isEmpty)
    }

    func testClearSearch_resetsAllState() async throws {
        let mockPlace = NominatimPlace(
            placeId: 1, lat: "0", lon: "0",
            displayName: "Test", category: nil, type: nil
        )
        let mockService = MockNominatimService()
        mockService.searchResult = .success([mockPlace])

        let viewModel = SearchViewModel(service: mockService)
        viewModel.searchText = "Test"
        try await Task.sleep(for: .milliseconds(600))

        viewModel.clearSearch()

        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertTrue(viewModel.places.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
}
