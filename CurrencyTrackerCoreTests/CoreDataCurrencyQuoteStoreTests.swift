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
        
        XCTAssertEqual(result, [])
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() async {
        let sut = makeSUT()
        
        do {
            try await sut.save(quotes: makeCurrencies().models)
        } catch {
            XCTFail("Expected no error but got \(error) instead.")
        }
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() async {
        let sut = makeSUT()
        
        do {
            try await sut.save(quotes: makeCurrencies(codeIn: "EUR").models)
            try await sut.save(quotes: makeCurrencies(codeIn: "USD").models)
        } catch {
            XCTFail("Expected no error but got \(error) instead.")
        }
    }
    
    func test_insert_deliversErrorOnInsertDuplicatedCombinationOfCodeAndCodeIn() async {
        let sut = makeSUT()
        
        do {
            try await sut.save(quotes: makeCurrencies(codeIn: "BRL").models)
            try await sut.save(quotes: makeCurrencies(codeIn: "BRL").models)
        } catch {
            XCTAssertNotNil(error, "Expected an error when attempting to insert a duplicate combination of code and codeIn values, as they form the unique identifier of a currency quote.")
        }
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() async {
        let sut = makeSUT()
        
        do {
            let currencyCodeIn = "USD"
            try await sut.deleteWhereCodeInEquals(currencyCodeIn)
        } catch {
            XCTFail("Expected no error but got \(error) instead.")
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> CoreDataCurrencyQuoteStore {
        let storeBundle = Bundle(for: CoreDataCurrencyQuoteStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataCurrencyQuoteStore(storeURL: storeURL, bundle: storeBundle)
        
        return sut
    }
}
