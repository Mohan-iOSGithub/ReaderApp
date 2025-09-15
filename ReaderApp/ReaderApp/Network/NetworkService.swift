//
//  NetworkService.swift
//  ReaderApp
//
//  Created by Mohanaprabhu on 12/09/25.
//

import Foundation
import UIKit

class NetworkService {
    private let apiKey = "7bc6ec09099247d4bde16f78c455640a"
    private let baseURL = "https://newsapi.org/v2/top-headlines"
    
    func fetchArticles(completion: @escaping (Result<[Article], Error>) -> Void) {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "country", value: "us"),
            URLQueryItem(name: "category", value: "technology"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        
        guard let url = components.url else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let decoded = try decoder.decode(NewsResponse.self, from: data)
                
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                let mappedArticles: [Article] = decoded.articles.map { apiArticle in
                    let publishedDate = isoFormatter.date(from: apiArticle.publishedAt) ?? Date()
                    
                    return Article(
                        id: UUID().uuidString,
                        title: apiArticle.title,
                        author: apiArticle.author ?? "Unknown",
                        publishedAt: publishedDate,
                        content: apiArticle.content ?? "",
                        imageURL: apiArticle.urlToImage,
                        url: apiArticle.url,
                        isBookmarked: false
                    )
                }
                
                completion(.success(mappedArticles))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
