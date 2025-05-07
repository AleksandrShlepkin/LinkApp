//
//  GallaryView.swift
//  LinkApp
//
//  Created by Александр Коротков on 29.04.2025.
//

import SwiftUI

private enum Constants {
    static let minimusSizwGridItem: CGFloat = UIScreen.main.bounds.width / 3.5
    static let maximusSizwGridItem: CGFloat = UIScreen.main.bounds.width / 3.5
    static let widthOnboardingView: CGFloat = UIScreen.main.bounds.width
    static let heigthOnboardingView: CGFloat = UIScreen.main.bounds.height
    static let spacingBeetwenSections: CGFloat = 40
    static let spacingGritItem: CGFloat = 20
    static let widthCell: CGFloat = 120
    static let heightCell: CGFloat = 120
    static let cornerRadiusCell: CGFloat = 10
}

struct GalleryView: View {
    
    //MARK: UI Properties
    
    @StateObject private var viewModel = GalleryViewModel()
    @State var isPresentAlert: Bool = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.mainAppColorStart,.mainAppColorEnd],
                               startPoint: .top,
                               endPoint: .bottom)
                .ignoresSafeArea()
                
                switch viewModel.galleryState {
                case .loading:
                    OnboardingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .error(let error):
                    Text(viewModel.errorMessageDontHaveImage)
                case .content(let urls):
                    ContentView(viewModel: viewModel, urls: urls)
                case .alert:
                    OnboardingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .alert(viewModel.titleAlert, isPresented: $isPresentAlert) {
                            Button(viewModel.titleReloadButtonAlert) {
                                isPresentAlert = false
                                Task {
                                    await viewModel.loadImages()
                                }
                            }
                            Button(viewModel.titleCancelButtonAlert, role: .cancel) {}
                        }
                }
            }
            .task {
                if viewModel.cachedImageURLs.isEmpty {
                    await viewModel.loadImages()
                }
            }
        }
        .toolbar(.hidden)
    }
}


private extension GalleryView {
    
    struct ContentView: View {
        
        @StateObject var viewModel: GalleryViewModel
        
        let urls: [URL]
        var body: some View {
            ZStack {
                ScrollView {
                    Text(viewModel.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    if urls.isEmpty {
                        Text(viewModel.errorMessageLoadImage)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: Constants.minimusSizwGridItem,
                                                               maximum: Constants.maximusSizwGridItem),
                                                     spacing: Constants.spacingBeetwenSections)],
                                  spacing: Constants.spacingGritItem)
                        {
                            ForEach(urls, id: \.self) { url in
                                NavigationLink(destination: DetailsView(urls: urls,
                                                                        selectedURL: url,
                                                                        viewModel: DetailsViewModel(cachedImageURLs: viewModel.cachedImageURLs))) {
                                    CellView(url: url, viewModel: viewModel)
                                        .frame(width: Constants.widthCell, height: Constants.heightCell)
                                        .clipped()
                                        .cornerRadius(Constants.cornerRadiusCell)
                                }
                            }
                        }
                    }

                }

            }
        }
    }
    
    struct CellView: View {
        
        //MARK: Properties
        
        let url: URL
        
        //MARK: UI Properties
        
        @ObservedObject var viewModel: GalleryViewModel
        
        var body: some View {
            if let localURL = viewModel.cachedImageURLs[url] {
                AsyncImage(url: localURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "photo")
                    default:
                        EmptyView()
                    }
                }
            } else {
                ProgressView()
                    .task {
                        await viewModel.cacheImage(url: url)
                    }
            }
        }
    }
}
