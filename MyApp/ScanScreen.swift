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
                .overlay { TargetMarkerLayer(memory: memory) }   // shares AR coordinates

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
                memory.clearFocus()
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

/// Pins the found object's name onto the object itself; when the target is
/// outside the camera view, a chevron at the screen edge points the way.
private struct TargetMarkerLayer: View {
    let memory: RoomMemory

    var body: some View {
        ZStack {
            if memory.focusedAnchorID != nil {
                if memory.focusIsOnScreen, let point = memory.focusScreenPoint {
                    VStack(spacing: 6) {
                        Text(memory.focusedItemName ?? "target")
                            .font(.callout.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .glassEffect()
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.cyan)
                        Circle()
                            .stroke(.cyan, lineWidth: 3)
                            .frame(width: 28, height: 28)
                            .shadow(color: .cyan.opacity(0.8), radius: 6)
                    }
                    .position(x: point.x, y: max(60, point.y - 44))
                    .animation(.linear(duration: 0.1), value: point)
                } else {
                    HStack {
                        if memory.focusSide < 0 {
                            edgeArrow("chevron.left.2")
                            Spacer()
                        } else {
                            Spacer()
                            edgeArrow("chevron.right.2")
                        }
                    }
                    .padding(.horizontal, 18)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func edgeArrow(_ symbol: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(.cyan)
                .symbolEffect(.pulse)
            Text(memory.focusedItemName ?? "target")
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .glassEffect()
        }
    }
}
