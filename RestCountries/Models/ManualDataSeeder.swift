//
//  ManualDataSeeder.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//

import Foundation
import SwiftData


//  This file I added to help manually for testing when API is down.

@MainActor
struct ManualDataSeeder {
    
    // database with ==> sample countries for testing
    static func seedSampleData(modelContext: ModelContext) throws {
        
        let sampleCountries = [
            ("EG", "Egypt", "Cairo", "EGP — Egyptian pound", "https://flagcdn.com/w320/eg.png"),
            ("US", "United States of America", "Washington, D.C.", "USD — United States dollar", "https://flagcdn.com/w320/us.png"),
            ("FR", "France", "Paris", "EUR — Euro", "https://flagcdn.com/w320/fr.png"),
            ("GB", "United Kingdom", "London", "GBP — British pound", "https://flagcdn.com/w320/gb.png"),
            ("JP", "Japan", "Tokyo", "JPY — Japanese yen", "https://flagcdn.com/w320/jp.png"),
            ("DE", "Germany", "Berlin", "EUR — Euro", "https://flagcdn.com/w320/de.png"),
            ("IT", "Italy", "Rome", "EUR — Euro", "https://flagcdn.com/w320/it.png"),
            ("ES", "Spain", "Madrid", "EUR — Euro", "https://flagcdn.com/w320/es.png"),
            ("CA", "Canada", "Ottawa", "CAD — Canadian dollar", "https://flagcdn.com/w320/ca.png"),
            ("AU", "Australia", "Canberra", "AUD — Australian dollar", "https://flagcdn.com/w320/au.png"),
            ("BR", "Brazil", "Brasília", "BRL — Brazilian real", "https://flagcdn.com/w320/br.png"),
            ("IN", "India", "New Delhi", "INR — Indian rupee", "https://flagcdn.com/w320/in.png"),
            ("CN", "China", "Beijing", "CNY — Chinese yuan", "https://flagcdn.com/w320/cn.png"),
            ("MX", "Mexico", "Mexico City", "MXN — Mexican peso", "https://flagcdn.com/w320/mx.png"),
            ("ZA", "South Africa", "Pretoria", "ZAR — South African rand", "https://flagcdn.com/w320/za.png"),
            ("RU", "Russia", "Moscow", "RUB — Russian ruble", "https://flagcdn.com/w320/ru.png"),
            ("AE", "United Arab Emirates", "Abu Dhabi", "AED — United Arab Emirates dirham", "https://flagcdn.com/w320/ae.png"),
            ("SA", "Saudi Arabia", "Riyadh", "SAR — Saudi riyal", "https://flagcdn.com/w320/sa.png"),
            ("TR", "Turkey", "Ankara", "TRY — Turkish lira", "https://flagcdn.com/w320/tr.png"),
            ("KR", "South Korea", "Seoul", "KRW — South Korean won", "https://flagcdn.com/w320/kr.png")
        ]
        
        for (code, name, capital, currency, flagURL) in sampleCountries {
            let country = CachedCountry(
                alpha2Code: code,
                name: name,
                capital: capital,
                currencySummary: currency,
                flagPngURL: flagURL,
                updatedAt: Date()
            )
            modelContext.insert(country)
        }
        
        try modelContext.save()
    }
    
    // Check if database has any data
    static func hasData(modelContext: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<CachedCountry>()
        return (try? modelContext.fetchCount(descriptor)) ?? 0 > 0
    }
}
