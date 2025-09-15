//
//  LocalBookmarkViewModel.swift
//  ReaderApp
//
//  Created by Mohanaprabhu on 12/09/25.
//

import Foundation
import CoreData

protocol BookmarkServiceDelegate: AnyObject {
    func bookmarkService(_ service: LocalBookmarkService, didUpdateBookmarks bookmarks: [Article])
    func bookmarkService(_ service: LocalBookmarkService, didFailWithError error: Error)
}

class LocalBookmarkService {
    private let context = CoreDataStack.shared.context
    private let userDefaults = UserDefaults.standard
    
    weak var delegate: BookmarkServiceDelegate?
    
    // MARK: - Bookmark Operations
    func toggleBookmark(for article: Article) {
        if isBookmarked(articleId: article.id) {
            removeBookmark(articleId: article.id)
        } else {
            addBookmark(article)
        }

        // Notify delegate
        delegate?.bookmarkService(self, didUpdateBookmarks: getBookmarkedArticles())
    }
    
    func addBookmark(_ article: Article) {
        if isBookmarked(articleId: article.id) { return }
        
        let bookmark = BookmarkedArticle(context: context)
        bookmark.id = article.id
        bookmark.title = article.title
        bookmark.author = article.author
        bookmark.content = article.content
        bookmark.url = article.url
        bookmark.imageURL = article.imageURL
        bookmark.publishedAt = article.publishedAt
        bookmark.bookmarkedAt = Date()
        
        do {
            try context.save()
            print("Bookmark saved: \(article.title)")
        } catch {
            print("Error saving bookmark: \(error)")
        }
    }
    
    func removeBookmark(articleId: String) {
        let fetchRequest: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", articleId)
        
        do {
            let bookmarks = try context.fetch(fetchRequest)
            for bookmark in bookmarks {
                context.delete(bookmark)
            }
            try context.save()
            print("Bookmark removed for article: \(articleId)")
        } catch {
            print("Error removing bookmark: \(error)")
        }
    }
    
    func isBookmarked(articleId: String) -> Bool {
        let fetchRequest: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", articleId)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking bookmark status: \(error)")
            return false
        }
    }
    
    func getBookmarkedArticles() -> [Article] {
        let fetchRequest: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "bookmarkedAt", ascending: false)]
        
        do {
            let bookmarkedArticles = try context.fetch(fetchRequest)
            return bookmarkedArticles.compactMap { convertToArticle($0) }
        } catch {
            print("Error fetching bookmarked articles: \(error)")
            return []
        }
    }
    
    func getBookmarkCount() -> Int {
        let fetchRequest: NSFetchRequest<BookmarkedArticle> = BookmarkedArticle.fetchRequest()
        
        do {
            return try context.count(for: fetchRequest)
        } catch {
            print("Error counting bookmarks: \(error)")
            return 0
        }
    }
    
    func clearAllBookmarks() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = BookmarkedArticle.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            delegate?.bookmarkService(self, didUpdateBookmarks: [])
        } catch {
            print("Error clearing bookmarks: \(error)")
        }
    }
    
    private func convertToArticle(_ bookmarkedArticle: BookmarkedArticle) -> Article? {
        guard let id = bookmarkedArticle.id,
              let title = bookmarkedArticle.title,
              let url = bookmarkedArticle.url,
              let publishedAt = bookmarkedArticle.publishedAt else {
            return nil
        }
        
        return Article(
            id: id,
            title: title,
            author: bookmarkedArticle.author,
            publishedAt: publishedAt,
            content: bookmarkedArticle.content,
            imageURL: bookmarkedArticle.imageURL,
            url: url,
            isBookmarked: true,
            isCached: true
        )
    }
}
