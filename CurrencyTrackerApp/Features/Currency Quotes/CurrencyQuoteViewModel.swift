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
    @Published var selectedCurrency = Currency.brl
    @Published private(set) var currencyQuotes: [CurrencyQuote] = []
    @Published var isShowingAlert = false
    let currencies = Currency.availables
    private(set) var alertItem: AlertItem? {
        didSet {
            isShowingAlert = true
        }
    }
    
    private let currencyQuoteLoadUseCase: CurrencyQuoteLoadUseCaseProtocol
    
    init(currencyQuoteLoadUseCase: CurrencyQuoteLoadUseCaseProtocol) {
        self.currencyQuoteLoadUseCase = currencyQuoteLoadUseCase
    }
    
    @MainActor
    func loadCurrencyQuotes() async {
        defer { isLoading = false }
        
        isLoading = true
        do {
            let result = try await currencyQuoteLoadUseCase.load(toCurrency: selectedCurrency.code,
                                                                 from: currencies)
            if result.isEmpty {
                alertItem = AlertContext.loadQuotesGenericError
            }
            
            currencyQuotes = result
        } catch {
            if let receivedError = error as? RemoteQuoteLoaderError,
               case RemoteQuoteLoaderError.currencyQuoteNotFound = receivedError {
                alertItem = AlertContext.currencyQuotesNotFound
            } else {
                alertItem = AlertContext.loadQuotesGenericError
            }
        }
    }
}
