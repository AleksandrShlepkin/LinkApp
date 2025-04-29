//
//  GallaryViewModel.swift
//  LinkApp
//
//  Created by Александр Коротков on 29.04.2025.
//

import SwiftUI
import Combine

@MainActor
final class GalleryViewModel: ObservableObject {
    @Published var imageURLs: [URL] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isShowNetworkErrorAlert = false
    @Published var cachedImageURLs: [URL: URL] = [:]
    
    private let fileDownloader = NetworkManager()
    private let isConnectivityAvailable = NetworkConnectionManager.shared
    private var cancellables = Set<AnyCancellable>()
    

    func loadImages() async {
        guard isConnectivityAvailable.isConnected else {
            isShowNetworkErrorAlert = true
            return
        }
        isLoading = true
        error = nil
        
        do {
            imageURLs = try await fileDownloader.fetchImageLinks()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }

    func loadImage(url: URL) async {
        guard cachedImageURLs[url] == nil else { return }
        
        let previewURL = CacheManager.shared.url(forKey: url.absoluteString, type: .preview)
        guard let previewURL = previewURL else { return }
        if FileManager.default.fileExists(atPath: previewURL.path) {
            cachedImageURLs[url] = previewURL
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            CacheManager.shared.save(data, forKey: url.absoluteString, type: .full)
            if let image = UIImage(data: data),
               let resized = image.resized(to: 300),
               let compressed = resized.jpegData(compressionQuality: 0.7) {
                
                CacheManager.shared.save(compressed, forKey: url.absoluteString, type: .preview)
                cachedImageURLs[url] = CacheManager.shared.url(forKey: url.absoluteString, type: .preview)
            } else {
                print("Failed to resize or compress image")
            }
        } catch {
            print("Image load error: \(error)")
        }
    }


}
