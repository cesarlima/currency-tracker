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
    
    func test_load_requestsCacheRetrieval()  async throws {
        let (sut, store) = makeSUT()
        
        _ = try? await sut.load(codeIn: "BRL")
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalCurrencyQuoteHandler, store: CurrencyQuoteStoreStub) {
        let store = CurrencyQuoteStoreStub()
        let sut = LocalCurrencyQuoteHandler(store: store)
        
        return (sut, store)
    }
}
