//
//  URLSessionHTTPClientTests.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 07/03/24.
//

import XCTest
@testable import CurrencyTrackerCore

public class URLSessionHTTPClient: HttpClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}

    public func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UnexpectedValuesRepresentation()
        }
        
        return (data, httpResponse)
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    override func tearDown() async throws {
        URLProtocolStub.removeStub()
    }
    
    func test_getFromURL_permormsGETRequestWithURL() async throws {
        let sut = makeSUT()
        let url = anyURL()
        var expectedRequest: URLRequest?
        let response = HTTPURLResponse(
            url: anyURL(),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)!
        URLProtocolStub.stub(data: Data("{}".utf8), response: response, error: nil)
        URLProtocolStub.observeRequests { request in
            expectedRequest = request
        }
        
        _ = try await sut.get(from: url)
        
        XCTAssertEqual(expectedRequest?.url, url)
        XCTAssertEqual(expectedRequest?.httpMethod, "GET")
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HttpClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let sut = URLSessionHTTPClient(session: session)
        return sut
    }
    
    final class URLProtocolStub: URLProtocol {
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
            let requestObserver: ((URLRequest) -> Void)?
        }
        
        private static var _stub: Stub?
        private static var stub: Stub? {
            get { return queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }
        
        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error, requestObserver: nil)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
        }
        
        static func removeStub() {
            stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
            
            stub.requestObserver?(request)
        }
        
        override func stopLoading() {}
    }
}
