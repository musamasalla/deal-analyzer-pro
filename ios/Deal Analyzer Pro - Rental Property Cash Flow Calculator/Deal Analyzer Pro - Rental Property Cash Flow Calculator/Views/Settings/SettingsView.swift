//
//  SettingsView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Settings and account management
struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = true
    @State private var showingPaywall: Bool = false
    @State private var isPremium: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Premium Status
                    if !isPremium {
                        PremiumUpgradeCard {
                            showingPaywall = true
                        }
                    } else {
                        PremiumStatusCard()
                    }
                    
                    // Default Settings
                    VStack(alignment: .leading, spacing: 0) {
                        Text("DEFAULT VALUES")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                        
                        SettingsGroup {
                            SettingsRow(
                                icon: "percent",
                                title: "Down Payment",
                                value: "20%"
                            )
                            
                            Divider().background(AppColors.divider)
                            
                            SettingsRow(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Interest Rate",
                                value: "7.5%"
                            )
                            
                            Divider().background(AppColors.divider)
                            
                            SettingsRow(
                                icon: "calendar",
                                title: "Loan Term",
                                value: "30 years"
                            )
                            
                            Divider().background(AppColors.divider)
                            
                            SettingsRow(
                                icon: "house.fill",
                                title: "Vacancy Rate",
                                value: "8%"
                            )
                        }
                    }
                    
                    // App Settings
                    VStack(alignment: .leading, spacing: 0) {
                        Text("APP SETTINGS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                        
                        SettingsGroup {
                            Button(action: {
                                hasCompletedOnboarding = false
                            }) {
                                SettingsRow(
                                    icon: "arrow.counterclockwise",
                                    title: "Replay Onboarding",
                                    showChevron: true
                                )
                            }
                            
                            Divider().background(AppColors.divider)
                            
                            SettingsRow(
                                icon: "bell.fill",
                                title: "Notifications",
                                showChevron: true
                            )
                            
                            Divider().background(AppColors.divider)
                            
                            SettingsRow(
                                icon: "icloud.fill",
                                title: "iCloud Sync",
                                value: isPremium ? "On" : "Premium"
                            )
                        }
                    }
                    
                    // Support
                    VStack(alignment: .leading, spacing: 0) {
                        Text("SUPPORT")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                        
                        SettingsGroup {
                            SettingsRow(
                                icon: "questionmark.circle.fill",
                                title: "Help Center",
                                showChevron: true
                            )
                            
                            Divider().background(AppColors.divider)
                            
                            SettingsRow(
                                icon: "envelope.fill",
                                title: "Contact Support",
                                showChevron: true
                            )
                            
                            Divider().background(AppColors.divider)
                            
                            SettingsRow(
                                icon: "star.fill",
                                title: "Rate App",
                                showChevron: true
                            )
                            
                            Divider().background(AppColors.divider)
                            
                            SettingsRow(
                                icon: "doc.text.fill",
                                title: "Privacy Policy",
                                showChevron: true
                            )
                        }
                    }
                    
                    // Version
                    Text("Deal Analyzer Pro v1.0.0")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                        .padding(.top, 10)
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

// MARK: - Settings Components

struct SettingsGroup<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(.horizontal, 16)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    var showChevron: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.primaryTeal)
                .frame(width: 28)
            
            Text(title)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textMuted)
            }
        }
        .padding(.vertical, 14)
    }
}

// MARK: - Premium Cards

struct PremiumUpgradeCard: View {
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "crown.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.warningAmber)
                
                Text("Upgrade to Premium")
                    .font(AppFonts.title2)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                PremiumFeatureRow(text: "Unlimited property analyses")
                PremiumFeatureRow(text: "Side-by-side deal comparison")
                PremiumFeatureRow(text: "Scenario testing (What-If mode)")
                PremiumFeatureRow(text: "5-year projections")
                PremiumFeatureRow(text: "PDF report export")
                PremiumFeatureRow(text: "Cloud sync across devices")
            }
            
            Button(action: action) {
                Text("Start 7-Day Free Trial")
                    .font(AppFonts.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [AppColors.warningAmber, AppColors.warningAmber.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
            }
            
            Text("Then $10/month. Cancel anytime.")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textMuted)
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.warningAmber.opacity(0.3), lineWidth: 1)
        )
    }
}

struct PremiumFeatureRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppColors.successGreen)
                .font(.system(size: 14))
            
            Text(text)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

struct PremiumStatusCard: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 24))
                .foregroundColor(AppColors.warningAmber)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Premium Active")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("All features unlocked")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Text("Manage")
                .font(AppFonts.body)
                .foregroundColor(AppColors.primaryTeal)
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

#Preview {
    SettingsView()
}
