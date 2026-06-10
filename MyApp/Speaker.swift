import AVFoundation

/// Spoken answers — the accessibility beat. Three lines, as promised.
final class Speaker {
    static let shared = Speaker()
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.52
        synthesizer.speak(utterance)
    }
}
