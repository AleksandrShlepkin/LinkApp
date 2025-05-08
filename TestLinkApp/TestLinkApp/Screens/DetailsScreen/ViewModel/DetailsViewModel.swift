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
    
    @Published var cachedImageURLs: [ImageModel] = []

}

