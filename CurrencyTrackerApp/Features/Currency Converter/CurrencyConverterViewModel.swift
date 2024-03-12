//
//  CurrencyConverterViewModel.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 12/03/24.
//

import SwiftUI
import Combine

final class CurrencyConverterViewModel: ObservableObject {
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt-BR")
        return formatter
    }()
    
    @Published var amount: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    init() {
        $amount
            .debounce(for: 0.7, scheduler: RunLoop.main)
            .sink { [weak self] newValue in
                guard let value = Double(newValue) else { return }
                let currencyAmmount = self?.formatter.string(from: NSNumber(value: value)) ?? ""
                self?.amount = currencyAmmount.replacingOccurrences(of: "R$", with: "").trimmingCharacters(in: .whitespaces)
            }
            .store(in: &cancellables)
    }
}
