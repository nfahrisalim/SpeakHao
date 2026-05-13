# SpeakHao 

**Master Mandarin Chinese through interactive, AI-powered conversation scenarios.**

SpeakHao is an iOS language learning app that combines real-time speech recognition, AI-powered NPC conversations, and interactive translation tools to help learners practice Mandarin Chinese in immersive dialogue scenarios.

## Overview

SpeakHao transforms language learning from rote memorization into dynamic, real-world conversation practice. Users engage with AI-controlled NPCs in contextual scenarios, receive instant feedback through speech recognition, and leverage on-device AI for realistic conversations. The app combines modern iOS frameworks with Apple Intelligence to create a seamless learning experience without requiring external API calls.

## Features

- **Interactive Conversation Scenarios** — Engage with AI-controlled NPCs in structured dialogue scenes (e.g., client meetings, restaurant orders, business negotiations)
- **Speech Recognition** — Press and hold the microphone button to record Mandarin speech; the app recognizes your input and advances the conversation
- **Text-to-Speech Playback** — Listen to natural-sounding Mandarin pronunciation with adjustable playback speed
- **Pinyin & Translation Display** — Every NPC response shows Simplified Chinese characters, pinyin romanization, and English translation
- **Built-in Dictionary** — Translate text between Chinese and English on-the-fly using Apple's Translation framework
- **Conversation History** — Replay past conversations with full context, perfect for review and reflection
- **Progress Tracking** — Unlock new scenarios as you advance through chapters
- **No External APIs** — Runs entirely on-device using Apple's Foundation Models and Speech frameworks

## App Flow

### 1. **Splash Screen**
   - 1-second intro animation with the SpeakHao logo
   - Smoothly transitions to Main Menu

### 2. **Main Menu (MainMenuSwipe)**
   - Browse scenario cards arranged by chapter
   - Each card displays:
     - Scenario title and difficulty
     - Brief description of the dialogue context
     - Lock/unlock status
   - Swipe through chapters to find scenarios
   - Tap a scenario to begin conversation

### 3. **Conversation View (NPC Mode)**
   - **NPC speaks first** with:
     - Speech bubble displaying pinyin (small, gray), Chinese characters (bold, black), and English translation (italic, blue)
     - Automatically plays audio for natural immersion
   - **Two action buttons:**
     - **Answer** — When ready to respond, tap to transition to User Mode
     - **Dictionary** — Quickly look up unfamiliar words mid-conversation

### 4. **Conversation View (User Mode)**
   - **Your turn to respond:**
     - Press and hold the microphone button to record your voice
     - Release to submit and wait for the NPC to respond
     - Your speech is transcribed and displayed in the speech bubble
   - **Repeat Button** — Tap to have the NPC repeat their last response
   - **Dictionary Access** — Still available for quick translations
   - NPC generates a contextually appropriate response and advances the conversation

### 5. **Dictionary Page**
   - **Language Selection:**
     - Top field: Input text in either Chinese or English
     - Bottom field: View real-time translation in the other language
   - **Swap Button** — Toggle between Chinese→English and English→Chinese modes
   - Uses Apple's **Translation framework** for accurate, on-device translations
   - Perfect for pausing mid-conversation to clarify vocabulary

### 6. **History Page**
   - **Scenario Context Card** — Shows the description of the scenario you just completed
   - **Full Conversation Replay:**
     - All NPC and user messages displayed in chronological order
     - Each message shows pinyin, Chinese, and English
     - NPC bubbles align left (green background), user bubbles align right (blue background)
   - **Review & Reinforce** — Study the conversation to reinforce learning
   - Back button to return to Main Menu

## Tech Stack

### Core Frameworks
- **SwiftUI** — Modern, declarative UI framework for iOS 17+
- **AVFoundation** — Audio recording and playback for microphone input and TTS
- **Speech Framework** — Real-time speech recognition for Mandarin and English

### AI & Translation
- **Foundation Models** — Apple Intelligence on-device LLM for generating contextually accurate NPC responses
- **Translation Framework** — Native on-device translation between Chinese and English (iOS 18+)
- **Natural Language Processing** — Semantic understanding for speech recognition and vocabulary analysis

### State Management & Architecture
- **Combine Framework** — Reactive data binding and async operations
- **MVVM Pattern** — Clean separation between Views, ViewModels, and Services
- **StateObject & Environment** — Efficient state propagation across the view hierarchy

## Screenshots

<div align="center">

### Main Menu — Browse Scenarios
![Main Menu](SpeakHao/Images/MainMenu.png)

### Conversation (NPC Mode) — Listen & Learn
![Interaction Page](SpeakHao/Images/Interaction%20page.png)

### Conversation (User Mode) — Speak & Respond
![Interaction Page - User](SpeakHao/Images/Interaction%20page%20-%20USER.png)

### Dictionary — Quick Translation
![Dictionary Page](SpeakHao/Images/Dictionary%20Page.png)

### History — Review & Reinforce
![History Page](SpeakHao/Images/History%20Page.png)

</div>

## Requirements

### Minimum iOS Version
- **iOS 17.6** — Core SwiftUI and AVFoundation features
- **iOS 18.0+** — Recommended for Translation Framework and Foundation Models support

### Required Permissions
- **Microphone Access** — To record your Mandarin speech during conversation
- **Speech Recognition** — To transcribe your recorded audio into text

## How to Use

### Starting a Conversation
1. Launch the app and browse the **Main Menu**
2. Swipe through scenario chapters
3. Tap an unlocked scenario card to begin

### During Conversation

#### NPC Mode (Listening)
- Read the NPC's message with pinyin, Chinese, and English
- Tap **Dictionary** if you see an unfamiliar word
- Tap **Answer** when ready to respond

#### User Mode (Speaking)
- **Press and hold** the microphone button
- Speak your Mandarin response clearly into the device
- Release the button to submit
- Wait for the NPC to generate and speak their reply

#### Review
- Tap **History** at any time to view the conversation transcript
- Tap back to return and continue the conversation

### Using the Dictionary
1. Tap **Dictionary** from the conversation screen
2. Enter text in either the Chinese or English field
3. View instant translation in the other field
4. Tap the **Swap button** to reverse direction
5. Go back to the conversation when done

## Development Roadmap

- [ ] Additional scenario packs (Restaurant, Hotel, Travel, etc.)
- [ ] User progress tracking & achievement badges
- [ ] Spaced repetition for vocabulary review
- [ ] Detailed pronunciation feedback
- [ ] Multi-regional accent support
- [ ] Offline mode with pre-cached models
- [ ] Community scenario contributions

## Known Limitations

- Speech recognition optimized for Mandarin; English recognition available for reference
- Translation Framework requires iOS 18+ (fallback UI gracefully disabled on iOS 17)
- Foundation Models require adequate on-device storage and processing power
- Scenarios are narrative-driven; users should have basic Chinese literacy

## Troubleshooting

### "Microphone Permission Denied"
- Go to **Settings → SpeakHao → Microphone** and toggle "Allow"
- Restart the app

### "Speech Recognition Unavailable"
- Ensure Mandarin language is available in **Settings → General → Language & Region**
- Check internet connectivity (recognition can use online models on some devices)
- Restart the app

### "Translation Not Available"
- Requires iOS 18.0 or later
- Check **Settings → General → Language & Region** for supported language pairs

### App Crashes on Startup
- Clear app cache: Go to **Settings → General → iPhone Storage → SpeakHao → Offload App**
- Reinstall: **Settings → General → iPhone Storage → SpeakHao → Delete App → Reinstall**

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit changes: `git commit -m 'Add new feature'`
4. Push: `git push origin feature/your-feature-name`
5. Open a Pull Request

## License

SpeakHao is provided as-is for educational purposes. See the included LICENSE file for details.

## Contact & Support

- **GitHub Issues** — Report bugs or request features
- **Email** — nfahrisalim@example.com
- **Discord** — Join our community for discussions and feedback

---
