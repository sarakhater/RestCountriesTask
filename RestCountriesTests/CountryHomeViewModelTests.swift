//
//  CountryHomeViewModelTests.swift
//  RestCountriesTests
//
//  Created by Sara on 7/04/2026
//

@testable import RestCountries
import XCTest

@MainActor
final class CountryHomeViewModelTests: XCTestCase {
    
    //check  use default location when current location is  nil
    func testUsesDefaultLocationWhenLocationNil() async {
        let repo = MockCountryRepository()
        repo.catalog = [
            CountryDisplay(
                alpha2Code: AppConstants.defaultCountryAlpha2Code,
                name: "Egypt",
                capital: "Cairo",
                currencySummary: "EGP",
                flagPngURL: nil
            ),
        ]
        let vm = CountryHomeViewModel(repository: repo, location: StubLocation(code: nil))
        await vm.load()
        XCTAssertEqual(vm.pinnedCountries.count, 1)
        XCTAssertEqual(vm.pinnedCountries.first?.alpha2Code, AppConstants.defaultCountryAlpha2Code)
    }

    func testBootstrapUsesGPSWhenProvided() async {
        let repo = MockCountryRepository()
        repo.catalog = [
            CountryDisplay(alpha2Code: "DE", name: "Germany", capital: "Berlin", currencySummary: "EUR", flagPngURL: nil),
            CountryDisplay(
                alpha2Code: AppConstants.defaultCountryAlpha2Code,
                name: "Egypt",
                capital: "Cairo",
                currencySummary: "EGP",
                flagPngURL: nil
            ),
        ]
        let vm = CountryHomeViewModel(repository: repo, location: StubLocation(code: "DE"))
        await vm.load()
        XCTAssertEqual(vm.pinnedCountries.first?.alpha2Code, "DE")
    }

    func testAddFromSearchRespectsPinLimit() async {
        let repo = MockCountryRepository()
        repo.catalog = (0 ..< 6).map { i in
            CountryDisplay(
                alpha2Code: "C\(i)",
                name: "Country \(i)",
                capital: "Cap \(i)",
                currencySummary: "CUR",
                flagPngURL: nil
            )
        }
        for i in 0 ..< AppConstants.maxPinnedCountries {
            try? repo.addPin(alpha2Code: "C\(i)")
        }
        let vm = CountryHomeViewModel(repository: repo, location: StubLocation(code: nil))
        vm.reloadPins()
        vm.addFromSearch(repo.catalog[5])
        XCTAssertNotNil(vm.toastMessage)
        XCTAssertTrue(vm.toastMessage?.contains("5") == true)
    }

    func testRemoveUpdatesPinnedList() async {
        let repo = MockCountryRepository()
        repo.catalog = [
            CountryDisplay(alpha2Code: "US", name: "U", capital: "W", currencySummary: "USD", flagPngURL: nil),
        ]
        try? repo.addPin(alpha2Code: "US")
        let vm = CountryHomeViewModel(repository: repo, location: StubLocation(code: nil))
        vm.reloadPins()
        XCTAssertEqual(vm.pinnedCountries.count, 1)
        vm.remove(vm.pinnedCountries[0])
        XCTAssertTrue(vm.pinnedCountries.isEmpty)
    }
}
