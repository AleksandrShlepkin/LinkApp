//
//  DetailsView.swift
//  LinkApp
//
//  Created by Александр Коротков on 29.04.2025.
//

import SwiftUI

private enum Constants {
    static let scaleZoomableImageView: CGFloat =  1.0
    static let minimumScaleZoomableImageView: CGFloat =  1.0
    static let durationAnimateShowNavBar: CGFloat =  0.2
}

struct DetailsView: View {
    
    //MARK: Properties
    
    let urls: [URL]
    
    //MARK: UI Properties
    
    @State var selectedURL: URL
    @State private var isNavBarHidden = false
    @State var viewModel: DetailsViewModel
    @State private var isZoomed = false
    
    
    struct ZoomableImageView: View {
        
        //MARK: Properties
        
        let url: URL
        
        //MARK: Private Properties
        
        private let minimunScale: CGFloat = Constants.minimumScaleZoomableImageView
        
        //MARK: Actions
        
        var onTap: () -> Void = {}
        var onZoom: (Bool) -> Void = { _ in }
        
        //MARK: UI Properties
        
        @State private var scale: CGFloat = Constants.scaleZoomableImageView
        
        
        var body: some View {
            GeometryReader { geo in
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(max(scale, minimunScale))
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = max(value, minimunScale)
                                    onZoom(scale > minimunScale)
                                }
                                .onEnded { _ in
                                    withAnimation(.easeInOut) {
                                        scale = minimunScale
                                        onZoom(false)
                                    }
                                }
                        )
                } placeholder: {
                    ProgressView()
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .onTapGesture {
                    onTap()
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedURL) {
                ForEach( urls, id: \.self) { url in
                    if let localURL: URL = viewModel.cachedImageURLs[url] {
                        ZoomableImageView(url: localURL,
                                          onTap: {
                            withAnimation(.easeInOut(duration: Constants.durationAnimateShowNavBar)) {
                                isNavBarHidden.toggle()
                            }
                        },
                                          onZoom: { zooming in
                            withAnimation {
                                isZoomed = zooming
                            }
                        })
                        .tag(url)
                    } else {
                        ZoomableImageView(url: url,
                                          onTap: {
                            withAnimation(.easeInOut(duration: Constants.durationAnimateShowNavBar)) {
                                isNavBarHidden.toggle()
                            }
                        },
                                          onZoom: { zooming in
                            withAnimation {
                                isZoomed = zooming
                            }
                        })
                        .task {
                            await viewModel.uploadCacheImage(url: url)
                        }
                    }
                }
            }
        }
        .background(
            Group {
                if isZoomed || isNavBarHidden {
                    Color.black
                } else {
                    LinearGradient(
                        colors: [.mainAppColorStart, .mainAppColorEnd],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
        )
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: isNavBarHidden || isZoomed ? .never : .automatic))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isNavBarHidden || isZoomed)
        .edgesIgnoringSafeArea(.all)
        .toolbar {
            if !isNavBarHidden {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(item: selectedURL) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        
    }
}
