//
//  CurrencyConvertUseCaseTests.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 12/03/24.
//

import XCTest
import CurrencyTrackerCore

final class CurrencyConvertUseCase {
    
    enum Error: Swift.Error {
        case exchangeRateNotFound
    }
    
    func convert(from currency: Currency, toCurrency: Currency) async throws {
        throw Error.exchangeRateNotFound
    }
}

final class CurrencyConvertUseCaseTests: XCTestCase {
    
    func test_convert_deliversErrorOnExchangeRateLoadingOperationCompletesWithError() async {
        let sut = CurrencyConvertUseCase()
        let brl = Currency(code: "BRL", name: "Real")
        let usd = Currency(code: "USD", name: "Dólar")
        var expecteError = CurrencyConvertUseCase.Error.exchangeRateNotFound
        var receivedError: CurrencyConvertUseCase.Error?
        
        do {
            try await sut.convert(from: usd, toCurrency: brl)
        } catch {
            receivedError = error as? CurrencyConvertUseCase.Error
        }
        
        XCTAssertEqual(expecteError, receivedError)
    }

    func test_convert_deliversErrorOnExchangeRateLoadingOperationCompletesEmpty() async {
        let sut = CurrencyConvertUseCase()
        let brl = Currency(code: "BRL", name: "Real")
        let usd = Currency(code: "USD", name: "Dólar")
        var expecteError = CurrencyConvertUseCase.Error.exchangeRateNotFound
        var receivedError: CurrencyConvertUseCase.Error?
        
        do {
            try await sut.convert(from: usd, toCurrency: brl)
        } catch {
            receivedError = error as? CurrencyConvertUseCase.Error
        }
        
        XCTAssertEqual(expecteError, receivedError)
    }
}

private func makeCurrenciesModel() -> [Currency] {
    return [
        Currency(code: "BRL", name: "Real"),
        Currency(code: "USD", name: "Dólar"),
        Currency(code: "EUR", name: "Euro"),
        Currency(code: "BTC", name: "Bitcoin"),
    ]
}
