//
//  TripDetailViewModelTests.swift
//  ExpedioTests
//
//  Tests for TripDetailViewModel
//

import XCTest
import SwiftUI
import SwiftData
@testable import expedio

final class TripDetailViewModelTests: XCTestCase {

    // MARK: - Initialization Tests

    func testInit_storesTrip() {
        let trip = Trip(name: "Test Trip", destination: "Paris")
        let viewModel = TripDetailViewModel(trip: trip)

        XCTAssertEqual(viewModel.trip.name, "Test Trip")
        XCTAssertEqual(viewModel.trip.destination, "Paris")
    }

    // MARK: - HasPlaces Tests

    func testHasPlaces_emptyTrip_returnsFalse() {
        let trip = Trip(name: "Test", destination: "Test")
        let viewModel = TripDetailViewModel(trip: trip)

        XCTAssertFalse(viewModel.hasPlaces)
    }

    func testHasPlaces_tripWithPlaces_returnsTrue() {
        let trip = Trip(name: "Test", destination: "Test")
        let place = SavedPlace(
            placeId: "1", name: "Place", displayName: "Place",
            category: "Test", lat: "0", lon: "0", orderIndex: 0
        )
        trip.places = [place]

        let viewModel = TripDetailViewModel(trip: trip)

        XCTAssertTrue(viewModel.hasPlaces)
    }

    // MARK: - SortedPlaces Tests

    func testSortedPlaces_returnsSortedByOrderIndex() {
        let trip = Trip(name: "Test", destination: "Paris")
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

        let viewModel = TripDetailViewModel(trip: trip)
        let sorted = viewModel.sortedPlaces

        XCTAssertEqual(sorted[0].name, "First")
        XCTAssertEqual(sorted[1].name, "Second")
        XCTAssertEqual(sorted[2].name, "Third")
    }

    // MARK: - SwiftData Integration Tests

    @MainActor
    func testDeletePlace_removesFromTrip() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, SavedPlace.self, configurations: config)
        let context = container.mainContext

        let trip = Trip(name: "Test", destination: "Paris")
        let place = SavedPlace(
            placeId: "1", name: "Eiffel Tower", displayName: "Eiffel Tower, Paris",
            category: "Tourism", lat: "48.85", lon: "2.35", orderIndex: 0
        )
        trip.places.append(place)
        context.insert(trip)
        try context.save()

        // Delete place from trip
        trip.places.removeAll { $0.id == place.id }
        context.delete(place)
        try context.save()

        XCTAssertTrue(trip.places.isEmpty)
    }

    @MainActor
    func testMovePlaces_updatesOrderIndices() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, SavedPlace.self, configurations: config)
        let context = container.mainContext

        let trip = Trip(name: "Test", destination: "Paris")
        let place1 = SavedPlace(
            placeId: "1", name: "First", displayName: "First",
            category: "Test", lat: "0", lon: "0", orderIndex: 0
        )
        let place2 = SavedPlace(
            placeId: "2", name: "Second", displayName: "Second",
            category: "Test", lat: "0", lon: "0", orderIndex: 1
        )
        let place3 = SavedPlace(
            placeId: "3", name: "Third", displayName: "Third",
            category: "Test", lat: "0", lon: "0", orderIndex: 2
        )
        trip.places = [place1, place2, place3]
        context.insert(trip)
        try context.save()

        let viewModel = TripDetailViewModel(trip: trip)

        // Simulate move: move first item to end (index 0 -> after index 2)
        var places = viewModel.sortedPlaces
        places.move(fromOffsets: IndexSet(integer: 0), toOffset: 3)

        for (index, place) in places.enumerated() {
            place.orderIndex = index
        }
        try context.save()

        let sorted = trip.sortedPlaces
        XCTAssertEqual(sorted[0].name, "Second")
        XCTAssertEqual(sorted[1].name, "Third")
        XCTAssertEqual(sorted[2].name, "First")
    }

    @MainActor
    func testDeletePlace_updatesRemainingOrderIndices() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, SavedPlace.self, configurations: config)
        let context = container.mainContext

        let trip = Trip(name: "Test", destination: "Paris")
        let place1 = SavedPlace(
            placeId: "1", name: "First", displayName: "First",
            category: "Test", lat: "0", lon: "0", orderIndex: 0
        )
        let place2 = SavedPlace(
            placeId: "2", name: "Second", displayName: "Second",
            category: "Test", lat: "0", lon: "0", orderIndex: 1
        )
        let place3 = SavedPlace(
            placeId: "3", name: "Third", displayName: "Third",
            category: "Test", lat: "0", lon: "0", orderIndex: 2
        )
        trip.places = [place1, place2, place3]
        context.insert(trip)
        try context.save()

        // Delete first place
        trip.places.removeAll { $0.id == place1.id }
        context.delete(place1)

        // Update order indices
        for (index, place) in trip.sortedPlaces.enumerated() {
            place.orderIndex = index
        }
        try context.save()

        let sorted = trip.sortedPlaces
        XCTAssertEqual(sorted.count, 2)
        XCTAssertEqual(sorted[0].orderIndex, 0)
        XCTAssertEqual(sorted[0].name, "Second")
        XCTAssertEqual(sorted[1].orderIndex, 1)
        XCTAssertEqual(sorted[1].name, "Third")
    }
}
