//
//  LoginView.swift
//  Assistant
//
//  Created by Divyansh Bhardwaj on 21/02/25.
//

import SwiftUI
import KindeSDK

struct LoginView: View {
    @State private var presentAlert = false
    @State private var alertMessage = ""
    private let hintEmail = "test@test.com"
    
    private let logger: Logger?
    private let onLoggedIn: () -> Void
    private let auth: Auth = KindeSDKAPI.auth
    
    init(logger: Logger?, onLoggedIn: @escaping () -> Void) {
        self.logger = logger
        self.onLoggedIn = onLoggedIn
    }
    
    @State private var botOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Image(.BG)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack{
                Spacer(minLength: 139)
                
                Text("Enjoy Bluff with friends")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                
                Text("Simple and classic bluff at your fingertips.")
                    .font(.body)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 32)
                
                HStack(spacing: 16) {
                    Button(action: login) {
                        RoundedRectangle(cornerRadius: 14)
                            .frame(width: 163, height: 56)
                            .foregroundStyle(.white)
                            .overlay(Text("Sign In")
                                .font(.headline)
                                .foregroundStyle(.black))
                    }
                    
                    Button(action: register) {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black, lineWidth: 2) // Black border
                            .background(Color.white) // White background
                            .cornerRadius(14)
                            .frame(width: 163, height: 56)
                            .overlay(Text("Sign Up")
                                .font(.headline)
                                .foregroundStyle(.black))
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 72)
            }
        }
    }
    
    func signIn() {
        print("Sign In tapped")
    }
}

extension LoginView {
    func register() {
        auth.enablePrivateAuthSession(true)
        auth.register(loginHint: hintEmail) { result in
            switch result {
            case let .failure(error):
                if !auth.isUserCancellationErrorCode(error) {
                    alertMessage = "Registration failed: \(error.localizedDescription)"
                    self.logger?.error(message: alertMessage)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        presentAlert = true
                    }
                }
            case .success:
                self.onLoggedIn()
            }
        }
    }
    
    func login() {
        auth.enablePrivateAuthSession(true)
        auth.login(loginHint: hintEmail) { result in
            switch result {
            case let .failure(error):
                if !auth.isUserCancellationErrorCode(error) {
                    alertMessage = "Login failed: \(error.localizedDescription)"
                    self.logger?.error(message: alertMessage)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        presentAlert = true
                    }
                }
            case .success:
                self.onLoggedIn()
            }
        }
    }
}
