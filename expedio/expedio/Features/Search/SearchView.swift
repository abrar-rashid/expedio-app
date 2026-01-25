//
//  SearchView.swift
//  Expedio
//
//  Main search interface for finding places
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()

                Group {
                    if viewModel.isLoading {
                        LoadingView(message: "Searching...")
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
            .navigationDestination(for: NominatimPlace.self) { place in
                PlaceDetailView(place: place)
            }
        }
    }

    private var resultsList: some View {
        List(viewModel.places) { place in
            NavigationLink(value: place) {
                PlaceRow(place: place)
            }
            .listRowBackground(Theme.Colors.background)
            .listRowSeparatorTint(Theme.Colors.textSecondary.opacity(0.2))
            .listRowInsets(EdgeInsets(
                top: Theme.Spacing.xs,
                leading: Theme.Spacing.md,
                bottom: Theme.Spacing.xs,
                trailing: Theme.Spacing.md
            ))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Theme.Colors.background)
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

#Preview {
    SearchView()
}
