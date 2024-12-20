import SwiftUI

struct CategoryFilterSection: View {
    @Binding var selectedCategory: String?
    let categories: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All Categories",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                
                ForEach(categories, id: \.self) { category in
                    FilterChip(
                        title: category,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct DifficultyFilterSection: View {
    @Binding var selectedDifficulty: String?
    let difficulties: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All Levels",
                    isSelected: selectedDifficulty == nil,
                    action: { selectedDifficulty = nil }
                )
                
                ForEach(difficulties, id: \.self) { difficulty in
                    FilterChip(
                        title: difficulty,
                        isSelected: selectedDifficulty == difficulty,
                        action: { selectedDifficulty = difficulty }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}
