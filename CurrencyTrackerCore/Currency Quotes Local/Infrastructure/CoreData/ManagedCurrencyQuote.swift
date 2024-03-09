//
//  ManagedCurrencyQuote+CoreDataClass.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 09/03/24.
//
//

import Foundation
import CoreData

@objc(ManagedCurrencyQuote)
public class ManagedCurrencyQuote: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var quoteDate: Date
    @NSManaged public var quote: Double
    @NSManaged public var codeIn: String
    @NSManaged public var name: String
    @NSManaged public var code: String
    
    static func createManagedCurrencyQuote(from localQuote: CurrencyQuote,
                                           in context: NSManagedObjectContext) {
        let managedQuote = ManagedCurrencyQuote(context: context)
        managedQuote.id = localQuote.id
        managedQuote.code = localQuote.code
        managedQuote.codeIn = localQuote.codeIn
        managedQuote.name = localQuote.name
        managedQuote.quote = localQuote.quote
        managedQuote.quoteDate = localQuote.quoteDate
    }
    
    static func findByCodeIn(_ codeIn: String,
                             in context: NSManagedObjectContext) throws -> [ManagedCurrencyQuote]? {
        let request = NSFetchRequest<ManagedCurrencyQuote>(entityName: ManagedCurrencyQuote.entity().name!)
        request.predicate = NSPredicate(format: "%K = %@",
                                        argumentArray: [#keyPath(ManagedCurrencyQuote.codeIn), codeIn])
        return try context.fetch(request)
    }
    
    func toLocal() -> CurrencyQuote {
        return CurrencyQuote(name: name,
                             code: code,
                             codeIn: codeIn,
                             quote: quote,
                             quoteDate: quoteDate)
    }
}
