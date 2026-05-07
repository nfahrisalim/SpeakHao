//
//  SpeechBubbleComponents.swift
//  SpeakHao
//
//  Created by SpeakHao Team on 05/07/26.
//
import SwiftUI

// MARK: - Speech Bubble User Component

struct SpeechBubbleUser: View {
    
    @Binding var pinyinText: String
    @Binding var chineseText: String
    @Binding var translationText: String

    // FIX: tambahkan callback agar parent bisa handle aksi Send
    var onSend: (() -> Void)? = nil
    
    var body: some View {
        
        let isEmpty = pinyinText.isEmpty &&
                      chineseText.isEmpty &&
                      translationText.isEmpty
        
        HStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                
                // TEXT AREA (SCROLLABLE)
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        
                        if !pinyinText.isEmpty {
                            Text(pinyinText)
                                .font(.system(size: 16))
                                .foregroundColor(.black.opacity(0.7))
                        }
                        
                        if !chineseText.isEmpty {
                            Text(chineseText)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        if !translationText.isEmpty {
                            Text(translationText)
                                .font(.system(size: 16).italic())
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                }
                .frame(maxHeight: 120)
                
                // ACTION BUTTONS
                HStack {
                    
                    // DELETE
                    Button(action: {
                        pinyinText = ""
                        chineseText = ""
                        translationText = ""
                    }) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(isEmpty ? .gray.opacity(0.8) : .gray)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.6))
                            .clipShape(Circle())
                            .font(Font.system(size: 23))
                    }
                    .shadow(color: .black.opacity(0.2), radius: 0, x: 0, y: 0)
                    .disabled(isEmpty)
                    
                    Spacer()
                    
                    // SEND — FIX: panggil onSend callback, bukan hanya print
                    Button(action: {
                        onSend?()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "paperplane.fill")
                            Text("Send")
                        }
                        .font(.system(size: 17, weight: .medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(isEmpty ? Color.gray.opacity(0.5) : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                    .disabled(isEmpty)
                }
            }
            .padding(14)
            .frame(maxWidth: 400)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.white)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                .overlay(alignment: .bottomTrailing) {
                    BubbleTail()
                        .fill(Color.white)
                        .frame(width: 40, height: 12)
                        .rotationEffect(.degrees(180))
                        .offset(x: -30, y: 10)
                }
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Bubble Tail Shape

struct BubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX + rect.width * 0.30, y: rect.maxY),
            control2: CGPoint(x: rect.midX - rect.width * 0.10, y: rect.minY)
        )
        
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control1: CGPoint(x: rect.midX + rect.width * 0.10, y: rect.minY),
            control2: CGPoint(x: rect.maxX - rect.width * 0.30, y: rect.maxY)
        )
        
        path.closeSubpath()
        return path
    }
}
