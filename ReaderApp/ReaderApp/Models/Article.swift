//
//  Article.swift
//  ReaderApp
//
//  Created by Mohanaprabhu on 12/09/25.
//

import Foundation

// MARK: - Article Model
struct Article {
    let id: String
    let title: String
    let author: String?
    let publishedAt: Date
    let content: String?
    let imageURL: String?
    let url: String
    var isBookmarked: Bool?
    var isCached: Bool
    
    // MARK: - Custom Initializers
    
    // Convenience initializer with default values
    init(id: String,
         title: String,
         author: String?,
         publishedAt: Date,
         content: String?,
         imageURL: String?,
         url: String,
         isBookmarked: Bool = false,
         isCached: Bool = false) {
        self.id = id
        self.title = title
        self.author = author
        self.publishedAt = publishedAt
        self.content = content
        self.imageURL = imageURL
        self.url = url
        self.isBookmarked = isBookmarked
        self.isCached = isCached
    }
    
    // Convenience initializer for API responses
    init(from apiResponse: ArticleResponse) {
        self.id = apiResponse.url
        self.title = apiResponse.title
        self.author = apiResponse.author
        self.publishedAt = ISO8601DateFormatter().date(from: apiResponse.publishedAt) ?? Date()
        self.content = apiResponse.content
        self.imageURL = apiResponse.urlToImage
        self.url = apiResponse.url
        self.isBookmarked = false
        self.isCached = false
    }
}

// MARK: - Article Extensions
extension Article {
    
    // MARK: - Computed Properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: publishedAt)
    }
    
    var timeAgo: String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(publishedAt)
        
        if timeInterval < 3600 { // Less than 1 hour
            let minutes = Int(timeInterval / 60)
            return "\(minutes) minutes ago"
        } else if timeInterval < 86400 { // Less than 1 day
            let hours = Int(timeInterval / 3600)
            return "\(hours) hours ago"
        } else {
            let days = Int(timeInterval / 86400)
            return "\(days) days ago"
        }
    }
    
    var shortContent: String {
        guard let content = content else { return "" }
        if content.count > 150 {
            return String(content.prefix(150)) + "..."
        }
        return content
    }
    
    var hasImage: Bool {
        return imageURL != nil && !imageURL!.isEmpty
    }
}

// MARK: - API Response Models
struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [ArticleResponse]
}

struct ArticleResponse: Codable {
    let title: String
    let author: String?
    let publishedAt: String
    let content: String?
    let urlToImage: String?
    let url: String
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case author
        case publishedAt = "publishedAt"
        case content
        case urlToImage
        case url
        case description
    }
}

// MARK: - Equatable and Hashable
extension Article: Equatable, Hashable {
    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


// MARK: - Article Categories
enum ArticleCategory: String, CaseIterable {
    case technology = "technology"
    case science = "science"
    case sports = "sports"
    case health = "health"
    case business = "business"
    case entertainment = "entertainment"
    case general = "general"
    
    var displayName: String {
        return rawValue.capitalized
    }
    
    var emoji: String {
        switch self {
        case .technology: return "💻"
        case .science: return "🔬"
        case .sports: return "⚽"
        case .health: return "🏥"
        case .business: return "💼"
        case .entertainment: return "🎭"
        case .general: return "📰"
        }
    }
}

// MARK: - Article Validation
extension Article {
    var isValid: Bool {
        return !id.isEmpty &&
               !title.isEmpty &&
               !url.isEmpty &&
               URL(string: url) != nil
    }
    
    func validate() throws {
        guard !id.isEmpty else {
            throw ArticleValidationError.missingID
        }
        
        guard !title.isEmpty else {
            throw ArticleValidationError.missingTitle
        }
        
        guard !url.isEmpty else {
            throw ArticleValidationError.missingURL
        }
        
        guard URL(string: url) != nil else {
            throw ArticleValidationError.invalidURL
        }
    }
}

// MARK: - Article Validation Errors
enum ArticleValidationError: LocalizedError {
    case missingID
    case missingTitle
    case missingURL
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .missingID:
            return "Article ID is required"
        case .missingTitle:
            return "Article title is required"
        case .missingURL:
            return "Article URL is required"
        case .invalidURL:
            return "Article URL is not valid"
        }
    }
}
