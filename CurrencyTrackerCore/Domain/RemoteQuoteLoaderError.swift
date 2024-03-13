//
//  RemoteQuoteLoaderError.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 12/03/24.
//

import Foundation

public enum RemoteQuoteLoaderError: Error {
    case invalidResponse
    case invalidData
    case currencyQuoteNotFound
}
