//
//  MainTabBarController.swift
//  ReaderApp
//
//  Created by Mohanaprabhu on 12/09/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let articlesVC = NewsViewController()
        articlesVC.title = "News"
        let articlesNav = UINavigationController(rootViewController: articlesVC)
        articlesNav.tabBarItem = UITabBarItem(title: "News", image: UIImage(systemName: "newspaper"), tag: 0)
        
        let bookmarksVC = BookmarksViewController()
        bookmarksVC.title = "Bookmarks"
        let bookmarksNav = UINavigationController(rootViewController: bookmarksVC)
        bookmarksNav.tabBarItem = UITabBarItem(title: "Bookmarks", image: UIImage(systemName: "bookmark"), tag: 1)
        
        viewControllers = [articlesNav, bookmarksNav]
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .secondarySystemBackground
    }
}
