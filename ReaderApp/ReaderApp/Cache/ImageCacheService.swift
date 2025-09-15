//
//  ImageCacheService.swift
//  ReaderApp
//
//  Created by Mohanaprabhu on 12/09/25.
//

import Foundation
import UIKit

class ImageCacheService {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    init() {
        let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cachesURL.appendingPathComponent("ImageCache", isDirectory: true)
        
        // Create cache directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    func cacheImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let filename = sha256(urlString)
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        
        // Check if image is already cached
        if fileManager.fileExists(atPath: fileURL.path) {
            return
        }
        
        // Download and cache image
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data,
                  error == nil,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return
            }
            
            try? data.write(to: fileURL)
        }.resume()
    }
    
    func getCachedImage(for urlString: String) -> UIImage? {
        let filename = sha256(urlString)
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    func removeImage(for urlString: String) {
        let filename = sha256(urlString)
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        try? fileManager.removeItem(at: fileURL)
    }
    
    func clearCache() {
        guard let fileURLs = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        for fileURL in fileURLs {
            try? fileManager.removeItem(at: fileURL)
        }
    }
    
    func getCacheSize() -> Int {
        guard let fileURLs = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize = 0
        for fileURL in fileURLs {
            if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
               let fileSize = resourceValues.fileSize {
                totalSize += fileSize
            }
        }
        
        return totalSize
    }
    
    private func sha256(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else { return string }
        return data.sha256
    }
}
