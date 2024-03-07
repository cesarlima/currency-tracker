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
        let client = HttpClientSpy(result: .failure(makeNSError()))
        let sut = RemoteQuoteLoader(httpClient: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() async throws {
        let url = anyURL()
        let client = HttpClientSpy(result: makeSuccessResponse(withStatusCode: 200, data: Data(), url: url))
        let sut = RemoteQuoteLoader(httpClient: client)
        
        try await sut.load(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() async throws {
        let url = anyURL()
        let client = HttpClientSpy(result: makeSuccessResponse(withStatusCode: 200, data: Data(), url: url))
        let sut = RemoteQuoteLoader(httpClient: client)
        
        try await sut.load(from: url)
        try await sut.load(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
}

final class HttpClientSpy: HttpClient {
    private(set) var requestedURLs: [URL] = []
    let result: Swift.Result<(Data, HTTPURLResponse), Error>
    
    init(result: Swift.Result<(Data, HTTPURLResponse), Error>) {
        self.result = result
    }
    
    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        requestedURLs.append(url)
        
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
