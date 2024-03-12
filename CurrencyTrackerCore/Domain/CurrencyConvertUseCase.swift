//
//  CurrencyConvertUseCase.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 12/03/24.
//

import Foundation

public final class CurrencyConvertUseCase {
    private let currencyQuteCache: CurrencyQuoteCache
    
    public enum Error: Swift.Error {
        case exchangeRateNotFound
    }
    
    public init(currencyQuteCache: CurrencyQuoteCache) {
        self.currencyQuteCache = currencyQuteCache
    }
    
    public func convert(from currency: Currency, toCurrency: Currency, amount: Double) async throws -> Double {
        let currencyQuoteId = makeCurrencyQuoteID(from: currency, toCurrency: toCurrency)
        guard let currencyQuote = try? await currencyQuteCache.retrieveById(id: currencyQuoteId) else {
            throw Error.exchangeRateNotFound
        }
        
        return  currencyQuote.quote * amount
    }
    
    private func makeCurrencyQuoteID(from currency: Currency, toCurrency: Currency) -> String {
        return "\(currency.code)\(toCurrency.code)"
    }
}
