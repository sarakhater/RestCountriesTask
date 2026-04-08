//
//  CountryRepository.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//

import Foundation
import SwiftData

enum CountryRepositoryError: Error, Equatable {
    case pinLimitReached
    case alreadyPinned
    case countryNotFound
}

@MainActor
protocol CountryRepositoryProtocol: AnyObject {
    func refreshFromNetwork() async throws
    func allCachedDisplays() throws -> [CountryDisplay]
    func searchCached(query: String) throws -> [CountryDisplay]
    func pinnedDisplays() throws -> [CountryDisplay]
    func addPin(alpha2Code: String) throws
    func removePin(alpha2Code: String) throws
    func pinCount() throws -> Int
    func display(for alpha2Code: String) throws -> CountryDisplay?
}

@MainActor
final class CountryRepository: CountryRepositoryProtocol {
    private let modelContext: ModelContext
    private let api: CountryAPIServiceProtocol

    init(modelContext: ModelContext, api: CountryAPIServiceProtocol = CountryAPIService()) {
        self.modelContext = modelContext
        self.api = api
    }

    func refreshFromNetwork() async throws {
        
        do {
            // Fetch from API off the main actor for better performance
            let dtos = try await api.fetchAllCountries()
            print("Repository ==> Got \(dtos.count) DTOs from API")
            
            // Now save to SwiftData on main actor
            var saved = 0
            for dto in dtos {
                guard let code = dto.normalizedAlpha2 else { continue }
                let fd = FetchDescriptor<CachedCountry>(predicate: #Predicate { $0.alpha2Code == code })
                if let existing = try modelContext.fetch(fd).first {
                    existing.apply(dto: dto)
                } else {
                    modelContext.insert(CachedCountry(from: dto))
                }
                saved += 1
                
                // Save in batches to avoid memory issues
                if saved % 50 == 0 {
                    try modelContext.save()
                    print("Saved batch ==> (\(saved)/\(dtos.count))")
                }
            }
            
            try modelContext.save()
            
        } catch {
            print("Repository==> API failed with error: \(error)")
            
            // Check if we have any cached data
            let existing = try? allCachedDisplays()
            if existing?.isEmpty == true {
                print("No cached data. I will use sample data.")
                try? ManualDataSeeder.seedSampleData(modelContext: modelContext)
                
                let check = try? allCachedDisplays()
                print("Seeded data==>  Now have \(check?.count ?? 0) countries")
            }
            
            throw error
        }
    }

    func allCachedDisplays() throws -> [CountryDisplay] {
        var fd = FetchDescriptor<CachedCountry>(sortBy: [SortDescriptor(\.name, order: .forward)])
        fd.fetchLimit = 300
        return try modelContext.fetch(fd).map(CountryDisplay.init(cached:))
    }

    func searchCached(query: String) throws -> [CountryDisplay] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let all = try allCachedDisplays()
        
        print("Search==> Query='\(q)', Total cached=\(all.count)")
        
        guard !q.isEmpty else {
            print("Search==> Empty query, returning first 60")
            return Array(all.prefix(60))
        }
        
        let results = all.filter { $0.name.lowercased().contains(q) || $0.alpha2Code.lowercased().contains(q) }
        print("Search==> Found \(results.count) matches for '\(q)'")
        
        if results.isEmpty {
            print("Search==> No matches. Sample countries: \(all.prefix(5).map { $0.name })")
        }
        
        return results
    }

    func pinnedDisplays() throws -> [CountryDisplay] {
        var fd = FetchDescriptor<PinnedCountry>(sortBy: [SortDescriptor(\.sortIndex, order: .forward)])
        fd.fetchLimit = AppConstants.maxPinnedCountries
        let pins = try modelContext.fetch(fd)
        var result: [CountryDisplay] = []
        for pin in pins {
            if let d = try display(for: pin.alpha2Code) {
                result.append(d)
            } else {
                result.append(
                    CountryDisplay(
                        alpha2Code: pin.alpha2Code,
                        name: pin.alpha2Code,
                        capital: "—",
                        currencySummary: "—",
                        flagPngURL: nil
                    )
                )
            }
        }
        return result
    }

    func display(for alpha2Code: String) throws -> CountryDisplay? {
        let code = alpha2Code.uppercased()
        let fd = FetchDescriptor<CachedCountry>(predicate: #Predicate { $0.alpha2Code == code })
        guard let row = try modelContext.fetch(fd).first else { return nil }
        return CountryDisplay(cached: row)
    }

    func pinCount() throws -> Int {
        let fd = FetchDescriptor<PinnedCountry>()
        return try modelContext.fetchCount(fd)
    }

    func addPin(alpha2Code: String) throws {
        let code = alpha2Code.uppercased()
        guard try display(for: code) != nil else { throw CountryRepositoryError.countryNotFound }

        let existingPins = FetchDescriptor<PinnedCountry>(predicate: #Predicate { $0.alpha2Code == code })
        if try modelContext.fetchCount(existingPins) > 0 {
            throw CountryRepositoryError.alreadyPinned
        }

        let count = try pinCount()
        guard count < AppConstants.maxPinnedCountries else { throw CountryRepositoryError.pinLimitReached }

        let nextIndex = try nextSortIndex()
        modelContext.insert(PinnedCountry(alpha2Code: code, sortIndex: nextIndex))
        try modelContext.save()
    }

    func removePin(alpha2Code: String) throws {
        let code = alpha2Code.uppercased()
        let fd = FetchDescriptor<PinnedCountry>(predicate: #Predicate { $0.alpha2Code == code })
        for pin in try modelContext.fetch(fd) {
            modelContext.delete(pin)
        }
        try modelContext.save()
        try normalizeSortIndices()
    }

    private func nextSortIndex() throws -> Int {
        var fd = FetchDescriptor<PinnedCountry>(sortBy: [SortDescriptor(\.sortIndex, order: .reverse)])
        fd.fetchLimit = 1
        let max = try modelContext.fetch(fd).first?.sortIndex ?? -1
        return max + 1
    }

    private func normalizeSortIndices() throws {
        let fd = FetchDescriptor<PinnedCountry>(sortBy: [SortDescriptor(\.sortIndex, order: .forward)])
        let pins = try modelContext.fetch(fd)
        for (i, pin) in pins.enumerated() {
            pin.sortIndex = i
        }
        try modelContext.save()
    }
}
