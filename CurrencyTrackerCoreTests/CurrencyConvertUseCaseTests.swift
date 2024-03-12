//
//  CurrencyConvertUseCaseTests.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 12/03/24.
//

import XCTest
import CurrencyTrackerCore

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
        cache.completeFindById(with: makeCurrencyQuoteFromUSDToBRL())
        
        do {
            let receivedAmount = try await sut.convert(from: makeUSDCurrency(), toCurrency: makeBRLCurrency(), amount: 100.0)
            XCTAssertEqual(498.0, receivedAmount, accuracy: 0.1)
        } catch {
            XCTFail("Expected no error but got \(error) instead.")
        }
    }
    
    func test_convert_requestesCacheWithCorrectId() async {
        let (sut, cache) = makeSUT()
        let brl = makeBRLCurrency()
        let usd = makeUSDCurrency()
        let expectedID = "\(usd.code)\(brl.code)"

        cache.completeFindById(with: makeCurrencyQuoteFromUSDToBRL())
        
        do {
            _ = try await sut.convert(from: usd, toCurrency: brl, amount: 100.0)
            XCTAssertEqual(cache.receivedMessages, [.retrieveById(expectedID)])
        } catch {
            XCTFail("Expected no error but got \(error) instead.")
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: CurrencyConvertUseCase, cache: CurrencyQuoteStoreStub) {
        let store = CurrencyQuoteStoreStub()
        let cache = LocalCurrencyQuoteCache(store: store)
        let sut = CurrencyConvertUseCase(currencyQuteCache: cache)
        
        return (sut, store)
    }
    
    private func expect(_ sut: CurrencyConvertUseCase,
                        error expectedError: CurrencyConvertUseCase.Error,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) async {
        var receivedError: CurrencyConvertUseCase.Error?
        action()
        
        do {
            _ = try await sut.convert(from: makeUSDCurrency(), toCurrency: makeBRLCurrency(), amount: 100.0)
        } catch {
            receivedError = error as? CurrencyConvertUseCase.Error
        }
        
        XCTAssertEqual(expectedError, receivedError, file: file, line: line)
    }

    func makeBRLCurrency() -> Currency {
        return Currency(code: "BRL", name: "Real")
    }
    
    func makeUSDCurrency() -> Currency {
        return Currency(code: "USD", name: "Dólar")
    }
    
    func makeCurrencyQuoteFromUSDToBRL() -> CurrencyQuote {
        return CurrencyQuote(name: "Dólar Americano/Real Brasileiro",
                             code: "USD",
                             codeIn: "BRL",
                             quote: 4.98,
                             quoteDate: Date())
    }
}
