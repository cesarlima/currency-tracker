//
//  CurrencyConverterView.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 11/03/24.
//

import SwiftUI
import CurrencyTrackerCore

struct CurrencyConverterView: View {
    @State var fromAmount: Double = 100
    @State var fromSelectedCurrency = Currency(code: "BRL", name: "Real")
    
    @State var toAmount: Double = 100
    @State var toSelectedCurrency = Currency(code: "USD", name: "Dólar")
    
    let currencies: [Currency] = [
        Currency(code: "BRL", name: "Real"),
        Currency(code: "USD", name: "Dólar"),
        Currency(code: "EUR", name: "Euro"),
        Currency(code: "GBP", name: "Libra Esterlina"),
        Currency(code: "CNY", name: "Yuan Chinês"),
        Currency(code: "BTC", name: "Bitcoin"),
        Currency(code: "LTC", name: "Litecoin"),
        Currency(code: "ETH", name: "Ethereum")
    ]
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    CurrencyView(from: $fromAmount,
                                 selectedCurrency: $fromSelectedCurrency,
                                 currencies: currencies)
                    
                    CurrencyView(from: $toAmount,
                                 selectedCurrency: $toSelectedCurrency,
                                 currencies: currencies)
                    
                    
                    Spacer()
                }
                .navigationTitle("Calculadora")
            }
        }
    }
}

struct CurrencyConverterView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyConverterView()
    }
}
