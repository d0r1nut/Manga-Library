//
//  MALAPIManager.swift
//  MangaLibrary_iosproj
//
//  Created by patience sondengam on 2025-11-05.
//

import Foundation

// Simple MAL v2 search manager using Client ID header.
struct MALManga: Identifiable, Codable {
    let id: Int
    let title: String
    let authors: [String]?
    let genres: [String]?
    let main_picture: Picture?
    struct Picture: Codable {
        let medium: String?
        let large: String?
    }
}

struct MALSearchResponse: Codable {
    let data: [Node]
    struct Node: Codable {
        let node: MALManga
    }
}

final class MALAPIManager {
    static let shared = MALAPIManager()
    private init() {}
    private let baseURL = "https://api.myanimelist.net/v2/manga"
    private let clientID = Constants.MAL_CLIENT_ID // set in Constants.swift

    func searchManga(query: String, limit: Int = 20, completion: @escaping (Result<[MALManga], Error>) -> Void) {
        guard let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?q=\(q)&limit=\(limit)") else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1)))
            return
        }
        var req = URLRequest(url: url)
        req.setValue(clientID, forHTTPHeaderField: "X-MAL-Client-ID")
        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(NSError(domain: "NoData", code: -1))); return }
            do {
                let decoded = try JSONDecoder().decode(MALSearchResponse.self, from: data)
                let mangas = decoded.data.map { $0.node }
                completion(.success(mangas))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    private struct MALMangaDetail: Codable {
        let id: Int
        let title: String
        let main_picture: MALManga.Picture?
        let genres: [Genre]?
        let authors: [Author]?

        struct Genre: Codable {
            let id: Int
            let name: String
        }

        struct Author: Codable {
            let node: AuthorNode
            let role: String?
        }

        struct AuthorNode: Codable {
            let id: Int
            let first_name: String?
            let last_name: String?
            let name: String?
        }
    }

    func addManga(query idString: String, completion: @escaping (Result<MALManga, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(idString)?fields=id,title,main_picture,alternative_titles,start_date,end_date,synopsis,mean,rank,popularity,num_list_users,num_scoring_users,nsfw,created_at,updated_at,media_type,status,genres,my_list_status,num_volumes,num_chapters,authors{first_name,last_name},pictures,background,related_anime,related_manga,recommendations,serialization{name}") else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1)))
            return
        }
        var req = URLRequest(url: url)
        req.setValue(clientID, forHTTPHeaderField: "X-MAL-Client-ID")
        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { completion(.failure(NSError(domain: "NoData", code: -1))); return }
            do {
                let detail = try JSONDecoder().decode(MALMangaDetail.self, from: data)
                debugPrint(detail)
                let genreNames: [String]? = detail.genres?.map { $0.name }

                let authorNames: [String]? = detail.authors?.compactMap { author in
                    if let name = author.node.name, !name.isEmpty {
                        return name
                    }
                    let first = author.node.first_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    let last = author.node.last_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    let combined = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
                    return combined.isEmpty ? nil : combined
                }

                let simplified = MALManga(
                    id: detail.id,
                    title: detail.title,
                    authors: authorNames,
                    genres: genreNames,
                    main_picture: detail.main_picture
                )
                completion(.success(simplified))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

