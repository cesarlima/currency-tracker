//
//  Currency.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 10/03/24.
//

import Foundation

public struct Currency: Equatable {
    public let code: String
    public let name: String
    
    public init(code: String, name: String) {
        self.code = code
        self.name = name
    }
}
