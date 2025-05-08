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

    @StateObject var viewModel = OnboardingViewModel()

    // MARK: - Computed Properties
    var body: some View {
        VStack {
            Spacer()
            switch viewModel.loadingState {
            case .loading:
                CustomTitleView(viewModel: viewModel)
            case .alert:
                CustomAlertView(viewModel: viewModel)
            case .error(_):
                Text(viewModel.titleAlert)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                //Для обработки ошибок
            }
            Spacer()
        }
        .task {
            await viewModel.loadingApp()
        }
        .background(LinearGradient(colors: [Color(.mainAppColorStart),Color(.mainAppColorEnd)],
                                     startPoint: .top,
                                     endPoint: .bottom))
    }
}

private extension OnboardingView {
    
    struct CustomAlertView: View {
        
        // MARK: - Properties
        
        @StateObject var viewModel: OnboardingViewModel
        
        // MARK: - Computed Properties
        
        var body: some View {
            VStack {
                Text(viewModel.titleAlert)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Button(viewModel.titleReloadButtonAlert) {
                    viewModel.loadingState = .loading
                    Task {
                        await  viewModel.loadingApp()
                    }
                }
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(10)
            }
            .padding(20)
            .background(.mainAppColorEnd)
            .clipShape(.rect(cornerRadius: 10))
        }
    }
    
    struct CustomTitleView: View {
        
        // MARK: - Properties
        
        @StateObject var viewModel: OnboardingViewModel
        
        // MARK: - Computed Properties
        
        var body: some View {
            VStack {
                Text(viewModel.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                ProgressView()
            }
            .padding(20)
        }
    }
    
    struct CustomErrorView: View {
        
        // MARK: - Properties
        
        @StateObject var viewModel: OnboardingViewModel
        
        // MARK: - Computed Properties
        
        var body: some View {
            VStack {
                Text(viewModel.errorMessageLoadImage)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                ProgressView()
            }
            .padding(20)
        }
    }
}
