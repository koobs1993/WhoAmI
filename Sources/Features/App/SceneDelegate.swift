import UIKit
import SwiftUI
import Supabase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let supabase = SupabaseClient.shared
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let contentView = ContentView()
            .environmentObject(AuthViewModel(supabase: supabase))
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
        
        // Handle any URLs that were passed when launching the app
        if let urlContext = connectionOptions.urlContexts.first {
            handleIncomingURL(urlContext.url)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleIncomingURL(url)
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "whoami" else { return }
        
        Task {
            do {
                try await supabase.auth.session(from: url)
            } catch {
                print("Error handling OAuth callback: \(error)")
            }
        }
    }
} 