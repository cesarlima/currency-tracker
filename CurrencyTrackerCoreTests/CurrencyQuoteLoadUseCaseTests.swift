//
//  CurrencyQuoteLoadUseCaseTests.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 10/03/24.
//

import XCTest
@testable import CurrencyTrackerCore

final class CurrencyQuoteLoadUseCaseTests: XCTestCase {

    func test_load_requestsRemoteLoaderWithACorrectURL() async {
        let currencies = makeCurrenciesModel()
        let toCurrency = "BRL"
        let baseURL = makeBaseURL()
        let expectedPath = "USD-BRL,EUR-BRL,BTC-BRL"
        let expectedURL = baseURL.appending(path: expectedPath)
        let (sut, _, httpClient) = makeSUT(url: baseURL)
        httpClient.completeWithEmptyResponse()

        _ = try! await sut.load(toCurrency: toCurrency, from: currencies)

        XCTAssertEqual(httpClient.requestedURLs, [expectedURL])
    }
    
    func test_load_requestsCacheToLoadOnRemoteLoadCompletionEmpty() async {
        let (sut, store, httpClient) = makeSUT()
        httpClient.completeWithEmptyResponse()

        _ = try! await sut.load(toCurrency: "BRL", from: makeCurrenciesModel())

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_requestsCacheToLoadOnRemoteLoadCompletionError() async {
        let (sut, store, httpClient) = makeSUT()
        httpClient.completeWithError()
        
        await performWithoutError {
            _ = try await sut.load(toCurrency: "BRL", from: makeCurrenciesModel())
        }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_cacheResponseOnRemoteLoadCompletesWithValues() async {
        let (sut, store, httpClient) = makeSUT()
        let toCurrency = "BRL"
        httpClient.completeSuccess(with: makeCurrencies().data)
        
        await performWithoutError {
            _ = try await sut.load(toCurrency: toCurrency, from: makeCurrenciesModel())
        }

        XCTAssertEqual(store.receivedMessages, [.deleteCachedCurrencyQuote(toCurrency), .insert(makeCurrencies().models)])
    }
    
    func test_load_deliversNotFoundErrorOnRemoteLoadCompletesWithNotFound() async {
        let (sut, _, httpClient) = makeSUT()
        httpClient.completeSuccess(with: makeCurrencies().data, statusCode: 404)
        
        do {
            _ = try await sut.load(toCurrency: "BRL", from: makeCurrenciesModel())
            XCTAssertEqual(httpClient.requestedURLs.count, 1)
            XCTFail("Expected failure but got success instead.")
        } catch {
            XCTAssertEqual(error as? RemoteQuoteLoaderError, .currencyQuoteNotFound)
        }
    }

    // MARK: - Helpers
    
    private func makeSUT(url: URL = makeBaseURL()) -> (sut: CurrencyQuoteLoadUseCase,
                                                       store: CurrencyQuoteStoreStub,
                                                       httpClient: HttpClientSpy) {
        let store = CurrencyQuoteStoreStub()
        let httpClient = HttpClientSpy()
        let quoteCache = LocalCurrencyQuoteCache(store: store)
        let quoteLoader = RemoteCurrencyQuoteLoader(httpClient: httpClient)
        let sut = CurrencyQuoteLoadUseCase(url: url, currencyQuoteLoader: quoteLoader, currencyQuoteCache: quoteCache)
        
        return (sut, store, httpClient)
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

private func makeCurrenciesModel() -> [Currency] {
    return [
        Currency(code: "BRL", name: "Real"),
        Currency(code: "USD", name: "Dólar"),
        Currency(code: "EUR", name: "Euro"),
        Currency(code: "BTC", name: "Bitcoin"),
    ]
}

private func makeBaseURL() -> URL {
    return URL(string: "http://any-url.com/currencies/last/")!
}
