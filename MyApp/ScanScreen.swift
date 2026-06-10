import SwiftUI

struct ScanScreen: View {
    let memory: RoomMemory
    let engine: ScanEngine
    @State private var captureSignal = 0

    var body: some View {
        ZStack {
            ARScanView(memory: memory, engine: engine, captureSignal: $captureSignal)
                .ignoresSafeArea()

            reticle

            VStack {
                statusBar
                Spacer()
                if let guidance = memory.guidanceText {
                    guidanceBanner(guidance)
                }
                captureButton
            }
            .padding()
        }
    }

    private var reticle: some View {
        RoundedRectangle(cornerRadius: 24)
            .stroke(.white.opacity(0.55), style: StrokeStyle(lineWidth: 1.5, dash: [10, 8]))
            .frame(width: 190, height: 190)
            .allowsHitTesting(false)
    }

    private var statusBar: some View {
        HStack(spacing: 14) {
            Label("\(memory.entries.count)", systemImage: "brain.head.profile")
                .contentTransition(.numericText())

            if engine.pendingCount > 0 {
                HStack(spacing: 6) {
                    ProgressView()
                        .controlSize(.small)
                    Text("memorizing \(engine.pendingCount)…")
                }
                .transition(.opacity)
            }

            if !engine.modelAvailable {
                Label("model unavailable", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.yellow)
            }
        }
        .font(.subheadline.weight(.medium))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .glassEffect()
        .animation(.snappy, value: engine.pendingCount)
        .animation(.snappy, value: memory.entries.count)
    }

    private func guidanceBanner(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "location.north.line.fill")
                .symbolEffect(.pulse)
            Text(text)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
            Button {
                memory.focusedAnchorID = nil
                memory.guidanceText = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .glassEffect()
        .padding(.bottom, 8)
    }

    private var captureButton: some View {
        Button {
            captureSignal += 1
        } label: {
            ZStack {
                Circle()
                    .stroke(.white, lineWidth: 4)
                    .frame(width: 74, height: 74)
                Circle()
                    .fill(.white)
                    .frame(width: 60, height: 60)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact, trigger: captureSignal)
        .accessibilityLabel("Memorize this view")
    }
}
