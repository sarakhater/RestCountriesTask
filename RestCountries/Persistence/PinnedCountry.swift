//
//  PinnedCountry.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//

import Foundation
import SwiftData

@Model
final class PinnedCountry {
    var alpha2Code: String
    var sortIndex: Int

    init(alpha2Code: String, sortIndex: Int) {
        self.alpha2Code = alpha2Code.uppercased()
        self.sortIndex = sortIndex
    }
}
