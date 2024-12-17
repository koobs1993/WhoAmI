import SwiftUI

struct NotificationPromptView: View {
    @Environment(\.dismiss) private var dismiss
    let onAllow: () -> Void
    let onDeny: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.badge")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("Enable Notifications")
                .font(.title2)
                .bold()
            
            Text("Stay updated with important information about your courses, tests, and messages.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                Button {
                    onAllow()
                    dismiss()
                } label: {
                    Text("Allow Notifications")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
                
                Button {
                    onDeny()
                    dismiss()
                } label: {
                    Text("Not Now")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(32)
        .background(Color(PlatformUtils.systemBackground))
        .cornerRadius(20)
        .padding(.horizontal, 24)
    }
}

#Preview {
    NotificationPromptView(
        onAllow: {},
        onDeny: {}
    )
} 