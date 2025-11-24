//
//  LibraryView.swift
//  MangaLibrary_iosproj
//
//  Created by patience sondengam on 2025-11-04.
//

import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var mangaVM: MangaViewModel
    @EnvironmentObject var auth: AuthViewModel
    @State private var showSearch = false
    @State private var refreshTrigger = UUID()
    @State private var showFavoritesOnly = false

    private var filteredMangas: [Manga] {
        if showFavoritesOnly {
            return mangaVM.mangas.filter { $0.isFavorite == true }
        } else {
            return mangaVM.mangas
        }
    }

    var body: some View {
        VStack {
            List {
                ForEach(filteredMangas, id: \.self) { manga in
                    let coverImageView: some View = Group {
                        if let coverURLString = manga.coverURL, let url = URL(string: coverURLString) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else if phase.error != nil {
                                    Rectangle()
                                        .fill(Color.red.opacity(0.3))
                                        .overlay(Image(systemName: "exclamationmark.triangle").foregroundColor(.white))
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                }
                            }
                            .frame(width: 50, height: 75)
                            .clipped()
                            .id(refreshTrigger)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 75)
                                .id(refreshTrigger)
                        }
                    }
                    let textContentView = VStack(alignment: .leading) {
                        Text(manga.title)
                            .font(.headline)
                        Text(manga.authors?.first ?? "Unknown")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if let id = manga.id {
                        NavigationLink(value: id) {
                            HStack {
                                coverImageView
                                textContentView
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                mangaVM.toggleFavorite(manga)
                            } label: {
                                Label(manga.isFavorite == true ? "Unfavorite" : "Favorite", systemImage: manga.isFavorite == true ? "star.slash.fill" : "star.fill")
                            }
                            .tint(.yellow)
                        }
                    } else {
                        HStack {
                            coverImageView
                            textContentView
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                mangaVM.toggleFavorite(manga)
                            } label: {
                                Label(manga.isFavorite == true ? "Unfavorite" : "Favorite", systemImage: manga.isFavorite == true ? "star.slash.fill" : "star.fill")
                            }
                            .tint(.yellow)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .refreshable {
                // Refresh the LibraryView
                mangaVM.listenToMangas()
                refreshTrigger = UUID()
            }
            .navigationDestination(for: String.self) { mangaID in
                if let manga = mangaVM.mangas.first(where: { $0.id == mangaID }) {
                    MangaDetailView(manga: manga)
                } else {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading manga…")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                }
            }
        }
        .navigationTitle("Library")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Sign Out") {
                    auth.signout()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showFavoritesOnly.toggle()
                } label: {
                    Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                        .imageScale(.medium)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSearch = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .imageScale(.medium)
                }
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView()
                .environmentObject(mangaVM)
                .environmentObject(auth)
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        // Call Firestore deletion for each selected manga
        offsets.map { filteredMangas[$0] }.forEach { manga in
            mangaVM.delete(manga)
        }
    }
}
