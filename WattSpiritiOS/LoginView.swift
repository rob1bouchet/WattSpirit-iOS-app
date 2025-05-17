//
//  ContentView.swift
//  WattSpiritiOS
//
//  Created by Robin Bouchet on 17/05/2025.
//

import SwiftUI

struct LoginView: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @EnvironmentObject private var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 16) {
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button("Login") {
                Task {
                    do {
                        try await NetworkingManager().login(username: username, password: password)
                        navigationManager.navigate(to: .data)
                    } catch {
                        errorMessage = "Login failed: \(error.localizedDescription)"
                        print("Login failed: \(error)")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    LoginView()
        .environmentObject(NavigationManager())
}
