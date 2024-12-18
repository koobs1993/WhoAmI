import Foundation
import Supabase

class OnboardingService: BaseService {
    override init(supabase: SupabaseClient) {
        super.init(supabase: supabase)
    }
    
    func fetchQuestions() async throws -> [WhoAmI.OnboardingQuestion] {
        let response: PostgrestResponse<[WhoAmI.OnboardingQuestion]> = try await supabase.database
            .from("onboarding_questions")
            .select()
            .execute()
        return response.value
    }
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        try await supabase.database
            .from("user_profiles")
            .insert(profile)
            .execute()
    }
} 