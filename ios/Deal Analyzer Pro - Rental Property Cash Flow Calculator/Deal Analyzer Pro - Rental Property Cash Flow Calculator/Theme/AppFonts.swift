//
//  AppFonts.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Typography system for Deal Analyzer Pro
/// Optimized for readability at property viewings with large number displays
struct AppFonts {
    
    // MARK: - Display Fonts (Large Numbers)
    
    /// Extra large cash flow display - 48pt bold
    static let cashFlowDisplay = Font.system(size: 48, weight: .bold, design: .rounded)
    
    /// Large metric value - 32pt semibold
    static let metricValue = Font.system(size: 32, weight: .semibold, design: .rounded)
    
    /// Extra large metric value - 40pt bold
    static let metricValueLarge = Font.system(size: 40, weight: .bold, design: .rounded)
    
    /// Medium metric value - 24pt semibold
    static let metricValueMedium = Font.system(size: 24, weight: .semibold, design: .rounded)
    
    // MARK: - Heading Fonts
    
    /// Large title - 28pt bold
    static let largeTitle = Font.system(size: 28, weight: .bold, design: .default)
    
    /// Title - 22pt semibold
    static let title = Font.system(size: 22, weight: .semibold, design: .default)
    
    /// Title 2 - 20pt semibold
    static let title2 = Font.system(size: 20, weight: .semibold, design: .default)
    
    /// Section header - 17pt semibold
    static let sectionHeader = Font.system(size: 17, weight: .semibold, design: .default)
    
    // MARK: - Body Fonts
    
    /// Body text - 17pt regular
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    
    /// Body bold - 17pt semibold
    static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)
    
    /// Callout - 16pt regular
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    
    /// Subheadline - 15pt regular
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    
    // MARK: - Small Fonts
    
    /// Footnote - 13pt regular
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    
    /// Caption - 12pt regular
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    
    /// Caption 2 - 11pt regular
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    
    // MARK: - Input Fonts
    
    /// Text field input - 17pt regular monospaced for numbers
    static let input = Font.system(size: 17, weight: .regular, design: .monospaced)
    
    /// Currency input - 20pt semibold monospaced
    static let currencyInput = Font.system(size: 20, weight: .semibold, design: .monospaced)
    
    // MARK: - Button Fonts
    
    /// Primary button - 17pt semibold
    static let button = Font.system(size: 17, weight: .semibold, design: .default)
    
    /// Small button - 15pt medium
    static let buttonSmall = Font.system(size: 15, weight: .medium, design: .default)
    
    // MARK: - Label Fonts
    
    /// Metric label - 13pt medium uppercase
    static let metricLabel = Font.system(size: 13, weight: .medium, design: .default)
    
    /// Field label - 14pt medium
    static let fieldLabel = Font.system(size: 14, weight: .medium, design: .default)
}

// MARK: - View Modifiers for Typography

struct MetricLabelStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFonts.metricLabel)
            .foregroundColor(AppColors.textSecondary)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}

struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFonts.sectionHeader)
            .foregroundColor(AppColors.textPrimary)
    }
}

extension View {
    func metricLabelStyle() -> some View {
        modifier(MetricLabelStyle())
    }
    
    func sectionHeaderStyle() -> some View {
        modifier(SectionHeaderStyle())
    }
}
