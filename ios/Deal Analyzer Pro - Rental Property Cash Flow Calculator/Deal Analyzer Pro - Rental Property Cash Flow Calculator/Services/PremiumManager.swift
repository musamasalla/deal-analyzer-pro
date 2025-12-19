//
//  PremiumManager.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/19.
//

import SwiftUI
import StoreKit

/// Manages premium subscription state and feature access
@Observable
class PremiumManager {
    static let shared = PremiumManager()
    
    // MARK: - State
    var isPremium: Bool = false
    var isLifetime: Bool = false
    var expirationDate: Date?
    
    // For development/testing
    var isDebugMode: Bool = false
    
    // MARK: - Premium Features
    enum PremiumFeature: String, CaseIterable {
        case unlimitedDeals = "Unlimited Deal Analyses"
        case dealComparison = "Side-by-Side Deal Comparison"
        case scenarioTesting = "What-If Scenario Testing"
        case fiveYearProjections = "5-Year Projections"
        case pdfExport = "PDF Report Export"
        case brrrr = "BRRRR Strategy Analyzer"
        case offerCalculator = "Offer Calculator"
        case repairEstimator = "Repair Cost Estimator"
        case taxBenefits = "Tax Benefits Calculator"
        case marketResearch = "Market Research"
        case cloudSync = "Cloud Sync"
        case portfolio = "Investment Portfolio"
        
        var icon: String {
            switch self {
            case .unlimitedDeals: return "infinity"
            case .dealComparison: return "square.stack.3d.up.fill"
            case .scenarioTesting: return "slider.horizontal.3"
            case .fiveYearProjections: return "chart.line.uptrend.xyaxis"
            case .pdfExport: return "doc.richtext.fill"
            case .brrrr: return "arrow.triangle.2.circlepath.circle"
            case .offerCalculator: return "tag.fill"
            case .repairEstimator: return "wrench.and.screwdriver.fill"
            case .taxBenefits: return "percent"
            case .marketResearch: return "map.fill"
            case .cloudSync: return "icloud.fill"
            case .portfolio: return "building.2.fill"
            }
        }
    }
    
    // MARK: - Free Tier Limits
    let freeDealsLimit: Int = 3
    var savedDealsCount: Int = 0
    
    var hasReachedFreeLimit: Bool {
        !isPremium && savedDealsCount >= freeDealsLimit
    }
    
    // MARK: - Initialization
    private init() {
        loadPurchaseState()
    }
    
    // MARK: - Feature Access
    func canAccess(_ feature: PremiumFeature) -> Bool {
        if isPremium || isDebugMode { return true }
        
        // Some features are always free
        switch feature {
        case .unlimitedDeals:
            return !hasReachedFreeLimit
        default:
            return false
        }
    }
    
    func requiresPremium(for feature: PremiumFeature) -> Bool {
        !canAccess(feature)
    }
    
    // MARK: - Purchase State
    private func loadPurchaseState() {
        // Load from UserDefaults for now
        isPremium = UserDefaults.standard.bool(forKey: "isPremiumUser")
        isLifetime = UserDefaults.standard.bool(forKey: "isLifetimeUser")
        
        if let expiration = UserDefaults.standard.object(forKey: "premiumExpiration") as? Date {
            expirationDate = expiration
            // Check if expired
            if expiration < Date() {
                isPremium = false
                isLifetime = false
            }
        }
    }
    
    func savePurchaseState() {
        UserDefaults.standard.set(isPremium, forKey: "isPremiumUser")
        UserDefaults.standard.set(isLifetime, forKey: "isLifetimeUser")
        if let expiration = expirationDate {
            UserDefaults.standard.set(expiration, forKey: "premiumExpiration")
        }
    }
    
    // MARK: - Debug
    func enableDebugPremium() {
        isDebugMode = true
    }
    
    func disableDebugPremium() {
        isDebugMode = false
    }
    
    func activatePremium(lifetime: Bool = false) {
        isPremium = true
        isLifetime = lifetime
        if !lifetime {
            // Set expiration to 1 year from now for testing
            expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        }
        savePurchaseState()
    }
    
    func deactivatePremium() {
        isPremium = false
        isLifetime = false
        expirationDate = nil
        savePurchaseState()
    }
}

// MARK: - Premium Gate View Modifier

struct PremiumGateModifier: ViewModifier {
    let feature: PremiumManager.PremiumFeature
    let premiumManager = PremiumManager.shared
    @State private var showingPaywall: Bool = false
    
    func body(content: Content) -> some View {
        if premiumManager.canAccess(feature) {
            content
        } else {
            Button {
                showingPaywall = true
            } label: {
                content
                    .overlay(
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                PremiumBadge()
                                    .padding(8)
                            }
                        }
                    )
                    .opacity(0.6)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

extension View {
    func premiumGate(_ feature: PremiumManager.PremiumFeature) -> some View {
        modifier(PremiumGateModifier(feature: feature))
    }
}

// MARK: - Premium Required View

struct PremiumRequiredView: View {
    let feature: PremiumManager.PremiumFeature
    @State private var showingPaywall: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: feature.icon)
                .font(.system(size: 60))
                .foregroundColor(AppColors.warningAmber)
            
            Text("Premium Feature")
                .font(AppFonts.title2)
                .foregroundColor(AppColors.textPrimary)
            
            Text(feature.rawValue)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
            
            Button(action: { showingPaywall = true }) {
                HStack {
                    Image(systemName: "crown.fill")
                    Text("Unlock Premium")
                }
                .font(AppFonts.bodyBold)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [AppColors.warningAmber, AppColors.primaryTeal],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}
