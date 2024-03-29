//
//  CurrencyView.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 11/03/24.
//

import SwiftUI
import CurrencyTrackerCore
import Combine

struct CurrencyView: View {
    @Binding var amount: String
    @Binding var selectedCurrency: Currency
    let currencies: [Currency]
    let editable: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.gray, lineWidth: 0.5)
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .padding(16)
            .overlay(
                VStack(alignment: .center, spacing:3) {
                    
                    HStack {
                        Text(selectedCurrency.code)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 10)
                            .font(.caption)

                        Picker(selection: $selectedCurrency,
                               label: Text(selectedCurrency.name)) {
                            ForEach(currencies, id: \.name) {
                                Text($0.name).tag($0)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topTrailing)
                        .tint(Color(.label))
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Text(selectedCurrency.code.currencySymbol)
                            .font(.title2)
                        
                        TextField("", text: $amount)
                            .font(.title2)
                            .keyboardType(.decimalPad)
                            .disabled(!editable)
                    }.padding(.leading, 10)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
            )
    }
}

struct CurrencyView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyView(amount: .constant("1"),
                     selectedCurrency: .constant(MockData.currencySample),
                     currencies: MockData.currencies,
                     editable: true)
    }
}
