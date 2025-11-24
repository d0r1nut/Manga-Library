//
//  MangaDetailView.swift
//  MangaLibrary_iosproj
//
//  Created by patience sondengam on 2025-11-06.
//

import SwiftUI

struct MangaDetailView: View {
    let manga: Manga

    // Optional URL computed property for cover image
    private var coverURL: URL? {
        guard let str = manga.coverURL else { return nil }
        return URL(string: str)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Cover image
                if let url = coverURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(8)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 250)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                }

                // Title
                Text(manga.title)
                    .font(.title)
                    .bold()

                // Author
                if let authors = manga.authors, !authors.isEmpty {
                    Text("Authors: \(authors.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Genres
                if let genres = manga.genres, !genres.isEmpty {
                    Text("Genres: \(genres.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Synopsis
                if let synopsis = manga.synopsis, !synopsis.isEmpty {
                    Text("Synopsis:")
                        .font(.headline)
                        .padding(.top, 8)
                    Text(synopsis)
                        .font(.body)
                        .foregroundColor(.primary)
                }

                // Read Online Button
                if let link = manga.readLink, let url = URL(string: link) {
                    Link(destination: url) {
                        Text("Read Online")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 16)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Manga Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
