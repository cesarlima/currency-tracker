//
//  CurrencyQuoteLoader.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 07/03/24.
//

import Foundation

protocol CurrencyQuoteLoader {
    func load() async throws -> [Currency]
}
