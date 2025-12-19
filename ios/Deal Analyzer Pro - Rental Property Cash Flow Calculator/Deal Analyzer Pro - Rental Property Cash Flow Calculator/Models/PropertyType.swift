//
//  PropertyType.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import Foundation

/// Types of rental properties supported by the analyzer
enum PropertyType: String, CaseIterable, Identifiable, Codable {
    case singleFamily = "Single Family"
    case duplex = "Duplex"
    case triplex = "Triplex"
    case fourplex = "Fourplex"
    case smallMultiFamily = "Small Multi-Family"
    
    var id: String { rawValue }
    
    /// Display name for the property type
    var displayName: String { rawValue }
    
    /// Number of units for this property type
    var unitCount: Int {
        switch self {
        case .singleFamily: return 1
        case .duplex: return 2
        case .triplex: return 3
        case .fourplex: return 4
        case .smallMultiFamily: return 5 // 5+ units
        }
    }
    
    /// Description for display
    var description: String {
        switch self {
        case .singleFamily:
            return "Single-family home (1 unit)"
        case .duplex:
            return "Duplex (2 units)"
        case .triplex:
            return "Triplex (3 units)"
        case .fourplex:
            return "Fourplex (4 units)"
        case .smallMultiFamily:
            return "Small multi-family (5+ units)"
        }
    }
    
    /// SF icon name for property type
    var iconName: String {
        switch self {
        case .singleFamily:
            return "house.fill"
        case .duplex:
            return "building.2.fill"
        case .triplex, .fourplex:
            return "building.2.crop.circle.fill"
        case .smallMultiFamily:
            return "building.fill"
        }
    }
    
    /// Icon for property type (shorthand)
    var icon: String { iconName }
}

/// Loan term options
enum LoanTerm: Int, CaseIterable, Identifiable {
    case fifteen = 15
    case twenty = 20
    case thirty = 30
    
    var id: Int { rawValue }
    
    var displayName: String {
        "\(rawValue) Years"
    }
}
