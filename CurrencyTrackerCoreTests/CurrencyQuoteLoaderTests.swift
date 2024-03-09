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
        client.result = makeSuccessResponse(withStatusCode: 200, data: Data("{}".utf8), url: url)
        
        _ = try await sut.load(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT()
        client.result = makeSuccessResponse(withStatusCode: 200, data: Data("{}".utf8), url: url)
     
        _ = try await sut.load(from: url)
        _ = try await sut.load(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientCompletesError() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT()
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
        let (sut, client) = makeSUT()
        
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
                
                XCTAssertEqual(didFailWithError as! RemoteCurrencyQuoteLoader.LoadError, .invalidResponse)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT()
        client.result = makeSuccessResponse(withStatusCode: 200, data: Data("invalid json".utf8), url: url)
        var didFailWithError: Error?
        
        do {
            _ = try await sut.load(from: url)
        } catch {
            didFailWithError = error
        }
        
        XCTAssertEqual(didFailWithError as! RemoteCurrencyQuoteLoader.LoadError, .invalidData)
    }
    
    func test_load_deliversNoCurrenciesOn200HTTPResponseWithEmptyJSON() async throws {
        let url = anyURL()
        let (sut, client) = makeSUT()
        client.result = makeSuccessResponse(withStatusCode: 200, data: Data("{}".utf8), url: url)
        
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
        client.result = makeSuccessResponse(withStatusCode: 200, data: data, url: url)
        
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
    
    private func makeCurrencies() -> (data: Data, currencies: [CurrencyQuote]) {
        let data = """
        {
           "USDBRL":{
              "code":"USD",
              "codein":"BRL",
              "name":"Dólar Americano/Real Brasileiro",
              "high":"4.9473",
              "low":"4.9451",
              "varBid":"0.0005",
              "pctChange":"0.01",
              "bid":"4.9446",
              "ask":"4.9456",
              "timestamp":"1709773060",
              "create_date":"2024-03-06 21:57:40"
           },
           "EURBRL":{
              "code":"EUR",
              "codein":"BRL",
              "name":"Euro/Real Brasileiro",
              "high":"5.3884",
              "low":"5.3884",
              "varBid":"0",
              "pctChange":"0",
              "bid":"5.3844",
              "ask":"5.3924",
              "timestamp":"1709772809",
              "create_date":"2024-03-06 21:53:29"
           },
           "BTCBRL":{
              "code":"BTC",
              "codein":"BRL",
              "name":"Bitcoin/Real Brasileiro",
              "high":"337412",
              "low":"314801",
              "varBid":"12379",
              "pctChange":"3.89",
              "bid":"330376",
              "ask":"330618",
              "timestamp":"1709773087",
              "create_date":"2024-03-06 21:58:07"
           }
        }
        """.data(using: .utf8)!
        
        let response = HTTPURLResponse(
            url: anyURL(),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)!
        let currencies = try! CurrencyQuoteMapper.map(data, from: response)
        return (data, currencies)
    }
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
}

private func makeSuccessResponse(withStatusCode code: Int, data: Data, url: URL) -> Swift.Result<(Data, HTTPURLResponse), Error> {
    let response = HTTPURLResponse(
        url: url,
        statusCode: code,
        httpVersion: nil,
        headerFields: nil)!
    
    return .success((data, response))
}
