//
//  NetworkReachability.swift
//  ReaderApp
//
//  Created by Mohanaprabhu on 12/09/25.
//

import Foundation
import Network
import UIKit

class NetworkReachability {
    
    static let shared = NetworkReachability()
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkReachability")
    
    public private(set) var isConnected = false
    public private(set) var connectionType: ConnectionType = .unknown
    
    var onReachabilityChanged: ((Bool) -> Void)?
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        self.monitor = NWPathMonitor()
        addAppLifecycleObservers()
    }
    
    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            let newConnection = path.status == .satisfied
            self.isConnected = newConnection
            self.getConnectionType(path)
            
            DispatchQueue.main.async {
                self.onReachabilityChanged?(newConnection)
            }
        }
        
        monitor.start(queue: queue)
        
        let path = monitor.currentPath
        isConnected = path.status == .satisfied
        getConnectionType(path)
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
    
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
    
    // 🔄 Handle app moving foreground/background
    private func addAppLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func appBecameActive() {
        let path = monitor.currentPath
        isConnected = path.status == .satisfied
        getConnectionType(path)
        
        DispatchQueue.main.async {
            self.onReachabilityChanged?(self.isConnected)
        }
    }
    
    deinit {
        monitor.cancel()
        NotificationCenter.default.removeObserver(self)
    }
}
