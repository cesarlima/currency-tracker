//
//  CurrencySymbol.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 11/03/24.
//

import Foundation

/// Reference https://stackoverflow.com/questions/31999748/get-currency-symbols-from-currency-code-with-swift
final class CurrencySymbol {
    static let shared: CurrencySymbol = CurrencySymbol()

    private var cache: [String:String] = [:]

    func findSymbol(currencyCode: String) -> String {
        if let hit = cache[currencyCode] { return hit }
        guard currencyCode.count < 4 else { return currencyCode }

        let symbol = findSymbolBy(currencyCode)
        cache[currencyCode] = symbol

        return symbol
    }

    private func findSymbolBy(_ currencyCode: String) -> String {
        var candidates: [String] = []
        let locales = NSLocale.availableLocaleIdentifiers

        for localeId in locales {
            guard let symbol = findSymbolBy(localeId, currencyCode) else { continue }
            if symbol.count == 1 { return symbol }
            candidates.append(symbol)
        }

        return candidates.sorted(by: { $0.count < $1.count }).first ?? currencyCode
    }

    private func findSymbolBy(_ localeId: String, _ currencyCode: String) -> String? {
        let locale = Locale(identifier: localeId)
        return currencyCode.caseInsensitiveCompare(locale.currency?.identifier ?? "") == .orderedSame
            ? locale.currencySymbol : nil
    }
}

extension String {
    var currencySymbol: String { return CurrencySymbol.shared.findSymbol(currencyCode: self) }
}
