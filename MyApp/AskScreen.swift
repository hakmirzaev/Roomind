import SwiftUI

struct AskScreen: View {
    let librarian: Librarian
    let onFind: (MemoryEntry, String?) -> Void

    @State private var draft = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if librarian.messages.isEmpty {
                    emptyState
                } else {
                    messageList
                }
                inputBar
            }
            .navigationTitle("Ask the room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Toggle(isOn: Bindable(librarian).speakAnswers) {
                        Image(systemName: librarian.speakAnswers ? "speaker.wave.2.fill" : "speaker.slash")
                    }
                    .toggleStyle(.button)
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Ask anything about this room", systemImage: "bubble.left.and.text.bubble.right")
        } description: {
            Text("“Where's my charger?” · “What does the sticky note say?” · “Did I leave anything plugged in?”")
        }
        .frame(maxHeight: .infinity)
    }

    private var messageList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                ForEach(librarian.messages) { message in
                    MessageBubble(message: message, onFind: onFind)
                }
                if librarian.isThinking {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("thinking…")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding()
        }
        .defaultScrollAnchor(.bottom)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Where is my…", text: $draft)
                .textFieldStyle(.plain)
                .focused($inputFocused)
                .onSubmit(send)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .glassEffect()

            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
            }
            .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty || librarian.isThinking)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func send() {
        let question = draft
        draft = ""
        Task { await librarian.ask(question) }
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    let onFind: (MemoryEntry, String?) -> Void

    var body: some View {
        switch message.role {
        case .user:
            Text(message.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.tint, in: .rect(cornerRadius: 18))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
        case .assistant:
            VStack(alignment: .leading, spacing: 10) {
                Text(message.text)
                if let match = message.match {
                    HStack(spacing: 12) {
                        if let thumbnail = match.thumbnail {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 64, height: 64)
                                .clipShape(.rect(cornerRadius: 12))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(match.observation.sceneSummary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            Button {
                                onFind(match, message.matchItemName)
                            } label: {
                                Label("Find it", systemImage: "location.north.line.fill")
                                    .font(.callout.weight(.semibold))
                            }
                            .buttonStyle(.glassProminent)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassEffect(in: .rect(cornerRadius: 18))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
