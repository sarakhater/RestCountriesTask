//
//  CountryFlagImage.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//

import SwiftUI

struct CountryFlagImage: View {
    let url: URL?
    var cornerRadius: CGFloat = 8

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "flag.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Theme.accent)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "flag.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Theme.accent)
            }
        }
        .frame(width: 56, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
    }
}
