//
//  PlaceDetailViewModelTests.swift
//  expedioTests
//
//  Tests for PlaceDetailViewModel
//

import XCTest
@testable import expedio

final class PlaceDetailViewModelTests: XCTestCase {

    // MARK: - Coordinate Parsing Tests

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

    func testCoordinate_emptyStrings_returnsNil() {
        let place = NominatimPlace(
            placeId: 1, lat: "", lon: "",
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

    func testPlace_returnsInjectedPlace() {
        let place = NominatimPlace(
            placeId: 999, lat: "51.5074", lon: "-0.1278",
            displayName: "London, UK", category: "place", type: "city"
        )
        let viewModel = PlaceDetailViewModel(place: place)

        XCTAssertEqual(viewModel.place.placeId, 999)
        XCTAssertEqual(viewModel.place.displayName, "London, UK")
        XCTAssertEqual(viewModel.place.category, "place")
        XCTAssertEqual(viewModel.place.type, "city")
    }

    func testCoordinate_negativeValues_parsesCorrectly() {
        let place = NominatimPlace(
            placeId: 1, lat: "-33.8688", lon: "151.2093",
            displayName: "Sydney, Australia", category: nil, type: nil
        )
        let viewModel = PlaceDetailViewModel(place: place)

        let coord = viewModel.coordinate

        XCTAssertNotNil(coord)
        guard let coord = coord else { return }
        XCTAssertEqual(coord.lat, -33.8688, accuracy: 0.0001)
        XCTAssertEqual(coord.lon, 151.2093, accuracy: 0.0001)
    }
}
