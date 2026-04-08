//
//  CountryRepositoryTests.swift
//  RestCountriesTests
//
//  Created by Sara on 7/04/2026
//
@testable import RestCountries
import SwiftData
import XCTest

@MainActor
final class CountryRepositoryTests: XCTestCase {
    private func makeRepository(stubs: [CountryDTO]) throws -> (CountryRepository, ModelContext) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: CachedCountry.self, PinnedCountry.self, configurations: configuration)
        let context = ModelContext(container)
        let api = MockCountryAPI()
        api.stubs = stubs
        let repo = CountryRepository(modelContext: context, api: api)
        return (repo, context)
    }

    func testRefreshPersistsCountries() async throws {
        let stubs = [
            CountryDTO(name: "Egypt", alpha2Code: "EG", capital: "Cairo", currencies: [], flags: nil),
        ]
        let (repo, _) = try makeRepository(stubs: stubs)
        try await repo.refreshFromNetwork()
        let all = try repo.allCachedDisplays()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.alpha2Code, "EG")
    }

    func testCannotExceedFivePins() async throws {
        let stubs = (0 ..< 6).map { i in
            CountryDTO(name: "C\(i)", alpha2Code: String(format: "%02d", i), capital: "X", currencies: nil, flags: nil)
        }
        let (repo, _) = try makeRepository(stubs: stubs)
        try await repo.refreshFromNetwork()
        for i in 0 ..< AppConstants.maxPinnedCountries {
            try repo.addPin(alpha2Code: String(format: "%02d", i))
        }
        XCTAssertThrowsError(try repo.addPin(alpha2Code: "05")) { error in
            XCTAssertEqual(error as? CountryRepositoryError, .pinLimitReached)
        }
    }

    func testSearchFiltersByName() async throws {
        let stubs = [
            CountryDTO(name: "Germany", alpha2Code: "DE", capital: "Berlin", currencies: nil, flags: nil),
            CountryDTO(name: "France", alpha2Code: "FR", capital: "Paris", currencies: nil, flags: nil),
        ]
        let (repo, _) = try makeRepository(stubs: stubs)
        try await repo.refreshFromNetwork()
        let hits = try repo.searchCached(query: "ger")
        XCTAssertEqual(hits.count, 1)
        XCTAssertEqual(hits.first?.alpha2Code, "DE")
    }
}
