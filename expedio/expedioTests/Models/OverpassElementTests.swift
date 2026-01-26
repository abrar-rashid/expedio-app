//
//  OverpassElementTests.swift
//  expedioTests
//
//  Unit tests for OverpassElement model
//

import XCTest
@testable import expedio

final class OverpassElementTests: XCTestCase {

    // MARK: - Decoding Tests

    func testDecoding_nodeElement_decodesCorrectly() throws {
        let json = """
        {
            "type": "node",
            "id": 123456789,
            "lat": 48.8566,
            "lon": 2.3522,
            "tags": {
                "name": "Le Comptoir",
                "amenity": "restaurant",
                "cuisine": "french"
            }
        }
        """.data(using: .utf8)!

        let element = try JSONDecoder().decode(OverpassElement.self, from: json)

        XCTAssertEqual(element.type, "node")
        XCTAssertEqual(element.id, 123456789)
        XCTAssertEqual(element.latitude, 48.8566)
        XCTAssertEqual(element.longitude, 2.3522)
        XCTAssertEqual(element.name, "Le Comptoir")
        XCTAssertEqual(element.category, "restaurant")
    }

    func testDecoding_wayElementWithCenter_decodesCorrectly() throws {
        let json = """
        {
            "type": "way",
            "id": 987654321,
            "center": {
                "lat": 51.5074,
                "lon": -0.1278
            },
            "tags": {
                "name": "British Museum",
                "tourism": "museum"
            }
        }
        """.data(using: .utf8)!

        let element = try JSONDecoder().decode(OverpassElement.self, from: json)

        XCTAssertEqual(element.type, "way")
        XCTAssertEqual(element.id, 987654321)
        XCTAssertNil(element.latitude)
        XCTAssertNil(element.longitude)
        XCTAssertNotNil(element.center)
        XCTAssertEqual(element.center?.lat, 51.5074)
        XCTAssertEqual(element.center?.lon, -0.1278)
    }

    // MARK: - Computed Property Tests

    func testCoordinate_fromLatLon_returnsCoordinate() {
        let json = """
        {"type": "node", "id": 1, "lat": 48.8566, "lon": 2.3522, "tags": {"name": "Test"}}
        """.data(using: .utf8)!

        let element = try! JSONDecoder().decode(OverpassElement.self, from: json)
        let coord = element.coordinate

        XCTAssertNotNil(coord)
        XCTAssertEqual(coord?.latitude, 48.8566, accuracy: 0.0001)
        XCTAssertEqual(coord?.longitude, 2.3522, accuracy: 0.0001)
    }

    func testCoordinate_fromCenter_returnsCoordinate() {
        let json = """
        {"type": "way", "id": 1, "center": {"lat": 51.5074, "lon": -0.1278}, "tags": {"name": "Test"}}
        """.data(using: .utf8)!

        let element = try! JSONDecoder().decode(OverpassElement.self, from: json)
        let coord = element.coordinate

        XCTAssertNotNil(coord)
        XCTAssertEqual(coord?.latitude, 51.5074, accuracy: 0.0001)
        XCTAssertEqual(coord?.longitude, -0.1278, accuracy: 0.0001)
    }

    func testName_withNameTag_returnsName() {
        let json = """
        {"type": "node", "id": 1, "lat": 0, "lon": 0, "tags": {"name": "Café Paris"}}
        """.data(using: .utf8)!

        let element = try! JSONDecoder().decode(OverpassElement.self, from: json)
        XCTAssertEqual(element.name, "Café Paris")
    }

    func testName_withoutTags_returnsUnknown() {
        let json = """
        {"type": "node", "id": 1, "lat": 0, "lon": 0}
        """.data(using: .utf8)!

        let element = try! JSONDecoder().decode(OverpassElement.self, from: json)
        XCTAssertEqual(element.name, "Unknown Place")
    }

    func testCategory_amenityTag_returnsAmenity() {
        let json = """
        {"type": "node", "id": 1, "lat": 0, "lon": 0, "tags": {"name": "Test", "amenity": "cafe"}}
        """.data(using: .utf8)!

        let element = try! JSONDecoder().decode(OverpassElement.self, from: json)
        XCTAssertEqual(element.category, "cafe")
    }

    func testCategory_tourismTag_returnsTourism() {
        let json = """
        {"type": "node", "id": 1, "lat": 0, "lon": 0, "tags": {"name": "Test", "tourism": "hotel"}}
        """.data(using: .utf8)!

        let element = try! JSONDecoder().decode(OverpassElement.self, from: json)
        XCTAssertEqual(element.category, "hotel")
    }

    func testFormattedCategory_underscoresReplaced() {
        let json = """
        {"type": "node", "id": 1, "lat": 0, "lon": 0, "tags": {"name": "Test", "amenity": "fast_food"}}
        """.data(using: .utf8)!

        let element = try! JSONDecoder().decode(OverpassElement.self, from: json)
        XCTAssertEqual(element.formattedCategory, "Fast Food")
    }

    // MARK: - PlaceDisplayable Conformance Tests

    func testLatLon_returnsStrings() {
        let json = """
        {"type": "node", "id": 1, "lat": 48.8566, "lon": 2.3522, "tags": {"name": "Test"}}
        """.data(using: .utf8)!

        let element = try! JSONDecoder().decode(OverpassElement.self, from: json)

        XCTAssertEqual(element.lat, "48.8566")
        XCTAssertEqual(element.lon, "2.3522")
    }

    func testCanAddToTrip_returnsTrue() {
        let json = """
        {"type": "node", "id": 1, "lat": 0, "lon": 0, "tags": {"name": "Test"}}
        """.data(using: .utf8)!

        let element = try! JSONDecoder().decode(OverpassElement.self, from: json)
        XCTAssertTrue(element.canAddToTrip)
    }

    // MARK: - Hashable Tests

    func testHashable_sameIdAndType_areEqual() {
        let json1 = """
        {"type": "node", "id": 123, "lat": 0, "lon": 0, "tags": {"name": "A"}}
        """.data(using: .utf8)!
        let json2 = """
        {"type": "node", "id": 123, "lat": 1, "lon": 1, "tags": {"name": "B"}}
        """.data(using: .utf8)!

        let element1 = try! JSONDecoder().decode(OverpassElement.self, from: json1)
        let element2 = try! JSONDecoder().decode(OverpassElement.self, from: json2)

        XCTAssertEqual(element1, element2)
    }

    func testHashable_differentId_areNotEqual() {
        let json1 = """
        {"type": "node", "id": 123, "lat": 0, "lon": 0, "tags": {"name": "A"}}
        """.data(using: .utf8)!
        let json2 = """
        {"type": "node", "id": 456, "lat": 0, "lon": 0, "tags": {"name": "A"}}
        """.data(using: .utf8)!

        let element1 = try! JSONDecoder().decode(OverpassElement.self, from: json1)
        let element2 = try! JSONDecoder().decode(OverpassElement.self, from: json2)

        XCTAssertNotEqual(element1, element2)
    }
}
