//
//  RemoteQuoteLoader.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 07/03/24.
//

import Foundation

public final class RemoteCurrencyQuoteLoader: CurrencyQuoteLoader {
    private let httpClient: HttpClient
    private let url: URL
    
    public enum LoadError: Error {
        case invalidResponse
        case invalidData
    }
    
    public init(httpClient: HttpClient, url: URL) {
        self.httpClient = httpClient
        self.url = url
    }
    
    public func load() async throws -> [Currency] {
        let (data, httpResponse) = try await httpClient.get(from: url)
        
        let result = try CurrencyMapper.map(data, from: httpResponse)
        
        return result
    }
}
