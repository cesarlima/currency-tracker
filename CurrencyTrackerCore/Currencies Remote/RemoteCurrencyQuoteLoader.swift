//
//  RemoteQuoteLoader.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 07/03/24.
//

import Foundation

final class RemoteCurrencyQuoteLoader: CurrencyQuoteLoader {
    private let httpClient: HttpClient
    private let url: URL
    
    enum LoadError: Error {
        case invalidResponse
        case invalidData
    }
    
    init(httpClient: HttpClient, url: URL) {
        self.httpClient = httpClient
        self.url = url
    }
    
    func load() async throws -> [Currency] {
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
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
