//
//  EducationView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Education hub with glossary, benchmarks, and video tutorials
struct EducationView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Benchmarks
                    VStack(alignment: .leading, spacing: 16) {
                        Text("GOOD DEAL BENCHMARKS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                            .tracking(0.5)
                        
                        BenchmarkCard(
                            icon: "dollarsign.circle.fill",
                            title: "Cash Flow",
                            benchmark: "$200+/door/month",
                            description: "After ALL expenses including reserves",
                            color: .green
                        )
                        
                        BenchmarkCard(
                            icon: "percent",
                            title: "Cash-on-Cash Return",
                            benchmark: "8%+ good, 12%+ great",
                            description: "Compare to stock market ~10% average",
                            color: .teal
                        )
                        
                        BenchmarkCard(
                            icon: "chart.pie.fill",
                            title: "Cap Rate",
                            benchmark: "8%+ in most markets",
                            description: "Higher in Midwest, lower in coastal cities",
                            color: .blue
                        )
                        
                        BenchmarkCard(
                            icon: "shield.fill",
                            title: "DSCR",
                            benchmark: "1.25+ for bank approval",
                            description: "Income must cover debt + cushion",
                            color: .orange
                        )
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Navigation Links
                    NavigationLink(destination: GlossaryView()) {
                        EducationLinkCard(
                            icon: "book.fill",
                            title: "Glossary",
                            subtitle: "Learn real estate investing terms"
                        )
                    }
                    
                    // Video Tutorial Placeholder
                    VStack(alignment: .leading, spacing: 12) {
                        Text("VIDEO TUTORIALS")
                            .font(AppFonts.metricLabel)
                            .foregroundColor(AppColors.textSecondary)
                            .tracking(0.5)
                        
                        VideoTutorialCard(
                            title: "How to Analyze Your First Rental Property",
                            duration: "8:32",
                            thumbnail: "play.rectangle.fill"
                        )
                        
                        VideoTutorialCard(
                            title: "Understanding Cash Flow vs Appreciation",
                            duration: "6:15",
                            thumbnail: "play.rectangle.fill"
                        )
                        
                        VideoTutorialCard(
                            title: "The 1% Rule Explained",
                            duration: "4:48",
                            thumbnail: "play.rectangle.fill"
                        )
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Benchmark Card

struct BenchmarkCard: View {
    let icon: String
    let title: String
    let benchmark: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.15))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(benchmark)
                    .font(AppFonts.body)
                    .foregroundColor(color)
                
                Text(description)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            
            Spacer()
        }
    }
}

// MARK: - Education Link Card

struct EducationLinkCard: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.primaryTeal)
                .frame(width: 44, height: 44)
                .background(AppColors.primaryTeal.opacity(0.15))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textMuted)
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Video Tutorial Card

struct VideoTutorialCard: View {
    let title: String
    let duration: String
    let thumbnail: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.inputBackground)
                    .frame(width: 80, height: 50)
                
                Image(systemName: thumbnail)
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)
                
                Text(duration)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
            
            Spacer()
        }
        .padding(12)
        .background(AppColors.inputBackground)
        .cornerRadius(12)
    }
}

#Preview {
    EducationView()
}
