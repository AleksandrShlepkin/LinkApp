//
//  GallaryViewModel.swift
//  LinkApp
//
//  Created by Александр Коротков on 29.04.2025.
//

import SwiftUI
import Combine


final class GalleryViewModel: ObservableObject {
    
    //MARK: Properties
    
    @Published var gallaryState: GalleryContentState = .loading
    @Published var cachedImageURLs: [URL: URL] = [:]
    
    
    let titleAlert: String = "Not internet connection"
    let titleReloadButtonAlert: String = "Reload"
    let titleCancelButtonAlert: String = "Cancel"
    let errorMessageLoadImage: String = "Error load image"
    let errorMessageDontHaveImage: String = "Dont have image"
    let titileColor: Color = .white
    let title: String = "Gallary"
    
    //MARK: Private Properties
    
    private let networkManager: INetworkManager
    private let connectManager : INetworkConnection
    private let cacheManager: ICacheManager
    
    init(cacheManager: ICacheManager = CacheManager.shared,
         networkManager: INetworkManager = NetworkManager.shared,
         connectManager: INetworkConnection = NetworkConnectionManager.shared) {
        self.cacheManager = cacheManager
        self.networkManager = networkManager
        self.connectManager = connectManager
    }
    
    //MARK: Functions
    
    func loadImages() async {
        guard connectManager.isConnected else {
            await updateState(state: .alert)
            return
        }

        await updateState(state: .loading)

        do {
            let imageURLs = try await networkManager.fetchImageLinks()
            await updateState(state: .content(imageURLs))
        } catch {
            await updateState(state: .error(error))
        }
    }
    
    func cahceImage(url: URL) async {

        guard cachedImageURLs[url] == nil else {
            await loadImages()
            return
        }
        
        let previewURL = await cacheManager.urlImage(forKey: url.absoluteString, type: .preview)
        if FileManager.default.fileExists(atPath: previewURL.path) {
            await uploadCacheImage(key: url, value: previewURL)
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            await cacheManager.saveImage(data, forKey: url.absoluteString, type: .full)
            if let image = UIImage(data: data),
               let resized = image.resized(to: 300),
               let compressed = resized.jpegData(compressionQuality: 0.7) {
                
                await cacheManager.saveImage(compressed, forKey: url.absoluteString, type: .preview)
                
                let cacheUrl = await cacheManager.urlImage(forKey: url.absoluteString, type: .preview)
                await uploadCacheImage(key: url, value: cacheUrl)
                
            } else {
                print("Failed to resize or compress image")
            }
        } catch {
            print("Image load error: \(error)")
        }
    }
    
    @MainActor
    func updateState (state: GalleryContentState) {
        self.gallaryState = state
        print("State: \(connectManager.isConnected  ? "Connected" : "Not Connected")")
    }
    
    @MainActor
    func uploadCacheImage(key: URL, value: URL) async {
        cachedImageURLs[key] = value
    
    }
}

