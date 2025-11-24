//
//  AuthViewModel.swift
//  MangaLibrary_iosproj
//
//  Created by patience sondengam on 2025-11-04.
//

import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    static let shared = AuthViewModel()
    
    @Published var user: User?
    @Published var isSignedIn = false
    
    private init() {
        self.user = Auth.auth().currentUser
        self.isSignedIn = user != nil
    }
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: trimmedEmail, password: trimmedPassword) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Login error:", error.localizedDescription)
                    self.user = nil
                    self.isSignedIn = false
                    MangaViewModel.shared.listenToMangas()
                    completion(false)
                    return
                }
                self.user = result?.user
                self.isSignedIn = true
                MangaViewModel.shared.listenToMangas()
                completion(true)
            }
        }
    }
    
    func signup(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().createUser(withEmail: trimmedEmail, password: trimmedPassword) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Firebase signup error:", error.localizedDescription)
                    self.user = nil
                    self.isSignedIn = false
                    MangaViewModel.shared.listenToMangas()
                    completion(false)
                    return
                }
                self.user = result?.user
                self.isSignedIn = true
                MangaViewModel.shared.listenToMangas()
                completion(true)
            }
        }
    }
    
    func signout() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isSignedIn = false
            MangaViewModel.shared.listenToMangas()
        } catch {
            print("Sign out error:", error.localizedDescription)
        }
    }
}
