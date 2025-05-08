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
    
    @Published var galleryState: GalleryContentState = .loading
    var items: [ImageModel] = []

    let titleAlert: String = "Not internet connection"
    let titleReloadButtonAlert: String = "Reload"
    let titleCancelButtonAlert: String = "Cancel"
    let errorMessageLoadImage: String = "Error load image"
    let errorMessageDontHaveImage: String = "Dont have image"
    let titleColor: Color = .white
    let title: String = "Gallery"
    
    //MARK: Private Properties
    
    private let networkManager: INetworkManager
    private let connectManager : INetworkConnection
    private let cacheManager: ICacheManager
    private var cancellables = Set<AnyCancellable>()
    
    init(cacheManager: ICacheManager = CacheManager.shared,
         networkManager: INetworkManager = NetworkManager.shared,
         connectManager: INetworkConnection = NetworkConnectionManager.shared) {
        self.cacheManager = cacheManager
        self.networkManager = networkManager
        self.connectManager = connectManager
        setupNetworkObserver()
    }
    
    //MARK: Functions
    
    func fetchImageURLs() async {
        let cacheUrl = cacheManager.loadCachedURLs()
        if cacheUrl.isEmpty {
            do {
                await loadImages()
            }
        } else {
            await updateState(state: .content)
            items = cacheUrl.map { ImageModel(imageURL: $0) }
        }
    }

    @MainActor
    func updateState (state: GalleryContentState) {
        self.galleryState = state
    }
    
    @MainActor
    func uploadImage( _ url: String) async {
        guard let url = URL(string: url),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let uiImage = UIImage(data: data) else {
            //Обработка ошибки
           print( URLError(.badServerResponse))
            return
        }
    }
}

private extension GalleryViewModel {
    
    //MARK: Private Functions
    
    private func loadImages() async {
        guard connectManager.isConnected else {
            await updateState(state: .alert)
            return
        }

        await updateState(state: .loading)
        
        do {
            let result = try await networkManager.fetchImageLinks()
            items = result.map { ImageModel(imageURL: $0) }
            cacheManager.saveCachedURLs(result)
            await updateState(state: .content)
        } catch {
            await updateState(state: .alert)
        }
    }
    
    
    private func setupNetworkObserver() {
        connectManager.connectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                if isConnected {
                    Task { await self.fetchImageURLs() }
                } else {
                    Task { await self.updateState(state: .alert) }
                }
            }
            .store(in: &cancellables)
    }
}
