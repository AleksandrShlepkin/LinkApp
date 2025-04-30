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
    
    //MARK: Properties
    
    static let shared = NetworkConnectionManager()
    
    //MARK: Private Properties
    
    private var monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published private(set) var isConnected: Bool = false
    
    //MARK: Actions
    
    var onReconnect: (() -> Void)?
    
    //MARK: Init
    
    init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }
    
    //MARK: Private functions
    
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
