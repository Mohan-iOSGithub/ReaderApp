//
//  NewsViewModel.swift
//  ReaderApp
//
//  Created by Mohanaprabhu on 12/09/25.
//

import Foundation

protocol NewsViewModelDelegate: AnyObject {
    func newsViewModel(_ viewModel: NewsViewModel, didUpdateArticles articles: [Article])
    func newsViewModel(_ viewModel: NewsViewModel, didFailWithError error: Error)
    func newsViewModelDidStartLoading(_ viewModel: NewsViewModel)
    func newsViewModelDidFinishLoading(_ viewModel: NewsViewModel)
    func newsViewModel(_ viewModel: NewsViewModel, didUpdateOfflineStatus isOffline: Bool)
}

class NewsViewModel {
    weak var delegate: NewsViewModelDelegate?
    
    private let networkService = NetworkService()
    private let cacheService = CacheService()
    private let localBookmark = LocalBookmarkService()
    
    var allArticles: [Article] = []
    var filteredArticles: [Article] = []
    
    var articles: [Article] {
        return filteredArticles.isEmpty ? allArticles : filteredArticles
    }
    
    var isOffline: Bool {
        return !NetworkReachability.shared.isConnected
    }
    
    init() {
        setupNetworkObserver()
    }
    
    func loadArticles() {
        delegate?.newsViewModelDidStartLoading(self)
        
        if isOffline {
            loadCachedArticles()
        } else {
            fetchArticlesFromAPI()
        }
    }
    
    func refreshArticles() {
        guard !isOffline else {
            loadCachedArticles()
            return
        }
        
        fetchArticlesFromAPI()
    }
    
    func searchArticles(with query: String) {
        if query.isEmpty {
            filteredArticles = []
        } else {
            filteredArticles = allArticles.filter { article in
                article.title.lowercased().contains(query.lowercased()) ||
                article.author?.lowercased().contains(query.lowercased()) == true
            }
        }
        delegate?.newsViewModel(self, didUpdateArticles: articles)
    }
    
    func toggleBookmark(for article: Article) {
        if let index = allArticles.firstIndex(where: { $0.id == article.id }) {
            allArticles[index].isBookmarked?.toggle()
            NotificationCenter.default.post(name: .updateBookmarkOnBookmark, object: nil, userInfo: ["article": allArticles[index] as Any])
            localBookmark.addBookmark(article)
            cacheService.updateBookmarkStatus(articleId: article.id, isBookmarked: allArticles[index].isBookmarked ?? Bool())
            delegate?.newsViewModel(self, didUpdateArticles: articles)
        }
    }
    
    private func fetchArticlesFromAPI() {
        networkService.fetchArticles { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.delegate?.newsViewModelDidFinishLoading(self)
                
                switch result {
                case .success(let articles):
                    self.allArticles = articles
                    let uniqueArticles = Array(Set(self.allArticles))
                    self.allArticles = uniqueArticles
                    self.cacheService.cacheArticles(articles)
                    self.delegate?.newsViewModel(self, didUpdateArticles: self.articles)
                case .failure(let error):
                    self.loadCachedArticles()
                    self.delegate?.newsViewModel(self, didFailWithError: error)
                }
            }
        }
    }
    
    private func loadCachedArticles() {
        let cachedArticles = cacheService.getCachedArticles()
        self.allArticles = cachedArticles
        
        let uniqueArticles = Array(Set(self.allArticles))
        self.allArticles = uniqueArticles
        
        delegate?.newsViewModelDidFinishLoading(self)
        delegate?.newsViewModel(self, didUpdateArticles: articles)
    }
    
    private func setupNetworkObserver() {
        NetworkReachability.shared.onReachabilityChanged = { [weak self] isConnected in
            guard let self = self else { return }
            isConnected ? self.delegate?.newsViewModel(self, didUpdateOfflineStatus: false) : self.delegate?.newsViewModel(self, didUpdateOfflineStatus: true)
        }
    }
    
    // MARK: - Update Bookmark
    func updateBookmark(at index: Int, isBookmarked: Bool) {
        if filteredArticles.isEmpty {
            allArticles[index].isBookmarked = isBookmarked
        } else {
            filteredArticles[index].isBookmarked = isBookmarked

            if let id = filteredArticles[index].id as String?,
               let originalIndex = allArticles.firstIndex(where: { $0.id == id }) {
                allArticles[originalIndex].isBookmarked = isBookmarked
            }
        }
        
        delegate?.newsViewModel(self, didUpdateArticles: articles)
    }
}
