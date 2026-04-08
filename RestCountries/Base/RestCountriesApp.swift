//
//  RestCountriesApp.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//
import SwiftData
import SwiftUI

@main
struct RestCountriesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CachedCountry.self,
            PinnedCountry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            //for caching
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView() // my start view
        }
        .modelContainer(sharedModelContainer)
    }
}
