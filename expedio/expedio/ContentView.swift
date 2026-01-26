//
//  ContentView.swift
//  Expedio
//
//  Main entry point with tab navigation
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Explore", systemImage: "globe")
                }
                .tag(0)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)

            TripsListView()
                .tabItem {
                    Label("Trips", systemImage: "suitcase.fill")
                }
                .tag(2)
        }
        .tint(Theme.Colors.primary)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Trip.self, SavedPlace.self], inMemory: true)
}
