//
//  ContentView.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 27/03/25.
//

import SwiftUI
import KindeSDK

struct ContentView: View {
    @State private var isAuthenticated: Bool
    @State private var user: UserProfile?
    @State private var presentAlert = false
    @State private var alertMessage = ""
    
    private let logger: Logger?
    
    init() {
        self.logger = Logger()
        
        KindeSDKAPI.configure(self.logger ?? DefaultLogger())
        
        _isAuthenticated = State(initialValue: KindeSDKAPI.auth.isAuthorized())
    }
    
    var body: some View {
        Group {
            if isAuthenticated {
                GameView()
            } else {
                LoginView(logger: self.logger, onLoggedIn: onLoggedIn)
                    .transition(.opacity)
                    .animation(.easeInOut, value: isAuthenticated)
            }
        }
        .onAppear {
            Task{
                await logout()
            }
        }
        .alert(isPresented: $presentAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage)
            )
        }
    }
}

extension ContentView {
    func onLoggedIn() {
        isAuthenticated = true
        getUserProfile()
    }
    
    func onLoggedOut() {
        isAuthenticated = false
        user = nil
    }
    
    private func getUserProfile() {
        Task {
            isAuthenticated = await asyncGetUserProfile()
        }
    }
    
    private func asyncGetUserProfile() async -> Bool {
        do {
            let userProfile = try await OAuthAPI.getUser()
            self.user = userProfile
            let userName = "\(userProfile.givenName ?? "") \(userProfile.familyName ?? "")"
            self.logger?.info(message: "Got profile for user \(userName)")
            return true
        } catch {
            alertMessage = "Failed to get user profile: \(error.localizedDescription)"
            self.logger?.error(message: alertMessage)
            presentAlert = true
            return false
        }
    }
    //    "kp_4a44ef61202f46fea762d718a1082aea"
    func logout() async {
        do {
            try await KindeSDKAPI.auth.logout()
            isAuthenticated = false
            print("Successfully logged out")
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }
}


#Preview {
    ContentView()
}
