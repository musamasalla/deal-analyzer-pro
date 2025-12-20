//
//  SignUpView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/20.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingSuccess = false
    
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
                        
                        Text("Create Account")
                            .font(AppFonts.largeTitle)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Start analyzing deals across all your devices")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
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
                                .textContentType(.newPassword)
                            
                            if !password.isEmpty && password.count < 6 {
                                Text("Password must be at least 6 characters")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.warningAmber)
                            }
                        }
                        
                        // Confirm Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(AppFonts.fieldLabel)
                                .foregroundColor(AppColors.textSecondary)
                            
                            SecureField("", text: $confirmPassword)
                                .textFieldStyle(AuthTextFieldStyle())
                                .textContentType(.newPassword)
                            
                            if !confirmPassword.isEmpty && password != confirmPassword {
                                Text("Passwords don't match")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.dangerRed)
                            }
                        }
                        
                        // Error message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.dangerRed)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Sign Up Button
                        Button(action: signUp) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Create Account")
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
                        
                        Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                            .font(AppFonts.caption2)
                            .foregroundColor(AppColors.textMuted)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
        }
        .alert("Check Your Email", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("We've sent you a confirmation email. Please verify your email address to continue.")
        }
    }
    
    private var isValid: Bool {
        !email.isEmpty && 
        email.contains("@") && 
        password.count >= 6 && 
        password == confirmPassword
    }
    
    private func signUp() {
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                try await authService.signUp(email: email, password: password)
                await MainActor.run {
                    isLoading = false
                    showingSuccess = true
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

#Preview {
    SignUpView()
}
