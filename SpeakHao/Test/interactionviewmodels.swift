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

    @Published var messages:       [ConversationMessage] = []
    @Published var pendingUserText = ""
    @Published var isRecording     = false
    @Published var isNPCSpeaking   = false
    @Published var isGenerating    = false
    @Published var errorMessage:   String?
    @Published var lastAnalysis:   LanguageAnalysisResult?

    private var scenario: NPCScenario

    private var transcriptionSink: AnyCancellable?

    // Init

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
        guard !isRecording else { return }
        isRecording = true
        speechSynthesis.stopSpeaking()

        transcriptionSink = speechRecognition.$transcribedText
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                guard let self, self.isRecording else { return }
                self.pendingUserText = text
            }

        Task {
            do {
                try await speechRecognition.startRecording(useChinese: true)

            } catch {
                isRecording    = false
                transcriptionSink = nil
                errorMessage   = error.localizedDescription
            }
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        isRecording = false

        transcriptionSink = nil

        speechRecognition.stopRecording()

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 150_000_000)
            let finalText = speechRecognition.transcribedText
            if finalText.count > pendingUserText.count {
                pendingUserText = finalText
            }
        }
    }

    func updateLiveTranscription(_ text: String) {
        pendingUserText = text
    }

    func sendUserResponse() {
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
        pendingUserText = ""

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
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000_000)

            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default, options: [])
                try session.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                // Silently handle audio session errors
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


    var transcribedTextPublisher: Published<String>.Publisher {
        speechRecognition.$transcribedText
    }
}
