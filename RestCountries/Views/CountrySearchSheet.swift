//
//  CountrySearchSheet.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//

import SwiftUI

struct CountrySearchSheet: View {
    var viewModel: CountryHomeViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var results: [CountryDisplay] = []
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Search Field with Button
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        
                        TextField("Type country name (e.g., France)", text: $query)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onSubmit {
                                performSearch()
                            }
                        
                        if !query.isEmpty {
                            Button {
                                query = ""
                                performSearch()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Theme.card)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Theme.stroke, lineWidth: 1)
                    )
                    
                    Button {
                        performSearch()
                    } label: {
                        if isSearching {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "magnifyingglass")
                                .font(.body.weight(.semibold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .disabled(isSearching)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Results List
                if isSearching {
                    Spacer()
                    ProgressView("Searching...")
                        .tint(Theme.accent)
                    Spacer()
                } else if results.isEmpty && !query.isEmpty {
                    // Empty State
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No countries found")
                            .font(.headline)
                        Text("Try searching with a different name or code")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else if results.isEmpty && query.isEmpty {
                    // Initial State
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "globe.europe.africa")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.accent)
                        Text("Search for a country")
                            .font(.headline)
                        Text("Type a country name like 'France', 'Egypt', or 'Japan'")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else {
                    // Results
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(results) { country in
                                Button {
                                    viewModel.addFromSearch(country)
                                    dismiss()
                                } label: {
                                    HStack(spacing: 12) {
                                        CountryFlagImage(url: country.flagPngURL)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(country.name)
                                                .font(.body.weight(.semibold))
                                                .foregroundStyle(.primary)
                                            HStack(spacing: 8) {
                                                Text(country.capital)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                Text("•")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                Text(country.currencySummary)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title3)
                                            .symbolRenderingMode(.hierarchical)
                                            .foregroundStyle(Theme.accent)
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Theme.card)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(Theme.stroke, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationTitle("Add country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                performSearch()
            }
        }
    }
    
    private func performSearch() {
        print("Search query ==>  '\(query)'")
        isSearching = true
        
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            results = viewModel.search(query: query)
            print("Search Result ==>  \(results.count) results")
            isSearching = false
        }
    }
}

