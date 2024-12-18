import SwiftUI
import Supabase

@available(macOS 12.0, *)
struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel: AuthViewModel
    
    init(supabase: SupabaseClient) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(supabase: supabase))
    }
    
    var body: some View {
        VStack {
            Text("Welcome to WhoAmI")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            
            LoginView(viewModel: viewModel)
        }
        .padding()
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                // Clear any error messages when successfully authenticated
                viewModel.errorMessage = ""
            }
        }
    }
}

#if DEBUG
@available(macOS 12.0, *)
struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(supabase: Config.supabaseClient)
            .environmentObject(AuthManager(supabase: Config.supabaseClient))
    }
}
#endif
