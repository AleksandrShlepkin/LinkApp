//
//  GallaryViewData.swift
//  TestLinkApp
//
//  Created by Александр Коротков on 30.04.2025.
//

import Foundation

enum GalleryContentState: Equatable {
    case content
    case error(Error?)
    case loading
    case alert
    
    static func ==(lhs: GalleryContentState, rhs: GalleryContentState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.alert, .alert):
            return true
        case (.content, .content):
            return true
        case (.error, .error):
            return true 
        default:
            return false
        }
    }
}
