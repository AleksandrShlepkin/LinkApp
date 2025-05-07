//
//  GallaryViewData.swift
//  TestLinkApp
//
//  Created by Александр Коротков on 30.04.2025.
//

import Foundation

enum GalleryContentState {
    case content([URL])
    case error(Error?)
    case loading
    case alert
}
