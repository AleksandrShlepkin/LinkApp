//
//  OnboardingView.swift
//  TestLinkApp
//
//  Created by Александр Коротков on 30.04.2025.
//

import Foundation
import SwiftUI

private enum Constants {
    static let startColor: Color = .mainAppColorStart
    static let endColor: Color = .mainAppColorEnd
    static let titileColor: Color = .white
    static let title: String = "IT-LINK"
}

struct OnboardingView: View {
    var body: some View {
        VStack {
            Spacer()
            Text(Constants.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Constants.titileColor)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
                .foregroundStyle(Constants.titileColor)
            Spacer()
        }
        .background(LinearGradient(colors: [Color(Constants.startColor),Color(Constants.endColor)],
                                     startPoint: .top,
                                     endPoint: .bottom))
    }
}
