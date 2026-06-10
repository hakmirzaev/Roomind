import SwiftUI

struct MemoryScreen: View {
    let memory: RoomMemory
    let onFind: (MemoryEntry) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if memory.entries.isEmpty {
                    ContentUnavailableView {
                        Label("Nothing memorized yet", systemImage: "brain.head.profile")
                    } description: {
                        Text("Sweep the Scan tab across the room — every view becomes a memory you can search.")
                    }
                } else {
                    List(memory.entries.reversed()) { entry in
                        EntryRow(entry: entry, onFind: onFind)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Room memory")
        }
    }
}

private struct EntryRow: View {
    let entry: MemoryEntry
    let onFind: (MemoryEntry) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let thumbnail = entry.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 72, height: 72)
                    .clipShape(.rect(cornerRadius: 14))
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.observation.sceneSummary)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)
                FlowChips(items: entry.observation.items.map(\.name))
                Text(entry.date, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer(minLength: 0)
            Button {
                onFind(entry)
            } label: {
                Image(systemName: "location.north.line.fill")
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
}

private struct FlowChips: View {
    let items: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(items.prefix(6), id: \.self) { name in
                    Text(name)
                        .font(.caption)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(.tint.opacity(0.14), in: .capsule)
                }
            }
        }
    }
}
