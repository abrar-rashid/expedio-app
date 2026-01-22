//
//  PlaceDetailViewModelTests.swift
//  expedioTests
//
//  Tests for PlaceDetailViewModel
//

import XCTest
import SwiftData
@testable import expedio

final class PlaceDetailViewModelTests: XCTestCase {

    func testCoordinate_validLatLon_returnsTuple() {
        let place = NominatimPlace(
            placeId: 1, lat: "48.8566", lon: "2.3522",
            displayName: "Paris", category: nil, type: nil
        )
        let viewModel = PlaceDetailViewModel(place: place)

        let coord = viewModel.coordinate

        XCTAssertNotNil(coord)
        guard let coord = coord else { return }
        XCTAssertEqual(coord.lat, 48.8566, accuracy: 0.0001)
        XCTAssertEqual(coord.lon, 2.3522, accuracy: 0.0001)
    }

    func testCoordinate_invalidLat_returnsNil() {
        let place = NominatimPlace(
            placeId: 1, lat: "invalid", lon: "2.35",
            displayName: "Test", category: nil, type: nil
        )
        let viewModel = PlaceDetailViewModel(place: place)

        XCTAssertNil(viewModel.coordinate)
    }

    func testCoordinate_invalidLon_returnsNil() {
        let place = NominatimPlace(
            placeId: 1, lat: "48.85", lon: "invalid",
            displayName: "Test", category: nil, type: nil
        )
        let viewModel = PlaceDetailViewModel(place: place)

        XCTAssertNil(viewModel.coordinate)
    }

    func testInitialState_notSaving() {
        let place = NominatimPlace(
            placeId: 1, lat: "0", lon: "0",
            displayName: "Test", category: nil, type: nil
        )
        let viewModel = PlaceDetailViewModel(place: place)

        XCTAssertFalse(viewModel.isSaving)
        XCTAssertNil(viewModel.saveError)
    }

    @MainActor
    func testAddToTrip_addsPlaceToTrip() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, SavedPlace.self, configurations: config)
        let context = container.mainContext

        let trip = Trip(name: "Test Trip", destination: "Paris")
        context.insert(trip)

        let place = NominatimPlace(
            placeId: 123, lat: "48.85", lon: "2.35",
            displayName: "Eiffel Tower, Paris", category: "tourism", type: "attraction"
        )
        let viewModel = PlaceDetailViewModel(place: place)

        viewModel.addToTrip(trip, context: context)

        XCTAssertEqual(trip.places.count, 1)
        XCTAssertEqual(trip.places.first?.placeId, "123")
        XCTAssertEqual(trip.places.first?.orderIndex, 0)
    }

    @MainActor
    func testAddToTrip_incrementsOrderIndex() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, SavedPlace.self, configurations: config)
        let context = container.mainContext

        let trip = Trip(name: "Test Trip", destination: "Paris")
        let existingPlace = SavedPlace(
            placeId: "1", name: "First", displayName: "First Place",
            category: "Test", lat: "0", lon: "0", orderIndex: 0
        )
        trip.places.append(existingPlace)
        context.insert(trip)

        let place = NominatimPlace(
            placeId: 2, lat: "0", lon: "0",
            displayName: "Second", category: nil, type: nil
        )
        let viewModel = PlaceDetailViewModel(place: place)

        viewModel.addToTrip(trip, context: context)

        XCTAssertEqual(trip.places.count, 2)
        let newPlace = trip.places.first { $0.placeId == "2" }
        XCTAssertEqual(newPlace?.orderIndex, 1)
    }
}
