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
    
    @State var items: [ImageModel]
    @State var selectedItem: ImageModel
    
    //MARK: UI Properties
    
    @State private var isNavBarHidden = false
    @State private var isZoomed = false
    
    
    struct ZoomableImageView: View {
        
        //MARK: Properties
        
        let url: String
        
        //MARK: Private Properties
        
        private let minimunScale: CGFloat = Constants.minimumScaleZoomableImageView
        
        //MARK: Actions
        
        var onTap: () -> Void = {}
        var onZoom: (Bool) -> Void = { _ in }
        
        //MARK: UI Properties
        
        @State private var scale: CGFloat = Constants.scaleZoomableImageView
        
        
        var body: some View {
            GeometryReader { geo in
                AsyncImage(url: URL(string: url)) { image in
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
            .ignoresSafeArea(edges: .all)
        }
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedItem) {
                ForEach(items) { item in
                        ZoomableImageView(url: item.imageURL) {
                            withAnimation(.easeInOut(duration: Constants.durationAnimateShowNavBar)) {
                                isNavBarHidden.toggle()
                            }
                        } onZoom: { isZooming in
                            withAnimation {
                                isZoomed = isZooming
                            }
                        }
                        .tag(item)
                    
                }
            }

        }
        .onTapGesture {
            isNavBarHidden.toggle()
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
        .navigationBarTitleDisplayMode(.automatic)
        .navigationBarBackButtonHidden(isNavBarHidden || isZoomed)
        .edgesIgnoringSafeArea(.all)
        .toolbar {
            if !isNavBarHidden {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(item: URL(string:selectedItem.imageURL) ?? URL(fileURLWithPath: "Invalid URL")) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}
