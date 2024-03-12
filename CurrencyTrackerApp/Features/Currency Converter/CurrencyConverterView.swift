//
//  CurrencyConverterView.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 11/03/24.
//

import SwiftUI
import CurrencyTrackerCore

struct CurrencyConverterView: View {
    @FocusState private var currentCurrencyFocused: Bool
    
    @State var fromSelectedCurrency = Currency(code: "", name: "")
    
    @State var toAmount: String = ""
    @State var toSelectedCurrency = Currency(code: "", name: "")
    
    let currencies: [Currency] = MockData.currencies
    
    @StateObject var viewModel: CurrencyConverterViewModel = CurrencyConverterViewModel()
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    CurrencyView(amount: $viewModel.amount,
                                 selectedCurrency: $fromSelectedCurrency,
                                 currencies: MockData.currenciesOringi,
                                 editable: true)
                    .focused($currentCurrencyFocused)
                    
                    CurrencyView(amount: $toAmount,
                                 selectedCurrency: $toSelectedCurrency,
                                 currencies: currencies,
                                 editable: false)
                    
                    Text("A última atualização da cotação de \(fromSelectedCurrency.name) para \(toSelectedCurrency.name) foi em 11/03/2024 15:00")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.top, 32)
                        .padding([.leading, .trailing], 60)
                    
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
