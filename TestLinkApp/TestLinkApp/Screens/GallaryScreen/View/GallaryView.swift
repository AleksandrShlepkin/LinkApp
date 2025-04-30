//
//  GallaryView.swift
//  LinkApp
//
//  Created by Александр Коротков on 29.04.2025.
//

import SwiftUI

private enum Constants {
    static let startColor: Color = .mainAppColorStart
    static let endColor: Color = .mainAppColorEnd
    static let minimusSizwGridItem: CGFloat = UIScreen.main.bounds.width / 3.5
    static let maximusSizwGridItem: CGFloat = UIScreen.main.bounds.width / 3.5
    static let widthOnboardingView: CGFloat = UIScreen.main.bounds.width
    static let heigthOnboardingView: CGFloat = UIScreen.main.bounds.height
    static let spacingBeetwenSections: CGFloat = 40
    static let spacingGritItem: CGFloat = 20
    static let widthCell: CGFloat = 120
    static let heightCell: CGFloat = 120
    static let cornerRadiusCell: CGFloat = 10
    static let titleAlert: String = "Not internet connection"
    static let titleReloadButtonAlert: String = "Reload"
    static let titleCancelButtonAlert: String = "Cancel"
    static let errorMessageLoadImage: String = "Error load image"
    static let errorMessageDontHaveImage: String = "Dont have image"
    static let titileColor: Color = .white
    static let title: String = "Gallary"
}

struct GallaryView: View {
    
    //MARK: UI Properties
    
    @StateObject private var viewModel = GalleryViewModel()
    
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
                        await viewModel.loadImage(url: url)
                    }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(Constants.startColor),Color(Constants.endColor)],
                               startPoint: .top,
                               endPoint: .bottom)
                .ignoresSafeArea()
                
                if viewModel.isLoading {
                    OnboardingView()
                        .frame(width: Constants.widthOnboardingView,
                               height: Constants.heigthOnboardingView)
                }
                VStack {
                    ZStack {
                        ScrollView {
                            if !viewModel.isLoading  {
                                Text(Constants.title)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Constants.titileColor)
                                if !viewModel.imageURLs.isEmpty {
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: Constants.minimusSizwGridItem,
                                                                           maximum: Constants.maximusSizwGridItem),
                                                                 spacing: Constants.spacingBeetwenSections)],
                                              spacing: Constants.spacingGritItem)
                                    {
                                        ForEach(viewModel.imageURLs, id: \.self) { url in
                                            NavigationLink(destination: DetailsView(urls: viewModel.imageURLs,
                                                                                    selectedURL: url,
                                                                                    viewModel: DetailsViewModel(cachedImageURLs: viewModel.cachedImageURLs))) {
                                                CellView(url: url, viewModel: viewModel)
                                                    .frame(width: Constants.widthCell, height: Constants.heightCell)
                                                    .clipped()
                                                    .cornerRadius(Constants.cornerRadiusCell)
                                            }
                                        }
                                    }
                                } else if viewModel.error != nil {
                                    Text(Constants.errorMessageLoadImage)
                                } else {
                                    Text(Constants.errorMessageDontHaveImage)
                                }
                            }
                        }
                        .task {
                            if viewModel.cachedImageURLs.isEmpty {
                                await viewModel.loadImages()
                            }
                        }
                    }
                }
            }
        }
        .alert(Constants.titleAlert,
               isPresented: $viewModel.isShowNetworkErrorAlert) {
            Button(Constants.titleReloadButtonAlert) {
                Task {
                    await viewModel.loadImages()
                }
            }
            Button(Constants.titleCancelButtonAlert, role: .cancel) {}
        }
               .toolbar(.hidden)
    }
}
