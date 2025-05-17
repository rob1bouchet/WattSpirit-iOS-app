//
//  WattSpiritiOSApp.swift
//  WattSpiritiOS
//
//  Created by Robin Bouchet on 17/05/2025.
//

import SwiftUI

@main
struct WattSpiritiOSApp: App {
    
    @StateObject private var navManager = NavigationManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navManager.path) {
                LoginView()
                    .navigationDestination(for: AppScreen.self) { screen in
                        switch screen {
                        case .login:
                            LoginView()
                        case .data:
                            DataView()
                        }
                    }
            }
            .environmentObject(navManager)
        }
    }
}
