//
//  FlightTixURLSessionConfig.swift
//  FlightTix
//
//  Created by Jon Bauer on 12/22/24.
//

import Foundation

protocol URLSessionConfig {
    var baseURL: URL { get }
    var apiKey: String { get }
    var networkServiceType: NSURLRequest.NetworkServiceType { get }
    var httpAdditionalHeaders: [String: String] { get }
    var timeoutForRequest: TimeInterval { get }
    var timeoutForResource: TimeInterval { get }
}

struct FlightTixSessionConfigStruct: URLSessionConfig  {
    let baseURL = URL(string: "http://localhost/cloud-agent")!
    let apiKey = ""
    let networkServiceType: NSURLRequest.NetworkServiceType = .default
    var httpAdditionalHeaders: [String: String] = ["Accept": "application/json",
                                                   "Content-Type": "application/json"
    ]
    let timeoutForRequest: TimeInterval = 30
    let timeoutForResource: TimeInterval = 30
}

final class FlightTixURLSession {
    
    let urlSession: URLSession
    var config: FlightTixSessionConfigStruct
    let baseURL: URL
    
    enum Mode {
        case development
        case production
    }
    
    convenience init(mode: Mode, config: FlightTixSessionConfigStruct) {
        
        var headers = config.httpAdditionalHeaders
        
        switch mode {
            case .production:
                if !config.apiKey.isEmpty {
                    let additionalHeaders = ["apikey": config.apiKey]
                    headers.merge(additionalHeaders, uniquingKeysWith: { (_, new) in new })
                }
            case .development:
                headers.removeValue(forKey: "apikey")
        }
        self.init(config: FlightTixSessionConfigStruct(httpAdditionalHeaders: headers))
    }
    
    init(config: FlightTixSessionConfigStruct) {
        self.baseURL = config.baseURL
        self.config = config
        
        let defaultSessionConfig = URLSessionConfiguration.default
        defaultSessionConfig.networkServiceType = config.networkServiceType
        defaultSessionConfig.timeoutIntervalForRequest = config.timeoutForRequest
        defaultSessionConfig.timeoutIntervalForResource = config.timeoutForResource
        defaultSessionConfig.httpAdditionalHeaders = config.httpAdditionalHeaders
        urlSession = URLSession(configuration: defaultSessionConfig)
    }
}
