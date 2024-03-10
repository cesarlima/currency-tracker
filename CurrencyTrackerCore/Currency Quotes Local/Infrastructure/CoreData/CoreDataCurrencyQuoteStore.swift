//
//  CoreDataCurrencyQuoteStore.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 09/03/24.
//

import Foundation
import CoreData

public final class CoreDataCurrencyQuoteStore: CurrencyQuoteStore {
    private static let modelName = "CurrencyQuotes"
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL) throws {
        container = try NSPersistentContainer.load(modelName: Self.modelName,
                                                   url: storeURL,
                                                   in: Bundle(for: CoreDataCurrencyQuoteStore.self))
        context = container.newBackgroundContext()
    }
    
    public func save(quotes: [CurrencyQuote]) async throws {
        let context = context
        
        try await context.perform({
            quotes.forEach { currencyQuote in
                ManagedCurrencyQuote.createManagedCurrencyQuote(from: currencyQuote,
                                                                in: context)
            }
            try context.save()
        })
    }
    
    public func deleteWhereCodeInEquals(_ codeIn: String) async throws {
        let context = context
        
        try await context.perform({
            let managedQuotes = try ManagedCurrencyQuote.findByCodeIn(codeIn, in: context) ?? []
            
            managedQuotes.forEach { managedQuote in
                context.delete(managedQuote)
            }
            
            try context.save()
        })
    }
    
    public func retrieveWhereCodeInEquals(_ codeIn: String) async throws -> [CurrencyQuote]? {
        let context = context
        
        let managedQuotes = try await context.perform({
            try ManagedCurrencyQuote.findByCodeIn(codeIn, in: context)
        }) ?? []
        
        return managedQuotes.map { $0.toLocal() }
    }
}
