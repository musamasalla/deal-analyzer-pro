//
//  ContentView.swift
//  Deal Analyzer Pro - Rental Property Cash Flow Calculator
//
//  Created by Musa Masalla on 2025/12/17.
//

import SwiftUI

/// Root view that handles onboarding state, authentication, and shows main app
struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @Environment(AuthService.self) private var authService
    @State private var isSyncingInitialData = false
    
    var body: some View {
        ZStack {
            if !hasCompletedOnboarding {
                OnboardingView(isComplete: $hasCompletedOnboarding)
            } else if authService.isAuthenticated {
                MainTabView()
                    .task {
                        await performInitialSync()
                    }
            } else {
                AuthenticationRootView()
            }
            
            // Loading overlay during initial sync
            if isSyncingInitialData {
                ZStack {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Syncing your deals...")
                            .font(AppFonts.body)
                            .foregroundColor(.white)
                    }
                    .padding(32)
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    @MainActor
    private func performInitialSync() async {
        // Only sync once per session
        guard !isSyncingInitialData else { return }
        
        // Check if we need to pull initial data
        let hasLocalDeals = DealDataService().dealCount() > 0
        guard !hasLocalDeals else { return }
        
        isSyncingInitialData = true
        defer { isSyncingInitialData = false }
        
        do {
            try await CloudSyncService.shared.pullInitialData(dataService: DealDataService())
        } catch {
            print("Initial sync failed: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthService.shared)
}
