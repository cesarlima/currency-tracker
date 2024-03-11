//
//  CurrencyQuoteViewModel.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 10/03/24.
//

import SwiftUI
import CurrencyTrackerCore

final class CurrencyQuoteViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published var selectedCurrency: Currency = Currency(code: "BRL", name: "Real")
    @Published private(set) var currencyQuotes: [CurrencyQuote] = []
    
    let currencies: [Currency] = [
        Currency(code: "BRL", name: "Real"),
        Currency(code: "USD", name: "Dólar"),
        Currency(code: "EUR", name: "Euro"),
        Currency(code: "BTC", name: "Bitcoin")
    ]
    
    private let currencyQuoteLoadUseCase: CurrencyQuoteLoadUseCaseProtocol
    
    init(currencyQuoteLoadUseCase: CurrencyQuoteLoadUseCaseProtocol) {
        self.currencyQuoteLoadUseCase = currencyQuoteLoadUseCase
    }
    
    @MainActor
    func loadCurrencyQuotes() async {
        defer { isLoading = false }
        
        isLoading = true
        do {
            currencyQuotes = try await currencyQuoteLoadUseCase.load(toCurrency: selectedCurrency.code,
                                                                     from: currencies)
        } catch {
            print("--->>>", error)
        }
    }
}
