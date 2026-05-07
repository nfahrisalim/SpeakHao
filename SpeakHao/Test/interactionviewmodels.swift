//
//  interactionviewmodels.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/4/26.
//

import Foundation
import Combine
import AVFoundation  

@MainActor
class InteractionViewModel: ObservableObject {

    // MARK: - Services
    private let speechRecognition = SpeechRecognitionService()
    private let speechSynthesis   = SpeechSynthesisService()
    private let naturalLanguage   = NaturalLanguageService()
    private let foundationModels: FoundationModelsService

    // MARK: - State
    @Published var messages:       [ConversationMessage] = []
    @Published var pendingUserText = ""
    @Published var isRecording     = false
    @Published var isNPCSpeaking   = false
    @Published var isGenerating    = false
    @Published var errorMessage:   String?
    @Published var lastAnalysis:   LanguageAnalysisResult?

    private var scenario: NPCScenario

    // FIX B: Combine sink that live-mirrors transcription → pendingUserText.
    // Created in startRecording, cancelled in stopRecording.
    private var transcriptionSink: AnyCancellable?

    // MARK: - Init

    init(scenario: NPCScenario) {
        self.scenario      = scenario
        self.foundationModels = FoundationModelsService(scenario: scenario)
        messages.append(scenario.initialMessage)
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            speakMessage(scenario.initialMessage)
        }
    }

    // MARK: - Recording

    func startRecording() {
        // FIX A: guard here uses isRecording that is set synchronously below,
        // so a second tap that arrives before the Task executes is rejected.
        guard !isRecording else { return }

        // FIX A: set flag on MainActor BEFORE spawning the Task.
        isRecording = true
        speechSynthesis.stopSpeaking()

        // FIX B: start mirroring live transcription into pendingUserText.
        // receive(on: RunLoop.main) ensures UI updates happen on the main thread
        // even if SpeechRecognitionService publishes from a background queue.
        transcriptionSink = speechRecognition.$transcribedText
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                guard let self, self.isRecording else { return }
                self.pendingUserText = text
            }

        Task {
            do {
                try await speechRecognition.startRecording(useChinese: true)
                // isRecording is already true; nothing to set here.
            } catch {
                // Revert on actual error so the button doesn't stay in
                // "recording" state with no engine running.
                isRecording    = false
                transcriptionSink = nil
                errorMessage   = error.localizedDescription
            }
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        // FIX A: set flag immediately so any rapid re-entry is rejected.
        isRecording = false

        // FIX B: cancel the live mirror before stopping the engine.
        transcriptionSink = nil

        // Ask the recognition engine to stop.
        speechRecognition.stopRecording()

        // FIX C: give the recognition engine 150 ms to deliver its final
        // segment before we do a definitive read. This runs on the MainActor
        // so it doesn't block the UI thread.
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 150_000_000) // 0.15 s
            let finalText = speechRecognition.transcribedText
            // Only overwrite if the engine produced something and the live
            // sink hasn't already set a longer result (prefer the longer one).
            if finalText.count > pendingUserText.count {
                pendingUserText = finalText
            }
        }
    }

    // Kept for callers (e.g. InteractionPageNpc) that relay live transcription
    // via onReceive(vm.transcribedTextPublisher). ConversationView no longer
    // calls this; it reacts to onChange(of: vm.pendingUserText) instead.
    func updateLiveTranscription(_ text: String) {
        pendingUserText = text
    }

    // MARK: - Send Response

    func sendUserResponse() {
        // FIX D: reject the call if a generation is already in flight.
        guard !isGenerating else { return }

        let text = pendingUserText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let analysis  = naturalLanguage.analyze(userText: text)
        lastAnalysis  = analysis

        let langLabel = analysis.detectedLanguage ?? "unknown"
        let userMessage = ConversationMessage(
            role:    .user,
            chinese: text,
            pinyin:  "Lang: \(langLabel) · \(analysis.tokens.prefix(5).joined(separator: " "))",
            english: analysis.isRelevantToContext ? "✓ On topic" : "⚠ Off topic"
        )
        messages.append(userMessage)
        pendingUserText = ""   // clears the Kirim button in ConversationView

        isGenerating = true
        Task {
            let npcReply = await foundationModels.generateResponse(
                to: text,
                languageAnalysis: analysis
            )
            isGenerating = false
            messages.append(npcReply)
            speakMessage(npcReply)
        }
    }

    func deleteLastUserInput() {
        pendingUserText = ""
        if messages.last?.role == .user {
            messages.removeLast()
        }
    }

    // MARK: - TTS

    func speakMessage(_ message: ConversationMessage) {
        // FIX AUDIO: Paksa AVAudioSession beralih ke .playback sebelum TTS.
        // Ini menyelesaikan bug diam setelah rekam: AVAudioSession bisa tersangkut
        // di mode .record/.playAndRecord milik SpeechRecognitionService, sehingga
        // AVSpeechSynthesizer tidak bisa memutar suara.
        //
        // Delay 200 ms memberi waktu engine speech recognition benar-benar
        // melepas audio hardware sebelum kita mengaktifkan sesi playback.
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 s

            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default, options: [])
                try session.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                // Jika gagal set session, tetap coba speak — lebih baik
                // daripada tidak bersuara sama sekali.
                print("[InteractionViewModel] AVAudioSession setCategory error: \(error)")
            }

            let language = message.role == .npc ? "zh-CN" : "en-US"
            speechSynthesis.speak(message.chineseText, language: language)
            isNPCSpeaking = speechSynthesis.isSpeaking
        }
    }

    func speakCurrentNPCMessage() {
        guard let lastNPC = messages.last(where: { $0.role == .npc }) else { return }
        speakMessage(lastNPC)
    }

    func stopSpeaking() {
        speechSynthesis.stopSpeaking()
        isNPCSpeaking = false
    }

    func reset() {
        transcriptionSink = nil
        messages          = []
        foundationModels.reset()
        pendingUserText   = ""
        errorMessage      = nil
        isRecording       = false
        isGenerating      = false
        speechSynthesis.stopSpeaking()
        speechRecognition.stopRecording()
    }

    // MARK: - Publisher (kept for InteractionPageNpc compatibility)

    var transcribedTextPublisher: Published<String>.Publisher {
        speechRecognition.$transcribedText
    }
}
