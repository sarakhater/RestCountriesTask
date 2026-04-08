//
//  CountryDTOTests.swift
//  RestCountriesTests
//
//  Created by Sara on 8/04/2026
//
@testable import RestCountries
import XCTest

final class CountryDTOTests: XCTestCase {
    func testDecodesCountryJSON() throws {
        let json = """
        {
          "name": "Egypt",
          "alpha2Code": "EG",
          "capital": "Cairo",
          "currencies": [{"code": "EGP", "name": "Egyptian pound", "symbol": "£"}],
          "flags": {"png": "https://example.com/eg.png", "svg": "https://example.com/eg.svg"}
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let dto = try JSONDecoder().decode(CountryDTO.self, from: data)
        XCTAssertEqual(dto.name, "Egypt")
        XCTAssertEqual(dto.normalizedAlpha2, "EG")
        XCTAssertEqual(dto.capital, "Cairo")
        XCTAssertEqual(CountryDTO.currencySummary(from: dto.currencies), "EGP — Egyptian pound")
    }

    func testCurrencySummaryHandlesMissingCurrencies() {
        XCTAssertEqual(CountryDTO.currencySummary(from: nil), "No official currency")
        XCTAssertEqual(CountryDTO.currencySummary(from: []), "No official currency")
    }

    func testDisplayModelUsesDefaultsForMissingCapital() {
        let dto = CountryDTO(name: "Antarctica", alpha2Code: "AQ", capital: nil, currencies: nil, flags: nil)
        let display = CountryDisplay(dto: dto)
        XCTAssertEqual(display.capital, "—")
        XCTAssertEqual(display.currencySummary, "No official currency")
    }
}
