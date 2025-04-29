//
//  NetworkConnectionManager.swift
//  LinkApp
//
//  Created by Александр Коротков on 29.04.2025.
//

import Foundation
import Network
import SwiftUI

final class NetworkConnectionManager {
    static let shared = NetworkConnectionManager()
    
    private var monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published private(set) var isConnected: Bool = false
    var onReconnect: (() -> Void)?
    
    init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let newStatus = path.status == .satisfied
            
            if newStatus != self.isConnected {
                self.isConnected = newStatus
                if newStatus {
                    self.onReconnect?()
                }
            }
        }
        monitor.start(queue: queue)
    }
}
