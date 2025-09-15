//
//  ArticleTableViewCell.swift
//  ReaderApp
//
//  Created by Mohanaprabhu on 12/09/25.
//

import UIKit

protocol ArticleTableViewCellDelegate: AnyObject {
    func articleTableViewCell(_ cell: ArticleTableViewCell, didTapBookmarkFor article: Article)
}

class ArticleTableViewCell: UITableViewCell {
    
    static let identifier = "ArticleTableViewCell"
    
    weak var delegate: ArticleTableViewCellDelegate?
    private var article: Article?
    
   private var isOffline: Bool {
        return !NetworkReachability.shared.isConnected
    }
    
    // MARK: - UI Components
    private let articleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let metaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let excerptLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        
        contentView.addSubviews(with: [articleImageView, titleLabel, metaLabel, excerptLabel, bookmarkButton])
                
        articleImageView.top == contentView.top + .ratioHeightBasedOniPhoneX(15)
        articleImageView.leading == contentView.leading + .ratioWidthBasedOniPhoneX(15)
        articleImageView.height == .ratioWidthBasedOniPhoneX(80)
        articleImageView.width == .ratioWidthBasedOniPhoneX(80)
        
        bookmarkButton.trailing == contentView.trailing + .ratioWidthBasedOniPhoneX(-15)
        bookmarkButton.top == contentView.top + .ratioHeightBasedOniPhoneX(10)
        bookmarkButton.height == .ratioWidthBasedOniPhoneX(45)
        bookmarkButton.width == .ratioWidthBasedOniPhoneX(45)
        
        titleLabel.top == contentView.top + .ratioHeightBasedOniPhoneX(15)
        titleLabel.leading == articleImageView.trailing + .ratioWidthBasedOniPhoneX(15)
        titleLabel.trailing == bookmarkButton.leading + .ratioWidthBasedOniPhoneX(-8)
        
        metaLabel.top == titleLabel.bottom + .ratioHeightBasedOniPhoneX(5)
        metaLabel.leading == titleLabel.leading
        metaLabel.trailing == titleLabel.trailing
        
        excerptLabel.top == metaLabel.bottom + .ratioHeightBasedOniPhoneX(5)
        excerptLabel.leading == titleLabel.leading
        excerptLabel.trailing == titleLabel.trailing
        
        NSLayoutConstraint.activate([
            excerptLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -15)
        ])
    }
    
    // MARK: - Configuration
    func configure(with article: Article, isBookmarked: Bool) {
        self.article = article
        
        titleLabel.text = article.title
        excerptLabel.text = article.content
        bookmarkButton.isSelected = (isOffline ? isBookmarked : article.isBookmarked) ?? Bool()
        
        // Format meta information
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        
        var metaText = ""
        if let author = article.author {
            metaText += author + " • "
        }
        
        if article.isCached {
            metaText += "Cached " + formatter.string(from: article.publishedAt)
        } else {
            metaText += formatter.string(from: article.publishedAt)
        }
        
        metaLabel.text = metaText
        articleImageView.image = nil
        
        // Load image if available
        if let imageURL = article.imageURL {
            loadImage(from: imageURL)
        } else {
            articleImageView.backgroundColor = .systemGray5
        }
    }
    
    func updateBookmarkButton(with enable: Bool) {
        bookmarkButton.isEnabled = enable
        bookmarkButton.alpha = enable ? 1.0 : 0.5
    }
    
    @objc private func bookmarkButtonTapped() {
        guard let article = article else { return }
        delegate?.articleTableViewCell(self, didTapBookmarkFor: article)
    }
    
    private func loadImage(from urlString: String) {
        // Simple image loading - in production, use SDWebImage or similar
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.articleImageView.image = nil
                self?.articleImageView.image = image
            }
        }.resume()
    }
}
