//
//  Theme.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

enum Theme {
    static let accent = Color(red: 0.25, green: 0.55, blue: 0.95)
    static let accentSecondary = Color(red: 0.45, green: 0.35, blue: 0.92)
    static let card: Color = {
        #if os(iOS) || os(tvOS) || os(visionOS)
        return Color(.secondarySystemGroupedBackground)
        #elseif os(macOS)
        return Color(nsColor: .controlBackgroundColor)
        #else
        return Color.gray.opacity(0.15)
        #endif
    }()
    static let stroke = Color.primary.opacity(0.08)
}

struct MeshGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Theme.accent.opacity(0.35),
                Theme.accentSecondary.opacity(0.28),
                groupedBackground,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var groupedBackground: Color {
        #if os(iOS) || os(tvOS) || os(visionOS)
        Color(.systemGroupedBackground)
        #elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color.gray.opacity(0.12)
        #endif
    }
}
