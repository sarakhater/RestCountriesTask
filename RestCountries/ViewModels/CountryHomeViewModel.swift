//
//  CountryHomeViewModel.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//

import Foundation
import Observation

@MainActor
@Observable
final class CountryHomeViewModel {
    private let repository: CountryRepositoryProtocol
    private let location: LocationCountryResolving

    private(set) var pinnedCountries: [CountryDisplay] = []
    private(set) var isRefreshingCatalog = false
    var catalogError: String?
    var toastMessage: String?

    init(repository: CountryRepositoryProtocol, location: LocationCountryResolving) {
        self.repository = repository
        self.location = location
    }

    func load() async {
        //view model load () started
       
        catalogError = nil
    
        //Load from cache first
        reloadPins()
    
        await bootstrapIfPinsEmpty()
        
        // Now refresh from network in the background
        isRefreshingCatalog = true
        defer { isRefreshingCatalog = false }

        do {
            //Calling refreshFromNetwork() in background
            try await repository.refreshFromNetwork()
            catalogError = nil
            
            // Reload pins to get any updated data
            reloadPins()
            await bootstrapIfPinsEmpty()
            
        } catch {
            print("ViewModel==> refreshFromNetwork() failed: \(error)")
            let cached = (try? repository.allCachedDisplays()) ?? []
            
        
            // Only show error if we have NO cached data at all
            if cached.isEmpty {
                catalogError = "Could not load countries. Check your connection and try again"
            } else {
                // We have cached data, so just show a subtle indicator
                catalogError = nil
                print("use cached data instead")
            }
        }
        
        print("completed pinned==> \(pinnedCountries.count)")
    }

    func reloadPins() {
        pinnedCountries = (try? repository.pinnedDisplays()) ?? []
    }

    //ِEnsure user can't view empty screen at first
    private func bootstrapIfPinsEmpty() async {
        guard pinnedCountries.isEmpty else { return }

        let fromGPS = await location.resolveCountryCode()
        let code = fromGPS.flatMap { $0.count == 2 ? $0 : nil } ?? AppConstants.defaultCountryAlpha2Code

        if (try? repository.display(for: code)) != nil {
            try? repository.addPin(alpha2Code: code)
        } else if let fallback = try? repository.allCachedDisplays().first {
            try? repository.addPin(alpha2Code: fallback.alpha2Code)
        }

        reloadPins()
    }

    func addFromSearch(_ country: CountryDisplay) {
        do {
            try repository.addPin(alpha2Code: country.alpha2Code)
            pinnedCountries = try repository.pinnedDisplays()
            toastMessage = "Added \(country.name)"
        } catch CountryRepositoryError.pinLimitReached {
            toastMessage = "You can pin at most \(AppConstants.maxPinnedCountries) countries."
        } catch CountryRepositoryError.alreadyPinned {
            toastMessage = " This \(country.name) is already on your list."
        } catch {
            toastMessage = "Could not add this country."
        }
    }

    func remove(_ country: CountryDisplay) {
        try? repository.removePin(alpha2Code: country.alpha2Code)
        pinnedCountries = (try? repository.pinnedDisplays()) ?? []
    }

    func search(query: String) -> [CountryDisplay] {
        print("ViewModel==> Searching for '\(query)'")
        
        let results = (try? repository.searchCached(query: query)) ?? []
        print("ViewModel==> Returning \(results.count) results")
        
        return results
    }

    func clearToast() {
        toastMessage = nil
    }
}
