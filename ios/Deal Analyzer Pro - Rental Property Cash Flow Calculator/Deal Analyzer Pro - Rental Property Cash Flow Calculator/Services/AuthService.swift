import Foundation
import Supabase
import Observation

/// Service for handling user authentication via Supabase
@Observable
class AuthService {
    static let shared = AuthService()
    
    var currentUser: User?
    var session: Session?
    var isLoading = false
    var error: Error?
    
    private let supabase = SupabaseService.shared.client
    
    var isAuthenticated: Bool {
        session != nil
    }
    
    init() {
        Task {
            await checkSession()
            await observeAuthChanges()
        }
    }
    
    @MainActor
    func checkSession() async {
        do {
            self.session = try await supabase.auth.session
            self.currentUser = self.session?.user
        } catch {
            self.session = nil
            self.currentUser = nil
        }
    }
    
    @MainActor
    func observeAuthChanges() async {
        for await (event, session) in supabase.auth.authStateChanges {
            self.session = session
            self.currentUser = session?.user
            print("Auth Event: \(event)")
        }
    }
    
    @MainActor
    func signUp(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await supabase.auth.signUp(email: email, password: password)
            self.error = nil
        } catch {
            self.error = error
            throw error
        }
    }
    
    @MainActor
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            self.session = session
            self.currentUser = session.user
            self.error = nil
        } catch {
            self.error = error
            throw error
        }
    }
    
    @MainActor
    func signOut() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await supabase.auth.signOut()
            self.session = nil
            self.currentUser = nil
            self.error = nil
        } catch {
            self.error = error
            throw error
        }
    }
}
