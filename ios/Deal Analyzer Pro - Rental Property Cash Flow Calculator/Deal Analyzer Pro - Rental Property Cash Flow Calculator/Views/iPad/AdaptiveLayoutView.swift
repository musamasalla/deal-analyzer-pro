//
//  AdaptiveLayoutView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/18.
//

import SwiftUI

/// Adaptive layout that switches between iPhone and iPad layouts
struct AdaptiveLayoutView: View {
    @Bindable var viewModel: DealViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .regular {
            // iPad layout
            iPadDashboardView(viewModel: viewModel)
        } else {
            // iPhone layout
            MainTabView(viewModel: viewModel)
        }
    }
}

/// Device-aware modifier for responsive layouts
struct ResponsiveModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let compactPadding: CGFloat
    let regularPadding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding(horizontalSizeClass == .regular ? regularPadding : compactPadding)
    }
}

extension View {
    func responsivePadding(compact: CGFloat = 16, regular: CGFloat = 24) -> some View {
        modifier(ResponsiveModifier(compactPadding: compact, regularPadding: regular))
    }
}

/// Adaptive grid that changes columns based on device
struct AdaptiveGrid<Content: View>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var columns: [GridItem] {
        if horizontalSizeClass == .regular {
            return [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ]
        } else {
            return [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]
        }
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: horizontalSizeClass == .regular ? 16 : 12) {
            content
        }
    }
}

#Preview {
    AdaptiveLayoutView(viewModel: DealViewModel())
}
