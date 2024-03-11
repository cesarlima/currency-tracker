//
//  CurrencyPicker.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 11/03/24.
//

import SwiftUI
import CurrencyTrackerCore

struct CurrencyPicker: View {
    @Binding var selectedCurrency: Currency
    let currencies: [Currency]
    
    var body: some View {
        HStack {
            Text("Moeda:")
                .fontWeight(.bold)
            
            Picker(selection: $selectedCurrency,
                   label: Text(selectedCurrency.name)) {
                
                ForEach(currencies, id: \.name) {
                    Text($0.name).tag($0)
                }
            }
            .tint(Color(.label))
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

struct CurrencyPicker_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyPicker(selectedCurrency: .constant(Currency(code: "Dólar", name: "USD")),
                       currencies: [Currency(code: "BRL", name: "Real"),
                                    Currency(code: "Dólar", name: "USD")])
    }
}
