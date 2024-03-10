//
//  CurrencyQuoteLoadUseCaseTests.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 10/03/24.
//

import XCTest
@testable import CurrencyTrackerCore

struct Currency: Equatable {
    let code: String
    let name: String
}

final class CurrencyQuoteLoadUseCase {
    private let currencyQuoteLoader: CurrencyQuoteLoader
    private let currencyQuoteCache: CurrencyQuoteCache
    private let url: URL
    
    init(url: URL, currencyQuoteLoader: CurrencyQuoteLoader, currencyQuoteCache: CurrencyQuoteCache) {
        self.url = url
        self.currencyQuoteLoader = currencyQuoteLoader
        self.currencyQuoteCache = currencyQuoteCache
    }
    
    func load(toCurrency: String, from currencies: [Currency]) async throws -> [CurrencyQuote] {
        
        let remoteLoadResult = try? await currencyQuoteLoader.load(from: composeURL(toCurrency: toCurrency,
                                                                                    currencies: currencies))
        
        if let remoteLoadResult, remoteLoadResult.isEmpty == false {
            try? await currencyQuoteCache.save(quotes: remoteLoadResult)
            return remoteLoadResult
        }
        
        return try await currencyQuoteCache.load(codeIn: toCurrency)
        
    }
    
    private func composeURL(toCurrency: String, currencies: [Currency]) -> URL {
        let path = currencies.map { "\($0.code)-\(toCurrency)"}.joined(separator: ",")
        return url.appending(path: path)
    }
}

final class CurrencyQuoteLoadUseCaseTests: XCTestCase {

    func test_load_requestsRemoteLoaderWithACorrectURL() async {
        let currencies = makeCurrenciesModel()
        let toCurrency = "BRL"
        let baseURL = makeBaseURL()
        let expectedPath = currencies.map { "\($0.code)-\(toCurrency)"}.joined(separator: ",")
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
        Currency(code: "USD", name: "Dólar"),
        Currency(code: "EUR", name: "Euro"),
        Currency(code: "BTC", name: "Bitcoin"),
    ]
}

private func makeBaseURL() -> URL {
    return URL(string: "http://any-url.com/currencies/last/")!
}

private final class HttpClientSpy: HttpClient {
    typealias LoadResponse = Swift.Result<(Data, HTTPURLResponse), Error>
    
    private(set) var requestedURLs: [URL] = []
    var result: LoadResponse?
    
    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        requestedURLs.append(url)
        
        guard let result = result else {
            throw NSError(domain: "Result is nil", code: 0)
        }
        
        switch result {
        case .success(let response):
            return response
            
        case .failure(let error):
            throw error
        }
    }
    
    func completeWithEmptyResponse() {
        result = makeSuccessResponse(withStatusCode: 200,
                                     data: Data("{}".utf8),
                                     url: anyURL())
    }
    
    func completeWithError() {
        result = .failure(makeNSError())
    }
    
    func completeSuccess(with data: Data) {
        result = makeSuccessResponse(withStatusCode: 200,
                                     data: data,
                                     url: anyURL())
    }
}

private func makeSuccessResponse(withStatusCode code: Int, data: Data, url: URL) -> Swift.Result<(Data, HTTPURLResponse), Error> {
    let response = HTTPURLResponse(
        url: url,
        statusCode: code,
        httpVersion: nil,
        headerFields: nil)!
    
    return .success((data, response))
}
