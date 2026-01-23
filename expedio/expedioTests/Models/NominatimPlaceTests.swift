//
//  NominatimPlaceTests.swift
//  ExpedioTests
//
//  Unit tests for NominatimPlace API model
//

import XCTest
@testable import expedio

final class NominatimPlaceTests: XCTestCase {

    func testDecoding_validJSON_decodesCorrectly() throws {
        let json = """
        {
            "place_id": 123,
            "lat": "48.8566",
            "lon": "2.3522",
            "display_name": "Paris, France",
            "class": "place",
            "type": "city"
        }
        """.data(using: .utf8)!

        let place = try JSONDecoder().decode(NominatimPlace.self, from: json)

        XCTAssertEqual(place.placeId, 123)
        XCTAssertEqual(place.lat, "48.8566")
        XCTAssertEqual(place.lon, "2.3522")
        XCTAssertEqual(place.displayName, "Paris, France")
        XCTAssertEqual(place.category, "place")
        XCTAssertEqual(place.type, "city")
    }

    func testDecoding_missingOptionalFields_decodesSuccessfully() throws {
        let json = """
        {
            "place_id": 456,
            "lat": "51.5074",
            "lon": "-0.1278",
            "display_name": "London, UK"
        }
        """.data(using: .utf8)!

        let place = try JSONDecoder().decode(NominatimPlace.self, from: json)

        XCTAssertEqual(place.placeId, 456)
        XCTAssertNil(place.category)
        XCTAssertNil(place.type)
    }

    func testFormattedCategory_bothValues_joinedWithDot() {
        let place = NominatimPlace(
            placeId: 1, lat: "0", lon: "0",
            displayName: "Test", category: "tourism", type: "hotel"
        )
        XCTAssertEqual(place.formattedCategory, "Tourism · Hotel")
    }

    func testFormattedCategory_onlyCategory_returnsCapitalized() {
        let place = NominatimPlace(
            placeId: 1, lat: "0", lon: "0",
            displayName: "Test", category: "amenity", type: nil
        )
        XCTAssertEqual(place.formattedCategory, "Amenity")
    }

    func testFormattedCategory_noValues_returnsEmpty() {
        let place = NominatimPlace(
            placeId: 1, lat: "0", lon: "0",
            displayName: "Test", category: nil, type: nil
        )
        XCTAssertEqual(place.formattedCategory, "")
    }

    func testId_returnsPlaceId() {
        let place = NominatimPlace(
            placeId: 999, lat: "0", lon: "0",
            displayName: "Test", category: nil, type: nil
        )
        XCTAssertEqual(place.id, 999)
    }

    // MARK: - Extratags Tests

    func testDecoding_withExtratags_decodesCorrectly() throws {
        let json = """
        {
            "place_id": 123,
            "lat": "48.8566",
            "lon": "2.3522",
            "display_name": "Le Jules Verne, Paris, France",
            "class": "amenity",
            "type": "restaurant",
            "extratags": {
                "phone": "+33 1 45 55 61 44",
                "website": "https://www.restaurants-toureiffel.com",
                "opening_hours": "Mo-Su 12:00-14:00, 19:00-22:00",
                "cuisine": "french;fine_dining",
                "wheelchair": "yes",
                "diet:vegan": "yes",
                "diet:vegetarian": "yes"
            }
        }
        """.data(using: .utf8)!

        let place = try JSONDecoder().decode(NominatimPlace.self, from: json)

        XCTAssertNotNil(place.extratags)
        XCTAssertEqual(place.extratags?.phone, "+33 1 45 55 61 44")
        XCTAssertEqual(place.extratags?.website, "https://www.restaurants-toureiffel.com")
        XCTAssertEqual(place.extratags?.openingHours, "Mo-Su 12:00-14:00, 19:00-22:00")
        XCTAssertEqual(place.extratags?.cuisine, "french;fine_dining")
        XCTAssertEqual(place.extratags?.wheelchair, "yes")
        XCTAssertEqual(place.extratags?.dietVegan, "yes")
        XCTAssertEqual(place.extratags?.dietVegetarian, "yes")
    }

    func testDecoding_withoutExtratags_decodesSuccessfully() throws {
        let json = """
        {
            "place_id": 456,
            "lat": "51.5074",
            "lon": "-0.1278",
            "display_name": "London, UK"
        }
        """.data(using: .utf8)!

        let place = try JSONDecoder().decode(NominatimPlace.self, from: json)

        XCTAssertNil(place.extratags)
    }

    func testExtratags_formattedCuisine_splitsBySemicolon() {
        let extratags = NominatimExtratags(
            phone: nil, website: nil, openingHours: nil,
            cuisine: "italian;japanese;sushi",
            wheelchair: nil, wikipedia: nil,
            dietVegan: nil, dietVegetarian: nil
        )

        XCTAssertEqual(extratags.formattedCuisine, "Italian, Japanese, Sushi")
    }

    func testExtratags_formattedCuisine_nilWhenMissing() {
        let extratags = NominatimExtratags(
            phone: nil, website: nil, openingHours: nil,
            cuisine: nil, wheelchair: nil, wikipedia: nil,
            dietVegan: nil, dietVegetarian: nil
        )

        XCTAssertNil(extratags.formattedCuisine)
    }

    func testExtratags_dietaryOptions_returnsVeganAndVegetarian() {
        let extratags = NominatimExtratags(
            phone: nil, website: nil, openingHours: nil,
            cuisine: nil, wheelchair: nil, wikipedia: nil,
            dietVegan: "yes", dietVegetarian: "only"
        )

        XCTAssertEqual(extratags.dietaryOptions, ["Vegan", "Vegetarian"])
    }

    func testExtratags_dietaryOptions_emptyWhenNo() {
        let extratags = NominatimExtratags(
            phone: nil, website: nil, openingHours: nil,
            cuisine: nil, wheelchair: nil, wikipedia: nil,
            dietVegan: "no", dietVegetarian: nil
        )

        XCTAssertTrue(extratags.dietaryOptions.isEmpty)
    }

    func testExtratags_wheelchairStatus_yes() {
        let extratags = NominatimExtratags(
            phone: nil, website: nil, openingHours: nil,
            cuisine: nil, wheelchair: "yes", wikipedia: nil,
            dietVegan: nil, dietVegetarian: nil
        )

        XCTAssertEqual(extratags.wheelchairStatus, "Wheelchair accessible")
    }

    func testExtratags_wheelchairStatus_limited() {
        let extratags = NominatimExtratags(
            phone: nil, website: nil, openingHours: nil,
            cuisine: nil, wheelchair: "limited", wikipedia: nil,
            dietVegan: nil, dietVegetarian: nil
        )

        XCTAssertEqual(extratags.wheelchairStatus, "Limited wheelchair access")
    }

    func testExtratags_wheelchairStatus_no() {
        let extratags = NominatimExtratags(
            phone: nil, website: nil, openingHours: nil,
            cuisine: nil, wheelchair: "no", wikipedia: nil,
            dietVegan: nil, dietVegetarian: nil
        )

        XCTAssertEqual(extratags.wheelchairStatus, "Not wheelchair accessible")
    }

    func testExtratags_wheelchairStatus_nilWhenMissing() {
        let extratags = NominatimExtratags(
            phone: nil, website: nil, openingHours: nil,
            cuisine: nil, wheelchair: nil, wikipedia: nil,
            dietVegan: nil, dietVegetarian: nil
        )

        XCTAssertNil(extratags.wheelchairStatus)
    }

    func testExtratags_hasAnyData_trueWithPhone() {
        let extratags = NominatimExtratags(
            phone: "+1234567890", website: nil, openingHours: nil,
            cuisine: nil, wheelchair: nil, wikipedia: nil,
            dietVegan: nil, dietVegetarian: nil
        )

        XCTAssertTrue(extratags.hasAnyData)
    }

    func testExtratags_hasAnyData_falseWhenEmpty() {
        let extratags = NominatimExtratags(
            phone: nil, website: nil, openingHours: nil,
            cuisine: nil, wheelchair: nil, wikipedia: nil,
            dietVegan: nil, dietVegetarian: nil
        )

        XCTAssertFalse(extratags.hasAnyData)
    }
}
