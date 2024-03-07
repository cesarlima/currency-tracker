//
//  File.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 07/03/24.
//

import Foundation

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
