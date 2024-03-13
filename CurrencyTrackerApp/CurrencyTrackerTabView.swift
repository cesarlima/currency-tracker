//
//  CurrencyTrackerTabView.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 10/03/24.
//

import SwiftUI

struct CurrencyTrackerTabView: View {
    let appComposer: AppComposer
    
    var body: some View {
        TabView {
            appComposer.composeCurrencyQuoteView()
                .tabItem {
                    Image(systemName: "dollarsign")
                    Text("Cotações")
                        .bold()
                        .foregroundColor(Color.green)
                }
                .toolbarBackground(.visible, for: .tabBar)
                
            appComposer.composeCurrencyConverterView()
                .tabItem {
                    Image(systemName: "candybarphone")
                    Text("Calculadora")
                        .bold()
                        .foregroundColor(Color.green)
                }
                .toolbarBackground(.visible, for: .tabBar)
            
            appComposer.composeCurrencyQuoteView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Histórico")
                        .bold()
                        .foregroundColor(Color.green)
                }
                .toolbarBackground(.visible, for: .tabBar)
        }
    }
}
