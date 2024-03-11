//
//  LoadingView.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 10/03/24.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.color = UIColor(named: "brandPrimary")
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .opacity(0.7)
                .ignoresSafeArea(.all)
            
            ActivityIndicator()
        }
    }
}
