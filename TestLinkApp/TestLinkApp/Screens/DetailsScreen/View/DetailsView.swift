//
//  DetailsView.swift
//  LinkApp
//
//  Created by Александр Коротков on 29.04.2025.
//

import SwiftUI

struct DetailsView: View {
    let urls: [URL]
    @State var selectedURL: URL
    @State private var isUIHidden = false
    
    var body: some View {
        TabView(selection: $selectedURL) {
            ForEach(urls, id: \.self) { url in
                ZoomableImageView(url: url)
                    .tag(url)
                    .onTapGesture {
                        withAnimation {
                            isUIHidden.toggle()
                        }
                    }
            }
        }
        .background(.black)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .navigationBarTitleDisplayMode(.inline)

    }
}

//#Preview {
//    DetailsView(urls: [URL()], selectedURL: URL())
//}

struct ZoomableImageView: View {
    let url: URL
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geo in
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(MagnificationGesture().onChanged { value in
                        scale = value
                    })
            } placeholder: {
                ProgressView()
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
