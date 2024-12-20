import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Terms of Service
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Terms of Service")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Last updated: \(Date().formatted(date: .long, time: .omitted))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("By using WhoAmI, you agree to these terms. Please read them carefully.")
                            .font(.subheadline)
                    }
                    
                    // Privacy Policy
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Privacy Policy")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("We take your privacy seriously. This policy describes what personal information we collect and how we use it.")
                            .font(.subheadline)
                    }
                    
                    // Data Collection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Data Collection")
                            .font(.headline)
                        
                        Text("We collect information that you provide directly to us, including:")
                            .font(.subheadline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            BulletPoint("Name and contact information")
                            BulletPoint("Profile information")
                            BulletPoint("Test results and progress")
                            BulletPoint("Communication preferences")
                        }
                    }
                    
                    // Data Usage
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How We Use Your Data")
                            .font(.headline)
                        
                        Text("We use the information we collect to:")
                            .font(.subheadline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            BulletPoint("Provide and improve our services")
                            BulletPoint("Personalize your experience")
                            BulletPoint("Send important notifications")
                            BulletPoint("Analyze usage patterns")
                        }
                    }
                    
                    // Data Protection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Data Protection")
                            .font(.headline)
                        
                        Text("We implement appropriate technical and organizational measures to protect your personal data against unauthorized or unlawful processing, accidental loss, destruction, or damage.")
                            .font(.subheadline)
                    }
                    
                    // Contact
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Contact Us")
                            .font(.headline)
                        
                        Text("If you have any questions about these terms or our privacy practices, please contact us at support@whoami.com")
                            .font(.subheadline)
                    }
                }
                .padding()
            }
            .navigationTitle("Terms & Privacy")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            #else
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            #endif
        }
    }
}

private struct BulletPoint: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
        .font(.subheadline)
    }
}

#Preview {
    TermsView()
}
