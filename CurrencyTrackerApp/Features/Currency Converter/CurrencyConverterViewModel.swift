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
    @Published var fromCurrency = Currency.usd
    @Published var toCurrencyAmount: String = ""
    @Published var toCurrency = Currency.brl
    @Published var isShowingAlert = false
    let currencies = Currency.availables
    private(set) var alertItem: AlertItem? {
        didSet {
            isShowingAlert = true
        }
    }
    
    private let useCase: CurrencyConvertUseCase
    private var cancellables = Set<AnyCancellable>()
    
    var isConvertButtonDisabled: Bool {
        return fromCurrency.code.isEmpty
        || toCurrency.code.isEmpty
        || fromCurrencyAmount.isEmpty
    }
    
    init(useCase: CurrencyConvertUseCase) {
        self.useCase = useCase
        
        formatFromCurrencyAmount()
        cleanToCurrencyAmountOnFromCurrencyChanges()
        cleanToCurrencyAmountOnToCurrencyChanges()
    }
    
    @MainActor
    func convert() {
        guard let value = Formatter.fromBRLFormatedCurrency(fromCurrencyAmount) else {
            alertItem = AlertContext.invalidAmount
            return
        }
        
        Task {
            do {
                let result = try await useCase.convert(from: fromCurrency,
                                                       toCurrency: toCurrency,
                                                       amount: value)
                
                toCurrencyAmount = Formatter.toBRLFormatedCurrency(result)
            } catch {
                guard let _ = error as? CurrencyConvertUseCase.Error else {
                    alertItem = AlertContext.exchangeRateGenericError
                    return
                }
                
                alertItem = AlertContext.exchangeRateNotFound
            }
        }
    }
    
    private func cleanToCurrencyAmountOnToCurrencyChanges() {
        $toCurrency
            .sink { [weak self] _ in
                self?.toCurrencyAmount = ""
            }
            .store(in: &cancellables)
    }
    
    private func cleanToCurrencyAmountOnFromCurrencyChanges() {
        $fromCurrency
            .sink { [weak self] _ in
                self?.toCurrencyAmount = ""
            }
            .store(in: &cancellables)
    }
    
    private func formatFromCurrencyAmount() {
        $fromCurrencyAmount
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] newValue in
                guard let value = Formatter.fromBRLFormatedCurrency(newValue) else { return }
                self?.fromCurrencyAmount = Formatter.toBRLFormatedCurrency(value)
            }
            .store(in: &cancellables)
    }
}
