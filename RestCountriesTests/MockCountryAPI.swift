//
//  MockCountryAPI.swift
//  RestCountriesTests
//
//  Created by Sara on 7/04/2026
//
@testable import RestCountries
import Foundation

final class MockCountryAPI: CountryAPIServiceProtocol {
    var stubs: [CountryDTO] = []
    var error: Error?

    func fetchAllCountries() async throws -> [CountryDTO] {
        if let error {
            throw error
        }
        return stubs
    }
}
