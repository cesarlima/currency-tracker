//
//  ManagedCurrency+CoreDataClass.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 09/03/24.
//
//

import Foundation
import CoreData

@objc(ManagedCurrency)
public class ManagedCurrency: NSManagedObject {
    @NSManaged public var name: String?
    @NSManaged public var code: String?
}
