import Foundation
import Supabase

class OnboardingService: BaseService {
    func createProfile(_ profile: UserProfile) async throws {
        try await supabase.database
            .from("user_profiles")
            .insert(values: profile)
            .execute()
    }
    
    func updateProfile(_ profile: UserProfile) async throws {
        try await supabase.database
            .from("user_profiles")
            .update(values: profile)
            .eq(column: "user_id", value: profile.userId.uuidString)
            .execute()
    }
    
    func fetchQuestions() async throws -> [OnboardingQuestion] {
        let response = try await supabase.database
            .from("onboarding_questions")
            .select()
            .execute()
            
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let data = try JSONSerialization.data(withJSONObject: response.underlyingResponse.data)
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