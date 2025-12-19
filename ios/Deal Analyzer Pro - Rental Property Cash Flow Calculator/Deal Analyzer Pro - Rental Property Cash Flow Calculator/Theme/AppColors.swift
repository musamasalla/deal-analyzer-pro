//
//  AppColors.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Design system colors for Deal Analyzer Pro
/// Dark blue/green professional theme optimized for real estate investors
struct AppColors {
    
    // MARK: - Primary Colors
    
    /// Deep navy blue - primary brand color
    static let primaryNavy = Color(hex: "0A1628")
    
    /// Rich teal - accent color for positive values
    static let primaryTeal = Color(hex: "0D9488")
    
    /// Bright emerald - success/positive cash flow
    static let successGreen = Color(hex: "10B981")
    
    /// Coral red - negative values/warnings
    static let dangerRed = Color(hex: "EF4444")
    
    /// Amber - caution/warnings
    static let warningAmber = Color(hex: "F59E0B")
    
    // MARK: - Background Colors
    
    /// Main app background - deep navy
    static let background = Color(hex: "0A1628")
    
    /// Card background - slightly lighter navy
    static let cardBackground = Color(hex: "1E293B")
    
    /// Elevated card - for modals and sheets
    static let elevatedBackground = Color(hex: "334155")
    
    /// Input field background
    static let inputBackground = Color(hex: "1E293B")
    
    // MARK: - Text Colors
    
    /// Primary text - white
    static let textPrimary = Color.white
    
    /// Secondary text - light gray
    static let textSecondary = Color(hex: "94A3B8")
    
    /// Muted text - darker gray
    static let textMuted = Color(hex: "64748B")
    
    /// Accent text - teal
    static let textAccent = Color(hex: "5EEAD4")
    
    // MARK: - Cash Flow Colors
    
    /// Positive cash flow gradient start
    static let cashFlowPositiveStart = Color(hex: "059669")
    
    /// Positive cash flow gradient end
    static let cashFlowPositiveEnd = Color(hex: "10B981")
    
    /// Negative cash flow gradient start
    static let cashFlowNegativeStart = Color(hex: "DC2626")
    
    /// Negative cash flow gradient end
    static let cashFlowNegativeEnd = Color(hex: "EF4444")
    
    // MARK: - Gradients
    
    /// Primary gradient for buttons and accents
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "0D9488"), Color(hex: "14B8A6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Background gradient for main views
    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "0A1628"), Color(hex: "1E293B")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Positive cash flow card gradient
    static let positiveGradient = LinearGradient(
        colors: [cashFlowPositiveStart, cashFlowPositiveEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Negative cash flow card gradient
    static let negativeGradient = LinearGradient(
        colors: [cashFlowNegativeStart, cashFlowNegativeEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Border & Divider Colors
    
    /// Subtle border color
    static let border = Color(hex: "334155")
    
    /// Divider line color
    static let divider = Color(hex: "475569")
    
    // MARK: - Tab Bar Colors
    
    /// Tab bar background
    static let tabBarBackground = Color(hex: "0F172A")
    
    /// Selected tab icon
    static let tabSelected = primaryTeal
    
    /// Unselected tab icon
    static let tabUnselected = Color(hex: "64748B")
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
