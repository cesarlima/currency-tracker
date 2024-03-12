//
//  CurrencyQuoteStore.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 08/03/24.
//

import Foundation

public protocol CurrencyQuoteStore {
    func save(quotes: [CurrencyQuote]) async throws
    func deleteWhereCodeInEquals(_ codeIn: String) async throws
    func retrieveWhereCodeInEquals(_ codeIn: String) async throws -> [CurrencyQuote]?
    func retrieveById(id: String) async throws -> CurrencyQuote?
}

public extension CurrencyQuoteStore {
    func retrieveById(id: String) async throws -> CurrencyQuote? {
        return nil
    }
}
