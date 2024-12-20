import SwiftUI
import Supabase

@MainActor
class CharacterDetailViewModel: ObservableObject {
    @Published var character: Character?
    @Published var problems: [Problem] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let supabase: SupabaseClient
    private let characterId: Int
    
    init(supabase: SupabaseClient, characterId: Int) {
        self.supabase = supabase
        self.characterId = characterId
    }
    
    func fetchCharacter() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let response: PostgrestResponse<Character> = try await supabase
            .from("characters")
            .select()
            .eq("id", value: characterId)
            .single()
            .execute()
        
        character = response.value
        try await fetchProblems()
    }
    
    func fetchProblems() async throws {
        struct JoinResult: Codable {
            let problemId: Int
            
            enum CodingKeys: String, CodingKey {
                case problemId = "problem_id"
            }
        }
        
        let response: PostgrestResponse<[JoinResult]> = try await supabase
            .from("character_problems")
            .select("problem_id")
            .eq("character_id", value: characterId)
            .execute()
        
        let problemIds = response.value.map { $0.problemId }
        
        if !problemIds.isEmpty {
            let problemsResponse: PostgrestResponse<[Problem]> = try await supabase
                .from("problems")
                .select()
                .or(problemIds.map { "id.eq.\($0)" }.joined(separator: ","))
                .execute()
            
            problems = problemsResponse.value
        }
    }
    
    func updateCharacter(_ updatedCharacter: Character) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await supabase
            .from("characters")
            .update(updatedCharacter)
            .eq("id", value: characterId)
            .execute()
        
        character = updatedCharacter
    }
}
