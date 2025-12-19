//
//  OnboardingView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// 5-screen onboarding flow
struct OnboardingView: View {
    @Binding var isComplete: Bool
    @State private var currentPage: Int = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "timer",
            title: "Analyze Deals in 60 Seconds",
            subtitle: "Enter property details and instantly see if a deal makes financial sense",
            color: .teal
        ),
        OnboardingPage(
            icon: "chart.bar.doc.horizontal.fill",
            title: "See REAL Cash Flow",
            subtitle: "After ALL expenses including vacancy, maintenance, management, and reserves",
            color: .green
        ),
        OnboardingPage(
            icon: "square.stack.3d.up.fill",
            title: "Compare Deals Side-by-Side",
            subtitle: "Save multiple properties and find the best investment opportunity",
            color: .blue
        ),
        OnboardingPage(
            icon: "exclamationmark.triangle.fill",
            title: "Never Guess Again",
            subtitle: "One bad deal can cost $50,000+. Make data-driven decisions on every property",
            color: .orange
        ),
        OnboardingPage(
            icon: "house.fill",
            title: "Start Your First Analysis",
            subtitle: "Enter a property and see instant results. It only takes a minute.",
            color: .teal
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip Button
                HStack {
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button(action: { completeOnboarding() }) {
                            Text("Skip")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .padding()
                
                // Page Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? AppColors.primaryTeal : AppColors.textMuted.opacity(0.3))
                            .frame(width: currentPage == index ? 10 : 8, height: currentPage == index ? 10 : 8)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
                .padding(.vertical, 20)
                
                // Action Button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                        .font(AppFonts.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(AppColors.primaryGradient)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        withAnimation {
            isComplete = true
        }
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 140, height: 140)
                
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 180, height: 180)
                
                Image(systemName: page.icon)
                    .font(.system(size: 56))
                    .foregroundColor(page.color)
            }
            
            // Text
            VStack(spacing: 16) {
                Text(page.title)
                    .font(AppFonts.largeTitle)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isComplete: .constant(false))
}
