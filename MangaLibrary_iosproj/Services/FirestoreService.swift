//
//  FirestoreService.swift
//  MangaLibrary_iosproj
//
//  Created by patience sondengam on 2025-11-05.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// Wrapper for user favourites. Partial implementation.
final class FirestoreService {
    static let shared = FirestoreService()
    private init() {}
    private let db = Firestore.firestore()

    func fetchUserFavourites(uid: String, completion: @escaping (Result<[Manga], Error>) -> Void) {
        db.collection("users").document(uid).collection("favourites").getDocuments { snapshot, error in
            if let error = error { completion(.failure(error)); return }
            let items = snapshot?.documents.compactMap { try? $0.data(as: Manga.self) } ?? []
            completion(.success(items))
        }
    }

    func saveFavourite(uid: String, manga: Manga, completion: @escaping (Error?) -> Void) {
        guard let id = manga.id else { completion(NSError(domain: "NoID", code: -1)); return }
        do {
            try db.collection("users").document(uid).collection("favourites").document(id).setData(from: manga, completion: completion)
        } catch {
            completion(error)
        }
    }

    func removeFavourite(uid: String, mangaId: String, completion: @escaping (Error?) -> Void) {
        db.collection("users").document(uid).collection("favourites").document(mangaId).delete(completion: completion)
    }
}

