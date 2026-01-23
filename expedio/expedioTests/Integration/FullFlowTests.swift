//
//  FullFlowTests.swift
//  ExpedioTests
//
//  End-to-end integration tests for the full app flow
//

import XCTest
import SwiftData
import SwiftUI
@testable import expedio

final class FullFlowTests: XCTestCase {

    @MainActor
    func testFullFlow_createTripAndAddPlace() throws {
        // Setup in-memory container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, SavedPlace.self, configurations: config)
        let context = container.mainContext

        // 1. Create a trip using TripsListViewModel
        let tripsViewModel = TripsListViewModel()
        tripsViewModel.createTrip(
            name: "Paris Adventure",
            destination: "Paris, France",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 7),
            context: context
        )

        // Verify trip created
        let tripDescriptor = FetchDescriptor<Trip>()
        let trips = try context.fetch(tripDescriptor)
        XCTAssertEqual(trips.count, 1)

        let trip = trips.first!
        XCTAssertEqual(trip.name, "Paris Adventure")

        // 2. Add a place to the trip (simulating what PlaceDetailView does)
        let nominatimPlace = NominatimPlace(
            placeId: 12345,
            lat: "48.8584",
            lon: "2.2945",
            displayName: "Eiffel Tower, Paris, France",
            category: "tourism",
            type: "attraction"
        )

        let orderIndex = trip.places.count
        let savedPlace = SavedPlace(from: nominatimPlace, orderIndex: orderIndex)
        savedPlace.trip = trip
        trip.places.append(savedPlace)
        try context.save()

        // Verify place added
        XCTAssertEqual(trip.places.count, 1)
        XCTAssertEqual(trip.places.first?.name, "Eiffel Tower")
        XCTAssertEqual(trip.places.first?.orderIndex, 0)

        // 3. Add another place
        let nominatimPlace2 = NominatimPlace(
            placeId: 67890,
            lat: "48.8606",
            lon: "2.3376",
            displayName: "Louvre Museum, Paris, France",
            category: "tourism",
            type: "museum"
        )

        let orderIndex2 = trip.places.count
        let savedPlace2 = SavedPlace(from: nominatimPlace2, orderIndex: orderIndex2)
        savedPlace2.trip = trip
        trip.places.append(savedPlace2)
        try context.save()

        XCTAssertEqual(trip.places.count, 2)
        XCTAssertEqual(trip.sortedPlaces[1].orderIndex, 1)

        // 4. Reorder places using TripDetailViewModel
        let tripDetailViewModel = TripDetailViewModel(trip: trip)
        tripDetailViewModel.movePlaces(from: IndexSet(integer: 0), to: 2, context: context)

        let sorted = trip.sortedPlaces
        XCTAssertEqual(sorted[0].name, "Louvre Museum")
        XCTAssertEqual(sorted[1].name, "Eiffel Tower")

        // 5. Delete a place
        tripDetailViewModel.deletePlace(sorted[0], context: context)
        XCTAssertEqual(trip.places.count, 1)

        // 6. Delete the trip
        tripsViewModel.deleteTrip(trip, context: context)

        let remainingTrips = try context.fetch(tripDescriptor)
        XCTAssertTrue(remainingTrips.isEmpty)
    }

    @MainActor
    func testCascadeDelete_tripDeletionRemovesPlaces() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, SavedPlace.self, configurations: config)
        let context = container.mainContext

        let trip = Trip(name: "Test", destination: "Test")
        let place1 = SavedPlace(
            placeId: "1", name: "Place 1", displayName: "Place 1",
            category: "Test", lat: "0", lon: "0", orderIndex: 0
        )
        let place2 = SavedPlace(
            placeId: "2", name: "Place 2", displayName: "Place 2",
            category: "Test", lat: "0", lon: "0", orderIndex: 1
        )
        trip.places = [place1, place2]
        context.insert(trip)
        try context.save()

        // Verify places exist
        let placeDescriptor = FetchDescriptor<SavedPlace>()
        var places = try context.fetch(placeDescriptor)
        XCTAssertEqual(places.count, 2)

        // Delete trip
        let viewModel = TripsListViewModel()
        viewModel.deleteTrip(trip, context: context)

        // Verify places are cascade deleted
        places = try context.fetch(placeDescriptor)
        XCTAssertTrue(places.isEmpty)
    }

    @MainActor
    func testSearchViewModel_debouncesBehavior() async throws {
        // Test that the search view model properly debounces
        let mockService = MockNominatimService()
        mockService.searchResult = .success([
            NominatimPlace(
                placeId: 1, lat: "48.85", lon: "2.35",
                displayName: "Paris, France", category: "place", type: "city"
            )
        ])

        let viewModel = SearchViewModel(service: mockService)

        // Rapid typing simulation
        viewModel.searchText = "P"
        viewModel.searchText = "Pa"
        viewModel.searchText = "Par"
        viewModel.searchText = "Pari"
        viewModel.searchText = "Paris"

        // Wait for debounce
        try await Task.sleep(for: .milliseconds(600))

        // Should only have searched once with final value
        XCTAssertEqual(mockService.searchCallCount, 1)
        XCTAssertEqual(mockService.lastQuery, "Paris")
        XCTAssertEqual(viewModel.places.count, 1)
    }

    @MainActor
    func testSavedPlace_initFromNominatimPlace() {
        // Test that SavedPlace correctly extracts name from display name
        let nominatimPlace = NominatimPlace(
            placeId: 123,
            lat: "48.8584",
            lon: "2.2945",
            displayName: "Eiffel Tower, Champ de Mars, Paris, France",
            category: "tourism",
            type: "attraction"
        )

        let savedPlace = SavedPlace(from: nominatimPlace, orderIndex: 5)

        XCTAssertEqual(savedPlace.placeId, "123")
        XCTAssertEqual(savedPlace.name, "Eiffel Tower")
        XCTAssertEqual(savedPlace.displayName, "Eiffel Tower, Champ de Mars, Paris, France")
        XCTAssertEqual(savedPlace.category, "Tourism · Attraction")
        XCTAssertEqual(savedPlace.lat, "48.8584")
        XCTAssertEqual(savedPlace.lon, "2.2945")
        XCTAssertEqual(savedPlace.orderIndex, 5)
    }

    @MainActor
    func testTrip_sortedPlaces_returnsByOrderIndex() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, SavedPlace.self, configurations: config)
        let context = container.mainContext

        let trip = Trip(name: "Test", destination: "Test")
        let place1 = SavedPlace(
            placeId: "1", name: "Third", displayName: "Third",
            category: "Test", lat: "0", lon: "0", orderIndex: 2
        )
        let place2 = SavedPlace(
            placeId: "2", name: "First", displayName: "First",
            category: "Test", lat: "0", lon: "0", orderIndex: 0
        )
        let place3 = SavedPlace(
            placeId: "3", name: "Second", displayName: "Second",
            category: "Test", lat: "0", lon: "0", orderIndex: 1
        )
        trip.places = [place1, place2, place3]
        context.insert(trip)
        try context.save()

        let sorted = trip.sortedPlaces

        XCTAssertEqual(sorted[0].name, "First")
        XCTAssertEqual(sorted[1].name, "Second")
        XCTAssertEqual(sorted[2].name, "Third")
    }
}

// MARK: - Mock Service for Integration Tests
private class MockNominatimService: NominatimServiceProtocol {
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
