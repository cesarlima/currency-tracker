//
//  CurrencyConvertUseCaseTests.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 12/03/24.
//

import XCTest
import CurrencyTrackerCore

final class CurrencyConvertUseCase {
    private let currencyQuteCache: CurrencyQuoteStoreStub
    
    enum Error: Swift.Error {
        case exchangeRateNotFound
    }
    
    init(currencyQuteCache: CurrencyQuoteStoreStub) {
        self.currencyQuteCache = currencyQuteCache
    }
    
    func convert(from currency: Currency, toCurrency: Currency, amount: Double) async throws -> Double {
        guard let currencyQuote = try? await currencyQuteCache.retrieveById(id: "") else {
            throw Error.exchangeRateNotFound
        }
        
        return  currencyQuote.quote * amount
    }
}

final class CurrencyConvertUseCaseTests: XCTestCase {
    
    func test_convert_deliversErrorOnExchangeRateLoadingOperationCompletesWithError() async {
        let (sut, _) = makeSUT()
        let brl = Currency(code: "BRL", name: "Real")
        let usd = Currency(code: "USD", name: "Dólar")
        let expecteError = CurrencyConvertUseCase.Error.exchangeRateNotFound
        var receivedError: CurrencyConvertUseCase.Error?
        
        do {
            _ = try await sut.convert(from: usd, toCurrency: brl, amount: 100.0)
        } catch {
            receivedError = error as? CurrencyConvertUseCase.Error
        }
        
        XCTAssertEqual(expecteError, receivedError)
    }

    func test_convert_deliversErrorOnExchangeRateLoadingOperationCompletesEmpty() async {
        let (sut, _) = makeSUT()
        let brl = Currency(code: "BRL", name: "Real")
        let usd = Currency(code: "USD", name: "Dólar")
        let expecteError = CurrencyConvertUseCase.Error.exchangeRateNotFound
        var receivedError: CurrencyConvertUseCase.Error?
        
        do {
            _ = try await sut.convert(from: usd, toCurrency: brl, amount: 100.0)
        } catch {
            receivedError = error as? CurrencyConvertUseCase.Error
        }
        
        XCTAssertEqual(expecteError, receivedError)
    }
    
    func test_convert_deliversConvertedValueCorreclty() async {
        let (sut, cache) = makeSUT()
        let brl = Currency(code: "BRL", name: "Real")
        let usd = Currency(code: "USD", name: "Dólar")
        let amout = 100.0
        let currencyQuote = CurrencyQuote(name: "Dólar Americano/Real Brasileiro",
                                          code: "USD",
                                          codeIn: "BRL",
                                          quote: 4.98,
                                          quoteDate: Date())
        cache.completeFindById(with: currencyQuote)
        
        do {
            let receivedAmount = try await sut.convert(from: usd, toCurrency: brl, amount: 100.0)
            XCTAssertEqual(currencyQuote.quote * amout, receivedAmount)
        } catch {
            XCTFail("Expected no error but got \(error) instead.")
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: CurrencyConvertUseCase, cache: CurrencyQuoteStoreStub) {
        let cache = CurrencyQuoteStoreStub()
        let sut = CurrencyConvertUseCase(currencyQuteCache: cache)
        
        return (sut, cache)
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
