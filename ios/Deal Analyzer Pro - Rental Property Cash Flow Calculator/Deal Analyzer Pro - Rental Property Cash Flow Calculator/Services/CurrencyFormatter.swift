//
//  CurrencyFormatter.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/20.
//

import Foundation

/// Centralized currency formatter for consistent USD formatting across the app
struct CurrencyFormatter {
    
    /// Shared formatter configured for USD
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.currencySymbol = "$"
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    /// Formatter with cents for precise values
    private static let formatterWithCents: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.currencySymbol = "$"
        formatter.locale = Locale(identifier: "en_US")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    /// Format a value as USD currency
    /// - Parameters:
    ///   - value: The numeric value to format
    ///   - showSign: Whether to show + for positive values
    ///   - showCents: Whether to show decimal places
    /// - Returns: Formatted currency string (e.g., "$150,000" or "+$500")
    static func format(_ value: Double, showSign: Bool = false, showCents: Bool = false) -> String {
        let absoluteValue = abs(value)
        let selectedFormatter = showCents ? formatterWithCents : formatter
        let formatted = selectedFormatter.string(from: NSNumber(value: absoluteValue)) ?? "$0"
        
        if value < 0 {
            return "-\(formatted)"
        } else if showSign && value > 0 {
            return "+\(formatted)"
        }
        return formatted
    }
    
    /// Format for compact display (e.g., "$150K" for large values)
    static func formatCompact(_ value: Double) -> String {
        if abs(value) >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else if abs(value) >= 1_000 {
            return String(format: "$%.0fK", value / 1_000)
        }
        return format(value)
    }
}
