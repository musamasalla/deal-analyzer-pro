//
//  MainTabView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/17.
//

import SwiftUI

/// Main tab navigation for the app
struct MainTabView: View {
    @State var viewModel: DealViewModel = DealViewModel()
    @State private var selectedTab: Tab = .analyze
    
    enum Tab {
        case analyze
        case saved
        case compare
        case calculators
        case settings
        
        var title: String {
            switch self {
            case .analyze: return "Analyze"
            case .saved: return "Saved"
            case .compare: return "Compare"
            case .calculators: return "Calc"
            case .settings: return "Account"
            }
        }
        
        var icon: String {
            switch self {
            case .analyze: return "house.fill"
            case .saved: return "folder.fill"
            case .compare: return "square.stack.3d.up.fill"
            case .calculators: return "function"
            case .settings: return "person.circle.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DealEntryView(viewModel: viewModel)
                .tabItem {
                    Label(Tab.analyze.title, systemImage: Tab.analyze.icon)
                }
                .tag(Tab.analyze)
            
            SavedDealsListView(viewModel: viewModel)
                .tabItem {
                    Label(Tab.saved.title, systemImage: Tab.saved.icon)
                }
                .tag(Tab.saved)
            
            DealComparisonView(viewModel: viewModel)
                .tabItem {
                    Label(Tab.compare.title, systemImage: Tab.compare.icon)
                }
                .tag(Tab.compare)
            
            CalculatorsTabView(viewModel: viewModel)
                .tabItem {
                    Label(Tab.calculators.title, systemImage: Tab.calculators.icon)
                }
                .tag(Tab.calculators)
            
            AccountView()
                .tabItem {
                    Label(Tab.settings.title, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(AppColors.primaryTeal)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(AppColors.tabBarBackground)
            
            // Normal state
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.tabUnselected)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(AppColors.tabUnselected)
            ]
            
            // Selected state
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.tabSelected)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(AppColors.tabSelected)
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainTabView()
}
