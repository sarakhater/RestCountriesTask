//
//  HomeContentView.swift
//  RestCountries
//
//  Created by Sara on 07/04/2026.
//

import SwiftUI

struct HomeContentView: View {
    // MARK: - Properties
    let viewModel: CountryHomeViewModel
    @Binding var showSearch: Bool
    @Binding var countryToDelete: CountryDisplay?
    @Binding var showDeleteConfirmation: Bool
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.96, blue: 0.98),
                        Color(red: 0.88, green: 0.92, blue: 0.96)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                List {
                    // Header Card
                    Section {
                        headerCard
                            .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }

                    // Loading indicator - less intrusive
                    if viewModel.isRefreshingCatalog {
                        Section {
                            HStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(0.9)
                                Text("Syncing...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.blue.opacity(0.08))
                            )
                            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }

                    // Only show error if NO data loaded
                    if let err = viewModel.catalogError, viewModel.pinnedCountries.isEmpty {
                        Section {
                            errorCard(message: err)
                            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }

                    // Countries List or Empty State
                    if viewModel.pinnedCountries.isEmpty {
                        Section {
                            emptyStateView
                                .listRowInsets(EdgeInsets(top: 30, leading: 20, bottom: 20, trailing: 20))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    } else {
                        Section {
                            ForEach(viewModel.pinnedCountries) { country in
                                NavigationLink(value: country) {
                                    CountryRowCard(country: country)
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        countryToDelete = country
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Remove", systemImage: "trash.fill")
                                    }
                                    .tint(.red)
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        countryToDelete = country
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Remove from Collection", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationDestination(for: CountryDisplay.self) { country in
                CountryDetailView(country: country)
            }
            .navigationTitle("My Countries")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Check if at pin limit
                        if viewModel.pinnedCountries.count >= AppConstants.maxPinnedCountries {
                            // Show toast message
                            viewModel.toastMessage = "Maximum of \(AppConstants.maxPinnedCountries) countries pinned. Please remove one to add another."
                        } else {
                            // Open search normally
                            showSearch = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Theme.accent)
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                CountrySearchSheet(viewModel: viewModel)
            }
            .alert("Remove Country?", isPresented: $showDeleteConfirmation, presenting: countryToDelete) { country in
                Button("Cancel", role: .cancel) {
                    countryToDelete = nil
                }
                Button("Remove", role: .destructive) {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.remove(country)
                    }
                    countryToDelete = nil
                }
            } message: { country in
                Text("Are you sure you want to remove \(country.name) from your collection?")
            }
            .overlay(alignment: .top) {
                if let toast = viewModel.toastMessage {
                    toastView(message: toast)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .task {
                            try? await Task.sleep(nanoseconds: 2_500_000_000)
                            viewModel.clearToast()
                        }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.toastMessage)
        }
    }
    
    // MARK: - Subviews
    
    private var headerCard: some View {
        HeaderCardView(viewModel: viewModel)
    }
    
    private func errorCard(message: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.title3)
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unable to Connect")
                        .font(.subheadline.weight(.semibold))
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Button {
                Task { await viewModel.load() }
            } label: {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.orange.opacity(0.08))
        )
    }
    
    private var emptyStateView: some View {
        EmptyStateView(onAddCountry: {
            showSearch = true
        })
    }
    
    private func toastView(message: String) -> some View {
        Text(message)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.88))
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            )
    }
}

// MARK: - Country Row Card Wrapper

struct CountryRowCard: View {
    let country: CountryDisplay
    
    var body: some View {
        CountryRowCardView(country: country)
    }
}
