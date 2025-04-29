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
    static let minimusSizwGridItem: CGFloat = UIScreen.main.bounds.width / 1
    static let maximusSizwGridItem: CGFloat = UIScreen.main.bounds.width / 2
    static let spacingBeetwenSections: CGFloat = 60
    static let spacingGritItem: CGFloat = 20
    static let widthCell: CGFloat = UIScreen.main.bounds.width / 1.25
    static let heightCell: CGFloat = UIScreen.main.bounds.height / 3
    static let cornerRadiusCell: CGFloat = 10
    static let titleAlert: String = "Not internet connection"
    static let titleReloadButtonAlert: String = "Reload"
    static let titleCancelButtonAlert: String = "Cancel"
    static let errorMessageLoadImage: String = "Error load image"
    static let errorMessageDontHaveImage: String = "Dont have image"
}

struct GallaryView: View {
    
    //MARK: Properties
    
    @StateObject private var viewModel = GalleryViewModel()
    
    struct CellView: View {
        let url: URL
        
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
                ScrollView {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        if !viewModel.imageURLs.isEmpty {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: Constants.minimusSizwGridItem,
                                                                   maximum: Constants.maximusSizwGridItem),
                                                         spacing: Constants.spacingBeetwenSections)],
                                      spacing: Constants.spacingGritItem)
                            {
                                ForEach(viewModel.imageURLs, id: \.self) { url in
                                    NavigationLink(destination: DetailsView(urls: viewModel.imageURLs, selectedURL: url)) {
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
            .alert(Constants.titleAlert,
                   isPresented: $viewModel.isShowNetworkErrorAlert) {
                Button(Constants.titleReloadButtonAlert) {
                    Task {
                        await viewModel.loadImages()
                    }
                }
                Button(Constants.titleCancelButtonAlert, role: .cancel) {}
            }
        }
        .toolbar(.hidden)
        
    }
}

#Preview {
    GallaryView()
}


