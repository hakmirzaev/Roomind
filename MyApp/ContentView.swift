import SwiftUI

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
                AskScreen(librarian: librarian, onFind: find)
            }
            Tab("Memory", systemImage: "brain.head.profile", value: AppTab.recall) {
                MemoryScreen(memory: memory, onFind: find)
            }
        }
        .tint(.cyan)
    }

    /// "Find it": focus the matched anchor and jump to the AR view — the
    /// beacon pulses and guidance + haptics take over.
    private func find(_ entry: MemoryEntry) {
        memory.focusedAnchorID = entry.anchorID
        selectedTab = .scan
    }
}
