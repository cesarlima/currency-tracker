//
//  Currency.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 07/03/24.
//

import Foundation

struct Currency: Equatable {
    let name: String
    let code: String
    let codeIn: String
    let quote: Double
    let quoteDate: Date
}
