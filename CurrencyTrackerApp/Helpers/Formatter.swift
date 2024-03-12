//
//  Formatter.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 12/03/24.
//

import Foundation

enum Formatter {
    static func toBRLFormatedCurrency(_ value: Double) -> String {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "pt-BR")
        let currencyAmmount = formatter.string(from: NSNumber(value: value)) ?? ""
        return currencyAmmount.replacingOccurrences(of: "R$", with: "").trimmingCharacters(in: .whitespaces)
    }
    
    static func fromBRLFormatedCurrency(_ value: String) -> Double? {
        let valueWithOutComma = value.replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
        return Double(valueWithOutComma)
    }
}
