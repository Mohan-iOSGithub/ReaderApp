//
//  CacheService.swift
//  ReaderApp
//
//  Created by Moahanaprabhu on 12/09/25.
//

import Foundation
import CoreData

// MARK: - Cache Service Protocol
protocol CacheServiceProtocol {
    func cacheArticles(_ articles: [Article])
    func getCachedArticles() -> [Article]
    func updateBookmarkStatus(articleId: String, isBookmarked: Bool)
    func getBookmarkedArticles() -> [Article]
    func clearCache()
    func getCacheSize() -> String
    func isArticleCached(articleId: String) -> Bool
    func removeArticle(articleId: String)
}

// MARK: - Cache Service Implementation
class CacheService: CacheServiceProtocol {
    private let context = CoreDataStack.shared.context
    private let imageCache = ImageCacheService()
    
    // MARK: - Article Caching
    func cacheArticles(_ articles: [Article]) {
        context.perform {
            for article in articles {
                // Use explicit entity name to avoid class-based issues
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CachedArticle")
                fetchRequest.predicate = NSPredicate(format: "id == %@", article.id as NSString)
                
                do {
                    let existingArticles = try self.context.fetch(fetchRequest)
                    
                    if let existingArticle = existingArticles.first {
                        self.updateCachedArticle(existingArticle, with: article)
                    } else {
                        self.createCachedArticle(from: article)
                    }
                } catch {
                    print("❌ Error fetching article with id \(article.id): \(error)")
                }
            }
            
            do {
                try self.context.save()
            } catch {
                print("❌ Error saving context after caching: \(error)")
            }
            
            self.cacheArticleImages(articles)
        }
    }
    
    func getCachedArticles() -> [Article] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CachedArticle")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "cachedAt", ascending: false)]
        
        do {
            let cachedArticles = try context.fetch(fetchRequest)
            return cachedArticles.compactMap { convertToArticle($0) }
        } catch {
            print("Error fetching cached articles: \(error)")
            return []
        }
    }
    
    func isArticleCached(articleId: String) -> Bool {        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CachedArticle")
        fetchRequest.predicate = NSPredicate(format: "id == %@", articleId)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking if article is cached: \(error)")
            return false
        }
    }
    
    // MARK: - Bookmark Management
    func updateBookmarkStatus(articleId: String, isBookmarked: Bool) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CachedArticle")
        fetchRequest.predicate = NSPredicate(format: "id == %@", articleId)
        
        do {
            let articles = try context.fetch(fetchRequest)
            if let article = articles.first {
                article.setValue(isBookmarked, forKey: "isBookmarked")
                if isBookmarked {
                    article.setValue(Date(), forKey: "bookmarkedAt")
                }
                CoreDataStack.shared.saveContext()
            }
        } catch {
            print("Error updating bookmark status: \(error)")
        }
    }
    
    func getBookmarkedArticles() -> [Article] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CachedArticle")
        fetchRequest.predicate = NSPredicate(format: "isBookmarked == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "bookmarkedAt", ascending: false)]
        
        do {
            let cachedArticles = try context.fetch(fetchRequest)
            return cachedArticles.compactMap { convertToArticle($0) }
        } catch {
            print("Error fetching bookmarked articles: \(error)")
            return []
        }
    }
    
    // MARK: - Cache Management
    func clearCache() {
        // Clear Core Data
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedArticle")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            CoreDataStack.shared.saveContext()
            
            imageCache.clearCache()
            
            print("Cache cleared successfully")
        } catch {
            print("Error clearing cache: \(error)")
        }
    }
    
    func removeArticle(articleId: String) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CachedArticle")
        fetchRequest.predicate = NSPredicate(format: "id == %@", articleId)
        
        do {
            let articles = try context.fetch(fetchRequest)
            for article in articles {
                // Remove associated image from cache
                if let imageURL = article.value(forKey: "imageURL") as? String {
                    imageCache.removeImage(for: imageURL)
                }
                context.delete(article)
            }
            CoreDataStack.shared.saveContext()
        } catch {
            print("Error removing article: \(error)")
        }
    }
    
    func getCacheSize() -> String {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CachedArticle")
        
        do {
            let count = try context.count(for: fetchRequest)
            let imageCacheSize = imageCache.getCacheSize()
            
            let estimatedTextSize = count * 2 * 1024 // ~2KB per article for text
            let totalSize = estimatedTextSize + imageCacheSize
            
            return ByteCountFormatter.string(fromByteCount: Int64(totalSize), countStyle: .file)
        } catch {
            print("Error calculating cache size: \(error)")
            return "Unknown"
        }
    }
    
    // MARK: - Cache Cleanup
    func cleanupOldCache(olderThan days: Int = 30) {
        //guard validateEntity() else { return }
        
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) else { return }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CachedArticle")
        fetchRequest.predicate = NSPredicate(format: "cachedAt < %@ AND isBookmarked == NO", cutoffDate as NSDate)
        
        do {
            let oldArticles = try context.fetch(fetchRequest)
            for article in oldArticles {
                // Remove associated images
                if let imageURL = article.value(forKey: "imageURL") as? String {
                    imageCache.removeImage(for: imageURL)
                }
                context.delete(article)
            }
            
            if !oldArticles.isEmpty {
                CoreDataStack.shared.saveContext()
                print("Cleaned up \(oldArticles.count) old articles from cache")
            }
        } catch {
            print("Error cleaning up old cache: \(error)")
        }
    }
    
    // MARK: - Private Methods
    private func createCachedArticle(from article: Article) {
        guard let entity = NSEntityDescription.entity(forEntityName: "CachedArticle", in: context) else {
            print("❌ Cannot create CachedArticle entity")
            return
        }
        
        let cachedArticle = NSManagedObject(entity: entity, insertInto: context)
        updateCachedArticle(cachedArticle, with: article)
        cachedArticle.setValue(true, forKey: "isCached")
        cachedArticle.setValue(Date(), forKey: "cachedAt")
    }
    
    private func updateCachedArticle(_ cachedArticle: NSManagedObject, with article: Article) {
        cachedArticle.setValue(article.id, forKey: "id")
        cachedArticle.setValue(article.title, forKey: "title")
        cachedArticle.setValue(article.author, forKey: "author")
        cachedArticle.setValue(article.publishedAt, forKey: "publishedAt")
        cachedArticle.setValue(article.content, forKey: "content")
        cachedArticle.setValue(article.imageURL, forKey: "imageURL")
        cachedArticle.setValue(article.url, forKey: "url")
        cachedArticle.setValue(article.isBookmarked, forKey: "isBookmarked")
        cachedArticle.setValue(article.isCached, forKey: "isCached")
    }
    
    private func convertToArticle(_ cachedArticle: NSManagedObject) -> Article? {
        guard let id = cachedArticle.value(forKey: "id") as? String,
              let title = cachedArticle.value(forKey: "title") as? String,
              let publishedAt = cachedArticle.value(forKey: "publishedAt") as? Date,
              let url = cachedArticle.value(forKey: "url") as? String else {
            return nil
        }
        
        return Article(
            id: id,
            title: title,
            author: cachedArticle.value(forKey: "author") as? String,
            publishedAt: publishedAt,
            content: cachedArticle.value(forKey: "content") as? String,
            imageURL: cachedArticle.value(forKey: "imageURL") as? String,
            url: url,
            isBookmarked: (cachedArticle.value(forKey: "isBookmarked") as? Bool) ?? false,
            isCached: true
        )
    }
    
    private func cacheArticleImages(_ articles: [Article]) {
        DispatchQueue.global(qos: .background).async {
            for article in articles {
                if let imageURLString = article.imageURL {
                    self.imageCache.cacheImage(from: imageURLString)
                }
            }
        }
    }
}
