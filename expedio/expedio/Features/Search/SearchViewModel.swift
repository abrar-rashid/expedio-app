//
//  SearchViewModel.swift
//  Expedio
//
//  ViewModel for place search with debounced API calls
//

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
