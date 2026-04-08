//
//  HeaderCardView.swift
//  RestCountries
//
//  Created by Sara on 08/04/2026.
//

import SwiftUI

struct HeaderCardView: View {
    
    let viewModel: CountryHomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "star.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Theme.accent)
                Text("Your Collection")
                    .font(.title3.weight(.bold))
                Spacer()
                Text("\(viewModel.pinnedCountries.count)/\(AppConstants.maxPinnedCountries)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.primary.opacity(0.06)))
            }
            
            HStack(spacing: 4) {
                Image(systemName: "hand.tap.fill")
                    .font(.caption)
                    .foregroundStyle(Theme.accent)
                Text("Tap to explore")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("•")
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 4)
                
                Image(systemName: "hand.draw.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                Text("Swipe left to remove")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
        )
    }
}

