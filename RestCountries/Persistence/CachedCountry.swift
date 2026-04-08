//
//  CachedCountry.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//

import Foundation
import SwiftData

@Model
final class CachedCountry {
    @Attribute(.unique) var alpha2Code: String
    var name: String
    var capital: String
    var currencySummary: String
    var flagPngURL: String?
    var updatedAt: Date

    init(alpha2Code: String, name: String, capital: String, currencySummary: String, flagPngURL: String?, updatedAt: Date) {
        self.alpha2Code = alpha2Code
        self.name = name
        self.capital = capital
        self.currencySummary = currencySummary
        self.flagPngURL = flagPngURL
        self.updatedAt = updatedAt
    }

    convenience init(from dto: CountryDTO) {
        let code = dto.normalizedAlpha2 ?? ""
        let cap = dto.capital?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        self.init(
            alpha2Code: code,
            name: dto.name,
            capital: cap,
            currencySummary: CountryDTO.currencySummary(from: dto.currencies),
            flagPngURL: dto.flags?.png,
            updatedAt: Date()
        )
    }

    func apply(dto: CountryDTO) {
        name = dto.name
        capital = dto.capital?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        currencySummary = CountryDTO.currencySummary(from: dto.currencies)
        flagPngURL = dto.flags?.png
        updatedAt = Date()
    }
}
