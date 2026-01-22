//
//  TripTests.swift
//  ExpedioTests
//
//  Unit tests for Trip SwiftData model
//

import XCTest
import SwiftData
@testable import expedio

final class TripTests: XCTestCase {

    func testInit_defaultValues_setsCorrectDefaults() {
        let trip = Trip(name: "Summer Vacation", destination: "Paris")

        XCTAssertEqual(trip.name, "Summer Vacation")
        XCTAssertEqual(trip.destination, "Paris")
        XCTAssertNil(trip.startDate)
        XCTAssertNil(trip.endDate)
        XCTAssertTrue(trip.places.isEmpty)
        XCTAssertNotNil(trip.id)
        XCTAssertNotNil(trip.createdAt)
    }

    func testSortedPlaces_returnsPlacesByOrderIndex() {
        let trip = Trip(name: "Test", destination: "Test")
        let place1 = SavedPlace(
            placeId: "1", name: "First", displayName: "First Place",
            category: "Test", lat: "0", lon: "0", orderIndex: 2
        )
        let place2 = SavedPlace(
            placeId: "2", name: "Second", displayName: "Second Place",
            category: "Test", lat: "0", lon: "0", orderIndex: 0
        )
        let place3 = SavedPlace(
            placeId: "3", name: "Third", displayName: "Third Place",
            category: "Test", lat: "0", lon: "0", orderIndex: 1
        )
        trip.places = [place1, place2, place3]

        let sorted = trip.sortedPlaces

        XCTAssertEqual(sorted[0].name, "Second")
        XCTAssertEqual(sorted[1].name, "Third")
        XCTAssertEqual(sorted[2].name, "First")
    }

    func testDateRangeText_noStartDate_returnsNil() {
        let trip = Trip(name: "Test", destination: "Test")
        XCTAssertNil(trip.dateRangeText)
    }

    func testDateRangeText_onlyStartDate_returnsSingleDate() {
        let trip = Trip(
            name: "Test", destination: "Test",
            startDate: Date(timeIntervalSince1970: 0)
        )
        XCTAssertNotNil(trip.dateRangeText)
        XCTAssertFalse(trip.dateRangeText!.contains(" - "))
    }

    func testDateRangeText_bothDates_returnsRange() {
        let trip = Trip(
            name: "Test", destination: "Test",
            startDate: Date(timeIntervalSince1970: 0),
            endDate: Date(timeIntervalSince1970: 86400)
        )
        XCTAssertNotNil(trip.dateRangeText)
        XCTAssertTrue(trip.dateRangeText!.contains(" - "))
    }
}
