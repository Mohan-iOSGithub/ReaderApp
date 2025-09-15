//
//  OfflineIndicatorView.swift
//  ReaderApp
//
//  Created by Mohanaprabhu on 13/09/25.
//

import Foundation
import UIKit

class OfflineIndicatorView: UIView {
    
    // MARK: - UI Components
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Offline Mode"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
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
        self.backgroundColor = .systemRed
        self.isHidden = true
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubviews(with: [label])
        
        label.centerX == centerX
        label.centerY == centerY
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: .ratioWidthBasedOniPhoneX(15)),
            label.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: .ratioHeightBasedOniPhoneX(-15))
        ])
    }
}
