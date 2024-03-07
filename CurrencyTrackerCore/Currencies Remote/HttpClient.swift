//
//  HttpClient.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 07/03/24.
//

import Foundation

protocol HttpClient {
    func get(from url: URL) async throws -> (Data, HTTPURLResponse)
}
