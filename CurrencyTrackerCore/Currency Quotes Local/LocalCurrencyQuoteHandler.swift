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
        
        try await store.delete(with: codeIn)
        try await store.save(quotes: quotes)
    }
    
    func load(codeIn: String) async throws {
        try await store.retrieve(codeIn: codeIn)
    }
}
