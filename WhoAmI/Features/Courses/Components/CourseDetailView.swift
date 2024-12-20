import SwiftUI
import Supabase

struct CourseDetailView: View {
    @StateObject private var viewModel: CourseDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection: Int = 0
    @State private var showingQuiz = false
    
    init(supabase: SupabaseClient, userId: UUID, course: Course) {
        _viewModel = StateObject(wrappedValue: CourseDetailViewModel(
            supabase: supabase,
            userId: userId,
            course: course
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Section with Image
                ZStack(alignment: .bottom) {
                    if let imageUrl = viewModel.course.imageUrl {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 250)
                        }
                    }
                    
                    // Gradient Overlay
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    
                    // Course Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.course.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        // Tags Section
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                if let metadata = viewModel.course.metadata,
                                   let tagsArray = metadata["tags"]?.stringArrayValue {
                                    ForEach(tagsArray, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundStyle(.blue)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Course Info Section
                VStack(spacing: 24) {
                    // Quick Stats
                    HStack(spacing: 20) {
                        Spacer()
                        InfoCard(
                            icon: "clock.fill",
                            title: "Duration",
                            value: "\(viewModel.course.estimatedDuration ?? 0)m"
                        )
                        
                        InfoCard(
                            icon: "star.fill",
                            title: "Level",
                            value: viewModel.course.difficulty
                        )
                        
                        InfoCard(
                            icon: "person.2.fill",
                            title: "Enrolled",
                            value: "\(viewModel.enrolledCount)"
                        )
                        Spacer()
                    }
                    .padding(.top)
                    
                    // Progress Section
                    if viewModel.isEnrolled {
                        ProgressSection(progress: viewModel.progress)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About this course")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let description = viewModel.course.description {
                            Text(description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Course Content
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Course Content")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(Array(viewModel.sections.enumerated()), id: \.element.id) { index, section in
                            SectionCard(
                                section: section,
                                isCompleted: viewModel.isCompleted(section: index),
                                isLocked: !viewModel.isEnrolled && index > 0
                            ) {
                                if viewModel.isEnrolled {
                                    selectedSection = index
                                    showingQuiz = true
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showingQuiz) {
            if let section = viewModel.sections[safe: selectedSection] {
                QuizView(section: section)
            }
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarContent
            }
            #else
            ToolbarItem {
                toolbarContent
            }
            #endif
        }
    }
    
    @ViewBuilder
    private var toolbarContent: some View {
        if viewModel.isEnrolled {
            NavigationLink(destination: CourseDiscussionView(courseId: viewModel.course.id)) {
                Label("Discussion", systemImage: "bubble.left.and.bubble.right")
            }
        } else {
            Button(action: { Task { await viewModel.enroll() }}) {
                Text("Enroll")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
        }
        .frame(width: 100)
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
}

struct ProgressSection: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Your Progress")
                .font(.headline)
            
            Gauge(value: progress) {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .gaugeStyle(.accessoryCircular)
            .tint(.blue)
            .scaleEffect(1.5)
            .padding()
        }
        .padding()
        #if os(iOS)
        .background(Color(uiColor: .systemBackground))
        #else
        .background(Color(nsColor: .windowBackgroundColor))
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
    }
}

struct SectionCard: View {
    let section: CourseSection
    let isCompleted: Bool
    let isLocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(section.title)
                        .font(.headline)
                        .foregroundStyle(isLocked ? .secondary : .primary)
                    
                    if let description = section.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: isLocked ? "lock.fill" : (isCompleted ? "checkmark.circle.fill" : "chevron.right"))
                    .foregroundStyle(isCompleted ? .green : (isLocked ? .secondary : .blue))
            }
            .padding()
            #if os(iOS)
            .background(Color(uiColor: .systemBackground))
            #else
            .background(Color(nsColor: .windowBackgroundColor))
            #endif
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 2)
        }
        .disabled(isLocked)
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    NavigationView {
        CourseDetailView(
            supabase: Config.supabaseClient,
            userId: UUID(),
            course: Course.preview
        )
    }
}
