//
//  CountryDetailView.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//
import SwiftUI

struct CountryDetailView: View {
    let country: CountryDisplay

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 16) {
                    CountryFlagImage(url: country.flagPngURL, cornerRadius: 12)
                        .frame(width: 88, height: 64)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(country.name)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.primary)
                        Text(country.alpha2Code)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.primary.opacity(0.06)))
                    }
                    Spacer(minLength: 0)
                }

                detailCard(title: "Capital", systemImage: "building.2.fill", value: country.capital)
                detailCard(title: "Currency", systemImage: "dollarsign.circle.fill", value: country.currencySummary)
            }
            .padding(20)
        }
        .background(MeshGradientBackground())
        .navigationTitle("Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func detailCard(title: String, systemImage: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(Theme.accent)
            Text(value)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.stroke, lineWidth: 1)
        }
    }
}

#Preview {
    NavigationStack {
        CountryDetailView(
            country: CountryDisplay(
                alpha2Code: "EG",
                name: "Egypt",
                capital: "Cairo",
                currencySummary: "EGP — Egyptian pound",
                flagPngURL: nil
            )
        )
    }
}
