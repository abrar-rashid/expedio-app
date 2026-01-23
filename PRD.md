# Expedio - iOS Travel Itinerary App PRD

## Overview
A SwiftUI-based iOS travel itinerary app for interviewing senior iOS engineers. Candidates will review PRs containing subtle bugs (race conditions, threading issues) against this clean codebase.

## Tech Stack
- **UI Framework:** SwiftUI (iOS 17+)
- **Architecture:** MVVM with @Observable
- **Storage:** SwiftData
- **APIs:**
  - OpenStreetMap Nominatim (geocoding, place search - free, no API key)
  - Overpass API (category-based place queries - free, no API key)
  - Unsplash API (place/city images - free tier: 50 req/hour demo, 5000 req/hour production)
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

### 5. Enhanced Place Details
- Rich place data: phone, website, opening hours
- Cuisine types and dietary options (vegan, vegetarian)
- Wikipedia links for more information
- Wheelchair accessibility info

### 6. Place Images
- High-quality city/place photos from Unsplash
- Cached image loading (memory + disk)
- Photographer attribution (required by Unsplash)

### 7. Popular Destinations Homepage
- Curated list of 20+ top travel cities
- Beautiful destination cards with images
- Quick access to explore places in each city
- Category shortcuts (restaurants, attractions, etc.)

### 8. Category Browsing
- Browse restaurants, cafes, museums, attractions by city
- Filter by category: restaurants, cafes, bars, museums, attractions, hotels, viewpoints
- Nearby places search within radius

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
│   │   ├── LoadingView.swift         # Styled loading spinner
│   │   ├── CachedAsyncImage.swift    # Image loading with cache
│   │   └── UnsplashAttributionView.swift  # Photo attribution
│   └── Extensions/
│       └── View+Extensions.swift
├── Models/
│   ├── Trip.swift                    # SwiftData model
│   ├── SavedPlace.swift              # SwiftData model
│   ├── NominatimPlace.swift          # Nominatim API response
│   ├── UnsplashPhoto.swift           # Unsplash API response
│   ├── OverpassElement.swift         # Overpass API response
│   └── Destination.swift             # Static destination data
├── Services/
│   └── Networking/
│       ├── NominatimService.swift    # Place search API client
│       ├── UnsplashService.swift     # Image API client
│       ├── OverpassService.swift     # Category query API client
│       ├── ImageCacheManager.swift   # Image caching (memory + disk)
│       └── Endpoint.swift            # URL construction
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift            # Popular destinations homepage
│   │   ├── HomeViewModel.swift
│   │   └── Components/
│   │       └── DestinationCard.swift
│   ├── Search/
│   │   ├── SearchView.swift
│   │   └── SearchViewModel.swift
│   ├── Browse/
│   │   ├── CategoryBrowseView.swift  # Category-filtered results
│   │   └── CategoryBrowseViewModel.swift
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
    let extratags: NominatimExtratags?  // Rich place data
}

struct NominatimExtratags: Codable, Hashable {
    let phone: String?
    let website: String?
    let openingHours: String?           // OSM format: "Mo-Fr 09:00-18:00"
    let cuisine: String?                // e.g., "italian", "japanese"
    let wheelchair: String?             // "yes", "no", "limited"
    let wikipedia: String?              // e.g., "en:Eiffel Tower"
    let dietVegan: String?              // "yes", "only", "no"
    let dietVegetarian: String?
}
```

### UnsplashPhoto (API Response)
```swift
struct UnsplashPhoto: Codable, Identifiable {
    let id: String
    let urls: UnsplashURLs
    let user: UnsplashUser
    let color: String?                  // Hex color for placeholder
}

struct UnsplashURLs: Codable {
    let thumb: String                   // 200px width
    let small: String                   // 400px width
    let regular: String                 // 1080px width
    let full: String                    // Original size
}

struct UnsplashUser: Codable {
    let name: String                    // For attribution
    let username: String                // For profile link
}
```

### OverpassElement (API Response)
```swift
struct OverpassElement: Codable, Identifiable {
    let type: String                    // "node", "way", "relation"
    let id: Int64
    let lat: Double?
    let lon: Double?
    let center: OverpassCenter?         // For ways/relations
    let tags: [String: String]?         // name, amenity, tourism, addr:*, etc.
}

struct OverpassCenter: Codable {
    let lat: Double
    let lon: Double
}
```

### Destination (Static Data)
```swift
struct Destination: Identifiable {
    let id = UUID()
    let name: String                    // "Paris"
    let country: String                 // "France"
    let lat: Double
    let lon: Double
    let searchQuery: String             // For Unsplash: "Paris France travel"
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

### Nominatim Search Endpoint (Enhanced)
```
GET https://nominatim.openstreetmap.org/search
?q={query}
&format=jsonv2
&limit=20
&addressdetails=1
&extratags=1
&namedetails=1
```

**Required Headers:**
- `User-Agent: Expedio/1.0` (Nominatim requires this)

**Rate Limiting:** 1 request/second (implement debounce)

**Note:** `extratags=1` returns rich data like phone, website, opening_hours, cuisine

---

### Unsplash Search Photos Endpoint
```
GET https://api.unsplash.com/search/photos
?query={city_name}
&per_page=1
&orientation=landscape
```

**Required Headers:**
- `Authorization: Client-ID {YOUR_ACCESS_KEY}`
- `Accept-Version: v1`

**Rate Limiting:**
- Demo: 50 requests/hour
- Production: 5,000 requests/hour (requires approval)

**Attribution Required:** "Photo by {name} on Unsplash" with links
- Photographer link: `https://unsplash.com/@{username}?utm_source=Expedio&utm_medium=referral`
- Unsplash link: `https://unsplash.com/?utm_source=Expedio&utm_medium=referral`

---

### Overpass API (Category Queries)
```
POST https://overpass-api.de/api/interpreter
Content-Type: text/plain

[out:json][timeout:25];
area["name"="{city_name}"]["admin_level"="8"]->.searchArea;
node["amenity"="restaurant"](area.searchArea);
out center body;
```

**Query by Radius:**
```
[out:json][timeout:25];
node["amenity"="cafe"](around:1000,{lat},{lon});
out center body;
```

**Category Tags:**
| Category | OSM Tag |
|----------|---------|
| Restaurants | `amenity=restaurant` |
| Cafes | `amenity=cafe` |
| Bars | `amenity=bar` |
| Museums | `tourism=museum` |
| Attractions | `tourism=attraction` |
| Hotels | `tourism=hotel` |
| Viewpoints | `tourism=viewpoint` |

**Rate Limiting:** ~10,000 queries/day recommended (no hard limit)

---

## Screen Flow

```
┌─────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│    Home Tab     │────▶│  Category Browse │────▶│  Place Detail    │
│  (Destinations) │     │  (Restaurants)   │     │  (Add to Trip)   │
└─────────────────┘     └──────────────────┘     └──────────────────┘
        │                                               │
        ▼                                               │
┌─────────────────┐     ┌──────────────────┐           │
│   Search Tab    │────▶│  Place Detail    │───────────┤
│  (Place List)   │     │  (Rich Data)     │           │
└─────────────────┘     └──────────────────┘           │
                                                       │
        ┌──────────────────────────────────────────────┘
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

### Phase 7: Enhanced Place Data (extratags)
1. Add extratags=1, namedetails=1 to Nominatim endpoint
2. Update NominatimPlace model with NominatimExtratags struct
3. Display rich data (phone, website, hours) in PlaceDetailView
4. Add cuisine and dietary info badges

### Phase 8: Unsplash Image Service
1. Create UnsplashPhoto model
2. Implement UnsplashService with API client
3. Build ImageCacheManager (memory + disk caching)
4. Create CachedAsyncImage component
5. Add UnsplashAttributionView for required attribution

### Phase 9: Popular Destinations Homepage
1. Create Destination model with static data (20+ cities)
2. Build HomeView with destination grid
3. Create DestinationCard with Unsplash images
4. Update ContentView to add Home as first tab
5. Navigate to category browse on destination tap

### Phase 10: Category Browsing (Overpass API)
1. Create OverpassElement model
2. Implement OverpassService with query builder
3. Build CategoryBrowseView with filtered results
4. Add category selector (restaurants, cafes, museums, etc.)
5. Support radius-based nearby search

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
9. **Enhanced Data:** Search "Eiffel Tower" → detail shows phone, website, hours (if available)
10. **Images:** View any destination → image loads with photographer attribution
11. **Homepage:** Launch app → see destination cards with images → tap to explore
12. **Categories:** Select destination → tap "Restaurants" → see filtered list

---

## Files to Create (31 total)

**App (1)**
- `Expedio/App/ExpedioApp.swift`

**Core (4)**
- `Expedio/Core/Design/Theme.swift`
- `Expedio/Core/Extensions/View+Extensions.swift`
- `Expedio/Core/Components/CachedAsyncImage.swift`
- `Expedio/Core/Components/UnsplashAttributionView.swift`

**Models (6)**
- `Expedio/Models/Trip.swift`
- `Expedio/Models/SavedPlace.swift`
- `Expedio/Models/NominatimPlace.swift`
- `Expedio/Models/UnsplashPhoto.swift`
- `Expedio/Models/OverpassElement.swift`
- `Expedio/Models/Destination.swift`

**Services (5)**
- `Expedio/Services/Networking/NominatimService.swift`
- `Expedio/Services/Networking/UnsplashService.swift`
- `Expedio/Services/Networking/OverpassService.swift`
- `Expedio/Services/Networking/ImageCacheManager.swift`
- `Expedio/Services/Networking/Endpoint.swift`

**Home Feature (3)**
- `Expedio/Features/Home/HomeView.swift`
- `Expedio/Features/Home/HomeViewModel.swift`
- `Expedio/Features/Home/Components/DestinationCard.swift`

**Search Feature (3)**
- `Expedio/Features/Search/SearchView.swift`
- `Expedio/Features/Search/SearchViewModel.swift`
- `Expedio/Features/Search/Components/PlaceRow.swift`

**Browse Feature (2)**
- `Expedio/Features/Browse/CategoryBrowseView.swift`
- `Expedio/Features/Browse/CategoryBrowseViewModel.swift`

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
