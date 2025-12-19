//
//  SectionHeader.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Consistent section header with icon
struct SectionHeader: View {
    let title: String
    var icon: String? = nil
    var subtitle: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primaryTeal)
                }
                
                Text(title)
                    .font(AppFonts.sectionHeader)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Collapsible section with header
struct CollapsibleSection<Content: View>: View {
    let title: String
    var icon: String? = nil
    @Binding var isExpanded: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.primaryTeal)
                    }
                    
                    Text(title)
                        .font(AppFonts.sectionHeader)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(16)
                .background(AppColors.cardBackground)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                content
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

/// Card-style section container
struct SectionCard<Content: View>: View {
    let title: String
    var icon: String? = nil
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: title, icon: icon)
            
            content
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        ScrollView {
            VStack(spacing: 20) {
                SectionHeader(
                    title: "Property Details",
                    icon: "house.fill",
                    subtitle: "Enter basic property information"
                )
                
                SectionCard(title: "Financing", icon: "banknote.fill") {
                    VStack(spacing: 12) {
                        Text("Down Payment: 20%")
                        Text("Interest Rate: 7.5%")
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                
                CollapsibleSection(
                    title: "Advanced Options",
                    icon: "gearshape.fill",
                    isExpanded: .constant(true)
                ) {
                    VStack(spacing: 12) {
                        Text("Option 1")
                        Text("Option 2")
                    }
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal)
                }
            }
            .padding()
        }
    }
}
