import SwiftUI
import Supabase

@MainActor
class CharacterDetailViewModel: ObservableObject {
    @Published var character: Character?
    @Published var problems: [Problem] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let supabase: SupabaseClient
    private let characterId: UUID
    
    init(supabase: SupabaseClient, characterId: UUID) {
        self.supabase = supabase
        self.characterId = characterId
    }
    
    func fetchCharacter() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let response: PostgrestResponse<Character> = try await supabase.database
            .from("characters")
            .select()
            .eq("id", value: characterId.uuidString)
            .single()
            .execute()
        
        character = response.value
        try await fetchProblems()
    }
    
    func fetchProblems() async throws {
        let response: PostgrestResponse<[Dictionary<String, String>]> = try await supabase.database
            .from("character_problems")
            .select("problem_id")
            .eq("character_id", value: characterId.uuidString)
            .execute()
        
        let problemIds = response.value.compactMap { $0["problem_id"] }
        
        if !problemIds.isEmpty {
            let problemsResponse: PostgrestResponse<[Problem]> = try await supabase.database
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
        
        try await supabase.database
            .from("characters")
            .update(updatedCharacter)
            .eq("id", value: characterId.uuidString)
            .execute()
        
        character = updatedCharacter
    }
}
