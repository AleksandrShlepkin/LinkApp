//
//  AsyncImageView.swift
//  TestLinkApp
//
//  Created by Александр Коротков on 07.05.2025.
//

import SwiftUI

// MARK: - AsyncImageView

 struct AsyncImageView<Placeholder: View, LoaderView: View>: View {
    // MARK: - Properties

    let urlString: String
    let type: CacheImageType
    let placeholder: () -> Placeholder
    let loaderView: () -> LoaderView

    // MARK: - Properties State
    @State private var image: Image? = nil
    @State private var onFirstAppear: Bool = true
    @State private var isLoading = false
    @State private var isEmptyImage = false

    // MARK: - Private Properties
    private let cacheManager: ICacheManager = CacheManager.shared
    private let networkManager: INetworkManager = NetworkManager.shared

    // MARK: - Init
     init(
        urlString: String,
        type: CacheImageType,
        placeholder: @escaping () -> Placeholder,
        loaderView: @escaping () -> LoaderView
    ) {
        self.urlString = urlString
        self.type = type
        self.placeholder = placeholder
        self.loaderView = loaderView
    }

    // MARK: Computed Properties

    public var body: some View {
        VStack {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
            } else if isEmptyImage {
                placeholder()
                //Вот сюда можно положить функцию перезапуска загрузки
            } else {
                loaderView()
            }
        }
        .onAppear() {
            if onFirstAppear {
                Task { await loadImage() }
                onFirstAppear.toggle()
            }
        }
    }

    // MARK: - Private Functions

    private func loadImage() async {
        guard !isLoading else { return }

        isLoading = true

        if let cachedData = await cacheManager.getImage(forKey: urlString, type: .preview),
           let uiImage = UIImage(data: cachedData) {
            self.image = Image(uiImage: uiImage)
            isEmptyImage = false
            return
        }
        
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let uiImage = UIImage(data: data) else {
            isEmptyImage = true
            return
        }

        if type == .preview,
           let resized = uiImage.resized(to: 300),
           let compressed = resized.jpegData(compressionQuality: 0.7), let compressedImage = UIImage(data: compressed) {
            await cacheManager.saveImage(compressed, forKey: urlString, type: .preview)
            self.image = Image(uiImage: compressedImage)
        } else {
            await cacheManager.saveImage(data, forKey: urlString, type: type)
            self.image = Image(uiImage: uiImage)
        }
    }
}

