import SwiftUI

struct ScanScreen: View {
    let memory: RoomMemory
    let engine: ScanEngine
    @State private var captureSignal = 0
    @State private var flashOpacity = 0.0

    var body: some View {
        ZStack {
            ARScanView(memory: memory, engine: engine, captureSignal: $captureSignal)
                .ignoresSafeArea()

            Color.white
                .opacity(flashOpacity)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            reticle

            VStack(spacing: 10) {
                statusBar
                if let note = ScanEngine.availabilityNote {
                    banner(note, icon: "exclamationmark.triangle.fill", tint: .yellow)
                } else if let error = engine.lastError {
                    banner(error, icon: "xmark.octagon.fill", tint: .red)
                }
                Spacer()
                if let guidance = memory.guidanceText {
                    guidanceBanner(guidance)
                }
                captureBar
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
        }
        .font(.subheadline.weight(.medium))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .glassEffect()
        .animation(.snappy, value: engine.pendingCount)
        .animation(.snappy, value: memory.entries.count)
    }

    private func banner(_ text: String, icon: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(text)
                .font(.footnote.weight(.medium))
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassEffect(in: .rect(cornerRadius: 14))
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

    private var captureBar: some View {
        ZStack {
            if let thumbnail = engine.lastThumbnail {
                HStack {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 54, height: 54)
                        .clipShape(.rect(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.4)))
                    Spacer()
                }
            }
            Button {
                captureSignal += 1
                flashOpacity = 0.7
                withAnimation(.easeOut(duration: 0.35)) { flashOpacity = 0 }
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
}
