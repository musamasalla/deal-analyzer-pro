//
//  AppConfiguration.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/19.
//

import Foundation

/// App-wide configuration and constants
struct AppConfiguration {
    
    // MARK: - App Info
    static let appName = "Deal Analyzer Pro"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.dealanalyzer.pro"
    
    // MARK: - Support
    static let supportEmail = "support@dealanalyzerpro.com"
    static let websiteURL = URL(string: "https://dealanalyzerpro.com")!
    static let privacyPolicyURL = URL(string: "https://dealanalyzerpro.com/privacy")!
    static let termsOfServiceURL = URL(string: "https://dealanalyzerpro.com/terms")!
    
    // MARK: - App Store
    static let appStoreID = "YOUR_APP_STORE_ID" // Replace after app creation
    static var appStoreURL: URL {
        URL(string: "https://apps.apple.com/app/id\(appStoreID)")!
    }
    static var reviewURL: URL {
        URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review")!
    }
    
    // MARK: - StoreKit Product IDs
    struct Products {
        static let monthlySubscription = "com.dealanalyzer.pro.monthly"
        static let yearlySubscription = "com.dealanalyzer.pro.yearly"
        static let lifetime = "com.dealanalyzer.pro.lifetime"
        
        static var all: [String] {
            [monthlySubscription, yearlySubscription, lifetime]
        }
    }
    
    // MARK: - Feature Flags
    struct Features {
        static let enableCloudSync = true // Supabase integration ready
        static let enableAnalytics = false // Enable when analytics are configured
        static let enableCrashReporting = false // Enable when crash reporting is set up
        static let debugPremium = false // Set to true to unlock all premium features for testing
    }
    
    // MARK: - Defaults
    struct Defaults {
        static let defaultInterestRate: Double = 7.0
        static let defaultDownPayment: Double = 20.0
        static let defaultLoanTerm: Int = 30
        static let defaultVacancyRate: Double = 8.0
        static let defaultMaintenancePercent: Double = 1.0
        static let defaultCapExPercent: Double = 1.0
        static let defaultPropertyManagement: Double = 10.0
    }
    
    // MARK: - Limits
    struct Limits {
        static let freeTierDeals = 3
        static let maxPhotoAttachments = 20
        static let maxDealsForComparison = 4
        static let maxScenarios = 10
    }
    
    // MARK: - Cache Keys
    struct CacheKeys {
        static let lastViewedDeal = "lastViewedDealID"
        static let onboardingComplete = "hasCompletedOnboarding"
        static let isPremiumUser = "isPremiumUser"
        static let lastSyncDate = "lastCloudSyncDate"
    }
    
    // MARK: - Supabase
    struct Supabase {
        static let url = URL(string: "https://hdcrghjgprbrghmszzsu.supabase.co")!
        static let apiKey = "sb_publishable_4VuLLOKdoni0oMeUq06Pbw_wWcygKmI"
    }
}

// MARK: - Environment Detection

extension AppConfiguration {
    enum Environment {
        case debug
        case testFlight
        case appStore
    }
    
    static var currentEnvironment: Environment {
        #if DEBUG
        return .debug
        #else
        if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
            return .testFlight
        }
        return .appStore
        #endif
    }
    
    static var isDebug: Bool {
        currentEnvironment == .debug
    }
    
    static var isTestFlight: Bool {
        currentEnvironment == .testFlight
    }
    
    static var isAppStore: Bool {
        currentEnvironment == .appStore
    }
}
