//
//  HttpClientSpy.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 10/03/24.
//

import Foundation
@testable import CurrencyTrackerCore

final class HttpClientSpy: HttpClient {
    typealias LoadResponse = Swift.Result<(Data, HTTPURLResponse), Error>
    
    private(set) var requestedURLs: [URL] = []
    private var result: LoadResponse?
    
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
    
    func completeSuccess(with data: Data, statusCode: Int = 200) {
        result = makeSuccessResponse(withStatusCode: statusCode,
                                     data: data,
                                     url: anyURL())
    }
}
