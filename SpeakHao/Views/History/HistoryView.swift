//
//  HistoryView.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/12/26.
//
import SwiftUI

struct HistoryView: View {
    let messages: [ConversationMessage]
    let scenarioDescription: String
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 0.949, green: 0.949, blue: 0.969)
                .ignoresSafeArea()

            // Title
            Text("History")
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.top, 16)

            ScrollView {
                VStack(spacing: 16) {
                    // Intro card with scenario description
                    Text(scenarioDescription)
                        .font(.system(size: 17))
                        .foregroundColor(.black)
                        .padding(20)
                        .frame(width: 348, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 35)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.15), radius: 4)
                        )

                    // Chat bubbles from messages
                    ForEach(messages) { message in
                        ChatBubble(
                            pinyin: message.pinyinText,
                            hanzi: message.chineseText,
                            translation: message.englishText,
                            isUser: message.role == .user
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 80)
                .padding(.bottom, 40)
            }

            // Back button
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.65))
                            .shadow(color: Color.black.opacity(0.12), radius: 20, y: 8)
                    )
            }
            .padding(.leading, 27)
            .padding(.top, 20)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ChatBubble: View {
    let pinyin: String
    let hanzi: String
    let translation: String
    let isUser: Bool

    var body: some View {
        VStack(alignment: isUser ? .trailing : .leading, spacing: 8) {
            Text(pinyin)
                .font(.system(size: 16))
                .foregroundColor(.black)
            Text(hanzi)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
            Text(translation)
                .font(.system(size: 16))
                .italic()
                .foregroundColor(Color(red: 0.447, green: 0.447, blue: 0.447))
        }
        .multilineTextAlignment(isUser ? .trailing : .leading)
        .padding(20)
        .frame(width: isUser ? 328 : 305, alignment: isUser ? .trailing : .leading)
        .background(
            RoundedRectangle(cornerRadius: 38)
                .fill(Color.white.opacity(0.84))
                .shadow(color: Color.black.opacity(0.15), radius: 2)
        )
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
    }
}

#Preview {
    HistoryView(
        messages: [
            ConversationMessage(
                role: .npc,
                chinese: "李女士，早上好，您好吗？",
                pinyin: "Lǐ nǚshì, zǎoshang hǎo, nín hǎo ma?",
                english: "Good morning Ms Li, how are you?"
            ),
            ConversationMessage(
                role: .user,
                chinese: "我很好，您呢？",
                pinyin: "Wǒ hěn hǎo, nín ne?",
                english: "I'm fine, how about you?"
            )
        ],
        scenarioDescription: "You introduce yourself to your new coworkers and the workplace."
    )
}

