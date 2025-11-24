//
//  SearchView.swift
//  MangaLibrary_iosproj
//
//  Created by patience sondengam on 2025-11-05.
//

import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @State private var results: [MALManga] = []
    @State private var isLoading = false
    @State private var error: String?
    
    @EnvironmentObject var mangaVM: MangaViewModel
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @FocusState private var searchFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Search manga (3 letters min)", text: $query)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .focused($searchFieldFocused)
                    
                    Button("Search") { search() }
                        .disabled(query.trimmingCharacters(in: .whitespaces).count < 3)
                }
                .padding()
                
                if isLoading { ProgressView().padding() }
                if let e = error { Text(e).foregroundColor(.red).padding() }
                
                List(results, id: \.id) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)
                        }
                        Spacer()
                        Button("Import") {
                            importManga(item)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Search Online")
            .toolbar {
                // Keyboard toolbar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        // Dismiss keyboard first to avoid constraint warnings
                        searchFieldFocused = false
                        // Give the keyboard a moment to dismiss before closing the sheet
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            // Helps reduce awkward layout changes while the keyboard is up
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - Functions
    
    private func search() {
        isLoading = true
        error = nil
        
        MALAPIManager.shared.searchManga(query: query, limit: 15) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let mangas):
                    self.results = mangas
                case .failure(let e):
                    self.error = e.localizedDescription
                }
            }
        }
    }
    
    private func importManga(_ item: MALManga) {
        guard let uid = auth.user?.uid else {
            self.error = "You must be signed in to import manga."
            return
        }

        isLoading = true
        error = nil

        let idString = String(item.id)
        MALAPIManager.shared.addManga(query: idString) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetched):
                    let mangaToAdd = Manga(
                        title: fetched.title,
                        authors: fetched.authors ?? [],
                        synopsis: nil,
                        coverURL: fetched.main_picture?.large,
                        genres: fetched.genres ?? [],
                        popularity: nil,
                        createdBy: uid
                    )
                    self.mangaVM.addManga(mangaToAdd) { addResult in
                        DispatchQueue.main.async {
                            self.isLoading = false
                            switch addResult {
                            case .success:
                                MangaViewModel.shared.listenToMangas()
                                self.presentationMode.wrappedValue.dismiss()
                            case .failure(let error):
                                self.error = "Failed to import manga: \(error.localizedDescription)"
                            }
                        }
                    }
                case .failure(let e):
                    self.isLoading = false
                    self.error = e.localizedDescription
                }
            }
        }
    }

}
