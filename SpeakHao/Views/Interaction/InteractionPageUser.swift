//
//  InteractionPageUser.swift
//  SpeakHao
//
//  Created by Ririn Ayuning Riani on 03/05/26.
//

import SwiftUI
import AVFoundation

struct InteractionPageUser: View {
    @State private var goToMainMenu = false
    @State private var isPressed = false
    @State private var pinyin = ""
    @State private var chinese = ""
    @State private var translation = ""
    @Environment(\.dismiss) var dismiss
    
    let onBackTapped: () -> Void
    let npcMessage: ConversationMessage
    let speechSynthesizer: AVSpeechSynthesizer
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    InteractionSceneView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                    
                    // Interaction Container
                    VStack(spacing: 12) {
                        // Top Bar
                        NavigationBar(
                            onBack: {
                                print("Back tapped - going back to ConversationView")
                                onBackTapped()
                            },
                            onHistory: {
                                print("History tapped")
                            }
                        )
                        
                        Spacer()
                        
                        // MARK: - Container D (Speech Bubble)
                        SpeechBubbleUser(
                            pinyinText: $pinyin,
                            chineseText: $chinese,
                            translationText: $translation
                        )
                        .padding(.bottom, 12)
                        
                        // MARK: - Container P (button to repeat earlier question)
                        Button(action: {
                            print("Repeat tapped - speaking NPC message")
                            speakMessage(npcMessage)
                        }) {
                            Text("Please repeat what you said earlier")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                        }
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                        
                        // MARK: - Container E (Action Bar)
                        ActionBar(
                            isPressed: $isPressed,
                            onMainAction: {
                                print("Mic tapped")
                            },
                            onSecondaryAction: {
                                print("Vocabulary tapped")
                            }, isCircle: true
                        ) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        .padding(.bottom, -50)
                        .padding(.top, -20)
                    }
                }
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .navigationBar)
            }
            // ✅ Use navigationDestination(isPresented:) instead of deprecated NavigationLink(isActive:)
            .navigationDestination(isPresented: $goToMainMenu) {
                InteractionNPCView()
            }
        }
    }
    
    // MARK: - Text-to-Speech
    
    private func speakMessage(_ message: ConversationMessage) {
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: message.chineseText)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        speechSynthesizer.speak(utterance)
        print("🔊 Speaking: \(message.chineseText)")
    }
}



#Preview {
    InteractionPageUser(
        onBackTapped: {},
        npcMessage: ConversationMessage(role: .npc, chinese: "你好", pinyin: "Ni hao", english: "Hello"),
        speechSynthesizer: AVSpeechSynthesizer()
    )
}
