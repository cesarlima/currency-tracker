//
//  CurrencyQuoteStore.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 08/03/24.
//

import Foundation

protocol CurrencyQuoteStore {
    func save(quotes: [CurrencyQuote]) async throws
    func delete(with codeIn: String) async throws
}
