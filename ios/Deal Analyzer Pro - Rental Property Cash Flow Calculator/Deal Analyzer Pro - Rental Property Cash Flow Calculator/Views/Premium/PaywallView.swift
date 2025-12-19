//
//  PaywallView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Premium subscription paywall
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PricingPlan = .monthly
    
    enum PricingPlan {
        case monthly
        case yearly
        
        var price: String {
            switch self {
            case .monthly: return "$9.99"
            case .yearly: return "$79.99"
            }
        }
        
        var period: String {
            switch self {
            case .monthly: return "/month"
            case .yearly: return "/year"
            }
        }
        
        var savings: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "Save 33%"
            }
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Close Button
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 56))
                            .foregroundColor(AppColors.warningAmber)
                        
                        Text("Unlock Pro Features")
                            .font(AppFonts.largeTitle)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Make smarter investment decisions")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        PaywallFeature(
                            icon: "infinity",
                            title: "Unlimited Analyses",
                            description: "Analyze as many properties as you want"
                        )
                        
                        PaywallFeature(
                            icon: "square.stack.3d.up.fill",
                            title: "Deal Comparison",
                            description: "Compare up to 3 deals side-by-side"
                        )
                        
                        PaywallFeature(
                            icon: "slider.horizontal.3",
                            title: "Scenario Testing",
                            description: "\"What if\" analysis for rent, rate changes"
                        )
                        
                        PaywallFeature(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "5-Year Projections",
                            description: "See long-term returns and equity"
                        )
                        
                        PaywallFeature(
                            icon: "doc.fill",
                            title: "PDF Reports",
                            description: "Export professional deal summaries"
                        )
                        
                        PaywallFeature(
                            icon: "icloud.fill",
                            title: "Cloud Sync",
                            description: "Access deals on all your devices"
                        )
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Pricing Plans
                    VStack(spacing: 12) {
                        PricingPlanCard(
                            plan: .yearly,
                            isSelected: selectedPlan == .yearly
                        ) {
                            selectedPlan = .yearly
                        }
                        
                        PricingPlanCard(
                            plan: .monthly,
                            isSelected: selectedPlan == .monthly
                        ) {
                            selectedPlan = .monthly
                        }
                    }
                    
                    // Subscribe Button
                    Button(action: {
                        // StoreKit purchase
                        dismiss()
                    }) {
                        Text("Start 7-Day Free Trial")
                            .font(AppFonts.button)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [AppColors.warningAmber, AppColors.warningAmber.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                    }
                    
                    // Terms
                    VStack(spacing: 8) {
                        Text("After your 7-day free trial, you'll be charged \(selectedPlan.price)\(selectedPlan.period). Cancel anytime.")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 16) {
                            Button("Restore Purchases") {}
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.primaryTeal)
                            
                            Button("Terms of Service") {}
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.primaryTeal)
                            
                            Button("Privacy Policy") {}
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.primaryTeal)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Paywall Feature

struct PaywallFeature: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.primaryTeal)
                .frame(width: 40, height: 40)
                .background(AppColors.primaryTeal.opacity(0.15))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(description)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Pricing Plan Card

struct PricingPlanCard: View {
    let plan: PaywallView.PricingPlan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan == .monthly ? "Monthly" : "Yearly")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        if let savings = plan.savings {
                            Text(savings)
                                .font(AppFonts.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.successGreen)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppColors.successGreen.opacity(0.15))
                                .cornerRadius(4)
                        }
                    }
                    
                    if plan == .yearly {
                        Text("Best value")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                    }
                }
                
                Spacer()
                
                Text("\(plan.price)\(plan.period)")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? AppColors.primaryTeal : AppColors.textMuted)
            }
            .padding(16)
            .background(isSelected ? AppColors.primaryTeal.opacity(0.1) : AppColors.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppColors.primaryTeal : AppColors.border, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    PaywallView()
}
