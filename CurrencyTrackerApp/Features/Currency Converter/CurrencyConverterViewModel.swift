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
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt-BR")
        return formatter
    }()
    
    @Published var fromCurrencyAmount: String = ""
    @Published var fromCurrency: Currency = Currency(code: "", name: "")
    @Published var toCurrencyAmount: String = ""
    @Published var toCurrency: Currency = Currency(code: "", name: "")
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $fromCurrencyAmount
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] newValue in
                guard let value = Double(newValue) else { return }
                let currencyAmmount = self?.formatter.string(from: NSNumber(value: value)) ?? ""
                self?.fromCurrencyAmount = currencyAmmount.replacingOccurrences(of: "R$", with: "").trimmingCharacters(in: .whitespaces)
            }
            .store(in: &cancellables)
        
        $toCurrencyAmount
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] newValue in
                guard let value = Double(newValue) else { return }
                let currencyAmmount = self?.formatter.string(from: NSNumber(value: value)) ?? ""
                self?.fromCurrencyAmount = currencyAmmount.replacingOccurrences(of: "R$", with: "").trimmingCharacters(in: .whitespaces)
            }
            .store(in: &cancellables)
    }
}
