import FoundationModels
import Vision   // activates the _Vision_FoundationModels overlay: OCRTool
import CoreImage
import UIKit
import Observation

// MARK: - Scanner profile (session 241 pattern: terse extraction + system OCR tool)

struct ScannerProfile: LanguageModelSession.DynamicProfile {
    var body: some LanguageModelSession.DynamicProfile {
        Profile {
            Instructions(
                """
                You catalog physical spaces for a memory assistant.
                List every distinct object you can see. Be terse and literal.
                Use the OCR tool to read any visible text verbatim.
                """
            )
            #if !targetEnvironment(simulator)
            OCRTool()   // _Vision_FoundationModels overlay isn't in the simulator SDK
            #endif
        }
    }
}

// MARK: - Serialized capture → model → memory pipeline

@Observable
final class ScanEngine {
    let memory: RoomMemory

    private(set) var pendingCount = 0
    private(set) var lastError: String?
    var modelAvailable: Bool { SystemLanguageModel.default.isAvailable }

    private struct Job {
        let cgImage: CGImage
        let anchorID: UUID
        let thumbnail: UIImage
    }

    private var queue: [Job] = []
    private var isProcessing = false
    private let ciContext = CIContext()

    init(memory: RoomMemory) {
        self.memory = memory
    }

    /// Downscales the AR frame (token cost — session 241: larger images cost more tokens),
    /// fixes portrait orientation, and queues it for the model. Never blocks the camera.
    func enqueue(pixelBuffer: CVPixelBuffer, anchorID: UUID) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let longEdge = max(ciImage.extent.width, ciImage.extent.height)
        let scale = min(1, 768 / longEdge)
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let cgImage = ciContext.createCGImage(scaled, from: scaled.extent) else { return }

        // capturedImage is sensor-landscape; .right is the portrait fix
        let thumbnail = UIImage(cgImage: cgImage, scale: 1, orientation: .right)

        queue.append(Job(cgImage: cgImage, anchorID: anchorID, thumbnail: thumbnail))
        pendingCount = queue.count + (isProcessing ? 1 : 0)
        pump()
    }

    /// One model call in flight at a time — beta-1 concurrency is an unknown; serial is bulletproof.
    private func pump() {
        guard !isProcessing, !queue.isEmpty else { return }
        isProcessing = true
        let job = queue.removeFirst()
        pendingCount = queue.count + 1

        Task {
            await process(job)
            isProcessing = false
            pendingCount = queue.count
            pump()
        }
    }

    private func process(_ job: Job) async {
        // Fresh session per frame: extraction is stateless and the on-device
        // context window is 8K — never let transcripts accumulate images.
        let session = LanguageModelSession(profile: ScannerProfile())
        do {
            let observation = try await session.respond(generating: SpatialObservation.self) {
                "Catalog this view of the room."
                Attachment(job.cgImage, orientation: .right)
            }.content

            memory.entries.append(MemoryEntry(
                anchorID: job.anchorID,
                observation: observation,
                thumbnail: job.thumbnail
            ))
        } catch {
            lastError = error.localizedDescription
        }
    }
}
