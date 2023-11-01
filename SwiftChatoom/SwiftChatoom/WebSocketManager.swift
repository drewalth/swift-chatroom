//
//  WebSocketManager.swift
//  SwiftChatoom
//
//  Created by Andrew Althage on 10/31/23.
//

import Foundation
import Starscream

@Observable
class WebSocketManager {
    // Replace this value with your machine's IP address
    // if you want to test using a physical device.
    private var serverHost = "localhost"

    private var socket: WebSocket!
    var isConnected = false
    var messages: [String] = []

    init() {
        setupWebSocket()
    }

    private func setupWebSocket() {
        var request = URLRequest(url: URL(string: "ws://\(serverHost):8080/chat")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
    }

    func connect() {
        socket.connect()
    }

    func disconnect() {
        socket.disconnect()
    }

    func send(_ message: String) {
        socket.write(string: message)
    }
}

extension WebSocketManager: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client _: Starscream.WebSocketClient) {
        switch event {
        case .connected:
            DispatchQueue.main.async {
                self.isConnected = true
            }
        case .disconnected:
            DispatchQueue.main.async {
                self.isConnected = false
            }
        case let .text(string):
            DispatchQueue.main.async {
                self.messages.append(string)
            }
        // ... handle other cases as needed
        default:
            break
        }
    }
}
