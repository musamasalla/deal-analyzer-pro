//
//  ContentView.swift
//  Deal Analyzer Pro - Rental Property Cash Flow Calculator
//
//  Created by Musa Masalla on 2025/12/17.
//

import SwiftUI

/// Root view that handles onboarding state and shows main app
struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView(isComplete: $hasCompletedOnboarding)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
