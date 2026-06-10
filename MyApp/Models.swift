import FoundationModels
import UIKit
import Observation

// MARK: - Generable schema the on-device model fills in per captured frame

@Generable
struct SpatialObservation {
    @Guide(description: "Each physically distinct object visible in the image")
    var items: [SpatialItem]

    @Guide(description: "One short sentence describing this view")
    var sceneSummary: String
}

@Generable
struct SpatialItem {
    @Guide(description: "Short literal name, e.g. 'blue water bottle'")
    var name: String

    @Guide(description: "One of: electronics, document, food, personal, furniture, signage, other")
    var category: String

    @Guide(description: "Any readable text on the object, verbatim. Use the OCR tool for accuracy. Empty if none.")
    var readableText: String

    @Guide(description: "One short distinguishing detail (color, position, condition)")
    var detail: String
}

// MARK: - Memory store

struct MemoryEntry: Identifiable {
    let id = UUID()
    let anchorID: UUID            // ARAnchor.identifier
    let observation: SpatialObservation
    let thumbnail: UIImage?
    let date = Date()
}

@Observable
final class RoomMemory {
    var entries: [MemoryEntry] = []

    // Cross-screen state: which beacon the AR view should guide toward
    var focusedAnchorID: UUID?
    var guidanceText: String?

    var anchorIDsWithEntries: Set<UUID> { Set(entries.map(\.anchorID)) }

    func entry(forAnchor anchorID: UUID) -> MemoryEntry? {
        entries.first { $0.anchorID == anchorID }
    }

    private static let stopwords: Set<String> = [
        "the", "a", "an", "my", "is", "are", "was", "were", "where", "what",
        "did", "do", "does", "i", "me", "it", "in", "on", "of", "to", "and",
        "or", "any", "find", "there", "leave", "left", "say", "says"
    ]

    func search(_ query: String) -> [MemoryEntry] {
        let needles = query.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty && !Self.stopwords.contains($0) }
        guard !needles.isEmpty else { return [] }

        return entries
            .map { entry -> (MemoryEntry, Int) in
                let hay = (entry.observation.items
                    .map { "\($0.name) \($0.category) \($0.readableText) \($0.detail)" }
                    .joined(separator: " ") + " " + entry.observation.sceneSummary)
                    .lowercased()
                let score = needles.reduce(0) { $0 + (hay.contains($1) ? 1 : 0) }
                return (entry, score)
            }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .map(\.0)
    }
}
