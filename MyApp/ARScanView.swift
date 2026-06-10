import SwiftUI
import ARKit
import RealityKit
import UIKit

struct ARScanView: UIViewRepresentable {
    let memory: RoomMemory
    let engine: ScanEngine
    @Binding var captureSignal: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(memory: memory, engine: engine)
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        if ARWorldTrackingConfiguration.isSupported {
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal, .vertical]
            arView.session.run(config)
        }
        arView.session.delegate = context.coordinator
        context.coordinator.arView = arView
        return arView
    }

    func updateUIView(_ arView: ARView, context: Context) {
        let coordinator = context.coordinator
        if captureSignal != coordinator.lastCaptureSignal {
            coordinator.lastCaptureSignal = captureSignal
            coordinator.capture()
        }
    }

    // MARK: - Coordinator: capture, beacons, per-frame guidance

    final class Coordinator: NSObject, ARSessionDelegate {
        weak var arView: ARView?
        let memory: RoomMemory
        let engine: ScanEngine
        var lastCaptureSignal = 0

        private var beacons: [UUID: ModelEntity] = [:]   // anchorID → sphere
        private var litAnchorIDs: Set<UUID> = []
        private var lastGuidanceUpdate = Date.distantPast
        private var lastHaptic = Date.distantPast
        private let haptics = UIImpactFeedbackGenerator(style: .medium)

        init(memory: RoomMemory, engine: ScanEngine) {
            self.memory = memory
            self.engine = engine
        }

        func capture() {
            guard let arView, let frame = arView.session.currentFrame else { return }

            // World position: center-screen raycast; fallback 0.7 m in front of camera
            let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
            let transform: simd_float4x4
            if let hit = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any).first {
                transform = hit.worldTransform
            } else {
                var fallback = matrix_identity_float4x4
                fallback.columns.3.z = -0.7
                transform = frame.camera.transform * fallback
            }

            let anchor = ARAnchor(transform: transform)
            arView.session.add(anchor: anchor)
            addBeacon(for: anchor.identifier, at: transform, in: arView)

            engine.enqueue(pixelBuffer: frame.capturedImage, anchorID: anchor.identifier)
            haptics.impactOccurred()
        }

        private func addBeacon(for anchorID: UUID, at transform: simd_float4x4, in arView: ARView) {
            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 0.03),
                materials: [UnlitMaterial(color: UIColor.white.withAlphaComponent(0.5))]
            )
            let anchorEntity = AnchorEntity(world: transform)
            anchorEntity.addChild(sphere)
            arView.scene.addAnchor(anchorEntity)
            beacons[anchorID] = sphere
        }

        // MARK: Per-frame: light up finished beacons, pulse + guide toward focus

        // ARKit delivers frames on the main queue; entering the main actor
        // synchronously (no hop) is required here — an async hop queues ARFrames
        // and starves the camera ("delegate is retaining N ARFrames").
        nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
            MainActor.assumeIsolated { handleFrame(frame) }
        }

        private var storedCache: (entryCount: Int, ids: Set<UUID>) = (0, [])

        private func handleFrame(_ frame: ARFrame) {
            if storedCache.entryCount != memory.entries.count {
                storedCache = (memory.entries.count, memory.anchorIDsWithEntries)
            }
            let stored = storedCache.ids
            for (anchorID, sphere) in beacons where !litAnchorIDs.contains(anchorID) {
                if stored.contains(anchorID) {
                    sphere.model?.materials = [UnlitMaterial(color: .systemCyan)]
                    litAnchorIDs.insert(anchorID)
                }
            }

            guard let focusID = memory.focusedAnchorID else {
                if memory.guidanceText != nil { memory.guidanceText = nil }
                if memory.focusScreenPoint != nil {
                    memory.focusScreenPoint = nil
                    memory.focusIsOnScreen = false
                }
                resetBeaconScales()
                return
            }
            guard let anchor = frame.anchors.first(where: { $0.identifier == focusID }) else { return }

            // Pulse the focused beacon
            let pulse = 1.6 + 0.6 * sin(Float(Date.timeIntervalSinceReferenceDate * 5))
            for (anchorID, sphere) in beacons {
                sphere.scale = anchorID == focusID ? SIMD3(repeating: pulse) : .one
            }

            let (text, alignment) = Self.guidance(to: anchor, from: frame)
            updateTargetMarker(for: anchor, alignment: alignment)

            // Throttle UI text to ~5 Hz
            if Date().timeIntervalSince(lastGuidanceUpdate) > 0.2 {
                lastGuidanceUpdate = Date()
                memory.guidanceText = text
            }

            // Haptic pulses quicken as the camera turns toward the target
            let interval = 0.12 + 0.55 * Double(min(1, abs(alignment) / 0.5))
            if Date().timeIntervalSince(lastHaptic) > interval {
                lastHaptic = Date()
                haptics.impactOccurred(intensity: alignment.magnitude < 0.15 ? 1.0 : 0.6)
            }
        }

        /// Projects the target into screen space so SwiftUI can pin a named
        /// label on the object itself — or an edge arrow when it's off-screen.
        private func updateTargetMarker(for anchor: ARAnchor, alignment: Float) {
            guard let arView else { return }
            let t = anchor.transform.columns.3
            let world = SIMD3<Float>(t.x, t.y, t.z)

            memory.focusSide = alignment
            if let point = arView.project(world),
               abs(alignment) < 0.55,                       // roughly within the camera frustum
               arView.bounds.insetBy(dx: -40, dy: -40).contains(point) {
                memory.focusScreenPoint = point
                memory.focusIsOnScreen = true
            } else {
                memory.focusIsOnScreen = false
                memory.focusScreenPoint = nil
            }
        }

        private func resetBeaconScales() {
            for sphere in beacons.values where sphere.scale != .one {
                sphere.scale = .one
            }
        }

        /// Camera-space direction math: distance + left/right/ahead, returns
        /// the guidance string and the signed lateral alignment (0 = centered).
        static func guidance(to anchor: ARAnchor, from frame: ARFrame) -> (String, Float) {
            let target = anchor.transform.columns.3
            let camTransform = frame.camera.transform
            let camPos = camTransform.columns.3
            let delta = SIMD3<Float>(target.x - camPos.x, target.y - camPos.y, target.z - camPos.z)
            let dist = simd_length(delta)
            let right = SIMD3<Float>(camTransform.columns.0.x, camTransform.columns.0.y, camTransform.columns.0.z)
            let side = simd_dot(simd_normalize(delta), simd_normalize(right))
            let direction = side > 0.25 ? "to your right" : side < -0.25 ? "to your left" : "straight ahead"
            return (String(format: "%.1f meters, %@", dist, direction), side)
        }
    }
}
