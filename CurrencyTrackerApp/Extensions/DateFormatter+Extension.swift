//
//  DateFormatter+Extension.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 10/03/24.
//

import Foundation

extension DateFormatter {

    static func format(date: Date, format: String = "dd/MM/yyyy HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
