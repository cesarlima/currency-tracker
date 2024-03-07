//
//  CurrencyTrackerCoreTests.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 07/03/24.
//

import XCTest
@testable import CurrencyTrackerCore

protocol HttpClient {
    func get(from url: URL) async throws -> (Data, HTTPURLResponse)
}

final class RemoteQuoteLoader {
    private let httpClient: HttpClient
    
    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    func load(from url: URL) async throws {
        _ = try await httpClient.get(from: url)
    }
}

final class CurrencyQuoteLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() async throws {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        client.result = makeSuccessResponse(withStatusCode: 200, data: Data(), url: url)
        
        try await sut.load(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        client.result = makeSuccessResponse(withStatusCode: 200, data: Data(), url: url)
     
        try await sut.load(from: url)
        try await sut.load(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientCompletesError() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        client.result = .failure(makeNSError())
        var didFailWithError: Error?
        
        do {
            try await sut.load(from: url)
        } catch {
            didFailWithError = error
        }
        
        XCTAssertNotNil(didFailWithError)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = anyURL()) -> (sut: RemoteQuoteLoader, httpClient: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteQuoteLoader(httpClient: client)
        
        return (sut, client)
    }
}

final class HttpClientSpy: HttpClient {
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
}

func makeNSError() -> NSError {
    NSError(domain: "any erro", code: 0)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func makeSuccessResponse(withStatusCode code: Int, data: Data, url: URL) -> Swift.Result<(Data, HTTPURLResponse), Error> {
    let response = HTTPURLResponse(
        url: url,
        statusCode: code,
        httpVersion: nil,
        headerFields: nil)!
    
    return .success((data, response))
}
