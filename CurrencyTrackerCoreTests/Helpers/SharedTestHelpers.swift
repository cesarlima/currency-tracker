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

func makeCurrencies() -> (data: Data, models: [CurrencyQuote]) {
    let data = """
    {
       "USDBRL":{
          "code":"USD",
          "codein":"BRL",
          "name":"Dólar Americano/Real Brasileiro",
          "bid":"4.9446",
          "create_date":"2024-03-06 21:57:40"
       },
       "EURBRL":{
          "code":"EUR",
          "codein":"BRL",
          "name":"Euro/Real Brasileiro",
          "bid":"5.3844",
          "create_date":"2024-03-06 21:53:29"
       },
       "BTCBRL":{
          "code":"BTC",
          "codein":"BRL",
          "name":"Bitcoin/Real Brasileiro",
          "bid":"330376",
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
