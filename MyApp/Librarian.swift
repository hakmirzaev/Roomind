import FoundationModels
import Observation
import Foundation

// MARK: - Retrieval tool: memory lives OUTSIDE the prompt (8K on-device context)

struct RoomSearchTool: Tool {
    let name = "searchRoomMemory"
    let description = "Search everything memorized about this room. Returns matching objects with their stored details, readable text, and where they were seen."

    let memory: RoomMemory

    @Generable
    struct Arguments {
        @Guide(description: "Keywords for the object or text to find")
        var query: String
    }

    func call(arguments: Arguments) async throws -> String {
        let hits = await memory.search(arguments.query)
        guard !hits.isEmpty else { return "No memory of that in this room." }
        return hits.prefix(4).map { entry in
            "ENTRY \(entry.id.uuidString.prefix(6)): \(entry.observation.sceneSummary) Items: "
            + entry.observation.items
                .map { item in
                    item.readableText.isEmpty
                        ? "\(item.name) (\(item.detail))"
                        : "\(item.name) (\(item.detail)) — text: \"\(item.readableText)\""
                }
                .joined(separator: ", ")
        }.joined(separator: "\n")
    }
}

// MARK: - Librarian profile: answers only from memory, fully on-device

struct LibrarianProfile: LanguageModelSession.DynamicProfile {
    let memory: RoomMemory

    var body: some LanguageModelSession.DynamicProfile {
        Profile {
            Instructions(
                """
                You answer questions about a physical room using ONLY the
                room-search tool. Always search before answering. Be brief —
                one or two spoken-style sentences. If asked where something is,
                describe it and the view it was seen in. If the tool returns
                no memory, say you haven't seen it.
                """
            )
            RoomSearchTool(memory: memory)
        }
    }
}

// MARK: - Chat view model

struct ChatMessage: Identifiable {
    enum Role { case user, assistant }
    let id = UUID()
    let role: Role
    let text: String
    var match: MemoryEntry?
    var matchItemName: String?
}

@Observable
final class Librarian {
    let memory: RoomMemory

    var messages: [ChatMessage] = []
    var isThinking = false
    var speakAnswers = true

    private var session: LanguageModelSession

    init(memory: RoomMemory) {
        self.memory = memory
        session = LanguageModelSession(profile: LibrarianProfile(memory: memory))
    }

    func ask(_ question: String) async {
        let question = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, !isThinking else { return }

        messages.append(ChatMessage(role: .user, text: question))
        isThinking = true
        defer { isThinking = false }

        if let note = ScanEngine.availabilityNote {
            messages.append(ChatMessage(role: .assistant, text: note))
            return
        }

        do {
            let answer = try await session.respond(to: question).content
            // Anchor match: re-run our own search on the question — parsing entry
            // IDs out of model prose is fragile; this is deterministic.
            let match = memory.search(question).first
            messages.append(ChatMessage(
                role: .assistant,
                text: answer,
                match: match,
                matchItemName: match.map { memory.bestItemName(in: $0, query: question) }
            ))
            if speakAnswers { Speaker.shared.speak(answer) }
        } catch {
            messages.append(ChatMessage(
                role: .assistant,
                text: "I couldn't think about that: \(error.localizedDescription)"
            ))
        }
    }
}
