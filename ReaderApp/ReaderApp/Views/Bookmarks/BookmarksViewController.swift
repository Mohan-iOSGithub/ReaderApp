//
//  BookmarksViewController.swift
//  ReaderApp
//
//  Created by Mohanaprabhu on 12/09/25.
//

import UIKit

class BookmarksViewController: UIViewController {
    
    private lazy var bookMarkTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.identifier)
        return tableView
    }()
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        return view
    }()
    
    private let bookmarkService = LocalBookmarkService()
    private var bookmarkedArticles: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bookmarkService.delegate = self
        registerNotificationObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadBookmarks()
    }
    
    private func setupUI() {
        title = "Bookmarks"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubviews(with: [bookMarkTableView, emptyStateView])
        
        bookMarkTableView.top == view.safeAreaLayoutGuide.topAnchor
        bookMarkTableView.exceptTop == view.exceptTop
        
        emptyStateView.edges == bookMarkTableView.edges
    }
    
    private func loadBookmarks() {
        bookmarkedArticles = bookmarkService.getBookmarkedArticles()
        updateUI()
    }
    
    private func updateUI() {
        bookMarkTableView.isHidden = bookmarkedArticles.count > 0 ? false : true
        emptyStateView.isHidden = bookmarkedArticles.count < 1 ? false : true
        
        if bookmarkedArticles.count < 1 {
            emptyStateView.iconImageView.image = UIImage(named: "bookmark")
        }
        
        if bookmarkedArticles.count > 0 {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.bookMarkTableView.reloadData()
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.emptyStateView.titleLabel.text = "No bookmarks yet."
                self.emptyStateView.subtitleLabel.text = "Start bookmarking your favorite articles!"
            }
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = bookmarkedArticles.count > 0
    }
    
    private func registerNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleBookmarkUpdate(notification:)), name: .updateBookmarkOnBookmark, object: nil)
    }
    
    @objc private func handleBookmarkUpdate(notification: Notification) {
        if let userInfo = notification.userInfo,
           let updatedArticle = userInfo["article"] as? Article {
            print("Updated Article:", updatedArticle.title)
            if let isBookmarked = updatedArticle.isBookmarked, isBookmarked {
                bookmarkService.addBookmark(updatedArticle)
            } else {
                bookmarkService.removeBookmark(articleId: updatedArticle.id)
            }
        }
    }
}

// MARK: - BookmarksViewController Extensions
extension BookmarksViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarkedArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = bookMarkTableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.identifier, for: indexPath) as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        
        let article = bookmarkedArticles[indexPath.row]
        cell.configure(with: article, isBookmarked: true)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = bookmarkedArticles[indexPath.row]
        
        // Navigate to article detail
        let detailVC = ArticleDetailViewController(article: article)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let article = bookmarkedArticles[indexPath.row]
            bookmarkService.removeBookmark(articleId: article.id)
        }
    }
}

extension BookmarksViewController: ArticleTableViewCellDelegate {
    func articleTableViewCell(_ cell: ArticleTableViewCell, didTapBookmarkFor article: Article) {
        bookmarkService.toggleBookmark(for: article)
    }
}

extension BookmarksViewController: BookmarkServiceDelegate {
    func bookmarkService(_ service: LocalBookmarkService, didUpdateBookmarks bookmarks: [Article]) {
        self.bookmarkedArticles = bookmarks
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
    
    func bookmarkService(_ service: LocalBookmarkService, didFailWithError error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
