# Navigation Destination Flicker Bug

## Problem

When navigating to `PlaceDetailView` from search results, the screen would briefly flash a white screen with a yellow warning triangle icon before showing the destination view.

## Root Cause

The `.navigationDestination` modifier was attached to `resultsList`, which is only rendered in one branch of a conditional view hierarchy. When SwiftUI's state changed during navigation (e.g., debounce timer firing), a different branch could momentarily render, unmounting `resultsList` and its associated navigation destination. This caused the pushed view to briefly disappear.

## Buggy Code

```swift
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
                        resultsList  // navigationDestination only exists here!
                    }
                }
            }
            .navigationTitle("Search Places")
            .searchable(text: $viewModel.searchText, prompt: "Search cities, landmarks...")
        }
    }

    private var resultsList: some View {
        List(viewModel.places) { place in
            NavigationLink(value: place) {
                PlaceRow(place: place)
            }
        }
        .listStyle(.plain)
        // BUG: navigationDestination attached to conditional view
        .navigationDestination(for: NominatimPlace.self) { place in
            PlaceDetailView(place: place)
        }
    }
}
```

## Fix

Move `.navigationDestination` to the `NavigationStack` level so it remains registered regardless of which conditional branch is displayed.

```swift
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
            .searchable(text: $viewModel.searchText, prompt: "Search cities, landmarks...")
            // FIX: navigationDestination at NavigationStack level
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
        }
        .listStyle(.plain)
        // Removed navigationDestination from here
    }
}
```

## Key Takeaway

Always attach `.navigationDestination` to a view that persists throughout the navigation lifecycle, typically the `NavigationStack` itself or a view that won't be conditionally removed.
