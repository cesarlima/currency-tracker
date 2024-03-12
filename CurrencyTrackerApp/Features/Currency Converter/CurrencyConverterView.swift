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

import Combine

class CurrencyConverterViewModel: ObservableObject {
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
