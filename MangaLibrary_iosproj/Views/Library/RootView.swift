//
//  RootView.swift
//  MangaLibrary_iosproj
//
//  Created by d0r1nut on 2025-11-22.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        NavigationStack {
            if auth.isSignedIn {
                LibraryView()
            } else {
                LoginView()
            }
        }
    }
}
