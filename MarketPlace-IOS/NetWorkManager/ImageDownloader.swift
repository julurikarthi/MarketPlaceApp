//
//  ImageDownloader.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/28/25.
//
import Foundation
import SwiftUI
class ImageDownloader {
    static let shared = ImageDownloader()
    private init() {}
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    func getCachedImage(for url: String) -> UIImage? {
        return imageCache.object(forKey: url as NSString)
    }
    
    func cacheImage(_ image: UIImage, for url: String) {
        imageCache.setObject(image, forKey: url as NSString)
    }
}
