# Expedio - iOS Travel Itinerary App PRD

## Overview
A SwiftUI-based iOS travel itinerary app for interviewing senior iOS engineers. Candidates will review PRs containing subtle bugs (race conditions, threading issues) against this clean codebase.

## Tech Stack
- **UI Framework:** SwiftUI (iOS 17+)
- **Architecture:** MVVM with @Observable
- **Storage:** SwiftData
- **API:** OpenStreetMap Nominatim (free, no API key)
- **Design:** Soft pastel colors, Playfair Display serif font

---

## Core Features

### 1. Place Search
- Search places via Nominatim API
- Debounced search input
- Display results in scrollable list
- Show place name, category, and location

### 2. Place Details
- Full address and coordinates
- Category information
- Interactive map preview
- "Add to Trip" action

### 3. Trip Management
- Create trips (name, destination, dates)
- View all trips in list
- Delete trips with swipe
- Trip card shows place count

### 4. Trip Details
- View saved places in trip
- Reorder places (drag & drop)
- Remove places from trip
- Trip metadata display

---

## Project Structure

```
Expedio/
├── App/
│   └── ExpedioApp.swift              # App entry, SwiftData container
├── Core/
│   ├── Design/
│   │   └── Theme.swift               # Colors, typography, spacing
│   ├── Components/
│   │   └── LoadingView.swift         # Styled loading spinner
│   └── Extensions/
│       └── View+Extensions.swift
├── Models/
│   ├── Trip.swift                    # SwiftData model
│   ├── SavedPlace.swift              # SwiftData model
│   └── NominatimPlace.swift          # API response model
├── Services/
│   └── Networking/
│       ├── NominatimService.swift    # API client
│       └── Endpoint.swift            # URL construction
├── Features/
│   ├── Search/
│   │   ├── SearchView.swift
│   │   └── SearchViewModel.swift
│   ├── PlaceDetail/
│   │   ├── PlaceDetailView.swift
│   │   └── PlaceDetailViewModel.swift
│   └── Trips/
│       ├── TripsListView.swift
│       ├── TripsListViewModel.swift
│       ├── TripDetailView.swift
│       ├── TripDetailViewModel.swift
│       └── Components/
│           ├── TripCard.swift
│           └── CreateTripSheet.swift
└── Resources/
    └── Fonts/
        └── PlayfairDisplay-VariableFont_wght.ttf
```

---

## Data Models

### Trip (SwiftData)
```swift
@Model
final class Trip {
    var id: UUID
    var name: String
    var destination: String
    var startDate: Date?
    var endDate: Date?
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var places: [SavedPlace]
}
```

### SavedPlace (SwiftData)
```swift
@Model
final class SavedPlace {
    var id: UUID
    var placeId: String       // Nominatim place_id
    var name: String
    var displayName: String
    var category: String
    var lat: String
    var lon: String
    var orderIndex: Int
    var addedAt: Date
    @Relationship(inverse: \Trip.places) var trip: Trip?
}
```

### NominatimPlace (API Response)
```swift
struct NominatimPlace: Codable, Identifiable, Hashable {
    let placeId: Int
    let lat: String
    let lon: String
    let displayName: String
    let category: String?
    let type: String?
}
```

---

## Design System (Theme.swift)

### Colors (Soft Pastels)
| Name | Hex | Usage |
|------|-----|-------|
| background | #FDF8F4 | Main background (warm cream) |
| surface | #FFFFFF | Cards and elevated surfaces |
| primary | #7C9885 | Buttons, accents (sage green) |
| secondary | #B8A9C9 | Secondary elements (soft lavender) |
| textPrimary | #2D3436 | Headlines, important text |
| textSecondary | #636E72 | Body text, captions |
| accent | #E8B4B8 | Highlights (dusty rose) |

### Typography
- **Playfair Display** (variable font) - Headlines, titles, and navigation headers (serif)
- **SF Pro** (system font) - Body text, captions, and content (sans-serif)
- Clear hierarchy with serif for emphasis, sans-serif for readability

### Spacing Scale
- xs: 4pt, sm: 8pt, md: 16pt, lg: 24pt, xl: 32pt

---

## API Integration

### Nominatim Search Endpoint
```
GET https://nominatim.openstreetmap.org/search
?q={query}
&format=json
&limit=20
&addressdetails=1
```

**Required Headers:**
- `User-Agent: Expedio/1.0` (Nominatim requires this)

**Rate Limiting:** 1 request/second (implement debounce)

---

## Screen Flow

```
┌─────────────────┐     ┌──────────────────┐
│   Search Tab    │────▶│  Place Detail    │
│  (Place List)   │     │  (Add to Trip)   │
└─────────────────┘     └──────────────────┘
                               │
        ┌──────────────────────┘
        ▼
┌─────────────────┐     ┌──────────────────┐
│   Trips Tab     │────▶│   Trip Detail    │
│  (Trip List)    │     │  (Place List)    │
└─────────────────┘     └──────────────────┘
```

---

## Implementation Order

### Phase 1: Project Setup
1. Create Xcode project (SwiftUI, iOS 17+)
2. Add Playfair Display font files
3. Configure Info.plist for custom fonts
4. Create Theme.swift with design system
5. Set up SwiftData container in App

### Phase 2: Data Layer
1. Create NominatimPlace model
2. Create Trip and SavedPlace SwiftData models
3. Implement NominatimService with async/await
4. Add Endpoint enum for URL construction

### Phase 3: Search Feature
1. Build SearchView with search bar and list
2. Implement SearchViewModel with debouncing
3. Create PlaceRow component
4. Add loading and empty states

### Phase 4: Place Detail
1. Build PlaceDetailView with sections
2. Add map preview using MapKit
3. Implement PlaceDetailViewModel
4. Create AddToTripSheet

### Phase 5: Trips Feature
1. Build TripsListView with trip cards
2. Implement TripsListViewModel
3. Create CreateTripSheet
4. Build TripDetailView with place management

### Phase 6: Polish
1. Add tab bar navigation
2. Implement delete/reorder animations
3. Add ContentUnavailableView states
4. Final UI polish and testing

---

## PR Bug Injection Points

These areas are ideal for introducing subtle bugs in PRs for candidates to find:

| Location | Bug Type | Difficulty |
|----------|----------|------------|
| SearchViewModel | Race condition (stale results) | Medium |
| SearchViewModel | Task cancellation leak | Medium |
| TripDetailViewModel | SwiftData threading | Hard |
| TripsListView | Array index bounds on delete | Easy |
| PlaceDetailView | Sheet state race | Medium |
| NominatimService | Silent error swallowing | Easy |
| Trip model | Observation not triggering | Hard |

---

## Verification Plan

1. **Build & Run:** `Cmd+R` in Xcode, app launches without crashes
2. **Search:** Type "Paris" → results appear after debounce
3. **Detail:** Tap result → detail view shows map and info
4. **Create Trip:** Trips tab → "+" → fill form → trip appears
5. **Add to Trip:** Detail → "Add to Trip" → select trip → place saved
6. **Trip Detail:** Tap trip → see saved places
7. **Reorder:** Edit mode → drag places → order persists
8. **Delete:** Swipe trip → deleted from list

---

## Files to Create (18 total)

**App (1)**
- `Expedio/App/ExpedioApp.swift`

**Core (2)**
- `Expedio/Core/Design/Theme.swift`
- `Expedio/Core/Extensions/View+Extensions.swift`

**Models (3)**
- `Expedio/Models/Trip.swift`
- `Expedio/Models/SavedPlace.swift`
- `Expedio/Models/NominatimPlace.swift`

**Services (2)**
- `Expedio/Services/Networking/NominatimService.swift`
- `Expedio/Services/Networking/Endpoint.swift`

**Search Feature (3)**
- `Expedio/Features/Search/SearchView.swift`
- `Expedio/Features/Search/SearchViewModel.swift`
- `Expedio/Features/Search/Components/PlaceRow.swift`

**Place Detail (3)**
- `Expedio/Features/PlaceDetail/PlaceDetailView.swift`
- `Expedio/Features/PlaceDetail/PlaceDetailViewModel.swift`
- `Expedio/Features/PlaceDetail/Components/AddToTripSheet.swift`

**Trips Feature (4)**
- `Expedio/Features/Trips/TripsListView.swift`
- `Expedio/Features/Trips/TripsListViewModel.swift`
- `Expedio/Features/Trips/TripDetailView.swift`
- `Expedio/Features/Trips/TripDetailViewModel.swift`

**Resources**
- `Expedio/Resources/Fonts/PlayfairDisplay-VariableFont_wght.ttf`
