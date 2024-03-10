//
//  CurrencyTrackerAppApp.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 10/03/24.
//

import SwiftUI

@main
struct CurrencyTrackerAppApp: App {
    private let appComposer = AppComposer.shared
    
    var body: some Scene {
        WindowGroup {
            appComposer.composeCurrencyQuoteView()
        }
    }
}
