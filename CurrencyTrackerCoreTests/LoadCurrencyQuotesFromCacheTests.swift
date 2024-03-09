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
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalCurrencyQuoteHandler, store: CurrencyQuoteStoreStub) {
        let store = CurrencyQuoteStoreStub()
        let sut = LocalCurrencyQuoteHandler(store: store)
        
        return (sut, store)
    }
}
