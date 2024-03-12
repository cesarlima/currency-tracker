//
//  StandardPrimaryButton.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 12/03/24.
//

import SwiftUI

struct StandardPrimaryButton: View {
    let title: LocalizedStringKey
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(Color("brandPrimary"))
        .controlSize(.large)
        .padding(16)
    }
}
