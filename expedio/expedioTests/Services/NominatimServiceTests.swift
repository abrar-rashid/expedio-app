//
//  NominatimServiceTests.swift
//  ExpedioTests
//
//  Unit tests for NominatimService API client
//

import XCTest
@testable import expedio

final class NominatimServiceTests: XCTestCase {

    override func tearDown() {
        MockURLProtocol.mockData = nil
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.mockError = nil
        super.tearDown()
    }

    func testSearchPlaces_validResponse_returnsPlaces() async throws {
        let mockData = """
        [{"place_id": 1, "lat": "48.85", "lon": "2.35", "display_name": "Paris"}]
        """.data(using: .utf8)!

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200, httpVersion: nil, headerFields: nil
        )

        let session = URLSession(configuration: config)
        let service = NominatimService(session: session)

        let places = try await service.searchPlaces(query: "Paris")

        XCTAssertEqual(places.count, 1)
        XCTAssertEqual(places.first?.displayName, "Paris")
    }

    func testSearchPlaces_serverError_throwsError() async {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = Data()
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 500, httpVersion: nil, headerFields: nil
        )

        let session = URLSession(configuration: config)
        let service = NominatimService(session: session)

        do {
            _ = try await service.searchPlaces(query: "Test")
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            if case .serverError(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Expected serverError")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testSearchPlaces_invalidJSON_throwsDecodingError() async {
        let mockData = "invalid json".data(using: .utf8)!

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200, httpVersion: nil, headerFields: nil
        )

        let session = URLSession(configuration: config)
        let service = NominatimService(session: session)

        do {
            _ = try await service.searchPlaces(query: "Test")
            XCTFail("Expected error to be thrown")
        } catch let error as NetworkError {
            if case .decodingError = error {
                // Expected
            } else {
                XCTFail("Expected decodingError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

// MARK: - Mock URL Protocol

class MockURLProtocol: URLProtocol {
    static var mockData: Data?
    static var mockResponse: URLResponse?
    static var mockError: Error?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let error = MockURLProtocol.mockError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let response = MockURLProtocol.mockResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = MockURLProtocol.mockData {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
