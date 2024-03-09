//
//  CacheCurrencyQuoteTests.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 08/03/24.
//

import XCTest
@testable import CurrencyTrackerCore

final class CacheCurrencyQuoteTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() async throws {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() async throws {
        let (sut, store) = makeSUT()
        let models = makeCurrencies().models
        store.completeDeletion(with: makeNSError())
        
        try? await sut.save(quotes: models)
    
        XCTAssertEqual(store.receivedMessages, [.deleteCachedCurrencyQuote(models.first!.codeIn)])
    }
    
    func test_save_failsOnDeletionError() async throws {
        let (sut, store) = makeSUT()
        let deletionError = makeNSError()
        
        await expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() async throws {
        let (sut, store) = makeSUT()
        let insertionError = makeNSError()
        
        await expect(sut, toCompleteWithError: insertionError) {
            store.completeInsertion(with: insertionError)
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalCurrencyQuoteHandler, store: CurrencyQuoteStoreStub) {
        let store = CurrencyQuoteStoreStub()
        let sut = LocalCurrencyQuoteHandler(store: store)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalCurrencyQuoteHandler,
                        toCompleteWithError expectedError: NSError,
                        when storeAction: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) async {
        storeAction()
        var receivedError: NSError?
        
        do {
            try await sut.save(quotes: makeCurrencies().models)
        } catch {
            receivedError = error as NSError
        }
        
        XCTAssertEqual(expectedError, receivedError, file: file, line: line)
    }
}
