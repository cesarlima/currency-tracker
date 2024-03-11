//
//  ContentView.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 10/03/24.
//

import SwiftUI
import CurrencyTrackerCore

struct CurrencyQuoteView: View {
    @StateObject var viewModel: CurrencyQuoteViewModel
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    
                    CurrencyPicker(selectedCurrency: $viewModel.selectedCurrency,
                                   currencies: viewModel.currencies)
                    .onChange(of: viewModel.selectedCurrency) { _ in
                        Task {
                            await viewModel.loadCurrencyQuotes()
                        }
                    }
                    
                    Spacer(minLength: 30)
                    
                    List(viewModel.currencyQuotes) { currency in
                        CurrencyQuoteCell(currencyQuote: currency)
                    }
                    .listStyle(.plain)
                    
                }.navigationTitle("Cotações")
            }
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .onAppear {
            Task {
                await viewModel.loadCurrencyQuotes()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyQuoteView(viewModel: CurrencyQuoteViewModel(currencyQuoteLoadUseCase: CurrencyQuoteLoadUseCaseMock()))
    }
}

private final class CurrencyQuoteLoadUseCaseMock: CurrencyQuoteLoadUseCaseProtocol {
    func load(toCurrency: String, from currencies: [Currency]) async throws -> [CurrencyQuote] {
        return [
            CurrencyQuote(name: "Dólar Americano",
                          code: "USD",
                          codeIn: "BRL",
                          quote: 4.97,
                          quoteDate: Date()),
            CurrencyQuote(name: "Euro",
                          code: "EUR",
                          codeIn: "BRL",
                          quote: 5.39,
                          quoteDate: Date()),
            CurrencyQuote(name: "Bitcoin",
                          code: "BTC",
                          codeIn: "BRL",
                          quote: 337412,
                          quoteDate: Date()),
        ]
    }
}
