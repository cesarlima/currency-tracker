//
//  Currency+Extension.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 12/03/24.
//

import CurrencyTrackerCore

extension Currency {
    static let usd = Currency(code: "USD", name: "Dólar")
    static let brl = Currency(code: "BRL", name: "Real")
    
    static let availables = [
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
