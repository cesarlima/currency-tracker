//
//  CoreDataCurrencyQuoteStoreTests.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 09/03/24.
//

import XCTest
@testable import CurrencyTrackerCore

final class CoreDataCurrencyQuoteStoreTests: XCTestCase {

    func test_retrieve_deliversNilOnEmptyCache() async throws {
        let sut = makeSUT()
        
        let result = try await sut.retrieve(codeIn: "USD")
        
        XCTAssertEqual(result, nil)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> CoreDataCurrencyQuoteStore {
        let storeBundle = Bundle(for: CoreDataCurrencyQuoteStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataCurrencyQuoteStore(storeURL: storeURL, bundle: storeBundle)
        
        return sut
    }
}
