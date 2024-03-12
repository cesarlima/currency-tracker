//
//  AlertItem.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 11/03/24.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let buttonTitle: String
    
    init(title: String = "Oops",
         message: String,
         buttonTitle: String = "Ok") {
        self.title = Text(title)
        self.message = Text(message)
        self.buttonTitle = buttonTitle
    }
}

enum AlertContext {
    static let loadQuotesGenericError = AlertItem(message: "Não foi possível carregar as cotações, tente novamente em instantes.")
}

// MARK: - Currency Converter
extension AlertContext {
    static let invalidAmount = AlertItem(message: "O valor digitado é inválido.")
    static let exchangeRateNotFound = AlertItem(message: "Não foi possível carregar a cotação desejada.")
    static let exchangeRateGenericError = AlertItem(message: "Não foi possível realizar a conversão.")
}
