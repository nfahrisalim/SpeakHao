//
//  Scenariomenubridge.swift
//  SpeakHao
//
//  Created by Muh. Naufal Fahri Salim on 5/6/26.
//

import SwiftUI

// MARK: - Chapter Card Model

struct ChapterCard: Identifiable {
    let id: Int
    let scenario: NPCScenario
    let characterImage: String
    let isLocked: Bool

    var title:   String { scenario.title }
    var preview: String { scenario.description }   // baca langsung dari NPCScenario.description
}

// MARK: - ScenarioRegistry Extension

extension ScenarioRegistry {
    static var chapterCards: [ChapterCard] {
        all.enumerated().map { index, scenario in
            ChapterCard(
                id: index + 1,
                scenario: scenario,
                characterImage: "character_idle",
                isLocked: index > 0
            )
        }
    }
}

// MARK: - MainMenuSwipe2

struct MainMenuSwipe2: View {

    @State private var selectedScenario: NPCScenario? = nil

    var body: some View {
        ZStack(alignment: .bottom) {

            Image("Background")
                .resizable()
                .scaleEffect(1.7)
                .offset(x: -140, y: -300)
                .ignoresSafeArea()

            TabView {
                ForEach(ScenarioRegistry.chapterCards) { card in
                    cardPage(card: card)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .ignoresSafeArea()
        }
        .navigationDestination(item: $selectedScenario) { scenario in
            let initialMessage = scenario.initialMessage
            return ConversationView(
                pinyin: initialMessage.pinyinText,
                chinese: initialMessage.chineseText,
                translation: initialMessage.englishText
            )
        }
    }

    @ViewBuilder
    private func cardPage(card: ChapterCard) -> some View {
        if card.isLocked {
            ZStack {
                MainMenuView(
                    chapterNumber:  card.id,
                    chapterTitle:   card.title,
                    chapterPreview: card.preview,
                    characterImage: card.characterImage
                )
                PopUpLocked()
            }
        } else {
            MainMenuView(
                chapterNumber:  card.id,
                chapterTitle:   card.title,
                chapterPreview: card.preview,
                characterImage: card.characterImage,
                onStart: {
                    selectedScenario = card.scenario
                }
            )
        }
    }
}

#Preview {
    NavigationStack {
        MainMenuSwipe2()
    }
}
