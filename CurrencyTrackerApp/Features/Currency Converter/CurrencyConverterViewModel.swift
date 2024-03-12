//
//  CurrencyConverterViewModel.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 12/03/24.
//

import SwiftUI
import Combine
import CurrencyTrackerCore

final class CurrencyConverterViewModel: ObservableObject {
    @Published var fromCurrencyAmount: String = "1"
    @Published var fromCurrency: Currency = Currency(code: "USD", name: "Dólar")
    @Published var toCurrencyAmount: String = ""
    @Published var toCurrency: Currency = Currency(code: "BRL", name: "Real")
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $fromCurrencyAmount
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] newValue in
                guard let value = Formatter.fromBRLFormatedCurrency(newValue) else { return }
                self?.fromCurrencyAmount = Formatter.toBRLFormatedCurrency(value)
            }
            .store(in: &cancellables)
    }
}

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
