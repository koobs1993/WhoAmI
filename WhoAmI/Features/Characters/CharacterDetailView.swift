import SwiftUI
import Supabase

struct CharacterDetailView: View {
    @StateObject private var viewModel: CharacterDetailViewModel
    
    init(supabase: SupabaseClient, characterId: UUID) {
        _viewModel = StateObject(wrappedValue: CharacterDetailViewModel(
            supabase: supabase,
            characterId: characterId
        ))
    }
    
    var body: some View {
        ScrollView {
            if let character = viewModel.character {
                VStack(alignment: .leading, spacing: 16) {
                    CharacterHeaderView(character: character)
                    Divider()
                    
                    ForEach(viewModel.problems) { problem in
                        CharacterProblemCard(problem: problem)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            } else {
                ProgressView()
                    .padding()
            }
        }
        .navigationTitle("Character Details")
        .task {
            do {
                try await viewModel.fetchCharacter()
            } catch {
                print("Error fetching character: \(error)")
            }
        }
    }
}

struct CharacterHeaderView: View {
    let character: Character
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(character.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text(character.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            Text(character.bio)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 4)
            
            if let imageUrl = character.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                } placeholder: {
                    Color.gray.opacity(0.3)
                        .frame(height: 200)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct CharacterProblemCard: View {
    let problem: Problem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(problem.title)
                .font(.headline)
            
            Text(problem.shortDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text(problem.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(problem.updatedAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    NavigationView {
        CharacterDetailView(
            supabase: Config.supabaseClient,
            characterId: UUID()
        )
    }
}
