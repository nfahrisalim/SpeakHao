import SwiftUI
import Translation

struct DictionaryPage: View {
    @State private var isButtonBouncing = false
    @State private var inputText: String = ""
    @State private var translatedText: String = ""
    @State private var showTranslation: Bool = false
    @State private var isSwapped: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 0.949, green: 0.949, blue: 0.969)
                .ignoresSafeArea()
            
            // Back button + title
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.65))
                                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
                        )
                }
                Spacer()
            }
            .padding(.horizontal, 27)
            .padding(.top, 20)
            
            Text("Dictionary")
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.top, 27)
            
            // Card with centered swap button overlay
            ZStack(alignment: .center) {
                // Card
                VStack(alignment: .leading, spacing: 0) {
                    Text(isSwapped ? "English (US)" : "Chinese (Mandarin, Simplified)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.top, 17)
                    
                    TextField("Enter text", text: $inputText)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 7)
                    
                    Spacer()
                    
                    Divider()
                        .background(Color(red: 0.898, green: 0.898, blue: 0.918))
                    
                    Text(isSwapped ? "Chinese (Mandarin, Simplified)" : "English (US)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isSwapped ? .black : Color(red: 0, green: 0.533, blue: 1))
                        .padding(.top, 13)
                    
                    Text(translatedText.isEmpty ? "Translation" : translatedText)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(
                            translatedText.isEmpty
                                ? Color(red: 0, green: 0.533, blue: 1).opacity(0.2)
                                : (isSwapped ? .black : Color(red: 0, green: 0.533, blue: 1))
                        )
                        .padding(.top, 7)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(width: 348, height: 343)
                .background(
                    RoundedRectangle(cornerRadius: 35)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 2)
                )
                
                // Swap button - centered overlay on divider
                Button(action: {
                    isSwapped.toggle()
                    let temp = inputText
                    inputText = translatedText
                    translatedText = temp
                    isButtonBouncing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        isButtonBouncing = false
                    }
                }) {
                    Image(systemName: "arrow.trianglehead.swap")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(Color(red: 0, green: 0.533, blue: 1))
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.65))
                                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
                        )
                        .scaleEffect(isButtonBouncing ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.1).repeatCount(2, autoreverses: true), value: isButtonBouncing)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(width: 348, height: 343)
            .padding(.horizontal, 27)
            .padding(.top, 122)
            .modifier(TranslationModifier(
                inputText: inputText,
                isSwapped: isSwapped,
                translatedText: $translatedText
            ))
            .onChange(of: inputText) {
                translatedText = ""
                showTranslation = !inputText.isEmpty
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    DictionaryPage()
}

struct TranslationModifier: ViewModifier {
    let inputText: String
    let isSwapped: Bool
    @Binding var translatedText: String

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.translationTask(
                source: isSwapped 
                    ? Locale.Language(identifier: "en") 
                    : Locale.Language(identifier: "zh"),
                target: isSwapped 
                    ? Locale.Language(identifier: "zh") 
                    : Locale.Language(identifier: "en")
            ) { session in
                guard !inputText.isEmpty else { return }
                do {
                    let response = try await session.translate(inputText)
                    translatedText = response.targetText
                } catch {
                    translatedText = ""
                }
            }
        } else {
            content
        }
    }
}
