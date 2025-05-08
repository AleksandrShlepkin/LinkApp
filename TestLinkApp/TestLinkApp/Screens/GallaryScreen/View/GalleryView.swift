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
                case .content:
                    ContentView(viewModel: viewModel)
                case .alert:
                    OnboardingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .task {
                if viewModel.items.isEmpty {
                    await viewModel.fetchImageURLs()
                }
            }
        }
        .toolbar(.hidden)
        .tint(Color.white)
    }
}

private extension GalleryView {
    
    struct ContentView: View {
        
        //MARK: UI Properties

        @StateObject var viewModel: GalleryViewModel
        
        var body: some View {
            ZStack {
                ScrollView {
                    Text(viewModel.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    LazyVGrid(
                        columns: [
                            GridItem(
                                .adaptive(
                                    minimum: Constants.minimusSizwGridItem,
                                    maximum: Constants.maximusSizwGridItem
                                ),
                                spacing: Constants.spacingBeetwenSections
                            )
                        ],
                        spacing: Constants.spacingGritItem
                    )
                    {
                        ForEach(viewModel.items) { item in
                            NavigationLink(
                                destination: DetailsView(items: viewModel.items, selectedItem: item)
                            ) {
                                CellView(viewModel: viewModel, image: item)
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
    
    struct CellView: View {
        
        //MARK: Properties
        @StateObject var viewModel: GalleryViewModel
        
        var image: ImageModel
        //MARK: UI Properties
        
        var body: some View {
            
            AsyncImageView(
                urlString: image.imageURL,
                type: .preview) {
                    //Приерное исполнение функции подгрузки изображений, если они не загрузились
                    Image(systemName: "photo")
                        .onTapGesture {
                            Task { await viewModel.uploadImage(image.imageURL)}
                        }
                } loaderView: {
                    ProgressView()
                }
        }
    }
}

