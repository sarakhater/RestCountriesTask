//
//  MockCountryRepository.swift
//  RestCountriesTests
//  
//  Created by Sara on 7/04/2026
//
@testable import RestCountries
import Foundation

@MainActor
final class MockCountryRepository: CountryRepositoryProtocol {
    
    var catalog: [CountryDisplay] = []
    private(set) var pinnedCodes: [String] = []
    var refreshError: Error?

    func refreshFromNetwork() async throws {
        if let refreshError {
            throw refreshError
        }
    }

    func allCachedDisplays() throws -> [CountryDisplay] {
        catalog
    }

    func searchCached(query: String) throws -> [CountryDisplay] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        return catalog.filter {
            $0.name.lowercased().contains(q) || $0.alpha2Code.lowercased().contains(q)
        }
    }

    func pinnedDisplays() throws -> [CountryDisplay] {
        pinnedCodes.compactMap { code in catalog.first { $0.alpha2Code == code } }
    }

    func addPin(alpha2Code: String) throws {
        let upper = alpha2Code.uppercased()
        guard catalog.contains(where: { $0.alpha2Code == upper }) else {
            throw CountryRepositoryError.countryNotFound
        }
        if pinnedCodes.contains(upper) {
            throw CountryRepositoryError.alreadyPinned
        }
        guard pinnedCodes.count < AppConstants.maxPinnedCountries else {
            throw CountryRepositoryError.pinLimitReached
        }
        pinnedCodes.append(upper)
    }

    func removePin(alpha2Code: String) throws {
        let upper = alpha2Code.uppercased()
        pinnedCodes.removeAll { $0 == upper }
    }

    func pinCount() throws -> Int {
        pinnedCodes.count
    }

    func display(for alpha2Code: String) throws -> CountryDisplay? {
        let upper = alpha2Code.uppercased()
        return catalog.first { $0.alpha2Code == upper }
    }
}
