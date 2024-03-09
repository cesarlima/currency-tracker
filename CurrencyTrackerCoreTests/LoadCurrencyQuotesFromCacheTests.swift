//
//  LoadCurrencyQuotesFromCacheTests.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 08/03/24.
//

import XCTest
@testable import CurrencyTrackerCore

final class LoadCurrencyQuotesFromCacheTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() async throws {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() async throws {
        let (sut, store) = makeSUT()
        
        _ = try? await sut.load(codeIn: "BRL")
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() async throws {
        let (sut, store) = makeSUT()
        let expectedError = makeNSError()
        var receivedError: NSError?
        store.completeRetrieval(with: expectedError)
        
        do {
            _ = try await sut.load(codeIn: "BRL")
        } catch {
            receivedError = error as NSError
        }
        
        XCTAssertEqual(expectedError, receivedError)
    }
    
    func test_load_deliversEmptyCurrencyQuoteListOnEmptyCache() async throws {
        let (sut, store) = makeSUT()
        store.completeRetrievalWithEmptyCache()
        
        let quotes = try! await sut.load(codeIn: "BRL")
        
        XCTAssertEqual(quotes, [])
    }
    
    func test_load_deliversCurrencyQuotes() async throws {
        let (sut, store) = makeSUT()
        let models = makeCurrencies().models
        store.completeRetrieval(with: models)

        let quotes = try! await sut.load(codeIn: "BRL")

        XCTAssertEqual(quotes, models)
    }
    
    func test_load_hasNoSideEffectsOnRetrievalSuccessful() async throws {
        let (sut, store) = makeSUT()
        store.completeRetrieval(with: makeCurrencies().models)

         _ = try! await sut.load(codeIn: "USD")

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() async throws {
        let (sut, store) = makeSUT()
        store.completeRetrieval(with: makeNSError())

         _ = try? await sut.load(codeIn: "EUR")

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalCurrencyQuoteHandler, store: CurrencyQuoteStoreStub) {
        let store = CurrencyQuoteStoreStub()
        let sut = LocalCurrencyQuoteHandler(store: store)
        
        return (sut, store)
    }
}
