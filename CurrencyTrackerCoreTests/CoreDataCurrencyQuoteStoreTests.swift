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
        
        await performWithoutError {
            let result = try await sut.retrieve(codeIn: "USD")
            XCTAssertEqual(result, [])
        }
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() async {
        let sut = makeSUT()
        
        await performWithoutError {
            try await sut.save(quotes: makeCurrencies().models)
        }
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() async {
        let sut = makeSUT()
        
        await performWithoutError {
            try await sut.save(quotes: makeCurrencies(codeIn: "EUR").models)
            try await sut.save(quotes: makeCurrencies(codeIn: "USD").models)
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
        
        await performWithoutError({
            let currencyCodeIn = "USD"
            try await sut.deleteWhereCodeInEquals(currencyCodeIn)
        })
    }
    
    func test_delete_emptiesPreviousCachedData() async {
        let sut = makeSUT()
        
        await performWithoutError({
            let currencyCodeIn = "USD"
            try await sut.save(quotes: makeCurrencies(codeIn: currencyCodeIn).models)
            try await sut.deleteWhereCodeInEquals(currencyCodeIn)
            let result = try await sut.retrieve(codeIn: currencyCodeIn)
            
            XCTAssertTrue(result!.isEmpty)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> CoreDataCurrencyQuoteStore {
        let storeBundle = Bundle(for: CoreDataCurrencyQuoteStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataCurrencyQuoteStore(storeURL: storeURL, bundle: storeBundle)
        
        return sut
    }
    
    private func performWithoutError(_ action: () async throws -> Void,
                                    file: StaticString = #filePath,
                                    line: UInt = #line) async {
        do {
            try await action()
        } catch {
            XCTFail("Expected no error but got \(error) instead.", file: file, line: line)
        }
    }
}
