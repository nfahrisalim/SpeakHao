//
//  Speechsynthesisservice.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/4/26.
//

import Foundation
import Combine
import AVFoundation

@MainActor
class SpeechSynthesisService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {

    private let synthesizer = AVSpeechSynthesizer()

    @Published var isSpeaking = false

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Speak

    func speak(_ text: String, language: String = "zh-CN") {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
        try? session.setActive(true)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = bestVoice(for: language)
        utterance.rate = (language == "zh-CN") ? 0.45 : 0.52
        utterance.pitchMultiplier = 1.05
        utterance.volume = 1.0

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    // Voice Selection

    private func bestVoice(for language: String) -> AVSpeechSynthesisVoice? {
        let prefix = String(language.prefix(2))
        let all = AVSpeechSynthesisVoice.speechVoices()

        // Priority: premium → enhanced → default
        if let premium = all.first(where: {
            $0.language.hasPrefix(prefix) && $0.quality == .premium
        }) {
            return premium
        }

        if let enhanced = all.first(where: {
            $0.language.hasPrefix(prefix) && $0.quality == .enhanced
        }) {
            return enhanced
        }

        // Fallback — sistem pilih sendiri
        return AVSpeechSynthesisVoice(language: language)
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    // MARK: - AVSpeechSynthesizerDelegate

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                        didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                        didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false }
    }
}
