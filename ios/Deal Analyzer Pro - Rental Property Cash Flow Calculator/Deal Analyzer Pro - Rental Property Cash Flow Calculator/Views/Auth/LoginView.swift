//
//  LoginView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/20.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let authService = AuthService.shared
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.primaryTeal)
                        
                        Text("Welcome Back")
                            .font(AppFonts.largeTitle)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Sign in to sync your deals")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 60)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(AppFonts.fieldLabel)
                                .foregroundColor(AppColors.textSecondary)
                            
                            TextField("", text: $email)
                                .textFieldStyle(AuthTextFieldStyle())
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        
                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(AppFonts.fieldLabel)
                                .foregroundColor(AppColors.textSecondary)
                            
                            SecureField("", text: $password)
                                .textFieldStyle(AuthTextFieldStyle())
                                .textContentType(.password)
                        }
                        
                        // Error message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.dangerRed)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Sign In Button
                        Button(action: signIn) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Sign In")
                                        .font(AppFonts.button)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.primaryGradient)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isLoading || !isValid)
                        .opacity(isValid ? 1.0 : 0.5)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
        }
    }
    
    private var isValid: Bool {
        !email.isEmpty && email.contains("@") && password.count >= 6
    }
    
    private func signIn() {
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                try await authService.signIn(email: email, password: password)
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Text Field Style

struct AuthTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(AppFonts.body)
            .foregroundColor(AppColors.textPrimary)
            .padding()
            .background(AppColors.inputBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.border, lineWidth: 1)
            )
    }
}

#Preview {
    LoginView()
}
