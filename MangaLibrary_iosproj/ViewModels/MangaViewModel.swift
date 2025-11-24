//
//  MangaViewModel.swift
//  MangaLibrary_iosproj
//
//  Created by patience sondengam on 2025-11-05.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import FirebaseAuth

final class MangaViewModel: ObservableObject {
    static let shared = MangaViewModel()
    private init() {
        listenToMangas()
    }

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    @Published var mangas: [Manga] = []
    @Published var errorMessage: String?

    // Partial implementation: real-time listener + basic filtering helpers.
    func listenToMangas() {
        listener?.remove()
        self.mangas = []
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            // No user is logged in. Clear mangas and display a message.
            DispatchQueue.main.async { self.errorMessage = "Please log in to see your mangas." }
            return
        }
        
        listener = db.collection("mangas")
            .whereField("createdBy", isEqualTo: currentUserID)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    DispatchQueue.main.async { self?.errorMessage = error.localizedDescription }
                    return
                }
                guard let docs = snapshot?.documents else {
                    DispatchQueue.main.async { self?.mangas = [] }
                    return
                }
                let items = docs.compactMap { try? $0.data(as: Manga.self) }
                DispatchQueue.main.async { self?.mangas = items }
            }
    }

    // Add manga without image upload (50% done). Image upload to Storage not implemented yet.
    func addManga(_ manga: Manga, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let ref = db.collection("mangas").document()
            var m = manga
            m.id = ref.documentID
            m.createdAt = Date()
            m.createdBy = Auth.auth().currentUser?.uid
            try ref.setData(from: m) { error in
                if let e = error { completion(.failure(e)); return }
                completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }

    func toggleFavorite(_ manga: Manga) {
        guard let id = manga.id else { return }
        let doc = db.collection("mangas").document(id)
        doc.updateData(["isFavorite": !(manga.isFavorite ?? false)]) { error in
            if let e = error { print("Fav update error:\(e)") }
        }
    }

    func delete(_ manga: Manga) {
        guard let id = manga.id else { return }
        db.collection("mangas").document(id).delete { error in
            if let e = error { print("Delete error:\(e)") }
        }
    }

    // Helpers for filtering/sorting (local in-memory)
    func filterByGenre(_ genre: String) -> [Manga] {
        mangas.filter { $0.genres?.contains(genre) ?? false }
    }

    func sortByPopularity(descending: Bool = true) -> [Manga] {
        mangas.sorted { (a,b) in
            let ap = a.popularity ?? 0
            let bp = b.popularity ?? 0
            return descending ? ap > bp : ap < bp
        }
    }

    func sortByDate(newestFirst: Bool = true) -> [Manga] {
        mangas.sorted { (a,b) in
            let at = a.createdAt ?? Date.distantPast
            let bt = b.createdAt ?? Date.distantPast
            return newestFirst ? at > bt : at < bt
        }
    }
}

