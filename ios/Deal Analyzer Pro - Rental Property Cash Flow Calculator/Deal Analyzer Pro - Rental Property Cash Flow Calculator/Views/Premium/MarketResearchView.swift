//
//  MarketResearchView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI
import MapKit

/// Market research and property location view (Premium feature)
struct MarketResearchView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.4484, longitude: -112.0740), // Phoenix default
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Map View
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PROPERTY LOCATION")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                        
                        ZStack(alignment: .topTrailing) {
                            Map(coordinateRegion: $region, annotationItems: [PropertyAnnotation(coordinate: region.center)]) { annotation in
                                MapMarker(coordinate: annotation.coordinate, tint: Color(AppColors.primaryTeal))
                            }
                            .frame(height: 200)
                            .cornerRadius(12)
                            
                            Button(action: {}) {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(8)
                            }
                            .padding(8)
                        }
                        
                        // Address Search
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppColors.textMuted)
                            
                            TextField("Search address...", text: $searchText)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(12)
                        .background(AppColors.inputBackground)
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Market Stats (Premium Mockup)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("MARKET STATISTICS")
                                .font(AppFonts.metricLabel)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Spacer()
                            
                            PremiumBadge()
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            MarketStatCard(
                                title: "Median Home Price",
                                value: "$385,000",
                                change: "+5.2%",
                                isPositive: true
                            )
                            
                            MarketStatCard(
                                title: "Avg Rent (3BR)",
                                value: "$1,850",
                                change: "+3.1%",
                                isPositive: true
                            )
                            
                            MarketStatCard(
                                title: "Days on Market",
                                value: "32",
                                change: "-8 days",
                                isPositive: true
                            )
                            
                            MarketStatCard(
                                title: "Vacancy Rate",
                                value: "5.2%",
                                change: "+0.3%",
                                isPositive: false
                            )
                        }
                        
                        Text("Data updated: Dec 2025 • Source: Market Analytics")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Rent Comparables
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("RENT COMPARABLES")
                                .font(AppFonts.metricLabel)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Spacer()
                            
                            PremiumBadge()
                        }
                        
                        ForEach(sampleComparables) { comp in
                            RentComparableRow(comparable: comp)
                        }
                        
                        Button(action: {}) {
                            Text("View More Comparables")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.primaryTeal)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(AppColors.primaryTeal.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Neighborhood Score
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("NEIGHBORHOOD SCORES")
                                .font(AppFonts.metricLabel)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Spacer()
                            
                            PremiumBadge()
                        }
                        
                        HStack(spacing: 16) {
                            NeighborhoodScoreCircle(title: "Schools", score: 7)
                            NeighborhoodScoreCircle(title: "Safety", score: 8)
                            NeighborhoodScoreCircle(title: "Transit", score: 6)
                            NeighborhoodScoreCircle(title: "Walkability", score: 5)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Market Research")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.primaryTeal)
                }
            }
        }
    }
    
    var sampleComparables: [RentComparable] {
        [
            RentComparable(address: "456 Oak Street", distance: "0.3 mi", beds: 3, baths: 2, sqft: 1450, rent: 1750),
            RentComparable(address: "789 Pine Avenue", distance: "0.5 mi", beds: 3, baths: 2, sqft: 1600, rent: 1900),
            RentComparable(address: "321 Elm Drive", distance: "0.7 mi", beds: 3, baths: 2.5, sqft: 1520, rent: 1825)
        ]
    }
}

// MARK: - Property Annotation

struct PropertyAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Premium Badge

struct PremiumBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: 10))
            Text("PRO")
                .font(AppFonts.caption2)
                .fontWeight(.bold)
        }
        .foregroundColor(AppColors.warningAmber)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(AppColors.warningAmber.opacity(0.15))
        .cornerRadius(6)
    }
}

// MARK: - Market Stat Card

struct MarketStatCard: View {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textMuted)
            
            Text(value)
                .font(AppFonts.title2)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 4) {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 10))
                Text(change)
                    .font(AppFonts.caption)
            }
            .foregroundColor(isPositive ? AppColors.successGreen : AppColors.dangerRed)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppColors.inputBackground)
        .cornerRadius(12)
    }
}

// MARK: - Rent Comparable

struct RentComparable: Identifiable {
    let id = UUID()
    let address: String
    let distance: String
    let beds: Int
    let baths: Double
    let sqft: Int
    let rent: Double
}

struct RentComparableRow: View {
    let comparable: RentComparable
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(comparable.address)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(comparable.beds)bd \(String(format: "%.1f", comparable.baths))ba • \(comparable.sqft) sqft • \(comparable.distance)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            
            Spacer()
            
            Text("$\(Int(comparable.rent))/mo")
                .font(AppFonts.bodyBold)
                .foregroundColor(AppColors.successGreen)
        }
        .padding(12)
        .background(AppColors.inputBackground)
        .cornerRadius(10)
    }
}

// MARK: - Neighborhood Score Circle

struct NeighborhoodScoreCircle: View {
    let title: String
    let score: Int // 1-10
    
    var scoreColor: Color {
        if score >= 7 { return AppColors.successGreen }
        if score >= 5 { return AppColors.warningAmber }
        return AppColors.dangerRed
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(AppColors.inputBackground, lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 10)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Text("\(score)")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(scoreColor)
            }
            
            Text(title)
                .font(AppFonts.caption2)
                .foregroundColor(AppColors.textMuted)
        }
    }
}

#Preview {
    MarketResearchView(viewModel: {
        let vm = DealViewModel()
        vm.deal = .sampleDeal
        return vm
    }())
}
