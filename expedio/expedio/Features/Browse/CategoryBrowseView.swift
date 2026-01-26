//
//  CategoryBrowseView.swift
//  Expedio
//
//  Browse places by category within a destination
//

import SwiftUI
import MapKit

struct CategoryBrowseView: View {
    @State private var viewModel: CategoryBrowseViewModel
    @State private var showMapView = false

    init(destination: Destination) {
        _viewModel = State(initialValue: CategoryBrowseViewModel(destination: destination))
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            Divider()
            contentView
        }
        .background(Theme.Colors.background)
        .navigationTitle(viewModel.destination.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                viewToggleButton
            }
        }
        .task {
            await viewModel.loadPlaces()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 0) {
            categoryPicker
        }
    }

    // MARK: - View Toggle

    private var viewToggleButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                showMapView.toggle()
            }
        } label: {
            Image(systemName: showMapView ? "list.bullet" : "map")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Theme.Colors.primary)
        }
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(PlaceCategory.allCases) { category in
                    CategoryChip(
                        category: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
        }
        .background(Theme.Colors.background)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            loadingView
        } else if let error = viewModel.errorMessage {
            errorView(error)
        } else if viewModel.places.isEmpty {
            emptyView
        } else if showMapView {
            mapView
        } else {
            placesList
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            LoadingView(message: "Finding \(viewModel.selectedCategory.displayName.lowercased())s...")
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }

    private var placesList: some View {
        List(viewModel.places) { place in
            NavigationLink(value: place) {
                PlaceRowView(place: place)
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
        .navigationDestination(for: OverpassElement.self) { place in
            PlaceDetailView(place: place)
        }
    }

    private var mapView: some View {
        PlacesMapView(
            places: viewModel.places,
            destination: viewModel.destination
        )
        .navigationDestination(for: OverpassElement.self) { place in
            PlaceDetailView(place: place)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No \(viewModel.selectedCategory.displayName)s Found",
            systemImage: viewModel.selectedCategory.iconName,
            description: Text("Try a different category or check back later")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView(
            "Something went wrong",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

// MARK: - Places Map View

private struct PlacesMapView: View {
    let places: [OverpassElement]
    let destination: Destination
    @State private var selectedPlace: OverpassElement?
    @State private var cameraPosition: MapCameraPosition

    init(places: [OverpassElement], destination: Destination) {
        self.places = places
        self.destination = destination

        let center = CLLocationCoordinate2D(
            latitude: destination.lat,
            longitude: destination.lon
        )
        _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $cameraPosition, selection: $selectedPlace) {
                ForEach(places) { place in
                    if let coordinate = place.coordinate {
                        Marker(place.name, coordinate: coordinate)
                            .tint(Theme.Colors.primary)
                            .tag(place)
                    }
                }
            }
            .mapStyle(.standard)

            if let place = selectedPlace {
                PlaceCalloutView(place: place)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedPlace)
    }
}

// MARK: - Place Callout View

private struct PlaceCalloutView: View {
    let place: OverpassElement

    var body: some View {
        NavigationLink(value: place) {
            HStack(spacing: Theme.Spacing.md) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(place.name)
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineLimit(1)

                    if let address = place.address {
                        Text(address)
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .lineLimit(1)
                    }

                    Text(place.formattedCategory)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.primary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.CornerRadius.md)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.bottom, Theme.Spacing.md)
    }
}

// MARK: - Category Chip

private struct CategoryChip: View {
    let category: PlaceCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: category.iconName)
                    .font(.system(size: 12))
                Text(category.displayName)
                    .font(Theme.Typography.subheadline)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(isSelected ? Theme.Colors.primary : Theme.Colors.surface)
            .foregroundColor(isSelected ? Theme.Colors.surface : Theme.Colors.textPrimary)
            .cornerRadius(Theme.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.lg)
                    .stroke(isSelected ? Theme.Colors.primary : Theme.Colors.textSecondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Place Row View

private struct PlaceRowView: View {
    let place: OverpassElement

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(place.name)
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.textPrimary)
                .lineLimit(1)

            if let address = place.address {
                Text(address)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(1)
            }

            Text(place.formattedCategory)
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.primary)
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CategoryBrowseView(
            destination: Destination(
                name: "Paris",
                country: "France",
                lat: 48.8566,
                lon: 2.3522
            )
        )
    }
}
