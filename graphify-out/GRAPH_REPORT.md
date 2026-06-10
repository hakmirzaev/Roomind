# Graph Report - .  (2026-06-10)

## Corpus Check
- 10 files · ~4,823 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 77 nodes · 98 edges · 8 communities detected
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 10 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]

## God Nodes (most connected - your core abstractions)
1. `Coordinator` - 11 edges
2. `ScanEngine` - 6 edges
3. `Librarian` - 5 edges
4. `ARScanView` - 5 edges
5. `LibrarianProfile` - 4 edges
6. `ScanScreen` - 4 edges
7. `RoomMemory` - 4 edges
8. `ContentView` - 4 edges
9. `AppTab` - 4 edges
10. `AskScreen` - 3 edges

## Surprising Connections (you probably didn't know these)
- `ContentView` --inherits--> `View`  [EXTRACTED]
  MyApp/ContentView.swift →   _Bridges community 2 → community 3_
- `LibrarianProfile` --inherits--> `LanguageModelSession.DynamicProfile`  [EXTRACTED]
  MyApp/Librarian.swift →   _Bridges community 1 → community 4_
- `ChatMessage` --inherits--> `Identifiable`  [EXTRACTED]
  MyApp/Librarian.swift →   _Bridges community 1 → community 6_

## Communities

### Community 0 - "Community 0"
Cohesion: 0.17
Nodes (5): ARScanView, Coordinator, ARSessionDelegate, NSObject, UIViewRepresentable

### Community 1 - "Community 1"
Cohesion: 0.18
Nodes (8): Arguments, ChatMessage, Librarian, LibrarianProfile, Role, assistant, user, Speaker

### Community 2 - "Community 2"
Cohesion: 0.21
Nodes (7): AskScreen, MessageBubble, EntryRow, FlowChips, MemoryScreen, ScanScreen, View

### Community 3 - "Community 3"
Cohesion: 0.2
Nodes (7): App, AppTab, ask, recall, scan, ContentView, RoomindApp

### Community 4 - "Community 4"
Cohesion: 0.33
Nodes (4): LanguageModelSession.DynamicProfile, Job, ScanEngine, ScannerProfile

### Community 5 - "Community 5"
Cohesion: 0.29
Nodes (3): RoomSearchTool, RoomMemory, Tool

### Community 6 - "Community 6"
Cohesion: 0.4
Nodes (4): Identifiable, MemoryEntry, SpatialItem, SpatialObservation

### Community 7 - "Community 7"
Cohesion: 0.5
Nodes (1): SpotlightIndexer

## Knowledge Gaps
- **7 isolated node(s):** `Arguments`, `user`, `assistant`, `SpatialObservation`, `SpatialItem` (+2 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ScanEngine` connect `Community 4` to `Community 5`?**
  _High betweenness centrality (0.441) - this node is a cross-community bridge._
- **Why does `ContentView` connect `Community 3` to `Community 2`, `Community 5`?**
  _High betweenness centrality (0.435) - this node is a cross-community bridge._
- **Why does `Librarian` connect `Community 1` to `Community 5`?**
  _High betweenness centrality (0.272) - this node is a cross-community bridge._
- **What connects `Arguments`, `user`, `assistant` to the rest of the system?**
  _7 weakly-connected nodes found - possible documentation gaps or missing edges._