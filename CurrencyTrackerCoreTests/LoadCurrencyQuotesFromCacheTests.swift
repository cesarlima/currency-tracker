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
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalCurrencyQuoteHandler, store: CurrencyQuoteStoreStub) {
        let store = CurrencyQuoteStoreStub()
        let sut = LocalCurrencyQuoteHandler(store: store)
        
        return (sut, store)
    }
}

private final class CurrencyQuoteStoreStub: CurrencyQuoteStore {
    
    enum ReceivedMessage: Equatable {
        case deleteCachedCurrencyQuote(String)
    }
    
    private var deletionResult: Result<Void, Error>?
    private var insertionResult: Result<Void, Error>?
    
    private(set) var receivedMessages: [ReceivedMessage] = []
    
    func delete(with codeIn: String) async throws {
        receivedMessages.append(.deleteCachedCurrencyQuote(codeIn))
        try deletionResult?.get()
    }
    
    func completeDeletion(with error: Error) {
        deletionResult = .failure(error)
    }
    
    func save(quotes: [CurrencyQuote]) async throws {
        try insertionResult?.get()
    }
    
    func completeInsertion(with error: Error) {
        insertionResult = .failure(error)
    }
}
