//
//  ContentView.swift
//  SwiftChatoom
//
//  Created by Andrew Althage on 10/31/23.
//

import SwiftUI

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

    // MARK: - Article Early Steps

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
}

// MARK: - Preview

#Preview {
    ContentView()
}
