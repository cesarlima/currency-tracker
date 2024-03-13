//
//  CurrencyTrackerCoreTests.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 07/03/24.
//

import XCTest
@testable import CurrencyTrackerCore

final class CurrencyQuoteLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() async throws {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT()
        client.completeWithEmptyResponse()
        
        _ = try await sut.load(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT()
        client.completeWithEmptyResponse()
        
     
        _ = try await sut.load(from: url)
        _ = try await sut.load(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientCompletesError() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT()
        client.completeWithError()
        var didFailWithError: Error?
        
        do {
            _ = try await sut.load(from: url)
        } catch {
            didFailWithError = error
        }
        
        XCTAssertNotNil(didFailWithError)
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        let httpCodes = [199, 201, 300, 400, 500]
        
        httpCodes.enumerated().forEach { index, statusCode in
            client.completeSuccess(with: Data("{}".utf8), statusCode: statusCode)
            
            Task {
                var didFailWithError: Error?
                
                do {
                    _ = try await sut.load(from: url)
                } catch {
                    didFailWithError = error
                }
                
                XCTAssertEqual(didFailWithError as! LoadError, .invalidResponse)
            }
        }
    }
    
    func test_load_deliversNotFoundErrorOn404HTTPResponse() async {
        let (sut, client) = makeSUT()
        client.completeSuccess(with: Data("{}".utf8), statusCode: 404)
        
        do {
            _ = try await sut.load(from: anyURL())
        } catch {
            XCTAssertEqual(error as? LoadError, .currencyQuoteNotFound)
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT()
        client.completeSuccess(with: Data("invalid json".utf8))

        var didFailWithError: Error?
        
        do {
            _ = try await sut.load(from: url)
        } catch {
            didFailWithError = error
        }
        
        XCTAssertEqual(didFailWithError as! LoadError, .invalidData)
    }
    
    func test_load_deliversNoCurrenciesOn200HTTPResponseWithEmptyJSON() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT()
        client.completeSuccess(with: Data("{}".utf8), statusCode: 200)
        
        do {
            let currencies = try await sut.load(from: url)
            XCTAssertEqual(currencies, [])
        } catch {
            XCTFail("The load should completes with success.")
        }
    }
    
    func test_load_deliversCurrenciesOn200HTTPResponseWithJSONCurrencies() async throws {
       let (data, expectedCurrencies) = makeCurrencies()
        
        let url = anyURL()
        let (sut, client) = makeSUT()
        client.completeSuccess(with: data, statusCode: 200)
        
        do {
            let currencies = try await sut.load(from: url)
            XCTAssertEqual(currencies, expectedCurrencies)
          
        } catch {
            XCTFail("The load should completes with success.")
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: RemoteCurrencyQuoteLoader, httpClient: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteCurrencyQuoteLoader(httpClient: client)
        
        return (sut, client)
    }
}
