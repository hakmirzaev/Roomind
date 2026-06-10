# Graph Report - .  (2026-06-10)

## Corpus Check
- 10 files · ~5,229 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 84 nodes · 113 edges · 7 communities detected
- Extraction: 88% EXTRACTED · 12% INFERRED · 0% AMBIGUOUS · INFERRED: 13 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]

## God Nodes (most connected - your core abstractions)
1. `Coordinator` - 12 edges
2. `RoomMemory` - 8 edges
3. `ScanEngine` - 7 edges
4. `ARScanView` - 5 edges
5. `Librarian` - 4 edges
6. `ScanScreen` - 4 edges
7. `ContentView` - 4 edges
8. `AppTab` - 4 edges
9. `AskScreen` - 3 edges
10. `RoomSearchTool` - 3 edges

## Surprising Connections (you probably didn't know these)
- `ContentView` --inherits--> `View`  [EXTRACTED]
  MyApp/ContentView.swift →   _Bridges community 1 → community 5_
- `ScannerProfile` --inherits--> `LanguageModelSession.DynamicProfile`  [EXTRACTED]
  MyApp/ScanEngine.swift →   _Bridges community 2 → community 3_

## Communities

### Community 0 - "Community 0"
Cohesion: 0.17
Nodes (5): ARScanView, Coordinator, ARSessionDelegate, NSObject, UIViewRepresentable

### Community 1 - "Community 1"
Cohesion: 0.17
Nodes (8): AskScreen, MessageBubble, EntryRow, FlowChips, MemoryScreen, ScanScreen, TargetMarkerLayer, View

### Community 2 - "Community 2"
Cohesion: 0.17
Nodes (9): LanguageModelSession.DynamicProfile, Arguments, Librarian, LibrarianProfile, Role, assistant, user, RoomSearchTool (+1 more)

### Community 3 - "Community 3"
Cohesion: 0.22
Nodes (4): Job, ScanEngine, ScannerProfile, SpotlightIndexer

### Community 4 - "Community 4"
Cohesion: 0.29
Nodes (2): RoomMemory, Speaker

### Community 5 - "Community 5"
Cohesion: 0.2
Nodes (7): App, AppTab, ask, recall, scan, ContentView, RoomindApp

### Community 6 - "Community 6"
Cohesion: 0.33
Nodes (5): Identifiable, ChatMessage, MemoryEntry, SpatialItem, SpatialObservation

## Knowledge Gaps
- **7 isolated node(s):** `Arguments`, `user`, `assistant`, `SpatialObservation`, `SpatialItem` (+2 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ScanEngine` connect `Community 3` to `Community 2`?**
  _High betweenness centrality (0.449) - this node is a cross-community bridge._
- **Why does `ContentView` connect `Community 5` to `Community 1`, `Community 2`?**
  _High betweenness centrality (0.394) - this node is a cross-community bridge._
- **Why does `Librarian` connect `Community 2` to `Community 4`?**
  _High betweenness centrality (0.224) - this node is a cross-community bridge._
- **What connects `Arguments`, `user`, `assistant` to the rest of the system?**
  _7 weakly-connected nodes found - possible documentation gaps or missing edges._