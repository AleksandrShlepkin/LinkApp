//
//  Extension+Color.swift
//  LinkApp
//
//  Created by Александр Коротков on 29.04.2025.
//

import Foundation
import SwiftUI

extension LinearGradient {
    static let appGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color("GradientStart"),
            Color("GradientEnd")
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

