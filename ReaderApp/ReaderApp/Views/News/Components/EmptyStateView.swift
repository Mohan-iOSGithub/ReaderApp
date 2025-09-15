//
//  EmptyStateView.swift
//  ReaderApp
//
//  Created by Mohanaprabhu on 12/09/25.
//

import Foundation
import UIKit

class EmptyStateView: UIView {

    // MARK: - UI Components

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = .ratioHeightBasedOniPhoneX(30)
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No Articles Found"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Pull down to refresh or check your internet connection"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView() {
        self.isHidden = true
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubviews(with: [stackView])
        stackView.addArrangedSubviews([iconImageView, titleLabel, subtitleLabel])
        
        iconImageView.width == .ratioHeightBasedOniPhoneX(60)
        iconImageView.height == .ratioHeightBasedOniPhoneX(60)
        
        stackView.centerX == centerX
        stackView.centerY == centerY

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -32)
        ])
    }
}
