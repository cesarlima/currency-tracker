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
            let result = try await sut.retrieveWhereCodeInEquals("USD")
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
            let result = try await sut.retrieveWhereCodeInEquals(currencyCodeIn)
            
            XCTAssertTrue(result!.isEmpty)
        })
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() async {
        let sut = makeSUT()
        
        await performWithoutError({
            let currencyCodeIn = "BTC"
            let exptectedModelsToBeRetrieved = makeCurrencies(codeIn: currencyCodeIn).models.sorted { $0.id < $1.id }
            let notExptectedModelsToBeRetrieved = makeCurrencies(codeIn: "BRL").models
            
            try await sut.save(quotes: exptectedModelsToBeRetrieved)
            try await sut.save(quotes: notExptectedModelsToBeRetrieved)
            let retriviedModels = try await sut.retrieveWhereCodeInEquals(currencyCodeIn)!
            let sortedretriviedModels = retriviedModels.sorted { $0.id < $1.id }
            
            XCTAssertEqual(exptectedModelsToBeRetrieved, sortedretriviedModels)
        })
    }
    
    func test_retrieveById_deliversCorrectFoundValue() async {
        let sut = makeSUT()
        
        await performWithoutError({
            let idToRetrieve = "USDBRL"
            let currencyQuoteModels = makeCurrencies(codeIn: "BRL").models
            let expectedResult = currencyQuoteModels.first { $0.id == idToRetrieve }!
            try await sut.save(quotes: currencyQuoteModels)

            let receivedResult = try await sut.retrieveById(id: idToRetrieve)
            
            XCTAssertEqual(expectedResult, receivedResult)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> CoreDataCurrencyQuoteStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataCurrencyQuoteStore(storeURL: storeURL)
        
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
