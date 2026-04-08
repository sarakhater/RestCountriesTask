//
//  StubLocation.swift
//  RestCountriesTests
//
//  Created by Sara on 7/04/2026
//
@testable import RestCountries

struct StubLocation: LocationCountryResolving {
    var code: String?

    func resolveCountryCode() async -> String? {
        code
    }
}
