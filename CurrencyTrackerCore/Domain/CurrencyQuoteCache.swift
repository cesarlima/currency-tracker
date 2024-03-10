//
//  CurrencyQuoteHandler.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 10/03/24.
//

import Foundation

protocol CurrencyQuoteCache {
    func save(quotes: [CurrencyQuote]) async throws
    func load(codeIn: String) async throws -> [CurrencyQuote]
}
