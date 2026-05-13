//
//  Conversationview.swift
//  SpeakHao
//
//  Created by SpeakHao Team on 05/06/26.
//
import SwiftUI

struct ConversationView: View {

    @StateObject private var vm: InteractionViewModel
    @Environment(\.dismiss) var dismiss

    @State private var isUserTurn          = false
    @State private var isPressed           = false
    @State private var showTranslation     = false
    @State private var speechBubbleVisible = false
    @State private var showBackAlert       = false
    @State private var showHistory         = false
    @State private var showDictionary      = false
    @State private var pinyin      = ""
    @State private var chinese     = ""
    @State private var translation = ""

    @State private var currentDisplayMessage: ConversationMessage

    let pinyinText: String
    let chineseText: String
    let translationText: String

    // MARK: - Init

    init(pinyin: String, chinese: String, translation: String,
         scenario: NPCScenario? = nil) {

        self.pinyinText      = pinyin
        self.chineseText     = chinese
        self.translationText = translation

        let activeScenario = scenario ?? ScenarioRegistry.all[0]
        _vm = StateObject(wrappedValue: InteractionViewModel(scenario: activeScenario))

        _currentDisplayMessage = State(initialValue: ConversationMessage(
            role: .npc,
            chinese: chinese,
            pinyin: pinyin,
            english: translation
        ))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            InteractionSceneView()
                .ignoresSafeArea()

            GeometryReader { geometry in
                VStack(spacing: 0) {
                    NavigationBar(
                        onBack: {
                            if isUserTurn {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isUserTurn = false
                                }
                            } else {
                                showBackAlert = true
                            }
                        },
                        onHistory: {
                            showHistory = true
                        }
                    )
                    .padding(.top, geometry.safeAreaInsets.top > 0 ? 0 : 20)

                    Spacer()

                    if !isUserTurn {
                        npcModeContent(geometry: geometry)
                    } else {
                        userModeContent()
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .ignoresSafeArea(.keyboard)
        }
        .navigationBarBackButtonHidden(true)

        .customAlert(
            isPresented: $showBackAlert,
            alert: PopUpData(
                icon: "pause.circle",
                iconColor: .black,
                title: "Conversation Paused",
                secondaryButtonTitle: "Resume Conversation",
                primaryButtonTitle: "Exit Conversation",
                secondaryAction: {
                    showBackAlert = false
                },
                primaryAction: {
                    showBackAlert = false
                    vm.stopSpeaking()
                    dismiss()
                }
            )
        )
        .navigationDestination(isPresented: $showHistory) {
            HistoryView(
                messages: vm.messages,
                scenarioDescription: vm.scenario.description
            )
        }
        .navigationDestination(isPresented: $showDictionary) {
            DictionaryPage()
        }
        .onChange(of: vm.pendingUserText) { _, newValue in
            if !newValue.isEmpty {
                chinese     = newValue
                pinyin      = ""
                translation = ""
            }
        }

        .onChange(of: vm.messages.count) { _, _ in
            guard
                let latestNPC = vm.messages.last(where: { $0.role == .npc }),
                latestNPC.id != currentDisplayMessage.id
            else { return }

            currentDisplayMessage = latestNPC

            chinese     = ""
            pinyin      = ""
            translation = ""
            withAnimation(.easeInOut(duration: 0.3)) {
                isUserTurn = false
            }
        }

        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4)) {
                speechBubbleVisible = true
            }
        }
    }

    // MARK: - NPC Mode Content

    @ViewBuilder
    private func npcModeContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            SpeechBubbleView(
                pinyinText:      currentDisplayMessage.pinyinText,
                chineseText:     currentDisplayMessage.chineseText,
                translationText: currentDisplayMessage.englishText,
                showTranslation: $showTranslation
            )
            .padding(.horizontal, 40)
            .padding(.bottom, geometry.size.height * 0.2)
            .opacity(speechBubbleVisible ? 1 : 0)
            .offset(x: 5, y: -80)

            BottomActionBar(
                isPressed: $isPressed,
                onAnswerTap: {
                    chinese     = ""
                    pinyin      = ""
                    translation = ""
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isUserTurn = true
                    }
                },
                onBookTap: { showDictionary = true }
            )
        }
    }

    // MARK: - User Mode Content

    @ViewBuilder
    private func userModeContent() -> some View {
        VStack(spacing: 12) {

            SpeechBubbleUser(
                pinyinText:      $pinyin,
                chineseText:     $chinese,
                translationText: $translation,
                onSend:          { vm.sendUserResponse() }
            )
            .padding(.bottom, 12)

            // "Repeat NPC" button
            Button(action: { vm.speakCurrentNPCMessage() }) {
                Text("Please repeat what you said earlier")
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
            }
            .background(Capsule().fill(.ultraThinMaterial))
            .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
            .padding(.horizontal, 40)
            .padding(.bottom, 10)

            if vm.isGenerating {
                HStack(spacing: 6) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                    Text("NPC is responding…")
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.85))
                }
                .transition(.opacity)
                .padding(.bottom, 4)
            }

            ActionBar(
                isPressed: $isPressed,
                onMainAction: {  },
                onSecondaryAction: { showDictionary = true },
                isCircle: true
            ) {
                Image(systemName: vm.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .onLongPressGesture(
                        minimumDuration: .infinity,
                        pressing: { isPressing in
                            if isPressing {
                                vm.startRecording()
                            } else {
                                vm.stopRecording()
                            }
                        },
                        perform: { /* unreachable */ }
                    )
            }
            .padding(.bottom, -50)
            .padding(.top, -20)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ConversationView(
            pinyin:      "Lǐ nǚshì, zǎoshang hǎo, nín hǎo ma?",
            chinese:     "李女士，早上好，您好吗？",
            translation: "Ms. Li, good morning, how are you?"
        )
    }
}
