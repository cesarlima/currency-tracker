//
//  CurrencyQuoteHandler.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 10/03/24.
//

import Foundation

public protocol CurrencyQuoteCache {
    func save(quotes: [CurrencyQuote]) async throws
    func load(codeIn: String) async throws -> [CurrencyQuote]
}
