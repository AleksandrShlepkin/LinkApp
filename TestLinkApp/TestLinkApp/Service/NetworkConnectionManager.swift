//
//  NetworkConnectionManager.swift
//  LinkApp
//
//  Created by Александр Коротков on 29.04.2025.
//

import Network
import SwiftUI
import Combine
import Foundation

protocol INetworkConnection: AnyObject {
    var isConnected: Bool { get }
    var connectionPublisher: Published<Bool>.Publisher { get }
}

final class NetworkConnectionManager: INetworkConnection {
    
    // MARK: - Singleton
    
    static let shared = NetworkConnectionManager()
    
    // MARK: - Properties
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published private(set) var isConnected: Bool = false
    var connectionPublisher: Published<Bool>.Publisher { $isConnected }
    
    // MARK: - Init
    
    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }
    
    // MARK: - Private Methods
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let newStatus = path.status == .satisfied
            DispatchQueue.main.async {
                self.isConnected = newStatus
            }
        }

        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
