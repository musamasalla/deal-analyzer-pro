//
//  AccountView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/20.
//

import SwiftUI
import Auth

struct AccountView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    @State private var showingSignOutConfirmation = false
    @State private var isSigningOut = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Section
                        VStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(AppColors.primaryTeal)
                            
                            if let email = authService.currentUser?.email {
                                Text(email)
                                    .font(AppFonts.title2)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(AppColors.successGreen)
                                    .frame(width: 8, height: 8)
                                
                                Text("Synced")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        .padding(.top, 32)
                        
                        // Account Info
                        VStack(spacing: 16) {
                            AccountRow(
                                icon: "icloud.fill",
                                title: "Cloud Sync",
                                value: "Enabled",
                                valueColor: AppColors.successGreen
                            )
                            
                            Divider()
                                .background(AppColors.border)
                            
                            AccountRow(
                                icon: "building.2.fill",
                                title: "Saved Deals",
                                value: "\(DealDataService().dealCount())",
                                valueColor: AppColors.textSecondary
                            )
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Actions
                        VStack(spacing: 12) {
                            Button(action: { showingSignOutConfirmation = true }) {
                                HStack {
                                    Image(systemName: "arrow.right.square")
                                    Text("Sign Out")
                                }
                                .font(AppFonts.button)
                                .foregroundColor(AppColors.dangerRed)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                            }
                            .disabled(isSigningOut)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
        }
        .confirmationDialog("Sign Out", isPresented: $showingSignOutConfirmation) {
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        } message: {
            Text("Are you sure you want to sign out? Your data will remain synced in the cloud.")
        }
    }
    
    private func signOut() {
        isSigningOut = true
        
        Task {
            do {
                try await authService.signOut()
            } catch {
                print("Sign out error: \(error)")
            }
            await MainActor.run {
                isSigningOut = false
            }
        }
    }
}

struct AccountRow: View {
    let icon: String
    let title: String
    let value: String
    let valueColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.primaryTeal)
                .frame(width: 32)
            
            Text(title)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(AppFonts.bodyBold)
                .foregroundColor(valueColor)
        }
    }
}

#Preview {
    AccountView()
        .environment(AuthService.shared)
}
