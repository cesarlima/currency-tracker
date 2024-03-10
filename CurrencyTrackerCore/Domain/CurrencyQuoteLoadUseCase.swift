//
//  CurrencyQuoteLoadUseCase.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 10/03/24.
//

import Foundation

public protocol CurrencyQuoteLoadUseCaseProtocol {
    func load(toCurrency: String, from currencies: [Currency]) async throws -> [CurrencyQuote]
}

public final class CurrencyQuoteLoadUseCase: CurrencyQuoteLoadUseCaseProtocol {
    private let currencyQuoteLoader: CurrencyQuoteLoader
    private let currencyQuoteCache: CurrencyQuoteCache
    private let url: URL
    
    public init(url: URL, currencyQuoteLoader: CurrencyQuoteLoader, currencyQuoteCache: CurrencyQuoteCache) {
        self.url = url
        self.currencyQuoteLoader = currencyQuoteLoader
        self.currencyQuoteCache = currencyQuoteCache
    }
    
    public func load(toCurrency: String, from currencies: [Currency]) async throws -> [CurrencyQuote] {
        
        let remoteLoadResult = try? await currencyQuoteLoader.load(from: composeURL(toCurrency: toCurrency,
                                                                                    currencies: currencies))
        
        if let remoteLoadResult, remoteLoadResult.isEmpty == false {
            try? await currencyQuoteCache.save(quotes: remoteLoadResult)
            return remoteLoadResult
        }
        
        return try await currencyQuoteCache.load(codeIn: toCurrency)
        
    }
    
    private func composeURL(toCurrency: String, currencies: [Currency]) -> URL {
        let path = currencies
            .filter { $0.code != toCurrency }
            .map { "\($0.code)-\(toCurrency)"}
            .joined(separator: ",")
        return url.appending(path: path)
    }
}
