import SwiftUI
import Supabase

struct WeeklyColumnDetailView: View {
    let column: WeeklyColumn
    @State private var showingShareSheet = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let imageUrl = column.featuredImageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(column.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let subtitle = column.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(column.content)
                        .font(.body)
                        .lineSpacing(6)
                    
                    if let author = column.author {
                        HStack {
                            Image(systemName: "person.circle.fill")
                            Text("By \(author)")
                                .font(.subheadline)
                        }
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    }
                    
                    ShareButton(showingShareSheet: $showingShareSheet)
                        .padding(.top)
                }
                .padding(.horizontal)
            }
        }
        .background(colorScheme == .dark ? Color(.windowBackgroundColor) : Color(.textBackgroundColor))
        #if os(iOS)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [createShareText()])
        }
        #else
        .sheet(isPresented: $showingShareSheet) {
            MacShareView(text: createShareText())
        }
        #endif
        .alert("Error", isPresented: $showingError) {
            Button("OK") {
                showingError = false
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func createShareText() -> String {
        var text = column.title
        
        if let subtitle = column.subtitle {
            text += "\n\n\(subtitle)"
        }
        
        text += "\n\n\(column.content)"
        
        if let author = column.author {
            text += "\n\nBy \(author)"
        }
        
        return text
    }
}

struct ShareButton: View {
    @Binding var showingShareSheet: Bool
    
    var body: some View {
        Button(action: {
            showingShareSheet = true
        }) {
            Label("Share", systemImage: "square.and.arrow.up")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#else
struct MacShareView: View {
    let text: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Share")
                .font(.headline)
            
            Button("Copy to Clipboard") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(width: 300, height: 200)
        .background(colorScheme == .dark ? Color(.windowBackgroundColor) : Color(.textBackgroundColor))
    }
}
#endif 