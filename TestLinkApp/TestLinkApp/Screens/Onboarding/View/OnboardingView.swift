//
//  OnboardingView.swift
//  TestLinkApp
//
//  Created by Александр Коротков on 30.04.2025.
//

import Foundation
import SwiftUI

// MARK: - OnboardingView

struct OnboardingView: View {
    
    // MARK: - Properties

    let title: String = "IT-LINK"

    // MARK: - Computed Properties
    var body: some View {
        VStack {
            Spacer()
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
                .foregroundStyle(.white)
            Spacer()
        }
        .background(LinearGradient(colors: [Color(.mainAppColorStart),Color(.mainAppColorEnd)],
                                     startPoint: .top,
                                     endPoint: .bottom))
    }
}
