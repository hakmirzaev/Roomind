import CoreSpotlight
import UniformTypeIdentifiers
import UIKit

/// "Spotlight indexed your files. Roomind indexes your room." — literally:
/// every memorized object is donated to system Spotlight, so searching
/// "water bottle" from the home screen finds a physical object and
/// deep-links back into the app to guide you to it.
enum SpotlightIndexer {
    static let domain = "room-memory"

    static func donate(_ entry: MemoryEntry) {
        let attributes = CSSearchableItemAttributeSet(contentType: .image)
        let names = entry.observation.items.map(\.name)
        attributes.title = names.prefix(3).joined(separator: ", ")
        attributes.contentDescription = entry.observation.sceneSummary
        attributes.keywords = names
            + entry.observation.items.map(\.category)
            + entry.observation.items.flatMap { $0.readableText.split(separator: " ").map(String.init) }
        attributes.thumbnailData = entry.thumbnail?.jpegData(compressionQuality: 0.5)

        let item = CSSearchableItem(
            uniqueIdentifier: entry.anchorID.uuidString,
            domainIdentifier: domain,
            attributeSet: attributes
        )
        CSSearchableIndex.default().indexSearchableItems([item])
    }

    /// AR anchors don't survive an app relaunch, so stale items would point nowhere.
    static func clearAll() {
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [domain])
    }
}
