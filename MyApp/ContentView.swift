import SwiftUI
import CoreSpotlight

@main
struct RoomindApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var memory = RoomMemory()
    @State private var engine: ScanEngine
    @State private var librarian: Librarian
    @State private var selectedTab: AppTab = .scan

    enum AppTab { case scan, ask, recall }

    init() {
        let memory = RoomMemory()
        _memory = State(initialValue: memory)
        _engine = State(initialValue: ScanEngine(memory: memory))
        _librarian = State(initialValue: Librarian(memory: memory))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Scan", systemImage: "camera.viewfinder", value: AppTab.scan) {
                ScanScreen(memory: memory, engine: engine)
            }
            Tab("Ask", systemImage: "bubble.left.and.text.bubble.right", value: AppTab.ask) {
                AskScreen(librarian: librarian, onFind: find(_:itemName:))
            }
            Tab("Memory", systemImage: "brain.head.profile", value: AppTab.recall) {
                MemoryScreen(memory: memory, onFind: find(_:itemName:))
            }
        }
        .tint(.cyan)
        .task {
            // Anchors don't survive relaunch; drop stale Spotlight donations.
            SpotlightIndexer.clearAll()
        }
        .onContinueUserActivity(CSSearchableItemActionType) { activity in
            guard let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
                  let anchorID = UUID(uuidString: id),
                  let entry = memory.entry(forAnchor: anchorID) else { return }
            find(entry, itemName: nil)
        }
    }

    /// "Find it": focus the matched anchor and jump to the AR view — the
    /// named target marker, guidance and haptics take over.
    private func find(_ entry: MemoryEntry, itemName: String?) {
        memory.focus(on: entry, query: nil)
        if let itemName { memory.focusedItemName = itemName }
        selectedTab = .scan
    }
}
