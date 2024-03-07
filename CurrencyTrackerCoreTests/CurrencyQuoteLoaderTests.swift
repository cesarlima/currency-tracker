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
    
    func load() {
        
    }
}

final class CurrencyQuoteLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() async throws {
        let client = HttpClientSpy(result: .failure(makeNSError()))
        let sut = RemoteQuoteLoader(httpClient: client)
        
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
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
