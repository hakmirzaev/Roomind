# Graph Report - .  (2026-06-10)

## Corpus Check
- 9 files · ~2,607 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 71 nodes · 91 edges · 7 communities detected
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 9 edges (avg confidence: 0.8)
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
1. `Coordinator` - 10 edges
2. `ScanEngine` - 6 edges
3. `Librarian` - 5 edges
4. `ARScanView` - 5 edges
5. `LibrarianProfile` - 4 edges
6. `RoomMemory` - 4 edges
7. `ContentView` - 4 edges
8. `AppTab` - 4 edges
9. `AskScreen` - 3 edges
10. `RoomSearchTool` - 3 edges

## Surprising Connections (you probably didn't know these)
- `ContentView` --inherits--> `View`  [EXTRACTED]
  MyApp/ContentView.swift →   _Bridges community 1 → community 5_
- `LibrarianProfile` --inherits--> `LanguageModelSession.DynamicProfile`  [EXTRACTED]
  MyApp/Librarian.swift →   _Bridges community 3 → community 4_
- `AppTab` --case_of--> `ask`  [EXTRACTED]
  MyApp/ContentView.swift → MyApp/ContentView.swift  _Bridges community 6 → community 1_

## Communities

### Community 0 - "Community 0"
Cohesion: 0.18
Nodes (5): ARScanView, Coordinator, ARSessionDelegate, NSObject, UIViewRepresentable

### Community 1 - "Community 1"
Cohesion: 0.19
Nodes (8): AskScreen, MessageBubble, ask, EntryRow, FlowChips, MemoryScreen, ScanScreen, View

### Community 2 - "Community 2"
Cohesion: 0.18
Nodes (6): Identifiable, ChatMessage, RoomSearchTool, MemoryEntry, Speaker, Tool

### Community 3 - "Community 3"
Cohesion: 0.28
Nodes (6): Arguments, Librarian, LibrarianProfile, Role, assistant, user

### Community 4 - "Community 4"
Cohesion: 0.33
Nodes (4): LanguageModelSession.DynamicProfile, Job, ScanEngine, ScannerProfile

### Community 5 - "Community 5"
Cohesion: 0.25
Nodes (4): ContentView, RoomMemory, SpatialItem, SpatialObservation

### Community 6 - "Community 6"
Cohesion: 0.33
Nodes (5): App, AppTab, recall, scan, RoomindApp

## Knowledge Gaps
- **7 isolated node(s):** `Arguments`, `user`, `assistant`, `SpatialObservation`, `SpatialItem` (+2 more)
  These have ≤1 connection - possible missing edges or undocumented components.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ContentView` connect `Community 5` to `Community 1`, `Community 6`?**
  _High betweenness centrality (0.447) - this node is a cross-community bridge._
- **Why does `ScanEngine` connect `Community 4` to `Community 5`?**
  _High betweenness centrality (0.421) - this node is a cross-community bridge._
- **Why does `Librarian` connect `Community 3` to `Community 2`, `Community 5`?**
  _High betweenness centrality (0.299) - this node is a cross-community bridge._
- **What connects `Arguments`, `user`, `assistant` to the rest of the system?**
  _7 weakly-connected nodes found - possible documentation gaps or missing edges._