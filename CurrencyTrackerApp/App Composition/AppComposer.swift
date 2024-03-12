//
//  AppComposer.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 10/03/24.
//

import Foundation
import CurrencyTrackerCore
import CoreData

final class AppComposer {
    private lazy var baseURL = URL(string: "https://economia.awesomeapi.com.br/last/")!

    private lazy var httpClient: HttpClient = {
        return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var store: CurrencyQuoteStore = {
        do {
            let dbURL = NSPersistentContainer
                .defaultDirectoryURL()
                .appending(component: "currency-tracker-store.sqlite")
            return try CoreDataCurrencyQuoteStore(
                storeURL: dbURL)
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return NullStore()
        }
    }()

    static let shared = AppComposer()

    private init() {}
    
    func composeCurrencyQuoteView() -> CurrencyQuoteView {
        let localQuoteCache = LocalCurrencyQuoteCache(store: store)
        let RemoteQuoteLoader = RemoteCurrencyQuoteLoader(httpClient: httpClient)
        let useCase = CurrencyQuoteLoadUseCase(url: baseURL, currencyQuoteLoader: RemoteQuoteLoader,
                                               currencyQuoteCache: localQuoteCache)
        let viewModel = CurrencyQuoteViewModel(currencyQuoteLoadUseCase: useCase)
  
        return CurrencyQuoteView(viewModel: viewModel)
    }
    
    func composeCurrencyConverterView() -> CurrencyConverterView {
        let localQuoteCache = LocalCurrencyQuoteCache(store: store)
        let useCase = CurrencyConvertUseCase(currencyQuteCache: localQuoteCache)
        let viewModel = CurrencyConverterViewModel(useCase: useCase)
        
        return CurrencyConverterView(viewModel: viewModel)
    }
}

final class NullStore: CurrencyQuoteStore {
    
    func save(quotes: [CurrencyQuote]) async throws {}

    func deleteWhereCodeInEquals(_ codeIn: String) async throws {}

    func retrieveWhereCodeInEquals(_ codeIn: String) async throws -> [CurrencyQuote]? { nil }
    
    func retrieveById(id: String) async throws -> CurrencyQuote? {
        return nil
    }
}
