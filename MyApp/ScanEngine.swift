import FoundationModels
import Vision   // activates the _Vision_FoundationModels overlay: OCRTool
import CoreImage
import UIKit
import Observation

// MARK: - Scanner profile (session 241 pattern: terse extraction + system OCR tool)

struct ScannerProfile: LanguageModelSession.DynamicProfile {
    var useOCRTool = true

    var body: some LanguageModelSession.DynamicProfile {
        Profile {
            Instructions(
                """
                You catalog physical spaces for a memory assistant.
                List every distinct object you can see, including furniture.
                Be terse and literal. Read any visible text verbatim.
                The captured photo is attached with label "1".
                """
            )
            #if !targetEnvironment(simulator)
            // _Vision_FoundationModels overlay isn't in the simulator SDK
            if useOCRTool {
                OCRTool()
            }
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
    private(set) var lastThumbnail: UIImage?
    var modelAvailable: Bool { SystemLanguageModel.default.isAvailable }

    /// Human-readable diagnosis + fix when the on-device model can't run.
    static var availabilityNote: String? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        case .unavailable(.deviceNotEligible):
            return "This iPhone can't run Apple Intelligence."
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Turn on Apple Intelligence: Settings → Apple Intelligence & Siri."
        case .unavailable(.modelNotReady):
            return "The on-device model is still downloading. Keep the phone on Wi-Fi and charging, then check Settings → Apple Intelligence & Siri."
        case .unavailable:
            return "The on-device model is unavailable right now."
        }
    }

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
        lastThumbnail = thumbnail

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
        if let note = Self.availabilityNote {
            lastError = note
            return
        }
        do {
            let observation: SpatialObservation
            do {
                observation = try await analyze(job, useOCRTool: true)
            } catch {
                // Beta-1 tool invocation can fail; the model also reads text
                // straight from the image. Never let one tool lose a memory.
                observation = try await analyze(job, useOCRTool: false)
            }

            let entry = MemoryEntry(
                anchorID: job.anchorID,
                observation: observation,
                thumbnail: job.thumbnail
            )
            memory.entries.append(entry)
            lastError = nil
            SpotlightIndexer.donate(entry)
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func analyze(_ job: Job, useOCRTool: Bool) async throws -> SpatialObservation {
        // Fresh session per frame: extraction is stateless and the on-device
        // context window is 8K — never let transcripts accumulate images.
        let session = LanguageModelSession(profile: ScannerProfile(useOCRTool: useOCRTool))
        return try await session.respond(generating: SpatialObservation.self) {
            "Catalog this view of the room."
            Attachment(job.cgImage, orientation: .right).label("1")
        }.content
    }
}
