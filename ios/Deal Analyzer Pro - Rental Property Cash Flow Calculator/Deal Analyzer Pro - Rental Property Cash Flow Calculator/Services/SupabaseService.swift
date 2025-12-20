import Foundation
import Supabase

/// Central service for Supabase client management
class SupabaseService {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: AppConfiguration.Supabase.url,
            supabaseKey: AppConfiguration.Supabase.apiKey
        )
    }
    
    // Helper for auth
    var auth: AuthClient { client.auth }
    
    // Helper for database
    var database: PostgrestClient { client.database }
}
