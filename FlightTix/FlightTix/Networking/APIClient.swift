//
//  APIClient.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/22/24.
//

import Foundation

actor APIClient {
    
    let urlSession: URLSession
    let baseURL: URL
    //    final var responseError: Error
    //    final var requestError: Error
    //    final var noDataReturnedError: Error
    //    final var responseNotParsedError: Error
    
    init(configuration: FlightTixURLSession) {
        self.urlSession = configuration.urlSession
        self.baseURL = configuration.baseURL
    }
    
    public func handleRequest(request: URLRequest) async throws -> (data: Data, response: URLResponse) {
        do {
            return try await urlSession.getData(for: request)
        } catch {
            throw error
        }
    }
    
    public func dataFromResponse(urlResponse: URLResponse, data: Data?) async throws -> Data? {
        guard let response = urlResponse as? HTTPURLResponse, (response.statusCode == 200 || response.statusCode == 201) else {
            guard let response = urlResponse as? HTTPURLResponse, (response.statusCode == 400) else {
                
                return nil
            }
            return nil
        }
        return data
    }
}

//https://forums.developer.apple.com/forums/thread/727823
extension URLSession {
    public nonisolated func getData(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }

    public nonisolated func getData(for url: URL) async throws -> (Data, URLResponse) {
        try await data(from: url)
    }
}
