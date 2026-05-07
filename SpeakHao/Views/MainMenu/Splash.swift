//
//  Splash.swift
//  SpeakHao
//
//  Created by UpaCha on 03/05/26.
//

import SwiftUI

struct Splash: View {
    @State private var showMenu = false

    var body: some View {
        Group {
            if showMenu {
                MainMenuSwipe2()
                    .navigationBarBackButtonHidden(true)
            } else {
                ZStack {
                    Color.white.ignoresSafeArea()
                    
                    Image("cth")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            showMenu = true
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        Splash()
    }
}
