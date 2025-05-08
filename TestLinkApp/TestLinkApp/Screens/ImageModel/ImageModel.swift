//
//  ImageModel.swift
//  TestLinkApp
//
//  Created by Александр Коротков on 30.04.2025.
//

import Foundation

struct ImageModel: Identifiable, Hashable {
    let id: UUID = UUID()
    var imageURL: String

}
