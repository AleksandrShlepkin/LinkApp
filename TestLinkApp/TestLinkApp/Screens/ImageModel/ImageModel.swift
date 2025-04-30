//
//  ImageModel.swift
//  TestLinkApp
//
//  Created by Александр Коротков on 30.04.2025.
//

import Foundation

struct ImageModel: Identifiable {
    let id: UUID = UUID()
    var imageURLs: [URL] = []
    var cachedImageURLs: [URL: URL] = [:]
    var isLoading = false
    var error: Error?
}
