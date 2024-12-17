//
//  WhoAmIApp.swift
//  WhoAmI
//
//  Created by Kyle Kelley on 12/15/24.
//

import SwiftUI
import Supabase

@main
struct WhoAmIApp: App {
    @StateObject private var authManager = AuthManager(supabase: Config.supabaseClient)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
