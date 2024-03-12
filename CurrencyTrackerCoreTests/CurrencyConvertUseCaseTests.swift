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
        let currencyQuoteId = makeCurrencyQuoteID(from: currency, toCurrency: toCurrency)
        guard let currencyQuote = try? await currencyQuteCache.retrieveById(id: currencyQuoteId) else {
            throw Error.exchangeRateNotFound
        }
        
        return  currencyQuote.quote * amount
    }
    
    private func makeCurrencyQuoteID(from currency: Currency, toCurrency: Currency) -> String {
        return "\(currency.code)\(toCurrency.code)"
    }
}

final class CurrencyConvertUseCaseTests: XCTestCase {
    
    func test_convert_deliversErrorOnExchangeRateLoadingOperationCompletesWithError() async {
        let (sut, cache) = makeSUT()
        
        await expect(sut, error: .exchangeRateNotFound) {
            cache.completeFindById(with: makeNSError())
        }
    }
    
    func test_convert_deliversErrorOnExchangeRateLoadingOperationCompletesEmpty() async {
        let (sut, cache) = makeSUT()
        
        await expect(sut, error: .exchangeRateNotFound) {
            cache.completeFindByIdWithEmpty()
        }
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
    
    func test_convert_requestesCacheWithCorrectId() async {
        let (sut, cache) = makeSUT()
        let brl = Currency(code: "BRL", name: "Real")
        let usd = Currency(code: "USD", name: "Dólar")
        let expectedID = "\(usd.code)\(brl.code)"
        let currencyQuote = CurrencyQuote(name: "Dólar Americano/Real Brasileiro",
                                          code: "USD",
                                          codeIn: "BRL",
                                          quote: 4.98,
                                          quoteDate: Date())
        cache.completeFindById(with: currencyQuote)
        
        do {
            _ = try await sut.convert(from: usd, toCurrency: brl, amount: 100.0)
            XCTAssertEqual(cache.receivedMessages, [.retrieveById(expectedID)])
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
    
    private func expect(_ sut: CurrencyConvertUseCase,
                        error expectedError: CurrencyConvertUseCase.Error,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) async {
        let brl = Currency(code: "BRL", name: "Real")
        let usd = Currency(code: "USD", name: "Dólar")
        var receivedError: CurrencyConvertUseCase.Error?
        action()
        
        do {
            _ = try await sut.convert(from: usd, toCurrency: brl, amount: 100.0)
        } catch {
            receivedError = error as? CurrencyConvertUseCase.Error
        }
        
        XCTAssertEqual(expectedError, receivedError, file: file, line: line)
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
