//
//  NewsResponse.swift
//  ReaderApp
//
//  Created by Mohanaprabhu on 12/09/25.
//

import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [APIArticle]
}

struct APIArticle: Codable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

struct Source: Codable {
    let id: String?
    let name: String
}
