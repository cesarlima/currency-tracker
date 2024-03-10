//
//  SharedTestHelpers.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 08/03/24.
//

import Foundation
@testable import CurrencyTrackerCore

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func makeNSError() -> NSError {
    NSError(domain: "any erro", code: 0)
}

func makeCurrencies(codeIn: String = "BRL") -> (data: Data, models: [CurrencyQuote]) {
    let data = """
    {
    "BTCBRL":{
          "code":"BTC",
          "codein":"\(codeIn)",
          "name":"Bitcoin/Real Brasileiro",
          "bid":"330376",
          "create_date":"2024-03-06 21:58:07"
       },
       "EURBRL":{
          "code":"EUR",
          "codein":"\(codeIn)",
          "name":"Euro/Real Brasileiro",
          "bid":"5.3844",
          "create_date":"2024-03-06 21:53:29"
       },
       "USDBRL":{
          "code":"USD",
          "codein":"\(codeIn)",
          "name":"Dólar Americano/Real Brasileiro",
          "bid":"4.9446",
          "create_date":"2024-03-06 21:57:40"
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
