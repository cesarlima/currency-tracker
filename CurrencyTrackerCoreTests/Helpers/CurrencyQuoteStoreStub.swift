//
//  CurrencyQuoteStoreStub.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 08/03/24.
//

import Foundation
@testable import CurrencyTrackerCore

final class CurrencyQuoteStoreStub: CurrencyQuoteStore {
    
    enum ReceivedMessage: Equatable {
        case deleteCachedCurrencyQuote(String)
        case retrieve
    }
    
    private var deletionResult: Result<Void, Error>?
    private var insertionResult: Result<Void, Error>?
    private var retrievalResult: Result<Void, Error>?
    
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
    
    func retrieve(codeIn: String) async throws {
        receivedMessages.append(.retrieve)
        try retrievalResult?.get()
    }
    
    func completeRetrieval(with error: Error) {
        retrievalResult = .failure(error)
    }
}
