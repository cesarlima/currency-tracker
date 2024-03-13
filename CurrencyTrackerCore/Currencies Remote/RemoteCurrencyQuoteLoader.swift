//
//  RemoteQuoteLoader.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 07/03/24.
//

import Foundation

public final class RemoteCurrencyQuoteLoader: CurrencyQuoteLoader {
    private let httpClient: HttpClient
    
    public init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    public func load(from url: URL) async throws -> [CurrencyQuote] {
        let (data, httpResponse) = try await httpClient.get(from: url)
        
        let result = try CurrencyQuoteMapper.map(data, from: httpResponse)
        
        return result
    }
}
