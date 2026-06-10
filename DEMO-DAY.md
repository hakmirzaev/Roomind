# Roomind — demo-day state (built 12:55–1:10 PM, June 10)

## What is BUILT and COMPILING (signed .app ready)

All five day-old APIs, verified against the actual iOS 27 beta-1 SDK interface files:

| Plan item | Status | Where |
|---|---|---|
| Multimodal `Attachment(cgImage, orientation: .right)` | ✅ built | ScanEngine.swift |
| `OCRTool()` (lives in `_Vision_FoundationModels` overlay — `import Vision` + `import FoundationModels`) | ✅ built | ScanEngine.swift |
| `DynamicProfile` — Scanner ↔ Librarian | ✅ built | ScanEngine.swift / Librarian.swift |
| `@Generable` + custom `RoomSearchTool` retrieval | ✅ built | Models.swift / Librarian.swift |
| `.model(PrivateCloudComputeLanguageModel()).reasoningLevel(.deep)` — "Think deeper" toggle | ✅ built | Librarian.swift + sparkles button on Ask screen |
| ARKit anchors + beacons + raycast capture | ✅ built | ARScanView.swift |
| Direction guidance ("1.2 meters, to your left") + haptics quicken on alignment | ✅ built | ARScanView.swift |
| Spoken answers (AVSpeechSynthesizer, speaker toggle) | ✅ built | Speaker.swift |
| Liquid-glass UI, 3 tabs: Scan / Ask / Memory | ✅ built | ScanScreen / AskScreen / MemoryScreen |

Not built (per cut ladder): voice *input* (SpeechTranscriber), ARWorldMap persistence. Both are Q&A talking points, not demo blockers.

## To get it on the phone (2 minutes)

1. Plug in + unlock the iPhone, trust this Mac if asked.
2. `./install-to-iphone.sh`
   — or open `Untitled Project.xcodeproj` in **Xcode-beta** (Downloads folder!) and hit Run.
3. Prereq from the plan: iOS 27 beta on the phone, Apple Intelligence ON, model downloaded.

## First-run test loop (do this BEFORE rehearsing)

1. Scan tab → point at a text-bearing object → tap shutter → watch "memorizing 1…" → count ticks up.
2. Memory tab → entry shows thumbnail + item chips + OCR'd text in summary.
3. Ask tab → "where is my water bottle" → answer + thumbnail + **Find it**.
4. Find it → jumps to Scan → cyan beacon pulses, banner shows distance + direction, haptics quicken as you aim at it.
5. **Time the scan latency.** If a frame takes >8 s, demo with 3 props, not 6.

## 90-second script (unchanged from plan §7, all beats live)

1. *(10 s)* Pitch + **airplane mode on camera**.
2. *(20 s)* Sweep the prop table — 4–5 taps. "Each tap: the on-device foundation model — image attachments, new Monday — catalogs the view and calls Apple's new OCR tool to read text verbatim. Pinned to a world anchor."
3. *(35 s)* "Where's my charger?" → answer card + thumbnail → **Find it** → beacon + "1.2 meters, to your left" + haptics. Then "what does the sticky note say?" → verbatim handwriting, **spoken aloud** (speaker toggle is on by default). "For a blind user this is independence — and it's their home, so it never leaves the device."
4. *(15 s)* "One `LanguageModelSession`, two **Dynamic Profiles** — Scanner and Librarian. And the same code runs on Private Cloud Compute by flipping this toggle" *(tap sparkles — Think deeper)*. "Still in airplane mode."
   ⚠️ Note: Think-deeper uses PCC = needs network. Flip airplane mode OFF first if you demo it, and say so — "this one beat uses Apple's free private cloud; everything else was offline."

## Judge Q&A (from plan §7, all still true)

- **Persistence?** ARWorldMap serialization is the documented next step; out of 3-hour scope by design.
- **Why not CoreML classifiers?** Closed vocabulary, no language. The model read handwriting and answers follow-ups.
- **Scaling?** Tool-based retrieval *because* on-device context is 8K — memory lives outside the prompt.
- **Vision Pro?** Persistent room memory + visionOS 27 Environment Occlusion + spatial-audio beacons.

## Known beta-1 runtime unknowns (pre-flagged, all have fallbacks)

- Per-frame model latency → capture is queued + async; UI never blocks. Counter shows progress.
- If `OCRTool` misbehaves → the model still reads text via the image itself; @Guide tells it to be verbatim.
- If portrait orientation looks wrong in thumbnails → flip `.right` → `.up` in ScanEngine.swift (two places).
- FREEZE at 2:40. Screen-record one clean run as insurance.
