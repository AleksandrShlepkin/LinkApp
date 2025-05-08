//
//  OnboardingViewModel.swift
//  TestLinkApp
//
//  Created by Александр Коротков on 07.05.2025.
//

import Foundation
import Combine
import SwiftUI

final class OnboardingViewModel: ObservableObject {
    
    //MARK: Properties
    
    @Published var loadingState: OnboardingModel = .loading
    
    let titleAlert: String = "Not internet connection"
    let titleReloadButtonAlert: String = "Reload"
    let errorMessageLoadImage: String = "Error load image"
    let title: String = "IT-LINK"
    
    //MARK: Private Properties
    
    private let connectManager : INetworkConnection
    private var cancellables = Set<AnyCancellable>()
    
    init(connectManager: INetworkConnection = NetworkConnectionManager.shared) {
        self.connectManager = connectManager
        setupNetworkObserver()
    }
    
    //MARK: Functions
    
    func loadingApp() async {
        if  connectManager.isConnected {
            await updateState(state: .loading)
        } else {
           await updateState(state: .alert)
        }
    }
    
    @MainActor
    func updateState (state: OnboardingModel) {
        self.loadingState = state
    }
}

private extension OnboardingViewModel {
    private func setupNetworkObserver() {
        connectManager.connectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                if isConnected {
                    Task { await self.updateState(state: .loading) }
                } else {
                    Task { await self.updateState(state: .alert) }
                }
            }
            .store(in: &cancellables)
    }
}
