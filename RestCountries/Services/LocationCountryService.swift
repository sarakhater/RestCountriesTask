//
//  LocationCountryService.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//

import Foundation

#if os(iOS)
import CoreLocation

protocol LocationCountryResolving {
    func resolveCountryCode() async -> String?
}

@MainActor
final class LocationCountryService: NSObject, LocationCountryResolving, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<String?, Never>?
    private var authContinuation: CheckedContinuation<Void, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func resolveCountryCode() async -> String? {
        if manager.authorizationStatus == .notDetermined {
            await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                authContinuation = cont
                manager.requestWhenInUseAuthorization()
            }
        }

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            break
        default:
            return nil
        }

        return await withCheckedContinuation { cont in
            locationContinuation = cont
            manager.requestLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus != .notDetermined {
            authContinuation?.resume()
            authContinuation = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            resumeLocation(nil)
            return
        }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            let code = placemarks?.first?.isoCountryCode?.uppercased()
            guard let self else { return }
            Task { @MainActor in
                self.resumeLocation(code)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resumeLocation(nil)
    }

    private func resumeLocation(_ code: String?) {
        locationContinuation?.resume(returning: code)
        locationContinuation = nil
    }
}
#else
protocol LocationCountryResolving {
    func resolveCountryCode() async -> String?
}

final class LocationCountryService: LocationCountryResolving {
    func resolveCountryCode() async -> String? { nil }
}
#endif
