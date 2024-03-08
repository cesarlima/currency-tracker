//
//  Currency.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 07/03/24.
//

import Foundation

public struct Currency: Equatable, Identifiable {
    public var id: String {
        return code
    }
    public let name: String
    public let code: String
    public let codeIn: String
    public let quote: Double
    public let quoteDate: Date
    
    public init(name: String, code: String, codeIn: String, quote: Double, quoteDate: Date) {
        self.name = name
        self.code = code
        self.codeIn = codeIn
        self.quote = quote
        self.quoteDate = quoteDate
    }
}
