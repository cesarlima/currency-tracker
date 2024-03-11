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
        NavigationStack {
            VStack {
                
                HStack {
                    Text("Moeda:")
                        .fontWeight(.bold)
                    Picker(selection: $viewModel.selectedCurrency,
                           label: Text(viewModel.selectedCurrency.name)) {
                        
                        ForEach(viewModel.currencies, id: \.name) {
                            Text($0.name).tag($0)
                        }
                    }
                    .tint(Color(.label))
                    .onChange(of: viewModel.selectedCurrency) { newValue in
                        Task {
                            await viewModel.loadCurrencyQuotes()
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Spacer(minLength: 30)
                
                List(viewModel.currencyQuotes) { currency in
                    HStack(alignment: .center) {
                        Text(currency.code)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(currency.name)
                            Text(currency.quote, format: .currency(code: currency.codeIn))
                            Text(DateFormatter.format(date: currency.quoteDate))
                        }
                        .frame(width: 170, alignment: .leading)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    print("refreshing")
                }
                
            }.navigationTitle("Cotações")
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
