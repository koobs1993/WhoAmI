import SwiftUI
import Supabase

struct CharacterDetailView: View {
    @StateObject private var viewModel: CharacterDetailViewModel
    
    init(supabase: SupabaseClient, characterId: Int) {
        _viewModel = StateObject(wrappedValue: CharacterDetailViewModel(supabase: supabase, characterId: characterId))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let character = viewModel.character {
                    CharacterHeaderView(character: character)
                    
                    if !viewModel.problems.isEmpty {
                        Text("Problems")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(viewModel.problems) { problem in
                            ProblemCard(problem: problem)
                        }
                    }
                    
                    if !viewModel.relatedCharacters.isEmpty {
                        Text("Related Characters")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(viewModel.relatedCharacters) { character in
                                    RelatedCharacterCard(character: character)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.character?.name ?? "Character")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: viewModel.share) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Failed to load character details. Please try again later.")
        }
    }
}

struct CharacterHeaderView: View {
    let character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(character.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text(character.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct ProblemCard: View {
    let problem: CharacterProblem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(problem.title)
                .font(.headline)
                .fontWeight(.medium)
            
            Text(problem.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.background)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct RelatedCharacterCard: View {
    let character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(character.name)
                .font(.headline)
                .fontWeight(.medium)
            
            Text(character.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(width: 200)
        .padding()
        .background(Color.background)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 