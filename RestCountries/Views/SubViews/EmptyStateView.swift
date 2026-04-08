//
//  EmptyStateView.swift
//  RestCountries
//
//  Created by Sara on 08/04/2026.
//

import SwiftUI

struct EmptyStateView: View {
    let onAddCountry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.12))
                    .frame(width: 110, height: 110)
                
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(Theme.accent)
            }
            
            VStack(spacing: 10) {
                Text("Start Your Journey")
                    .font(.title2.weight(.bold))
                
                Text("Add countries to your collection and explore capitals, currencies, and more!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
            
            Button {
                onAddCountry()
            } label: {
                Label("Add Your First Country", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 16)
                    .background(Theme.accent)
                    .clipShape(Capsule())
                    .shadow(color: Theme.accent.opacity(0.3), radius: 12, y: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
        .padding(.horizontal, 30)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
        )
    }
}

#Preview {
    EmptyStateView(onAddCountry: {})
}
