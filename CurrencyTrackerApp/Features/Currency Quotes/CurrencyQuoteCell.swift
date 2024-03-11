//
//  CurrencyQuoteCell.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 11/03/24.
//

import SwiftUI
import CurrencyTrackerCore

struct CurrencyQuoteCell: View {
    let currencyQuote: CurrencyQuote
    
    var body: some View {
        HStack(alignment: .center) {
            Text(currencyQuote.code)
                .fontWeight(.bold)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 6) {
                Text(currencyQuote.name)
                Text(currencyQuote.quote, format: .currency(code: currencyQuote.codeIn))
                Text(DateFormatter.format(date: currencyQuote.quoteDate))
            }
            .frame(width: 170, alignment: .leading)
        }
    }
}

struct CurrencyQuoteCell_Previews: PreviewProvider {
    
    static var previews: some View {
        CurrencyQuoteCell(currencyQuote: CurrencyQuote(name: "Bitcoin",
                                                       code: "BTC",
                                                       codeIn: "BRL",
                                                       quote: 337412,
                                                       quoteDate: Date()))
    }
}
