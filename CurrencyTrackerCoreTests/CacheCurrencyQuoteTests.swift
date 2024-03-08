//
//  CacheCurrencyQuoteTests.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 08/03/24.
//

import XCTest

final class LocalCurrencyQuoteHandler {
    
}

final class CurrencyQuoteStore {
    
    enum Messages: Equatable {
    }
    
    private(set) var receivedMessages: [Messages] = []
}

final class CacheCurrencyQuoteTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let store = CurrencyQuoteStore()
        let sut = LocalCurrencyQuoteHandler()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
}
