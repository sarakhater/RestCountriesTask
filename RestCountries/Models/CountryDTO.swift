//
//  CountryDTO.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//

import Foundation

struct CountryDTO: Codable, Sendable, Equatable {
    let name: String
    let alpha2Code: String?
    let capital: String?
    let currencies: [CurrencyDTO]?
    let flags: FlagsDTO?
}

struct CurrencyDTO: Codable, Sendable, Equatable {
    let code: String?
    let name: String?
    let symbol: String?
}

struct FlagsDTO: Codable, Sendable, Equatable {
    let png: String?
    let svg: String?
}

extension CountryDTO {
    var normalizedAlpha2: String? {
        guard let raw = alpha2Code?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
              raw.count == 2
        else { return nil }
        return raw
    }

    static func currencySummary(from currencies: [CurrencyDTO]?) -> String {
        guard let currencies, !currencies.isEmpty else {
            return "No official currency"
        }
        return currencies.compactMap { cur -> String? in
            let code = cur.code?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let name = cur.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !code.isEmpty, !name.isEmpty { return "\(code) — \(name)" }
            if !code.isEmpty { return code }
            if !name.isEmpty { return name }
            return nil
        }
        .joined(separator: ", ")
    }
}
