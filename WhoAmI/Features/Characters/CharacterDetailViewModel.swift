import Foundation
import Supabase
import SwiftUI

@MainActor
class CharacterDetailViewModel: ObservableObject {
    @Published var character: Character?
    @Published var problems: [CharacterProblem] = []
    @Published var relatedCharacters: [Character] = []
    @Published var showError = false
    @Published var isLoading = false
    
    private let supabase: SupabaseClient
    private let characterId: Int
    
    init(supabase: SupabaseClient, characterId: Int) {
        self.supabase = supabase
        self.characterId = characterId
        Task {
            await fetchCharacter()
        }
    }
    
    func fetchCharacter() async {
        isLoading = true
        do {
            let query = supabase.from("characters")
                .select("""
                id,
                name,
                description,
                bio,
                image_url,
                problems!character_problems (
                    problem:problems (
                        id,
                        title,
                        description,
                        created_at,
                        updated_at
                    )
                )
                """)
                .eq("id", value: characterId)
                .single()
            
            let response: PostgrestResponse<Character> = try await query.execute()
            character = response.value
            
            if let problems = character?.problems {
                self.problems = problems
                await fetchRelatedCharacters(problems: problems)
            }
        } catch {
            showError = true
            print("Error fetching character: \(error)")
        }
        isLoading = false
    }
    
    private func fetchRelatedCharacters(problems: [CharacterProblem]) async {
        do {
            let problemIds = problems.map { String($0.id) }
            
            let query = supabase.from("character_problems")
                .select("""
                character:characters (
                    id,
                    name,
                    description,
                    bio,
                    image_url,
                    created_at,
                    updated_at
                )
                """)
                .in("problem_id", value: problemIds)  // Fixed: changed 'values' to 'value'
                .neq("character_id", value: characterId)
                .limit(5)
            
            let response: PostgrestResponse<[CharacterProblemRelation]> = try await query.execute()
            relatedCharacters = response.value.compactMap { $0.character }
        } catch {
            print("Error fetching related characters: \(error)")
        }
    }
    
    func share() {
        guard let character = character else { return }
        
        let text = """
        Check out \(character.name) in our app!
        
        \(character.bio)
        
        Download the app to learn more about \(character.name) and other characters.
        """
        
        #if os(iOS)
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
        #endif
    }
}
