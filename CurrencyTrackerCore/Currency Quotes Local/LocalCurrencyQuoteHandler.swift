//
//  LocalCurrencyQuoteHandler.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 08/03/24.
//

import Foundation

final class LocalCurrencyQuoteHandler {
    private let store: CurrencyQuoteStore
    
    init(store: CurrencyQuoteStore) {
        self.store = store
    }
    
    func save(quotes: [CurrencyQuote]) async throws {
        guard let codeIn = quotes.first?.codeIn else { return }
        
        try await store.deleteWhereCodeInEquals(codeIn)
        try await store.save(quotes: quotes)
    }
    
    func load(codeIn: String) async throws -> [CurrencyQuote] {
        return try await store.retrieveWhereCodeInEquals(codeIn) ?? []
    }
}
