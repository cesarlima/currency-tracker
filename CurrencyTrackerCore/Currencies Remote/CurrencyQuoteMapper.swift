//
//  CurrencyMapper.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 07/03/24.
//

import Foundation

enum CurrencyQuoteMapper {
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [CurrencyQuote] {
        guard response.statusCode == 200 else {
            throw RemoteCurrencyQuoteLoader.LoadError.invalidResponse
        }
        
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: [String: Any]]
            let currencies = jsonDict.compactMap { CurrencyQuote(json: $0.value) }.sorted { $0.code < $1.code }
            return currencies
        } catch {
            throw RemoteCurrencyQuoteLoader.LoadError.invalidData
        }
    }
}

extension CurrencyQuote {
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
        
        self.init(name: Self.removeToCurrencyName(name),
                  code: code,
                  codeIn: codeIn,
                  quote: quote,
                  quoteDate: quoteDate)
    }
    
    private static func removeToCurrencyName(_ name: String) -> String {
        return name.components(separatedBy: "/").first ?? name
    }
}

extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
