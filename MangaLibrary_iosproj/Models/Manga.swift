//
//  Manga.swift
//  MangaLibrary_iosproj
//
//  Created by patience sondengam on 2025-11-05.
//

import Foundation
import FirebaseFirestoreSwift

struct Manga: Identifiable, Hashable, Codable {
    @DocumentID var id: String? = nil
    var title: String
    var authors: [String]?
    var synopsis: String?
    var coverURL: String?
    var genres: [String]?
    var popularity: Int?
    var createdAt: Date?
    var createdBy: String?
    var isFavorite: Bool? = false
    var readLink: String?

    init(id: String? = nil,
         title: String,
         authors: [String]? = nil,
         synopsis: String? = nil,
         coverURL: String? = nil,
         genres: [String]? = nil,
         popularity: Int? = nil,
         createdAt: Date? = Date(),
         createdBy: String? = nil,
         isFavorite: Bool? = false) {
        self.id = id
        self.title = title
        self.authors = authors
        self.synopsis = synopsis
        self.coverURL = coverURL
        self.genres = genres
        self.popularity = popularity
        self.createdAt = createdAt
        self.createdBy = createdBy
        self.isFavorite = isFavorite
    }
}

