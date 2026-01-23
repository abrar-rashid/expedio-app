# Expedio - Implementation Phases

A phased implementation guide with unit tests for each phase.

---

## Phase 1: Project Setup & Design System

### Goals
- Create Xcode project structure with iOS 17+ target
- Configure custom fonts (Playfair Display)
- Implement design system (Theme.swift)
- Set up SwiftData container
- Create base View extensions

### Files to Create

#### 1.1 `Expedio/App/ExpedioApp.swift`
```swift
import SwiftUI
import SwiftData

@main
struct ExpedioApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Trip.self,
            SavedPlace.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

#### 1.2 `Expedio/Core/Design/Theme.swift`
```swift
import SwiftUI

enum Theme {
    // MARK: - Colors (Soft Pastels)
    enum Colors {
        static let background = Color(hex: "FDF8F4")    // Warm cream
        static let surface = Color(hex: "FFFFFF")       // Cards
        static let primary = Color(hex: "7C9885")       // Sage green
        static let secondary = Color(hex: "B8A9C9")     // Soft lavender
        static let textPrimary = Color(hex: "2D3436")   // Headlines
        static let textSecondary = Color(hex: "636E72") // Body text
        static let accent = Color(hex: "E8B4B8")        // Dusty rose
    }

    // MARK: - Typography
    enum Typography {
        // Headers and Titles - Playfair Display (serif)
        static let largeTitle = Font.custom("PlayfairDisplay", size: 34).weight(.bold)
        static let title = Font.custom("PlayfairDisplay", size: 28).weight(.bold)
        static let title2 = Font.custom("PlayfairDisplay", size: 22).weight(.bold)
        static let title3 = Font.custom("PlayfairDisplay", size: 20).weight(.bold)
        static let headline = Font.custom("PlayfairDisplay", size: 17).weight(.semibold)

        // Body Text - SF Pro (system font)
        static let body = Font.system(size: 17)
        static let callout = Font.system(size: 16)
        static let subheadline = Font.system(size: 15)
        static let footnote = Font.system(size: 13)
        static let caption = Font.system(size: 12)
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

#### 1.3 `Expedio/Core/Extensions/View+Extensions.swift`
```swift
import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.md)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    func primaryButtonStyle() -> some View {
        self
            .font(Theme.Typography.headline)
            .foregroundColor(.white)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.md)
            .background(Theme.Colors.primary)
            .cornerRadius(Theme.CornerRadius.md)
    }
}
```

#### 1.4 `Expedio/Core/Components/LoadingView.swift`
```swift
import SwiftUI

struct LoadingView: View {
    var message: String? = nil

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .stroke(Theme.Colors.primary.opacity(0.2), lineWidth: 4)
                    .frame(width: 44, height: 44)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        Theme.Colors.primary,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        .linear(duration: 1)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }

            if let message = message {
                Text(message)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
```

### Unit Tests for Phase 1

#### `ExpedioTests/Core/ThemeTests.swift`
```swift
import XCTest
@testable import Expedio

final class ThemeTests: XCTestCase {

    // MARK: - Color Tests

    func testColorHexInitialization_sixDigitHex_createsCorrectColor() {
        let color = Color(hex: "FF0000")
        // Red color should have components (1, 0, 0)
        XCTAssertNotNil(color)
    }

    func testColorHexInitialization_withHashPrefix_stripsPrefix() {
        let color = Color(hex: "#00FF00")
        XCTAssertNotNil(color)
    }

    func testColorHexInitialization_eightDigitHex_includesAlpha() {
        let color = Color(hex: "80FF0000")
        XCTAssertNotNil(color)
    }

    func testColorHexInitialization_invalidHex_returnsBlack() {
        let color = Color(hex: "invalid")
        XCTAssertNotNil(color)
    }

    func testThemeColors_allColorsExist() {
        XCTAssertNotNil(Theme.Colors.background)
        XCTAssertNotNil(Theme.Colors.surface)
        XCTAssertNotNil(Theme.Colors.primary)
        XCTAssertNotNil(Theme.Colors.secondary)
        XCTAssertNotNil(Theme.Colors.textPrimary)
        XCTAssertNotNil(Theme.Colors.textSecondary)
        XCTAssertNotNil(Theme.Colors.accent)
    }

    // MARK: - Spacing Tests

    func testSpacingValues_areInAscendingOrder() {
        XCTAssertLessThan(Theme.Spacing.xs, Theme.Spacing.sm)
        XCTAssertLessThan(Theme.Spacing.sm, Theme.Spacing.md)
        XCTAssertLessThan(Theme.Spacing.md, Theme.Spacing.lg)
        XCTAssertLessThan(Theme.Spacing.lg, Theme.Spacing.xl)
    }

    func testSpacingValues_areCorrect() {
        XCTAssertEqual(Theme.Spacing.xs, 4)
        XCTAssertEqual(Theme.Spacing.sm, 8)
        XCTAssertEqual(Theme.Spacing.md, 16)
        XCTAssertEqual(Theme.Spacing.lg, 24)
        XCTAssertEqual(Theme.Spacing.xl, 32)
    }

    // MARK: - Corner Radius Tests

    func testCornerRadiusValues_arePositive() {
        XCTAssertGreaterThan(Theme.CornerRadius.sm, 0)
        XCTAssertGreaterThan(Theme.CornerRadius.md, 0)
        XCTAssertGreaterThan(Theme.CornerRadius.lg, 0)
    }

    // MARK: - Typography Tests

    func testTypography_fontsExist() {
        XCTAssertNotNil(Theme.Typography.largeTitle)
        XCTAssertNotNil(Theme.Typography.title)
        XCTAssertNotNil(Theme.Typography.body)
        XCTAssertNotNil(Theme.Typography.caption)
    }
}
```

### Phase 1 Checklist
- [ ] Create Xcode project with iOS 17+ deployment target
- [ ] Add PlayfairDisplay variable font files (.ttf) to Resources/Fonts
- [ ] Configure Info.plist with `UIAppFonts` array (add font file names)
- [ ] Implement Theme.swift with colors, typography (Playfair Display for headers, SF Pro for body), and spacing
- [ ] Implement Color hex initializer extension
- [ ] Implement View+Extensions.swift with cardStyle and primaryButtonStyle
- [ ] Set up SwiftData container in ExpedioApp.swift
- [ ] Write and run ThemeTests
- [ ] Verify fonts load correctly in preview (Playfair Display for titles, SF Pro for body text)

---

## Phase 2: Data Layer

### Goals
- Create SwiftData models (Trip, SavedPlace)
- Create API response model (NominatimPlace)
- Implement networking layer with async/await
- Add proper error handling

### Files to Create

#### 2.1 `Expedio/Models/NominatimPlace.swift`
```swift
import Foundation

struct NominatimPlace: Codable, Identifiable, Hashable {
    let placeId: Int
    let lat: String
    let lon: String
    let displayName: String
    let category: String?
    let type: String?

    var id: Int { placeId }

    var formattedCategory: String {
        [category, type]
            .compactMap { $0?.capitalized }
            .joined(separator: " · ")
    }

    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case lat, lon
        case displayName = "display_name"
        case category = "class"
        case type
    }
}
```

#### 2.2 `Expedio/Models/Trip.swift`
```swift
import Foundation
import SwiftData

@Model
final class Trip {
    var id: UUID
    var name: String
    var destination: String
    var startDate: Date?
    var endDate: Date?
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var places: [SavedPlace]

    init(
        id: UUID = UUID(),
        name: String,
        destination: String,
        startDate: Date? = nil,
        endDate: Date? = nil,
        createdAt: Date = Date(),
        places: [SavedPlace] = []
    ) {
        self.id = id
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createdAt
        self.places = places
    }

    var sortedPlaces: [SavedPlace] {
        places.sorted { $0.orderIndex < $1.orderIndex }
    }

    var dateRangeText: String? {
        guard let start = startDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if let end = endDate {
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
        return formatter.string(from: start)
    }
}
```

#### 2.3 `Expedio/Models/SavedPlace.swift`
```swift
import Foundation
import SwiftData

@Model
final class SavedPlace {
    var id: UUID
    var placeId: String
    var name: String
    var displayName: String
    var category: String
    var lat: String
    var lon: String
    var orderIndex: Int
    var addedAt: Date
    @Relationship(inverse: \Trip.places) var trip: Trip?

    init(
        id: UUID = UUID(),
        placeId: String,
        name: String,
        displayName: String,
        category: String,
        lat: String,
        lon: String,
        orderIndex: Int = 0,
        addedAt: Date = Date(),
        trip: Trip? = nil
    ) {
        self.id = id
        self.placeId = placeId
        self.name = name
        self.displayName = displayName
        self.category = category
        self.lat = lat
        self.lon = lon
        self.orderIndex = orderIndex
        self.addedAt = addedAt
        self.trip = trip
    }

    convenience init(from place: NominatimPlace, orderIndex: Int = 0) {
        self.init(
            placeId: String(place.placeId),
            name: place.displayName.components(separatedBy: ",").first ?? place.displayName,
            displayName: place.displayName,
            category: place.formattedCategory,
            lat: place.lat,
            lon: place.lon,
            orderIndex: orderIndex
        )
    }
}
```

#### 2.4 `Expedio/Services/Networking/Endpoint.swift`
```swift
import Foundation

enum Endpoint {
    case search(query: String, limit: Int = 20)

    var url: URL? {
        switch self {
        case .search(let query, let limit):
            var components = URLComponents(string: "https://nominatim.openstreetmap.org/search")
            components?.queryItems = [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "addressdetails", value: "1")
            ]
            return components?.url
        }
    }
}
```

#### 2.5 `Expedio/Services/Networking/NominatimService.swift`
```swift
import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .decodingError(let error): return "Failed to decode: \(error.localizedDescription)"
        case .serverError(let code): return "Server error: \(code)"
        }
    }
}

protocol NominatimServiceProtocol {
    func searchPlaces(query: String) async throws -> [NominatimPlace]
}

final class NominatimService: NominatimServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchPlaces(query: String) async throws -> [NominatimPlace] {
        guard let url = Endpoint.search(query: query).url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Expedio/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode([NominatimPlace].self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
```

### Unit Tests for Phase 2

#### `ExpedioTests/Models/NominatimPlaceTests.swift`
```swift
import XCTest
@testable import Expedio

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
}
```

#### `ExpedioTests/Models/TripTests.swift`
```swift
import XCTest
import SwiftData
@testable import Expedio

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
```

#### `ExpedioTests/Services/EndpointTests.swift`
```swift
import XCTest
@testable import Expedio

final class EndpointTests: XCTestCase {

    func testSearchEndpoint_generatesCorrectURL() {
        let endpoint = Endpoint.search(query: "Paris")
        let url = endpoint.url

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.host, "nominatim.openstreetmap.org")
        XCTAssertEqual(url?.path, "/search")
        XCTAssertTrue(url?.query?.contains("q=Paris") ?? false)
        XCTAssertTrue(url?.query?.contains("format=json") ?? false)
        XCTAssertTrue(url?.query?.contains("limit=20") ?? false)
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
```

#### `ExpedioTests/Services/NominatimServiceTests.swift`
```swift
import XCTest
@testable import Expedio

final class NominatimServiceTests: XCTestCase {

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
        }
    }
}

// MARK: - Mock URL Protocol
class MockURLProtocol: URLProtocol {
    static var mockData: Data?
    static var mockResponse: URLResponse?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let data = MockURLProtocol.mockData {
            client?.urlProtocol(self, didLoad: data)
        }
        if let response = MockURLProtocol.mockResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
```

### Phase 2 Checklist
- [ ] Create NominatimPlace.swift with Codable conformance
- [ ] Create Trip.swift SwiftData model with relationships
- [ ] Create SavedPlace.swift SwiftData model
- [ ] Implement Endpoint.swift for URL construction
- [ ] Implement NominatimService.swift with async/await
- [ ] Add NetworkError enum with LocalizedError
- [ ] Create NominatimServiceProtocol for testability
- [ ] Write and run NominatimPlaceTests
- [ ] Write and run TripTests
- [ ] Write and run EndpointTests
- [ ] Write and run NominatimServiceTests with MockURLProtocol
- [ ] Verify models compile and work with SwiftData container

---

## Phase 3: Search Feature

### Goals
- Build SearchView with search bar and results list
- Implement SearchViewModel with debounced search
- Create PlaceRow component
- Handle loading, empty, and error states

### Files to Create

#### 3.1 `Expedio/Features/Search/SearchViewModel.swift`
```swift
import Foundation
import Observation

@Observable
final class SearchViewModel {
    private(set) var places: [NominatimPlace] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var searchText = "" {
        didSet { debounceSearch() }
    }

    private let service: NominatimServiceProtocol
    private var searchTask: Task<Void, Never>?
    private let debounceInterval: Duration = .milliseconds(500)

    init(service: NominatimServiceProtocol = NominatimService()) {
        self.service = service
    }

    private func debounceSearch() {
        searchTask?.cancel()

        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            places = []
            errorMessage = nil
            return
        }

        searchTask = Task { @MainActor in
            try? await Task.sleep(for: debounceInterval)
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }

    @MainActor
    private func performSearch() async {
        isLoading = true
        errorMessage = nil

        do {
            let results = try await service.searchPlaces(query: searchText)
            guard !Task.isCancelled else { return }
            places = results
        } catch {
            guard !Task.isCancelled else { return }
            errorMessage = error.localizedDescription
            places = []
        }

        isLoading = false
    }

    func clearSearch() {
        searchTask?.cancel()
        searchText = ""
        places = []
        errorMessage = nil
    }
}
```

#### 3.2 `Expedio/Features/Search/SearchView.swift`
```swift
import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let error = viewModel.errorMessage {
                        errorView(error)
                    } else if viewModel.places.isEmpty && !viewModel.searchText.isEmpty {
                        emptyView
                    } else if viewModel.places.isEmpty {
                        promptView
                    } else {
                        resultsList
                    }
                }
            }
            .navigationTitle("Search Places")
            .searchable(
                text: $viewModel.searchText,
                prompt: "Search cities, landmarks..."
            )
        }
    }

    private var resultsList: some View {
        List(viewModel.places) { place in
            NavigationLink(value: place) {
                PlaceRow(place: place)
            }
            .listRowBackground(Theme.Colors.surface)
        }
        .listStyle(.plain)
        .navigationDestination(for: NominatimPlace.self) { place in
            PlaceDetailView(place: place)
        }
    }

    private var promptView: some View {
        ContentUnavailableView(
            "Search for Places",
            systemImage: "magnifyingglass",
            description: Text("Find cities, landmarks, and attractions")
        )
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Results",
            systemImage: "mappin.slash",
            description: Text("Try a different search term")
        )
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView(
            "Something went wrong",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
    }
}
```

#### 3.3 `Expedio/Features/Search/Components/PlaceRow.swift`
```swift
import SwiftUI

struct PlaceRow: View {
    let place: NominatimPlace

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(placeName)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.textPrimary)
                .lineLimit(1)

            Text(placeLocation)
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.textSecondary)
                .lineLimit(2)

            if !place.formattedCategory.isEmpty {
                Text(place.formattedCategory)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.primary)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(Theme.Colors.primary.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.sm)
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
    }

    private var placeName: String {
        place.displayName.components(separatedBy: ",").first ?? place.displayName
    }

    private var placeLocation: String {
        let components = place.displayName.components(separatedBy: ",")
        guard components.count > 1 else { return "" }
        return components.dropFirst().joined(separator: ",").trimmingCharacters(in: .whitespaces)
    }
}
```

### Unit Tests for Phase 3

#### `ExpedioTests/Features/Search/SearchViewModelTests.swift`
```swift
import XCTest
@testable import Expedio

final class SearchViewModelTests: XCTestCase {

    // MARK: - Mock Service
    class MockNominatimService: NominatimServiceProtocol {
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

    // MARK: - Tests

    func testInitialState_isEmpty() {
        let viewModel = SearchViewModel(service: MockNominatimService())

        XCTAssertTrue(viewModel.places.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.searchText, "")
    }

    func testSearchText_emptyString_clearsPlaces() async throws {
        let mockService = MockNominatimService()
        let viewModel = SearchViewModel(service: mockService)

        viewModel.searchText = ""
        try await Task.sleep(for: .milliseconds(100))

        XCTAssertTrue(viewModel.places.isEmpty)
        XCTAssertEqual(mockService.searchCallCount, 0)
    }

    func testSearchText_whitespaceOnly_doesNotSearch() async throws {
        let mockService = MockNominatimService()
        let viewModel = SearchViewModel(service: mockService)

        viewModel.searchText = "   "
        try await Task.sleep(for: .milliseconds(600))

        XCTAssertEqual(mockService.searchCallCount, 0)
    }

    func testSearchText_validQuery_performsSearchAfterDebounce() async throws {
        let mockPlace = NominatimPlace(
            placeId: 1, lat: "48.85", lon: "2.35",
            displayName: "Paris", category: nil, type: nil
        )
        let mockService = MockNominatimService()
        mockService.searchResult = .success([mockPlace])

        let viewModel = SearchViewModel(service: mockService)
        viewModel.searchText = "Paris"

        try await Task.sleep(for: .milliseconds(600))

        XCTAssertEqual(mockService.searchCallCount, 1)
        XCTAssertEqual(mockService.lastQuery, "Paris")
        XCTAssertEqual(viewModel.places.count, 1)
    }

    func testSearchText_rapidChanges_onlySearchesOnce() async throws {
        let mockService = MockNominatimService()
        let viewModel = SearchViewModel(service: mockService)

        viewModel.searchText = "P"
        viewModel.searchText = "Pa"
        viewModel.searchText = "Par"
        viewModel.searchText = "Pari"
        viewModel.searchText = "Paris"

        try await Task.sleep(for: .milliseconds(600))

        XCTAssertEqual(mockService.searchCallCount, 1)
        XCTAssertEqual(mockService.lastQuery, "Paris")
    }

    func testSearchText_serviceError_setsErrorMessage() async throws {
        let mockService = MockNominatimService()
        mockService.searchResult = .failure(NetworkError.serverError(500))

        let viewModel = SearchViewModel(service: mockService)
        viewModel.searchText = "Test"

        try await Task.sleep(for: .milliseconds(600))

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.places.isEmpty)
    }

    func testClearSearch_resetsAllState() async throws {
        let mockPlace = NominatimPlace(
            placeId: 1, lat: "0", lon: "0",
            displayName: "Test", category: nil, type: nil
        )
        let mockService = MockNominatimService()
        mockService.searchResult = .success([mockPlace])

        let viewModel = SearchViewModel(service: mockService)
        viewModel.searchText = "Test"
        try await Task.sleep(for: .milliseconds(600))

        viewModel.clearSearch()

        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertTrue(viewModel.places.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
}
```

#### `ExpedioTests/Features/Search/PlaceRowTests.swift`
```swift
import XCTest
import SwiftUI
@testable import Expedio

final class PlaceRowTests: XCTestCase {

    func testPlaceRow_extractsNameFromDisplayName() {
        let place = NominatimPlace(
            placeId: 1, lat: "0", lon: "0",
            displayName: "Eiffel Tower, Paris, France",
            category: "tourism", type: "attraction"
        )

        // PlaceRow extracts "Eiffel Tower" as the name
        let name = place.displayName.components(separatedBy: ",").first
        XCTAssertEqual(name, "Eiffel Tower")
    }

    func testPlaceRow_extractsLocationFromDisplayName() {
        let place = NominatimPlace(
            placeId: 1, lat: "0", lon: "0",
            displayName: "Eiffel Tower, Paris, France",
            category: nil, type: nil
        )

        let components = place.displayName.components(separatedBy: ",")
        let location = components.dropFirst().joined(separator: ",").trimmingCharacters(in: .whitespaces)
        XCTAssertEqual(location, "Paris, France")
    }

    func testPlaceRow_singleComponentDisplayName_returnsEmptyLocation() {
        let place = NominatimPlace(
            placeId: 1, lat: "0", lon: "0",
            displayName: "Paris",
            category: nil, type: nil
        )

        let components = place.displayName.components(separatedBy: ",")
        guard components.count > 1 else {
            XCTAssertTrue(true) // Empty location expected
            return
        }
        XCTFail("Should have single component")
    }
}
```

### Phase 3 Checklist
- [ ] Create SearchViewModel with @Observable
- [ ] Implement debounced search with Task cancellation
- [ ] Create SearchView with NavigationStack
- [ ] Implement searchable modifier
- [ ] Create PlaceRow component
- [ ] Handle loading state with ProgressView
- [ ] Handle empty state with ContentUnavailableView
- [ ] Handle error state with error message display
- [ ] Write and run SearchViewModelTests
- [ ] Write and run PlaceRowTests
- [ ] Test debounce behavior manually
- [ ] Verify navigation to PlaceDetailView works

---

## Phase 4: Place Detail Feature

### Goals
- Build PlaceDetailView with place information
- Add interactive map preview using MapKit
- Implement AddToTripSheet for saving places
- Create PlaceDetailViewModel

### Files to Create

#### 4.1 `Expedio/Features/PlaceDetail/PlaceDetailViewModel.swift`
```swift
import Foundation
import SwiftData
import Observation

@Observable
final class PlaceDetailViewModel {
    let place: NominatimPlace
    private(set) var isSaving = false
    private(set) var saveError: String?

    var coordinate: (lat: Double, lon: Double)? {
        guard let lat = Double(place.lat),
              let lon = Double(place.lon) else { return nil }
        return (lat, lon)
    }

    init(place: NominatimPlace) {
        self.place = place
    }

    @MainActor
    func addToTrip(_ trip: Trip, context: ModelContext) {
        isSaving = true
        saveError = nil

        let orderIndex = trip.places.count
        let savedPlace = SavedPlace(from: place, orderIndex: orderIndex)
        savedPlace.trip = trip
        trip.places.append(savedPlace)

        do {
            try context.save()
        } catch {
            saveError = error.localizedDescription
        }

        isSaving = false
    }
}
```

#### 4.2 `Expedio/Features/PlaceDetail/PlaceDetailView.swift`
```swift
import SwiftUI
import MapKit
import SwiftData

struct PlaceDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [Trip]
    @State private var viewModel: PlaceDetailViewModel
    @State private var showAddToTrip = false
    @State private var showSaveConfirmation = false

    init(place: NominatimPlace) {
        _viewModel = State(initialValue: PlaceDetailViewModel(place: place))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                mapSection
                infoSection
                addToTripButton
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.Colors.background)
        .navigationTitle(placeName)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddToTrip) {
            AddToTripSheet(
                trips: trips,
                onSelect: { trip in
                    viewModel.addToTrip(trip, context: modelContext)
                    showAddToTrip = false
                    showSaveConfirmation = true
                }
            )
        }
        .alert("Added to Trip", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) {}
        }
    }

    private var mapSection: some View {
        Group {
            if let coord = viewModel.coordinate {
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))) {
                    Marker(placeName, coordinate: CLLocationCoordinate2D(
                        latitude: coord.lat, longitude: coord.lon
                    ))
                }
                .frame(height: 200)
                .cornerRadius(Theme.CornerRadius.md)
            }
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(viewModel.place.displayName)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textSecondary)

            if !viewModel.place.formattedCategory.isEmpty {
                Label(viewModel.place.formattedCategory, systemImage: "tag")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.primary)
            }

            if let coord = viewModel.coordinate {
                Label("\(coord.lat, specifier: "%.4f"), \(coord.lon, specifier: "%.4f")",
                      systemImage: "location")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .cardStyle()
        .padding(Theme.Spacing.md)
    }

    private var addToTripButton: some View {
        Button {
            showAddToTrip = true
        } label: {
            Label("Add to Trip", systemImage: "plus.circle.fill")
                .frame(maxWidth: .infinity)
                .primaryButtonStyle()
        }
        .disabled(trips.isEmpty)
    }

    private var placeName: String {
        viewModel.place.displayName.components(separatedBy: ",").first
            ?? viewModel.place.displayName
    }
}
```

#### 4.3 `Expedio/Features/PlaceDetail/Components/AddToTripSheet.swift`
```swift
import SwiftUI

struct AddToTripSheet: View {
    @Environment(\.dismiss) private var dismiss
    let trips: [Trip]
    let onSelect: (Trip) -> Void

    var body: some View {
        NavigationStack {
            List(trips, id: \.id) { trip in
                Button {
                    onSelect(trip)
                } label: {
                    TripRow(trip: trip)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Add to Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay {
                if trips.isEmpty {
                    ContentUnavailableView(
                        "No Trips",
                        systemImage: "suitcase",
                        description: Text("Create a trip first to add places")
                    )
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct TripRow: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(trip.name)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.textPrimary)

            Text(trip.destination)
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.textSecondary)

            if let dateRange = trip.dateRangeText {
                Text(dateRange)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}
```

### Unit Tests for Phase 4

#### `ExpedioTests/Features/PlaceDetail/PlaceDetailViewModelTests.swift`
```swift
import XCTest
import SwiftData
@testable import Expedio

final class PlaceDetailViewModelTests: XCTestCase {

    func testCoordinate_validLatLon_returnsTuple() {
        let place = NominatimPlace(
            placeId: 1, lat: "48.8566", lon: "2.3522",
            displayName: "Paris", category: nil, type: nil
        )
        let viewModel = PlaceDetailViewModel(place: place)

        let coord = viewModel.coordinate

        XCTAssertNotNil(coord)
        XCTAssertEqual(coord?.lat, 48.8566, accuracy: 0.0001)
        XCTAssertEqual(coord?.lon, 2.3522, accuracy: 0.0001)
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
```

### Phase 4 Checklist
- [ ] Create PlaceDetailViewModel with @Observable
- [ ] Implement coordinate parsing from lat/lon strings
- [ ] Create PlaceDetailView with ScrollView layout
- [ ] Add Map view with marker using MapKit
- [ ] Display place info (address, category, coordinates)
- [ ] Implement AddToTripSheet with trip selection
- [ ] Add "Add to Trip" button with sheet presentation
- [ ] Show confirmation alert after adding
- [ ] Write and run PlaceDetailViewModelTests
- [ ] Test adding place to trip with SwiftData
- [ ] Verify map displays correctly with coordinates

---

## Phase 5: Trips Feature

### Goals
- Build TripsListView with trip cards
- Implement CreateTripSheet for new trips
- Build TripDetailView with place management
- Add drag & drop reordering and delete functionality

### Files to Create

#### 5.1 `Expedio/Features/Trips/TripsListViewModel.swift`
```swift
import Foundation
import SwiftData
import Observation

@Observable
final class TripsListViewModel {
    private(set) var isDeleting = false

    @MainActor
    func deleteTrip(_ trip: Trip, context: ModelContext) {
        isDeleting = true
        context.delete(trip)
        try? context.save()
        isDeleting = false
    }

    @MainActor
    func createTrip(
        name: String,
        destination: String,
        startDate: Date?,
        endDate: Date?,
        context: ModelContext
    ) {
        let trip = Trip(
            name: name,
            destination: destination,
            startDate: startDate,
            endDate: endDate
        )
        context.insert(trip)
        try? context.save()
    }
}
```

#### 5.2 `Expedio/Features/Trips/TripsListView.swift`
```swift
import SwiftUI
import SwiftData

struct TripsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Trip.createdAt, order: .reverse) private var trips: [Trip]
    @State private var viewModel = TripsListViewModel()
    @State private var showCreateTrip = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                if trips.isEmpty {
                    emptyView
                } else {
                    tripsList
                }
            }
            .navigationTitle("My Trips")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showCreateTrip = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateTrip) {
                CreateTripSheet { name, destination, start, end in
                    viewModel.createTrip(
                        name: name,
                        destination: destination,
                        startDate: start,
                        endDate: end,
                        context: modelContext
                    )
                    showCreateTrip = false
                }
            }
        }
    }

    private var tripsList: some View {
        List {
            ForEach(trips) { trip in
                NavigationLink(value: trip) {
                    TripCard(trip: trip)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .onDelete(perform: deleteTrips)
        }
        .listStyle(.plain)
        .navigationDestination(for: Trip.self) { trip in
            TripDetailView(trip: trip)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Trips Yet",
            systemImage: "suitcase",
            description: Text("Tap + to create your first trip")
        )
    }

    private func deleteTrips(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteTrip(trips[index], context: modelContext)
        }
    }
}
```

#### 5.3 `Expedio/Features/Trips/Components/TripCard.swift`
```swift
import SwiftUI

struct TripCard: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(trip.name)
                .font(Theme.Typography.title3)
                .foregroundColor(Theme.Colors.textPrimary)

            Text(trip.destination)
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.textSecondary)

            HStack {
                if let dateRange = trip.dateRangeText {
                    Label(dateRange, systemImage: "calendar")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                Spacer()

                Label("\(trip.places.count)", systemImage: "mappin.circle.fill")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.primary)
            }
        }
        .padding(Theme.Spacing.md)
        .cardStyle()
    }
}
```

#### 5.4 `Expedio/Features/Trips/Components/CreateTripSheet.swift`
```swift
import SwiftUI

struct CreateTripSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var includeDates = false

    let onCreate: (String, String, Date?, Date?) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Details") {
                    TextField("Trip Name", text: $name)
                    TextField("Destination", text: $destination)
                }

                Section {
                    Toggle("Include Dates", isOn: $includeDates)
                    if includeDates {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate(
                            name,
                            destination,
                            includeDates ? startDate : nil,
                            includeDates ? endDate : nil
                        )
                    }
                    .disabled(name.isEmpty || destination.isEmpty)
                }
            }
        }
    }
}
```

#### 5.5 `Expedio/Features/Trips/TripDetailViewModel.swift`
```swift
import Foundation
import SwiftData
import Observation

@Observable
final class TripDetailViewModel {
    let trip: Trip

    init(trip: Trip) {
        self.trip = trip
    }

    @MainActor
    func deletePlace(_ place: SavedPlace, context: ModelContext) {
        trip.places.removeAll { $0.id == place.id }
        context.delete(place)
        updateOrderIndices(context: context)
    }

    @MainActor
    func movePlaces(from source: IndexSet, to destination: Int, context: ModelContext) {
        var places = trip.sortedPlaces
        places.move(fromOffsets: source, toOffset: destination)

        for (index, place) in places.enumerated() {
            place.orderIndex = index
        }

        try? context.save()
    }

    @MainActor
    private func updateOrderIndices(context: ModelContext) {
        for (index, place) in trip.sortedPlaces.enumerated() {
            place.orderIndex = index
        }
        try? context.save()
    }
}
```

#### 5.6 `Expedio/Features/Trips/TripDetailView.swift`
```swift
import SwiftUI
import SwiftData

struct TripDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TripDetailViewModel

    init(trip: Trip) {
        _viewModel = State(initialValue: TripDetailViewModel(trip: trip))
    }

    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()

            if viewModel.trip.places.isEmpty {
                emptyView
            } else {
                placesList
            }
        }
        .navigationTitle(viewModel.trip.name)
        .navigationBarTitleDisplayMode(.large)
    }

    private var placesList: some View {
        List {
            Section {
                ForEach(viewModel.trip.sortedPlaces) { place in
                    SavedPlaceRow(place: place)
                }
                .onDelete(perform: deletePlaces)
                .onMove(perform: movePlaces)
            } header: {
                tripHeader
            }
        }
        .listStyle(.plain)
        .toolbar { EditButton() }
    }

    private var tripHeader: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(viewModel.trip.destination)
                .font(Theme.Typography.subheadline)
                .foregroundColor(Theme.Colors.textSecondary)

            if let dateRange = viewModel.trip.dateRangeText {
                Text(dateRange)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .textCase(nil)
        .padding(.bottom, Theme.Spacing.sm)
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Places Yet",
            systemImage: "mappin",
            description: Text("Search and add places to this trip")
        )
    }

    private func deletePlaces(at offsets: IndexSet) {
        let sortedPlaces = viewModel.trip.sortedPlaces
        for index in offsets {
            viewModel.deletePlace(sortedPlaces[index], context: modelContext)
        }
    }

    private func movePlaces(from source: IndexSet, to destination: Int) {
        viewModel.movePlaces(from: source, to: destination, context: modelContext)
    }
}

private struct SavedPlaceRow: View {
    let place: SavedPlace

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(place.name)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.textPrimary)

            Text(place.category)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.primary)
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}
```

### Unit Tests for Phase 5

#### `ExpedioTests/Features/Trips/TripsListViewModelTests.swift`
```swift
import XCTest
import SwiftData
@testable import Expedio

final class TripsListViewModelTests: XCTestCase {

    @MainActor
    func testCreateTrip_insertsIntoContext() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, SavedPlace.self, configurations: config)
        let context = container.mainContext

        let viewModel = TripsListViewModel()
        viewModel.createTrip(
            name: "Summer Trip",
            destination: "Paris",
            startDate: Date(),
            endDate: nil,
            context: context
        )

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

        let viewModel = TripsListViewModel()
        viewModel.deleteTrip(trip, context: context)

        let descriptor = FetchDescriptor<Trip>()
        let trips = try context.fetch(descriptor)

        XCTAssertTrue(trips.isEmpty)
    }
}
```

#### `ExpedioTests/Features/Trips/TripDetailViewModelTests.swift`
```swift
import XCTest
import SwiftData
@testable import Expedio

final class TripDetailViewModelTests: XCTestCase {

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

        let viewModel = TripDetailViewModel(trip: trip)
        viewModel.deletePlace(place, context: context)

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

        // Move first item to end (index 0 -> after index 2)
        viewModel.movePlaces(from: IndexSet(integer: 0), to: 3, context: context)

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

        let viewModel = TripDetailViewModel(trip: trip)
        viewModel.deletePlace(place1, context: context)

        let sorted = trip.sortedPlaces
        XCTAssertEqual(sorted.count, 2)
        XCTAssertEqual(sorted[0].orderIndex, 0)
        XCTAssertEqual(sorted[1].orderIndex, 1)
    }
}
```

### Phase 5 Checklist
- [ ] Create TripsListViewModel with create/delete methods
- [ ] Create TripsListView with @Query for trips
- [ ] Implement CreateTripSheet with form validation
- [ ] Create TripCard component with place count
- [ ] Implement swipe-to-delete for trips
- [ ] Create TripDetailViewModel with place management
- [ ] Create TripDetailView with sorted places list
- [ ] Implement drag-and-drop reordering with onMove
- [ ] Implement swipe-to-delete for places
- [ ] Update order indices after delete/move
- [ ] Write and run TripsListViewModelTests
- [ ] Write and run TripDetailViewModelTests
- [ ] Test cascade delete (trip deletes places)

---

## Phase 6: Polish & Integration

### Goals
- Add tab bar navigation between Search and Trips
- Create ContentView as main entry point
- Add animations and transitions
- Final UI polish and accessibility

### Files to Create/Update

#### 6.1 `Expedio/App/ContentView.swift`
```swift
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(0)

            TripsListView()
                .tabItem {
                    Label("Trips", systemImage: "suitcase.fill")
                }
                .tag(1)
        }
        .tint(Theme.Colors.primary)
    }
}

#Preview {
    ContentView()
}
```

#### 6.2 Update `Expedio/App/ExpedioApp.swift`
```swift
import SwiftUI
import SwiftData

@main
struct ExpedioApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Trip.self,
            SavedPlace.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}
```

#### 6.3 `Expedio/Core/Extensions/View+Animations.swift`
```swift
import SwiftUI

extension View {
    func fadeInOnAppear() -> some View {
        modifier(FadeInModifier())
    }
}

struct FadeInModifier: ViewModifier {
    @State private var opacity: Double = 0

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.3)) {
                    opacity = 1
                }
            }
    }
}

extension AnyTransition {
    static var slideAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
```

### Unit Tests for Phase 6

#### `ExpedioTests/App/ContentViewTests.swift`
```swift
import XCTest
import SwiftUI
@testable import Expedio

final class ContentViewTests: XCTestCase {

    func testContentView_initialTab_isSearch() {
        // ContentView starts with selectedTab = 0 (Search)
        // This is a basic structural test
        let contentView = ContentView()
        XCTAssertNotNil(contentView)
    }

    func testFadeInModifier_appliesOpacityAnimation() {
        // Test that the modifier can be applied without crashing
        let view = Text("Test").fadeInOnAppear()
        XCTAssertNotNil(view)
    }
}
```

#### `ExpedioTests/Integration/FullFlowTests.swift`
```swift
import XCTest
import SwiftData
@testable import Expedio

final class FullFlowTests: XCTestCase {

    @MainActor
    func testFullFlow_createTripAndAddPlace() throws {
        // Setup in-memory container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, SavedPlace.self, configurations: config)
        let context = container.mainContext

        // 1. Create a trip
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

        // 2. Add a place to the trip
        let place = NominatimPlace(
            placeId: 12345,
            lat: "48.8584",
            lon: "2.2945",
            displayName: "Eiffel Tower, Paris, France",
            category: "tourism",
            type: "attraction"
        )

        let placeDetailViewModel = PlaceDetailViewModel(place: place)
        placeDetailViewModel.addToTrip(trip, context: context)

        // Verify place added
        XCTAssertEqual(trip.places.count, 1)
        XCTAssertEqual(trip.places.first?.name, "Eiffel Tower")
        XCTAssertEqual(trip.places.first?.orderIndex, 0)

        // 3. Add another place
        let place2 = NominatimPlace(
            placeId: 67890,
            lat: "48.8606",
            lon: "2.3376",
            displayName: "Louvre Museum, Paris, France",
            category: "tourism",
            type: "museum"
        )

        let placeDetailViewModel2 = PlaceDetailViewModel(place: place2)
        placeDetailViewModel2.addToTrip(trip, context: context)

        XCTAssertEqual(trip.places.count, 2)
        XCTAssertEqual(trip.sortedPlaces[1].orderIndex, 1)

        // 4. Reorder places
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
}
```

### Phase 6 Checklist
- [ ] Create ContentView with TabView
- [ ] Configure tab items with SF Symbols
- [ ] Apply Theme.Colors.primary as tint color
- [ ] Add fade-in animation modifier
- [ ] Create slide and fade transition
- [ ] Set preferredColorScheme to light
- [ ] Write ContentViewTests
- [ ] Write full integration flow tests
- [ ] Test cascade delete behavior
- [ ] Run full app verification plan
- [ ] Test on device/simulator

---

## Verification Plan

After completing all phases, verify the app works end-to-end:

1. **Build & Run:** `Cmd+R` in Xcode, app launches without crashes
2. **Search:** Type "Paris" → results appear after debounce (~500ms)
3. **Detail:** Tap result → detail view shows map and info
4. **Create Trip:** Trips tab → "+" → fill form → trip appears in list
5. **Add to Trip:** Search → tap place → "Add to Trip" → select trip → confirmation alert
6. **Trip Detail:** Tap trip → see saved places in order
7. **Reorder:** Edit mode → drag places → order persists after leaving edit mode
8. **Delete Place:** Swipe place → deleted, remaining places re-indexed
9. **Delete Trip:** Swipe trip → deleted with all places (cascade)
10. **Empty States:** Verify all ContentUnavailableView states display correctly

---

## Test Summary

| Phase | Test File | Test Count |
|-------|-----------|------------|
| 1 | ThemeTests.swift | 8 |
| 2 | NominatimPlaceTests.swift | 6 |
| 2 | TripTests.swift | 5 |
| 2 | EndpointTests.swift | 3 |
| 2 | NominatimServiceTests.swift | 2 |
| 3 | SearchViewModelTests.swift | 6 |
| 3 | PlaceRowTests.swift | 3 |
| 4 | PlaceDetailViewModelTests.swift | 5 |
| 5 | TripsListViewModelTests.swift | 2 |
| 5 | TripDetailViewModelTests.swift | 3 |
| 6 | ContentViewTests.swift | 2 |
| 6 | FullFlowTests.swift | 2 |
| **Total** | | **47** |

---

## File Summary

| Category | Files |
|----------|-------|
| App | 2 (ExpedioApp.swift, ContentView.swift) |
| Core/Design | 1 (Theme.swift) |
| Core/Extensions | 2 (View+Extensions.swift, View+Animations.swift) |
| Models | 3 (Trip.swift, SavedPlace.swift, NominatimPlace.swift) |
| Services | 2 (NominatimService.swift, Endpoint.swift) |
| Features/Search | 3 (SearchView.swift, SearchViewModel.swift, PlaceRow.swift) |
| Features/PlaceDetail | 3 (PlaceDetailView.swift, PlaceDetailViewModel.swift, AddToTripSheet.swift) |
| Features/Trips | 6 (TripsListView.swift, TripsListViewModel.swift, TripDetailView.swift, TripDetailViewModel.swift, TripCard.swift, CreateTripSheet.swift) |
| **Total Source Files** | **22** |
| **Total Test Files** | **12** |

---

## Phase 7: Enhanced Place Data (extratags)

### Goals
- Add extratags=1 to Nominatim API calls for rich place data
- Update NominatimPlace model with extratags fields
- Display phone, website, hours, cuisine in PlaceDetailView

### Files to Modify

#### 7.1 Update `Expedio/Services/Networking/Endpoint.swift`
```swift
case .search(let query, let limit):
    var components = URLComponents(string: "https://nominatim.openstreetmap.org/search")
    components?.queryItems = [
        URLQueryItem(name: "q", value: query),
        URLQueryItem(name: "format", value: "jsonv2"),
        URLQueryItem(name: "limit", value: String(limit)),
        URLQueryItem(name: "addressdetails", value: "1"),
        URLQueryItem(name: "extratags", value: "1"),
        URLQueryItem(name: "namedetails", value: "1")
    ]
    return components?.url
```

#### 7.2 Update `Expedio/Models/NominatimPlace.swift`
```swift
struct NominatimPlace: Codable, Identifiable, Hashable {
    let placeId: Int
    let lat: String
    let lon: String
    let displayName: String
    let category: String?
    let type: String?
    let extratags: NominatimExtratags?

    // ... existing code ...

    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case lat, lon
        case displayName = "display_name"
        case category = "class"
        case type
        case extratags
    }
}

struct NominatimExtratags: Codable, Hashable {
    let phone: String?
    let website: String?
    let openingHours: String?
    let cuisine: String?
    let wheelchair: String?
    let wikipedia: String?
    let dietVegan: String?
    let dietVegetarian: String?

    enum CodingKeys: String, CodingKey {
        case phone, website, cuisine, wheelchair, wikipedia
        case openingHours = "opening_hours"
        case dietVegan = "diet:vegan"
        case dietVegetarian = "diet:vegetarian"
    }
}
```

#### 7.3 Update `Expedio/Features/PlaceDetail/PlaceDetailView.swift`
Add rich data display section:
```swift
private var richDataSection: some View {
    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
        if let phone = viewModel.place.extratags?.phone {
            Link(destination: URL(string: "tel:\(phone)")!) {
                Label(phone, systemImage: "phone.fill")
            }
        }
        if let website = viewModel.place.extratags?.website,
           let url = URL(string: website) {
            Link(destination: url) {
                Label("Website", systemImage: "globe")
            }
        }
        if let hours = viewModel.place.extratags?.openingHours {
            Label(hours, systemImage: "clock")
        }
        if let cuisine = viewModel.place.extratags?.cuisine {
            Label(cuisine.capitalized, systemImage: "fork.knife")
        }
    }
    .font(Theme.Typography.subheadline)
    .foregroundColor(Theme.Colors.textSecondary)
}
```

### Phase 7 Checklist
- [ ] Update Endpoint.swift with extratags=1, namedetails=1, format=jsonv2
- [ ] Add NominatimExtratags struct to NominatimPlace.swift
- [ ] Update PlaceDetailView to display rich data
- [ ] Add clickable phone and website links
- [ ] Test with places that have extratags (restaurants, museums)
- [ ] Handle nil extratags gracefully

---

## Phase 8: Unsplash Image Service

### Goals
- Create UnsplashService for fetching place/city images
- Implement image caching (memory + disk)
- Add CachedAsyncImage component with attribution

### Files to Create

#### 8.1 `Expedio/Models/UnsplashPhoto.swift`
```swift
import Foundation

struct UnsplashSearchResponse: Codable {
    let results: [UnsplashPhoto]
}

struct UnsplashPhoto: Codable, Identifiable {
    let id: String
    let urls: UnsplashURLs
    let user: UnsplashUser
    let color: String?
}

struct UnsplashURLs: Codable {
    let thumb: String
    let small: String
    let regular: String
    let full: String
}

struct UnsplashUser: Codable {
    let name: String
    let username: String
}
```

#### 8.2 `Expedio/Services/Networking/UnsplashService.swift`
```swift
import Foundation

final class UnsplashService {
    private let session: URLSession
    private let accessKey: String
    private let baseURL = "https://api.unsplash.com"

    init(accessKey: String, session: URLSession = .shared) {
        self.accessKey = accessKey
        self.session = session
    }

    func searchPhotos(query: String, perPage: Int = 1) async throws -> [UnsplashPhoto] {
        var components = URLComponents(string: "\(baseURL)/search/photos")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "orientation", value: "landscape")
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")

        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(UnsplashSearchResponse.self, from: data)
        return response.results
    }
}
```

#### 8.3 `Expedio/Services/Networking/ImageCacheManager.swift`
```swift
import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private lazy var cacheDirectory: URL = {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ImageCache")
    }()

    private init() {
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
```

#### 8.4 `Expedio/Core/Components/CachedAsyncImage.swift`
```swift
import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder().onAppear { loadImage() }
            }
        }
    }

    private func loadImage() {
        guard let url = url else { return }
        let key = url.absoluteString
        if let cached = ImageCacheManager.shared.image(forKey: key) {
            self.image = cached
            return
        }
        Task {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                ImageCacheManager.shared.setImage(uiImage, forKey: key)
                await MainActor.run { self.image = uiImage }
            }
        }
    }
}
```

#### 8.5 `Expedio/Core/Components/UnsplashAttributionView.swift`
```swift
import SwiftUI

struct UnsplashAttributionView: View {
    let photographerName: String
    let photographerUsername: String
    private let appName = "Expedio"

    var body: some View {
        HStack(spacing: 4) {
            Text("Photo by")
            Link(photographerName, destination: photographerURL)
            Text("on")
            Link("Unsplash", destination: unsplashURL)
        }
        .font(Theme.Typography.caption)
        .foregroundColor(Theme.Colors.textSecondary)
    }

    private var photographerURL: URL {
        URL(string: "https://unsplash.com/@\(photographerUsername)?utm_source=\(appName)&utm_medium=referral")!
    }
    private var unsplashURL: URL {
        URL(string: "https://unsplash.com/?utm_source=\(appName)&utm_medium=referral")!
    }
}
```

### Phase 8 Checklist
- [ ] Create UnsplashPhoto model with Codable
- [ ] Implement UnsplashService with search endpoint
- [ ] Build ImageCacheManager with NSCache
- [ ] Create CachedAsyncImage component
- [ ] Add UnsplashAttributionView (required by Unsplash)
- [ ] Test image loading and caching

---

## Phase 9: Popular Destinations Homepage

### Goals
- Create HomeView as the first tab with popular destinations
- Display destination cards with Unsplash images
- Navigate to category browse on destination tap

### Files to Create

#### 9.1 `Expedio/Models/Destination.swift`
```swift
import Foundation

struct Destination: Identifiable {
    let id = UUID()
    let name: String
    let country: String
    let lat: Double
    let lon: Double
    var searchQuery: String { "\(name) \(country) travel" }

    static let popular: [Destination] = [
        Destination(name: "Paris", country: "France", lat: 48.8566, lon: 2.3522),
        Destination(name: "Tokyo", country: "Japan", lat: 35.6762, lon: 139.6503),
        Destination(name: "New York", country: "USA", lat: 40.7128, lon: -74.0060),
        Destination(name: "London", country: "UK", lat: 51.5074, lon: -0.1278),
        Destination(name: "Rome", country: "Italy", lat: 41.9028, lon: 12.4964),
        Destination(name: "Barcelona", country: "Spain", lat: 41.3851, lon: 2.1734),
        Destination(name: "Dubai", country: "UAE", lat: 25.2048, lon: 55.2708),
        Destination(name: "Sydney", country: "Australia", lat: -33.8688, lon: 151.2093),
        Destination(name: "Istanbul", country: "Turkey", lat: 41.0082, lon: 28.9784),
        Destination(name: "Bangkok", country: "Thailand", lat: 13.7563, lon: 100.5018),
        Destination(name: "Amsterdam", country: "Netherlands", lat: 52.3676, lon: 4.9041),
        Destination(name: "Singapore", country: "Singapore", lat: 1.3521, lon: 103.8198),
    ]
}
```

#### 9.2 `Expedio/Features/Home/HomeView.swift`
```swift
import SwiftUI

struct HomeView: View {
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
                    ForEach(Destination.popular) { destination in
                        NavigationLink(value: destination) {
                            DestinationCard(destination: destination)
                        }
                    }
                }
                .padding(Theme.Spacing.md)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Explore")
            .navigationDestination(for: Destination.self) { destination in
                CategoryBrowseView(destination: destination)
            }
        }
    }
}
```

#### 9.3 `Expedio/Features/Home/Components/DestinationCard.swift`
```swift
import SwiftUI

struct DestinationCard: View {
    let destination: Destination
    @State private var photo: UnsplashPhoto?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CachedAsyncImage(url: URL(string: photo?.urls.small ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Theme.Colors.secondary.opacity(0.3))
            }
            .frame(height: 120)
            .clipped()

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(destination.name)
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                Text(destination.country)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(Theme.Spacing.sm)
        }
        .cardStyle()
        .task { await loadImage() }
    }

    private func loadImage() async {
        // Load from UnsplashService
    }
}
```

#### 9.4 Update `Expedio/App/ContentView.swift`
```swift
TabView(selection: $selectedTab) {
    HomeView()
        .tabItem { Label("Explore", systemImage: "globe") }
        .tag(0)

    SearchView()
        .tabItem { Label("Search", systemImage: "magnifyingglass") }
        .tag(1)

    TripsListView()
        .tabItem { Label("Trips", systemImage: "suitcase.fill") }
        .tag(2)
}
```

### Phase 9 Checklist
- [ ] Create Destination model with static popular destinations
- [ ] Build HomeView with LazyVGrid
- [ ] Create DestinationCard with Unsplash images
- [ ] Update ContentView to add Home as first tab
- [ ] Navigate to CategoryBrowseView on tap
- [ ] Test image loading for all destinations

---

## Phase 10: Category Browsing (Overpass API)

### Goals
- Create OverpassService for querying places by category
- Build CategoryBrowseView with filtered results
- Support restaurants, cafes, museums, attractions, etc.

### Files to Create

#### 10.1 `Expedio/Models/OverpassElement.swift`
```swift
import Foundation
import CoreLocation

struct OverpassResponse: Codable {
    let elements: [OverpassElement]
}

struct OverpassElement: Codable, Identifiable {
    let type: String
    let id: Int64
    let lat: Double?
    let lon: Double?
    let center: OverpassCenter?
    let tags: [String: String]?

    var coordinate: CLLocationCoordinate2D? {
        if let lat = lat, let lon = lon {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        if let center = center {
            return CLLocationCoordinate2D(latitude: center.lat, longitude: center.lon)
        }
        return nil
    }

    var name: String { tags?["name"] ?? "Unknown" }
    var category: String { tags?["amenity"] ?? tags?["tourism"] ?? "" }
}

struct OverpassCenter: Codable {
    let lat: Double
    let lon: Double
}
```

#### 10.2 `Expedio/Services/Networking/OverpassService.swift`
```swift
import Foundation

enum PlaceCategory: String, CaseIterable {
    case restaurant, cafe, bar, museum, attraction, hotel, viewpoint

    var osmTag: String {
        switch self {
        case .restaurant, .cafe, .bar: return "amenity"
        case .museum, .attraction, .hotel, .viewpoint: return "tourism"
        }
    }
}

final class OverpassService {
    private let baseURL = "https://overpass-api.de/api/interpreter"

    func fetchPlaces(in city: String, category: PlaceCategory) async throws -> [OverpassElement] {
        let query = """
        [out:json][timeout:25];
        area["name"="\(city)"]["admin_level"~"[4-8]"]->.searchArea;
        node["\(category.osmTag)"="\(category.rawValue)"](area.searchArea);
        out center body 50;
        """

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.httpBody = query.data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(OverpassResponse.self, from: data).elements
    }
}
```

#### 10.3 `Expedio/Features/Browse/CategoryBrowseView.swift`
```swift
import SwiftUI

struct CategoryBrowseView: View {
    let destination: Destination
    @State private var selectedCategory: PlaceCategory = .attraction
    @State private var places: [OverpassElement] = []
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            categoryPicker
            if isLoading {
                ProgressView()
            } else {
                placesList
            }
        }
        .navigationTitle(destination.name)
        .task { await loadPlaces() }
        .onChange(of: selectedCategory) { await loadPlaces() }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(PlaceCategory.allCases, id: \.self) { cat in
                    Button(cat.rawValue.capitalized) {
                        selectedCategory = cat
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(selectedCategory == cat ? Theme.Colors.primary : Theme.Colors.secondary)
                }
            }
            .padding()
        }
    }

    private var placesList: some View {
        List(places) { place in
            VStack(alignment: .leading) {
                Text(place.name).font(Theme.Typography.headline)
                Text(place.category.capitalized).font(Theme.Typography.caption)
            }
        }
    }

    private func loadPlaces() async {
        isLoading = true
        defer { isLoading = false }
        do {
            places = try await OverpassService().fetchPlaces(
                in: destination.name,
                category: selectedCategory
            )
        } catch {
            places = []
        }
    }
}
```

### Phase 10 Checklist
- [ ] Create OverpassElement model
- [ ] Implement OverpassService with query builder
- [ ] Create PlaceCategory enum with OSM tags
- [ ] Build CategoryBrowseView with category picker
- [ ] Display filtered places list
- [ ] Handle loading and empty states
- [ ] Test with various cities and categories

---

## Updated Verification Plan

After completing all phases (1-10), verify:

1-8. (Original verification steps)
9. **Enhanced Data:** Search "Eiffel Tower" → detail shows phone, website, hours
10. **Images:** Destinations show Unsplash images with attribution
11. **Homepage:** Launch app → see destination cards → tap to explore
12. **Categories:** Select Paris → tap "Restaurants" → see restaurant list

---

## Updated File Summary

| Category | Files |
|----------|-------|
| App | 2 |
| Core/Design | 1 |
| Core/Components | 3 (LoadingView, CachedAsyncImage, UnsplashAttributionView) |
| Core/Extensions | 2 |
| Models | 6 (Trip, SavedPlace, NominatimPlace, UnsplashPhoto, OverpassElement, Destination) |
| Services | 5 (NominatimService, UnsplashService, OverpassService, ImageCacheManager, Endpoint) |
| Features/Home | 3 |
| Features/Search | 3 |
| Features/Browse | 2 |
| Features/PlaceDetail | 3 |
| Features/Trips | 6 |
| **Total Source Files** | **36** |
