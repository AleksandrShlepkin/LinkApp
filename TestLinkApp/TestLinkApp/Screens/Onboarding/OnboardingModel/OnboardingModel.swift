//
//  OnboardingModel.swift
//  TestLinkApp
//
//  Created by Александр Коротков on 07.05.2025.
//

import Foundation


enum OnboardingModel: Equatable {
    
    case error(Error?)
    case loading
    case alert
    
    static func ==(lhs: OnboardingModel, rhs: OnboardingModel) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.alert, .alert):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}
