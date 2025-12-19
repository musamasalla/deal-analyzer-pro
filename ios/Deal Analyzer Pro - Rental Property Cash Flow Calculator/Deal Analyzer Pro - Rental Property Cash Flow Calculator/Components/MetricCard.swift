//
//  MetricCard.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Display card for key financial metrics
struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String?
    var icon: String? = nil
    var valueColor: Color = AppColors.textPrimary
    var isLarge: Bool = false
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String? = nil,
        valueColor: Color = AppColors.textPrimary,
        isLarge: Bool = false
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.valueColor = valueColor
        self.isLarge = isLarge
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Text(title.uppercased())
                    .font(AppFonts.metricLabel)
                    .foregroundColor(AppColors.textSecondary)
                    .tracking(0.5)
            }
            
            Text(value)
                .font(isLarge ? AppFonts.metricValue : AppFonts.metricValueMedium)
                .foregroundColor(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

/// Horizontal metric display for comparisons
struct CompactMetricRow: View {
    let title: String
    let value: String
    var valueColor: Color = AppColors.textPrimary
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(AppFonts.bodyBold)
                .foregroundColor(valueColor)
        }
        .padding(.vertical, 8)
    }
}

/// Grid of metric cards
struct MetricsGrid: View {
    let metrics: [(title: String, value: String, subtitle: String?, icon: String?)]
    var columns: Int = 2
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: columns),
            spacing: 12
        ) {
            ForEach(Array(metrics.enumerated()), id: \.offset) { _, metric in
                MetricCard(
                    title: metric.title,
                    value: metric.value,
                    subtitle: metric.subtitle,
                    icon: metric.icon
                )
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        ScrollView {
            VStack(spacing: 16) {
                MetricCard(
                    title: "Cash-on-Cash Return",
                    value: "12.4%",
                    subtitle: "Annual return on invested cash",
                    icon: "percent",
                    valueColor: AppColors.successGreen,
                    isLarge: true
                )
                
                HStack(spacing: 12) {
                    MetricCard(
                        title: "Cap Rate",
                        value: "7.2%",
                        icon: "chart.pie.fill"
                    )
                    
                    MetricCard(
                        title: "GRM",
                        value: "11.5",
                        icon: "multiply"
                    )
                }
                
                VStack(spacing: 0) {
                    CompactMetricRow(title: "Monthly P&I", value: "$1,064")
                    Divider().background(AppColors.divider)
                    CompactMetricRow(title: "Total Expenses", value: "$1,450")
                    Divider().background(AppColors.divider)
                    CompactMetricRow(
                        title: "Cash Flow",
                        value: "+$350",
                        valueColor: AppColors.successGreen
                    )
                }
                .padding(16)
                .background(AppColors.cardBackground)
                .cornerRadius(16)
            }
            .padding()
        }
    }
}
