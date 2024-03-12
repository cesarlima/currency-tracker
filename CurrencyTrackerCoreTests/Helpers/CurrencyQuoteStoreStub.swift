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
        case insert([CurrencyQuote])
        case retrieveById(String)
    }
    
    private var deletionResult: Result<Void, Error>?
    private var insertionResult: Result<Void, Error>?
    private var retrievalResult: Result<[CurrencyQuote]?, Error>?
    private var findByIdResult: Result<CurrencyQuote?, Error>?
    
    private(set) var receivedMessages: [ReceivedMessage] = []
    
    func deleteWhereCodeInEquals(_ codeIn: String) async throws {
        receivedMessages.append(.deleteCachedCurrencyQuote(codeIn))
        try deletionResult?.get()
    }
    
    func completeDeletion(with error: Error) {
        deletionResult = .failure(error)
    }
    
    func completeDeletionSuccessfully() {
        deletionResult = .success(())
    }
    
    func save(quotes: [CurrencyQuote]) async throws {
        receivedMessages.append(.insert(quotes))
        try insertionResult?.get()
    }
    
    func completeInsertion(with error: Error) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully() {
        insertionResult = .success(())
    }
    
    func retrieveWhereCodeInEquals(_ codeIn: String) async throws -> [CurrencyQuote]? {
        receivedMessages.append(.retrieve)
        let result = try retrievalResult?.get()
        return result
    }
    
    func completeRetrieval(with error: Error) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrieval(with quotes: [CurrencyQuote]) {
        retrievalResult = .success(quotes)
    }
    
    func completeRetrievalWithEmptyCache() {
        retrievalResult = .success(.none)
    }
    
    func retrieveById(id: String) async throws -> CurrencyQuote? {
        receivedMessages.append(.retrieveById(id))
        return try findByIdResult?.get()
    }
    
    func completeFindById(with currencyQuote: CurrencyQuote) {
        findByIdResult = .success(currencyQuote)
    }
    
    func completeFindById(with error: Error) {
        findByIdResult = .failure(error)
    }
    
    func completeFindByIdWithEmpty() {
        findByIdResult = .success(.none)
    }
}
