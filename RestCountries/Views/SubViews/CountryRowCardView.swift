//
//  CountryRowCardView.swift
//  RestCountries
//
//  Created by Sara on 08/04/2026.
//

import SwiftUI

struct CountryRowCardView: View {
    let country: CountryDisplay
    
    var body: some View {
        HStack(spacing: 14) {
            // Flag with better sizing
            CountryFlagImage(url: country.flagPngURL)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(country.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(country.capital)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 3)
        )
        .contentShape(Rectangle()) // Makes entire card tappable
    }
}

