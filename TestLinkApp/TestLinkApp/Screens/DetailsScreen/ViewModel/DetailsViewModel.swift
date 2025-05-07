//
//  DetailsViewModel.swift
//  TestLinkApp
//
//  Created by Александр Коротков on 30.04.2025.
//

import Foundation
import SwiftUI
import Combine


final class DetailsViewModel: ObservableObject {
    
    //MARK: Properties
    
    @Published var cachedImageURLs: [URL: URL]
    
    //MARK: Private Properties
    
    private let networkManager: INetworkManager
    private let cacheManager: ICacheManager
    
    //MARK: Init
    
    init(cachedImageURLs: [URL : URL],
         networkManager: INetworkManager = NetworkManager.shared,
         cacheManager: ICacheManager = CacheManager.shared) {
        self.cachedImageURLs = cachedImageURLs
        self.networkManager = networkManager
        self.cacheManager = cacheManager
    }
    
    //MARK: Functions
    
    @MainActor
    func uploadCacheImage(url: URL) async {
        var updateModel = cachedImageURLs
        updateModel[url] = cachedImageURLs[url]
        cachedImageURLs = updateModel
    }
}

private extension DetailsViewModel {
    
    private func cacheImage(url: URL) async {
          let fullURL = await cacheManager.urlImage(forKey: url.absoluteString, type: .full)
          if FileManager.default.fileExists(atPath: fullURL.path) {
              let cacheURl = fullURL
              await uploadCacheImage(url: cacheURl)
              return
          }
          do {
              let (data, _) = try await URLSession.shared.data(from: url)
              await cacheManager.saveImage(data, forKey: url.absoluteString, type: .full)
              let cacheURl = await cacheManager.urlImage(forKey: url.absoluteString, type: .full)
              await uploadCacheImage(url: cacheURl)
              
          } catch {
              print("Image load error: \(error)")
          }
      }
}
