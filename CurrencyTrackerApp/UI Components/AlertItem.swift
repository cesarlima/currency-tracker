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
