import Foundation
import Supabase

struct OnboardingService {
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func fetchQuestions() async throws -> [OnboardingQuestion] {
        let response = try await supabase.database
            .from("onboarding_questions")
            .select()
            .execute()
            
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let data = try JSONSerialization.data(withJSONObject: response.underlyingResponse.data ?? [])
        return try decoder.decode([OnboardingQuestion].self, from: data)
    }
    
    func saveUserProfile(_ profile: UserResearchProfile) async throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(profile)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        
        let encodableDict = dict.mapValues { value -> String in
            if let v = value as? CustomStringConvertible {
                return String(describing: v)
            }
            return String(describing: value)
        }
        
        try await supabase.database
            .from("user_research_profiles")
            .upsert(values: encodableDict)
            .execute()
    }
} 