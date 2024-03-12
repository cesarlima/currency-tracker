//
//  LocalCurrencyQuoteHandler.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 08/03/24.
//

import Foundation

public final class LocalCurrencyQuoteCache: CurrencyQuoteCache {
    private let store: CurrencyQuoteStore
    
    public init(store: CurrencyQuoteStore) {
        self.store = store
    }
    
    public func save(quotes: [CurrencyQuote]) async throws {
        guard let codeIn = quotes.first?.codeIn else { return }
        
        try await store.deleteWhereCodeInEquals(codeIn)
        try await store.save(quotes: quotes)
    }
    
    public func load(codeIn: String) async throws -> [CurrencyQuote] {
        return try await store.retrieveWhereCodeInEquals(codeIn) ?? []
    }
    
    public func retrieveById(id: String) async throws -> CurrencyQuote? {
        return try await store.retrieveById(id: id)
    }
}
