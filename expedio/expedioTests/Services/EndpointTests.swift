//
//  EndpointTests.swift
//  ExpedioTests
//
//  Unit tests for Endpoint URL construction
//

import XCTest
@testable import expedio

final class EndpointTests: XCTestCase {

    func testSearchEndpoint_generatesCorrectURL() {
        let endpoint = Endpoint.search(query: "Paris")
        let url = endpoint.url

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.host, "nominatim.openstreetmap.org")
        XCTAssertEqual(url?.path, "/search")
        XCTAssertTrue(url?.query?.contains("q=Paris") ?? false)
        XCTAssertTrue(url?.query?.contains("format=jsonv2") ?? false)
        XCTAssertTrue(url?.query?.contains("limit=20") ?? false)
    }

    func testSearchEndpoint_includesExtratags() {
        let endpoint = Endpoint.search(query: "Paris")
        let url = endpoint.url

        XCTAssertTrue(url?.query?.contains("extratags=1") ?? false)
        XCTAssertTrue(url?.query?.contains("namedetails=1") ?? false)
    }

    func testSearchEndpoint_customLimit_usesLimit() {
        let endpoint = Endpoint.search(query: "London", limit: 10)
        let url = endpoint.url

        XCTAssertTrue(url?.query?.contains("limit=10") ?? false)
    }

    func testSearchEndpoint_encodesSpaces() {
        let endpoint = Endpoint.search(query: "New York")
        let url = endpoint.url

        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("New%20York") ?? false)
    }
}
