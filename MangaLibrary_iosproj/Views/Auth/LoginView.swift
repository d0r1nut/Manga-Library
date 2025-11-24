//
//  LoginView.swift
//  MangaLibrary_iosproj
//
//  Created by patience sondengam on 2025-11-04.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var mangaVM: MangaViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSigningIn = true
    @State private var navigationTag: String?
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(isSigningIn ? "Sign In" : "Sign Up")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button(isSigningIn ? "Sign In" : "Sign Up") {
                    handleAuth()
                }
                .buttonStyle(.borderedProminent)
                
                Button(isSigningIn ? "Don't have an account? Sign Up" : "Already have an account? Sign In") {
                    isSigningIn.toggle()
                    errorMessage = nil
                }
                .font(.footnote)
                .foregroundColor(.blue)
                
                NavigationLink(destination: LibraryView()
                                .environmentObject(auth)
                                .environmentObject(mangaVM),
                               tag: "Library",
                               selection: $navigationTag) {
                    EmptyView()
                }
                .hidden()
            }
            .padding()
            .navigationTitle(isSigningIn ? "Sign In" : "Sign Up")
        }
    }
    
    private func handleAuth() {
        errorMessage = nil
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        
        if isSigningIn {
            auth.login(email: trimmedEmail, password: trimmedPassword) { success in
                if !success {
                    errorMessage = "Failed to sign in. Check your credentials."
                }
            }
        } else {
            auth.signup(email: trimmedEmail, password: trimmedPassword) { success in
                if !success {
                    errorMessage = "Failed to sign up. Ensure password is at least 6 characters and email is valid."
                }
            }
        }
    }
}
