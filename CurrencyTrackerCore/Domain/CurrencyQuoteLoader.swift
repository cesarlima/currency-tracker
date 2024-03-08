//
//  CurrencyQuoteLoader.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 07/03/24.
//

import Foundation

public protocol CurrencyQuoteLoader {
    func load() async throws -> [Currency]
}
