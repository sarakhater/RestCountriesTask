//
//  CountryHomeView.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//
import SwiftData
import SwiftUI

struct CountryHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: CountryHomeViewModel?
    @State private var showSearch = false
    @State private var countryToDelete: CountryDisplay?
    @State private var showDeleteConfirmation = false

    var body: some View {
        Group {
            if let viewModel {
                homeContent(viewModel: viewModel)
            } else {
                // Quick loading indicator - don't wait for data
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Theme.accent)
            }
        }
        .task {
            if viewModel == nil {
                
                // Create ViewModel IMMEDIATELY - don't wait!
                let vm = CountryHomeViewModel(
                    repository: CountryRepository(modelContext: modelContext),
                    location: LocationCountryService()
                )
                
                // Show UI immediately
                viewModel = vm
                
                // Load data in background - UI is already visible!
                Task {
                    await vm.load()
                    print("Background data ==> load complete")
                }
            }
        }
    }

    @ViewBuilder
    private func homeContent(viewModel: CountryHomeViewModel) -> some View {
        HomeContentView(
            viewModel: viewModel,
            showSearch: $showSearch,
            countryToDelete: $countryToDelete,
            showDeleteConfirmation: $showDeleteConfirmation
        )
    }
}

#Preview {
    CountryHomeView()
        .modelContainer(for: [CachedCountry.self, PinnedCountry.self], inMemory: true)
}
