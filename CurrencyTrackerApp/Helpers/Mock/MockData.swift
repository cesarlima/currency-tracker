//
//  MockData.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 11/03/24.
//

import Foundation
import CurrencyTrackerCore

enum MockData {
    static let currencySample = Currency(code: "", name: "")
    
    static let currenciesOringi: [Currency] = [
        Currency(code: "", name: ""),
        Currency(code: "BRL", name: "Real"),
        Currency(code: "USD", name: "Dólar"),
        Currency(code: "EUR", name: "Euro"),
    ]
    
    static let currencies: [Currency] = [
        Currency(code: "", name: ""),
        Currency(code: "BRL", name: "Real"),
        Currency(code: "USD", name: "Dólar"),
        Currency(code: "EUR", name: "Euro"),
        Currency(code: "GBP", name: "Libra Esterlina"),
        Currency(code: "CNY", name: "Yuan Chinês"),
        Currency(code: "BTC", name: "Bitcoin"),
        Currency(code: "LTC", name: "Litecoin"),
        Currency(code: "ETH", name: "Ethereum")
    ]
}
