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
        .modelContainer(for: [Trip.self, SavedPlace.self], inMemory: true)
}
