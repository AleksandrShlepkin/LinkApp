//
//  DetailsViewModel.swift
//  TestLinkApp
//
//  Created by Александр Коротков on 30.04.2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class DetailsViewModel: ObservableObject {
    
    //MARK: Properties
    
    @Published var cachedImageURLs: [URL: URL]
    
    //MARK: Private Properties
    
    private let fileDownloader = NetworkManager()
    
    //MARK: Init
    
    init(cachedImageURLs: [URL : URL]) {
        self.cachedImageURLs = cachedImageURLs
    }
    
    //MARK: Functions
    
    func loadImage(url: URL) async {
        let fullURL = CacheManager.shared.url(forKey: url.absoluteString, type: .full)
        guard let fullURL = fullURL else { return }
        if FileManager.default.fileExists(atPath: fullURL.path) {
            cachedImageURLs[url] = fullURL
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            CacheManager.shared.save(data, forKey: url.absoluteString, type: .full)
            cachedImageURLs[url] = CacheManager.shared.url(forKey: url.absoluteString, type: .full)
            
        } catch {
            print("Image load error: \(error)")
        }
    }
}
