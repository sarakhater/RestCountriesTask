//
//  AppCoordinatorView.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//

import SwiftUI
import SwiftData

struct AppCoordinatorView: View {
    @State private var appState: AppState = .splash
    
    enum AppState {
        case splash
        case main
    }
    
    var body: some View {
        ZStack {
            if appState == .main {
                CountryHomeView() //Go Home
                    .transition(.opacity)
            }
            
            if appState == .splash {
                // Simple splash screen
                SimpleSplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            // Shorter splash - just 800ms
            try? await Task.sleep(nanoseconds: 800_000_000)
            
            withAnimation(.easeOut(duration: 0.4)) {
                appState = .main
            }
        }
    }
}

struct SimpleSplashView: View {
    @State private var isAnimating = false
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.45),
                    Color(red: 0.2, green: 0.3, blue: 0.6),
                    Color(red: 0.3, green: 0.4, blue: 0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // GPS Icon with Animation
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: pulseAnimation ? 180 : 120, height: pulseAnimation ? 180 : 120)
                        .blur(radius: 10)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                    
                    Image(systemName: "location.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color(red: 0.2, green: 0.3, blue: 0.6))
                }
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 1.0 : 0.5)
                
                // App Title
                VStack(spacing: 12) {
                    Text("Search at Countries")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
                    
                    Text("Discover countries around the world")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 20)
                
                Spacer()
                
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .padding(.bottom, 50)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}

#Preview {
    AppCoordinatorView()
        .modelContainer(for: [CachedCountry.self, PinnedCountry.self], inMemory: true)
}
