//
//  AuthenticationRootView.swift
//  Deal Analyzer Pro
//
//  Created on 2025/12/20.
//

import SwiftUI

struct AuthenticationRootView: View {
    @State private var showingSignUp = false
    
    var body: some View {
        ZStack {
            if showingSignUp {
                SignUpView()
            } else {
                LoginView()
            }
            
            // Toggle button
            VStack {
                Spacer()
                
                Button(action: { showingSignUp.toggle() }) {
                    HStack(spacing: 4) {
                        Text(showingSignUp ? "Already have an account?" : "Don't have an account?")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(showingSignUp ? "Sign In" : "Sign Up")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.primaryTeal)
                    }
                    .padding()
                }
                .padding(.bottom, 40)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingSignUp)
    }
}

#Preview {
    AuthenticationRootView()
}
