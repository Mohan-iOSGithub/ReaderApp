//
//  NewsViewController.swift
//  ReaderApp
//
//  Created by Mohanaprabhu on 12/09/25.
//

import UIKit

class NewsViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search articles..."
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshControlTriggered), for: .valueChanged)
        return control
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.refreshControl = refreshControl
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
        tableView.showsVerticalScrollIndicator = false
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.identifier)
        return tableView
    }()
    
    private lazy var offlineIndicator: OfflineIndicatorView = {
        let view = OfflineIndicatorView()
        return view
    }()
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        return view
    }()
    
    // MARK: - Properties
    private let viewModel = NewsViewModel()
    private let cacheService = CacheService()
    private let bookMarkModel = LocalBookmarkService()
    private var offlineIndicatorHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        registerNotificationObserver()
        viewModel.loadArticles()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Reader"
        
        // Setup navigation
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        view.addSubviews(with: [offlineIndicator, tableView, emptyStateView])

        setupConstraints()
    }
    
    private func registerNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(getArticalTitle(notification:)), name: .articalTitle, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateBookmark(notification:)), name: .updateBookmarkOnNews, object: nil)
    }
    
    @objc func getArticalTitle(notification: Notification) {
        if let userInfo = notification.userInfo,
           let updatedArticle = userInfo["article"] as? Article {
            
            if let index = viewModel.articles.firstIndex(where: { $0.title == updatedArticle.title }), let isBookmarked = updatedArticle.isBookmarked {
                cacheService.updateBookmarkStatus(articleId: updatedArticle.id, isBookmarked: false)
                viewModel.updateBookmark(at: index, isBookmarked: false)
            }
        }
    }
    
    @objc private func didUpdateBookmark(notification: Notification) {
        if let userInfo = notification.userInfo,
           let updatedArticle = userInfo["article"] as? Article {
            print("Updated Article:", updatedArticle.title)
            
            viewModel.toggleBookmark(for: updatedArticle)
            
            if viewModel.isOffline, let isBookmarked = updatedArticle.isBookmarked {
                cacheService.updateBookmarkStatus(articleId: updatedArticle.id, isBookmarked: isBookmarked)
            }
        }
    }
    
    private func setupConstraints() {
        offlineIndicatorHeightConstraint = offlineIndicator.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            offlineIndicatorHeightConstraint,
        ])
        
        offlineIndicator.top == view.safeAreaLayoutGuide.topAnchor
        offlineIndicator.leading == view.leading
        offlineIndicator.trailing == view.trailing
        
        tableView.top == offlineIndicator.bottom
        tableView.exceptTop == view.exceptTop
        
        emptyStateView.edges == tableView.edges
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    // MARK: - Actions
    @objc private func refreshControlTriggered() {
        viewModel.refreshArticles()
    }
    
    private func updateEmptyState() {
        let shouldShowEmptyState = viewModel.articles.isEmpty
        emptyStateView.isHidden = !shouldShowEmptyState
        if shouldShowEmptyState {
            emptyStateView.iconImageView.image = UIImage(named: "article")
        }
        tableView.isHidden = shouldShowEmptyState
    }
    
    private func showOfflineIndicator(_ show: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.offlineIndicator.isHidden = !show
            self.offlineIndicatorHeightConstraint.constant = show ? 44 : 0
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - NewsViewModelDelegate
extension NewsViewController: NewsViewModelDelegate {
    func newsViewModel(_ viewModel: NewsViewModel, didUpdateArticles articles: [Article]) {
        tableView.reloadData()
        updateEmptyState()
    }
    
    func newsViewModel(_ viewModel: NewsViewModel, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func newsViewModelDidStartLoading(_ viewModel: NewsViewModel) {
        // Loading state is handled by refresh control
    }
    
    func newsViewModelDidFinishLoading(_ viewModel: NewsViewModel) {
        refreshControl.endRefreshing()
    }
    
    func newsViewModel(_ viewModel: NewsViewModel, didUpdateOfflineStatus isOffline: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showOfflineIndicator(isOffline)
        }
    }
}

// MARK: - UITableViewDataSource
extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.identifier, for: indexPath) as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        let cachedArtical = cacheService.getCachedArticles()
        let article = viewModel.articles[indexPath.row]
        
        if let count = searchController.searchBar.text?.count, count <= 0 {
            cell.updateBookmarkButton(with: true)
        } else {
            cell.updateBookmarkButton(with: false)
        }
        
        cell.configure(with: article, isBookmarked: cachedArtical[safe: indexPath.row]?.isBookmarked ?? Bool())
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = viewModel.articles[indexPath.row]
        // Navigate to article detail
        let detailVC = ArticleDetailViewController(article: article)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let article = viewModel.articles[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let bookmarkTitle = article.isBookmarked ?? Bool() ? "Remove Bookmark" : "Add Bookmark"
            let bookmarkAction = UIAction(title: bookmarkTitle, image: UIImage(systemName: "bookmark")) { _ in
                self.viewModel.toggleBookmark(for: article)
            }
            
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                // Implement sharing
                let activityVC = UIActivityViewController(activityItems: [article.url], applicationActivities: nil)
                self.present(activityVC, animated: true)
            }
            
            return UIMenu(title: "", children: [bookmarkAction, shareAction])
        }
    }
}

// MARK: - UISearchResultsUpdating
extension NewsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        viewModel.searchArticles(with: searchText)
    }
}

// MARK: - ArticleTableViewCellDelegate
extension NewsViewController: ArticleTableViewCellDelegate {
    func articleTableViewCell(_ cell: ArticleTableViewCell, didTapBookmarkFor article: Article) {
        viewModel.toggleBookmark(for: article)
    }
}

public extension Notification.Name {
    static let articalTitle = Notification.Name("articalTitle")
    static let updateBookmarkOnNews = Notification.Name("updateBookOnNews")
    static let updateBookmarkOnBookmark = Notification.Name("updateBookmarkOnBookmark")
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
