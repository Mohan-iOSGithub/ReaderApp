//
//  ArticleDetailViewController.swift
//  ReaderApp
//
//  Created by Mohanaprabhu on 12/09/25.
//

import UIKit

class ArticleDetailViewController: UIViewController {
    
    private var article: Article
    
    // MARK: - UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var articleImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.backgroundColor = .secondarySystemBackground
        iv.heightAnchor.constraint(equalToConstant: 200).isActive = true
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            articleImageView,
            titleLabel,
            authorLabel,
            dateLabel,
            contentLabel
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .fill
        return stack
    }()
    
    // MARK: - Init
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: UIColor.label // Text color
        ]
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold), // For large titles
            .foregroundColor: UIColor.black
        ]
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        title = "News from \(article.author ?? "")"
        
        setupUI()
        setupNavigationBar()
        configureData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        scrollView.top == view.safeAreaLayoutGuide.topAnchor
        scrollView.exceptTop == view.exceptTop
        
        contentView.edges == scrollView.edges
        
        stackView.top == contentView.top + .ratioHeightBasedOniPhoneX(15)
        stackView.leading == contentView.leading + .ratioWidthBasedOniPhoneX(15)
        stackView.trailing == contentView.trailing + .ratioWidthBasedOniPhoneX(-15)
        stackView.bottom == contentView.bottom + .ratioHeightBasedOniPhoneX(-15)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        let bookmarkImage = article.isBookmarked ?? Bool() ? "bookmark.fill" : "bookmark"
        let bookmarkButton = UIBarButtonItem(
            image: UIImage(systemName: bookmarkImage),
            style: .plain,
            target: self,
            action: #selector(toggleBookmark)
        )
        navigationItem.rightBarButtonItem = bookmarkButton
    }
    
    // MARK: - Data Binding
    private func configureData() {
        titleLabel.text = article.title
        authorLabel.text = article.author ?? "Unknown Author"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: article.publishedAt)
        
        let cleanedContent = article.content?.replacingOccurrences(
            of: "\\[\\+\\d+ chars\\]",
            with: "",
            options: .regularExpression
        )
        contentLabel.text = cleanedContent ?? "No content available."
        
        if let imageUrl = article.imageURL, let url = URL(string: imageUrl) {
            loadImage(from: url)
        }
    }
    
    private func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.articleImageView.image = image
                }
            }
        }
    }
    
    @objc private func toggleBookmark() {
        article.isBookmarked?.toggle()
        
        let newIcon = article.isBookmarked ?? Bool() ? "bookmark.fill" : "bookmark"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: newIcon)
        
        NotificationCenter.default.post(
            name: .updateBookmarkOnNews,
            object: nil,
            userInfo: ["article": article as Any]
        )
        
        NotificationCenter.default.post(
            name: .updateBookmarkOnBookmark,
            object: nil,
            userInfo: ["article": article as Any]
        )
    }
}
