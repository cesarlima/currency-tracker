//
//  SharedTestHelpers.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 08/03/24.
//

import Foundation

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func makeNSError() -> NSError {
    NSError(domain: "any erro", code: 0)
}
