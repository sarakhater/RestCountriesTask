//
//  CountryDisplay.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//

import Foundation

struct CountryDisplay: Identifiable, Equatable, Hashable, Sendable {
    var id: String { alpha2Code }

    let alpha2Code: String
    let name: String
    let capital: String
    let currencySummary: String
    let flagPngURL: URL?

    init(alpha2Code: String, name: String, capital: String, currencySummary: String, flagPngURL: URL?) {
        self.alpha2Code = alpha2Code
        self.name = name
        self.capital = capital
        self.currencySummary = currencySummary
        self.flagPngURL = flagPngURL
    }

    init(dto: CountryDTO) {
        let code = dto.normalizedAlpha2 ?? "ZZ"
        self.alpha2Code = code
        self.name = dto.name
        self.capital = dto.capital?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "—"
        self.currencySummary = CountryDTO.currencySummary(from: dto.currencies)
        if let png = dto.flags?.png, let url = URL(string: png) {
            self.flagPngURL = url
        } else {
            self.flagPngURL = nil
        }
    }

    init(cached: CachedCountry) {
        self.alpha2Code = cached.alpha2Code
        self.name = cached.name
        self.capital = cached.capital.nilIfEmpty ?? "—"
        self.currencySummary = cached.currencySummary
        if let s = cached.flagPngURL, let url = URL(string: s) {
            self.flagPngURL = url
        } else {
            self.flagPngURL = nil
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        let t = trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }
}
