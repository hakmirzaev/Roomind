# Roomind

**A private, on-device spatial memory for the physical world.**
Built solo in 3 hours at Bitrig Hacks: WWDC Edition (June 10, 2026).

> Spotlight indexed your files. Roomind indexes your room.

Sweep your iPhone across a space once — every object, label, and handwritten
note becomes something you can ask about, point to, and find again.
**Entirely offline.** Footage of your home never leaves the device.

## Why this is new

Three days ago this required a cloud vision API, an API key, and sending
pictures of your home to someone else's datacenter. The enabling APIs all
shipped in iOS 27 beta 1 this week:

| API (WWDC26) | Use here |
|---|---|
| Multimodal prompting — `Attachment(cgImage, orientation:)` | The on-device foundation model *sees* each captured view |
| `OCRTool` (Vision ↔ FoundationModels cross-import overlay) | The model calls Vision itself to read labels & handwriting verbatim |
| `DynamicProfile` | Two agents, one primitive: **Scanner** (terse extraction) ↔ **Librarian** (answers only from memory) |
| `.model(PrivateCloudComputeLanguageModel()).reasoningLevel(.deep)` | "Think deeper" toggle — same session code, frontier-scale model, zero API keys |
| `@Generable` + custom `Tool` | Structured extraction in, tool-based retrieval out |
| CoreSpotlight | Every memorized object is donated to system Spotlight — search "water bottle" from the home screen, tap, and the app guides you to it |

## How it works

```
 Scan tab (ARKit + RealityKit)
   tap → ARFrame.capturedImage + center raycast → ARAnchor + beacon sphere
            │  downscale to ≤768 px (tokens cost money compute)
            ▼
 ScanEngine (serial queue, one model call in flight)
   Scanner profile: Instructions + OCRTool
   respond(generating: SpatialObservation.self) { prompt; Attachment(image) }
            ▼
 RoomMemory (in-memory store)  ──donate──▶  CoreSpotlight
   [anchorID : items, categories, readable text, scene summary]
            ▲
            │ RoomSearchTool.call(query) — memory lives OUTSIDE the prompt
 Ask tab (Librarian profile)               (on-device context is 8K)
   question → tool call → answer + matched thumbnail
            ▼
 "Find it" → AR beacon pulses + "1.2 meters, to your left"
   + haptics quicken as the camera aligns + spoken answer (accessibility)
```

Design decisions, pre-made:
- **Tool-based retrieval, never context-stuffing** — scales past the 8K on-device window.
- **Fresh Scanner session per frame** — transcripts never accumulate images.
- **One model call in flight** — beta-1 concurrency is unknown; serial is bulletproof.
- **Typed queries first; speech output built-in** — a flaky mic demo kills you, spoken answers don't.

## Who it's for

For a blind or low-vision person, "where did I put my medication?" is a daily
dependence on another human. Roomind turns one sweep of a phone into a private,
queryable memory of their own space — spoken answers, haptic pulses as the
phone turns toward the target, distance and direction guidance. On-device
matters *more* here, not less.

For everyone else: sweep your hotel room before checkout and ask
*"did I leave anything plugged in?"*

## Build & run

- **Xcode 27 beta** (iOS 27 SDK) — the stable Xcode cannot build this.
- iPhone with Apple Intelligence **enabled and model downloaded**
  (Settings → Apple Intelligence & Siri). The app diagnoses and explains
  the exact reason if the model is unavailable.
- Open `Untitled Project.xcodeproj`, scheme **MyApp**, run on a physical
  iPhone (ARKit + the OCR tool don't exist on the simulator).

## Roadmap

`ARWorldMap` persistence → memories that survive relaunch · SpeechTranscriber
voice queries · visionOS: persistent room memory + Environment Occlusion +
spatial-audio beacons.
