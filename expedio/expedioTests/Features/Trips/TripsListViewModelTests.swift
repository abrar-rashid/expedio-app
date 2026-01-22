//
//  TripsListViewModelTests.swift
//  ExpedioTests
//
//  Tests for TripsListViewModel
//

import XCTest
import SwiftData
@testable import expedio

final class TripsListViewModelTests: XCTestCase {

    // MARK: - ViewModel State Tests

    func testInitialState_showCreateTripIsFalse() {
        let viewModel = TripsListViewModel()
        XCTAssertFalse(viewModel.showCreateTrip)
    }

    func testShowCreateTrip_canBeToggled() {
        let viewModel = TripsListViewModel()

        viewModel.showCreateTrip = true
        XCTAssertTrue(viewModel.showCreateTrip)

        viewModel.showCreateTrip = false
        XCTAssertFalse(viewModel.showCreateTrip)
    }

    // MARK: - Validation Tests

    func testValidateTripInput_validInputs_returnsTrue() {
        let viewModel = TripsListViewModel()

        XCTAssertTrue(viewModel.validateTripInput(name: "Summer Trip", destination: "Paris"))
        XCTAssertTrue(viewModel.validateTripInput(name: "A", destination: "B"))
    }

    func testValidateTripInput_emptyName_returnsFalse() {
        let viewModel = TripsListViewModel()

        XCTAssertFalse(viewModel.validateTripInput(name: "", destination: "Paris"))
        XCTAssertFalse(viewModel.validateTripInput(name: "   ", destination: "Paris"))
    }

    func testValidateTripInput_emptyDestination_returnsFalse() {
        let viewModel = TripsListViewModel()

        XCTAssertFalse(viewModel.validateTripInput(name: "Summer Trip", destination: ""))
        XCTAssertFalse(viewModel.validateTripInput(name: "Summer Trip", destination: "   "))
    }

    func testValidateTripInput_bothEmpty_returnsFalse() {
        let viewModel = TripsListViewModel()

        XCTAssertFalse(viewModel.validateTripInput(name: "", destination: ""))
    }

    // MARK: - SwiftData Integration Tests

    @MainActor
    func testCreateTrip_insertsIntoContext() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, SavedPlace.self, configurations: config)
        let context = container.mainContext

        let trip = Trip(
            name: "Summer Trip",
            destination: "Paris",
            startDate: Date(),
            endDate: nil
        )
        context.insert(trip)
        try context.save()

        let descriptor = FetchDescriptor<Trip>()
        let trips = try context.fetch(descriptor)

        XCTAssertEqual(trips.count, 1)
        XCTAssertEqual(trips.first?.name, "Summer Trip")
        XCTAssertEqual(trips.first?.destination, "Paris")
    }

    @MainActor
    func testDeleteTrip_removesFromContext() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, SavedPlace.self, configurations: config)
        let context = container.mainContext

        let trip = Trip(name: "Test", destination: "Test")
        context.insert(trip)
        try context.save()

        context.delete(trip)
        try context.save()

        let descriptor = FetchDescriptor<Trip>()
        let trips = try context.fetch(descriptor)

        XCTAssertTrue(trips.isEmpty)
    }

    @MainActor
    func testDeleteTrip_cascadeDeletesPlaces() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, SavedPlace.self, configurations: config)
        let context = container.mainContext

        let trip = Trip(name: "Test Trip", destination: "Paris")
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
        context.delete(trip)
        try context.save()

        // Verify places are cascade deleted
        places = try context.fetch(placeDescriptor)
        XCTAssertTrue(places.isEmpty)
    }
}
