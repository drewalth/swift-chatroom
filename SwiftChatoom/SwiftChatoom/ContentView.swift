//
//  ContentView.swift
//  SwiftChatoom
//
//  Created by Andrew Althage on 10/31/23.
//

import SwiftUI
import Starscream

struct ContentView: View {
    @State private var webSocketManager = WebSocketManager()
    @State private var message: String = ""

    var body: some View {
        VStack(spacing: 20) {
            List(webSocketManager.messages, id: \.self) { msg in
                Text(msg)
            }

            HStack {
                TextField("Enter message...", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Send") {
                    webSocketManager.send(message)
                    message = ""
                }
            }
            .padding()
        }
        .onAppear {
            webSocketManager.connect()
        }
        .onDisappear {
            webSocketManager.disconnect()
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - API

func fetchGreeting() async throws -> String {
    // Create the URL
    guard let url = URL(string: "http://localhost:8080/hello") else {
        throw URLError(.badURL)
    }

    let session = URLSession.shared

    // Make an async request
    let (data, response) = try await session.data(from: url)

    // Check for HTTP response and status code
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }

    // Decode the response
    return try JSONDecoder().decode(Greeting.self, from: data).message
}

struct Greeting: Decodable {
    let message: String
}

// MARK: - Websocket

@Observable
class WebSocketManager {
    private var socket: WebSocket!
    var isConnected = false
    var messages: [String] = []

    init() {
        setupWebSocket()
    }

    private func setupWebSocket() {
        var request = URLRequest(url: URL(string: "ws://10.11.211.192:8080/chat")!)
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
    // Handle WebSocket events here, similar to the previous example.
    // For instance:
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(_):
            DispatchQueue.main.async {
                self.isConnected = true
            }
        case .disconnected(_, _):
            DispatchQueue.main.async {
                self.isConnected = false
            }
        case .text(let string):
            DispatchQueue.main.async {
                self.messages.append(string)
            }
        // ... handle other cases as needed
        default:
            break
        }
    }
}
