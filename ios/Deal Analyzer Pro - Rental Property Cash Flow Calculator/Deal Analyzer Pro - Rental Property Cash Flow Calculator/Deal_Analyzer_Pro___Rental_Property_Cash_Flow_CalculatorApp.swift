//
//  DealAnalyzerProApp.swift
//  Deal Analyzer Pro - Rental Property Cash Flow Calculator
//
//  Created by Musa Masalla on 2025/12/17.
//

import SwiftUI
import Supabase
import Auth

@main
struct DealAnalyzerProApp: App {
    @State private var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authService)
                .onOpenURL { url in
                    // Handle Supabase auth deep links (email confirmation, password reset, etc.)
                    Task {
                        await handleDeepLink(url)
                    }
                }
        }
    }
    
    /// Handles incoming deep links for Supabase authentication
    private func handleDeepLink(_ url: URL) async {
        // Supabase SDK will automatically handle the URL if it's a valid auth callback
        do {
            try await SupabaseService.shared.client.auth.session(from: url)
        } catch {
            print("Deep link handling failed: \(error)")
        }
    }
}
