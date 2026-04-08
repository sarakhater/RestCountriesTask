//
//  CountryAPIService.swift
//  RestCountries
//
//  Created by Sara on 7/04/2026
//

import Alamofire
import Foundation

protocol CountryAPIServiceProtocol: AnyObject {
    func fetchAllCountries() async throws -> [CountryDTO]
}

final class CountryAPIService: CountryAPIServiceProtocol {
    private let session: Session
    private let url: URL

    init(session: Session? = nil, url: URL = AppConstants.countriesAPIURL) {
        // Configure session with proper timeouts
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15  // 15 seconds for request
        configuration.timeoutIntervalForResource = 30 // 30 seconds total
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        self.session = session ?? Session(configuration: configuration)
        self.url = url
    }

    func fetchAllCountries() async throws -> [CountryDTO] {
        print("Fetching countries from \(url)")
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = session.request(url)
                .validate()
                        
            request.responseData { response in
                    print("Status Code ==> \(response.response?.statusCode ?? -1)")
                    print("Error From API==>\(String(describing: response.error))")
                    
                    switch response.result {
                    case .success(let data):
                        do {
                            let decoded = try JSONDecoder().decode([CountryDTO].self, from: data)
                            continuation.resume(returning: decoded)
                        } catch {
                            print("Decoding error==> \(error)")
                            if let jsonString = String(data: data.prefix(200), encoding: .utf8) {
                                print("\(jsonString)")
                            }
                            continuation.resume(throwing: error)
                        }
                    case .failure(let error):
                        print("Request failed ==> \(error)")
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
