//
//  DealAnalyzerProApp.swift
//  Deal Analyzer Pro - Rental Property Cash Flow Calculator
//
//  Created by Musa Masalla on 2025/12/17.
//

import SwiftUI

@main
struct DealAnalyzerProApp: App {
    @State private var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authService)
        }
    }
}
