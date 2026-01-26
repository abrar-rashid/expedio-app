//
//  CategoryBrowseViewModel.swift
//  Expedio
//
//  ViewModel for browsing places by category within a destination
//

import Foundation
import Observation

@Observable
final class CategoryBrowseViewModel {
    private(set) var places: [OverpassElement] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var selectedCategory: PlaceCategory = .attraction {
        didSet {
            if oldValue != selectedCategory {
                Task { await loadPlaces() }
            }
        }
    }

    let destination: Destination
    private let service: OverpassServiceProtocol
    private var loadTask: Task<Void, Never>?

    init(destination: Destination, service: OverpassServiceProtocol = OverpassService()) {
        self.destination = destination
        self.service = service
    }

    deinit {
        loadTask?.cancel()
    }

    @MainActor
    func loadPlaces() async {
        loadTask?.cancel()

        loadTask = Task { @MainActor in
            isLoading = true
            errorMessage = nil

            do {
                let results = try await service.fetchPlaces(
                    city: destination.name,
                    category: selectedCategory
                )
                guard !Task.isCancelled else { return }
                places = results
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
                places = []
            }

            isLoading = false
        }
    }

    @MainActor
    func loadNearbyPlaces() async {
        loadTask?.cancel()

        loadTask = Task { @MainActor in
            isLoading = true
            errorMessage = nil

            do {
                let results = try await service.fetchNearbyPlaces(
                    latitude: destination.lat,
                    longitude: destination.lon,
                    category: selectedCategory,
                    radiusMeters: 2000
                )
                guard !Task.isCancelled else { return }
                places = results
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
                places = []
            }

            isLoading = false
        }
    }
}
