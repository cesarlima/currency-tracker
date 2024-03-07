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
    
    enum LoadError: Error {
        case invalidResponse
        case invalidData
    }
    
    init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
    func load(from url: URL) async throws -> [Currency] {
        let (data, httpResponse) = try await httpClient.get(from: url)
        
        if httpResponse.statusCode != 200 {
            throw LoadError.invalidResponse
        }
        
        let result = try map(data, from: httpResponse)
        
        return result
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) throws -> [Currency] {
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: [String: Any]]
            let currencies = jsonDict.compactMap { Currency(json: $0.value) }
            return currencies
        } catch {
            throw LoadError.invalidData
        }
    }
}

extension Currency {
    init?(json: [String: Any]) {
        guard let name = json["name"] as? String,
              let code = json["code"] as? String,
              let codeIn = json["codein"] as? String,
              let bid = json["bid"] as? String,
              let quote = Double(bid),
              let dateString = json["create_date"] as? String,
              let quoteDate = DateFormatter.iso8601.date(from: dateString) else {
            return nil
        }
        
        self.init(name: name, code: code, codeIn: codeIn, quote: quote, quoteDate: quoteDate)
    }
}

extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY HH:mm:ss"
        return formatter
    }()
}

final class CurrencyQuoteLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() async throws {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        client.result = makeSuccessResponse(withStatusCode: 200, data: Data("{}".utf8), url: url)
        
        _ = try await sut.load(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        client.result = makeSuccessResponse(withStatusCode: 200, data: Data("{}".utf8), url: url)
     
        _ = try await sut.load(from: url)
        _ = try await sut.load(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientCompletesError() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        client.result = .failure(makeNSError())
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
        let (sut, client) = makeSUT(url: url)
        
        let httpCodes = [199, 201, 300, 400, 500]
        
        httpCodes.enumerated().forEach { index, statusCode in
            
            client.result = makeSuccessResponse(withStatusCode: statusCode, data: Data(), url: url)
            
            Task {
                var didFailWithError: Error?
                
                do {
                    _ = try await sut.load(from: url)
                } catch {
                    didFailWithError = error
                }
                
                XCTAssertEqual(didFailWithError as! RemoteQuoteLoader.LoadError, .invalidResponse)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        client.result = makeSuccessResponse(withStatusCode: 200, data: Data("invalid json".utf8), url: url)
        var didFailWithError: Error?
        
        do {
            _ = try await sut.load(from: url)
        } catch {
            didFailWithError = error
        }
        
        XCTAssertEqual(didFailWithError as! RemoteQuoteLoader.LoadError, .invalidData)
    }
    
    func test_load_deliversNoCurrenciesOn200HTTPResponseWithEmptyJSON() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        client.result = makeSuccessResponse(withStatusCode: 200, data: Data("{}".utf8), url: url)
        
        do {
            let currencies = try await sut.load(from: url)
            XCTAssertEqual(currencies, [])
        } catch {
            XCTFail("The load should completes with success.")
        }
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
