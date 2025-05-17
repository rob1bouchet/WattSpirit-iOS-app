//
//  NavigationManager.swift
//  WattSpiritiOS
//
//  Created by Robin Bouchet on 17/05/2025.
//

import Foundation

enum AppScreen: Hashable {
    case login
    case data
    // Add more screens as needed
}

struct AppNavigation {
    static let login = AppScreen.login
    static let data = AppScreen.data
}


class NavigationManager: ObservableObject {
    @Published var path: [AppScreen] = []

    func navigate(to screen: AppScreen) {
        path.append(screen)
    }

    func goBack() {
        _ = path.popLast()
    }

    func resetToRoot() {
        path.removeAll()
    }
}
