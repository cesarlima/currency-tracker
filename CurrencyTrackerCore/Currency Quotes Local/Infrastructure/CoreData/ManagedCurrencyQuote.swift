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
    @NSManaged public var quoteDate: Date?
    @NSManaged public var quote: Double
    @NSManaged public var codeIn: String?
    @NSManaged public var name: String?
    @NSManaged public var code: String?
}
