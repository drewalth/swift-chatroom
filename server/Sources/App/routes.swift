import Vapor

var connectedClients: [UUID: WebSocket] = [:]


func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> Greeting in
        Greeting(message: "Hello world!")
    }

    app.webSocket("chat") { req, ws in
        // Generate a unique ID for the connected client
        let clientId = UUID()

        // Add the new WebSocket connection to our dictionary
        connectedClients[clientId] = ws

        // Handle when a client disconnects
        ws.onClose.whenComplete { _ in
            connectedClients[clientId] = nil
        }

        // Listen for messages from the client
        ws.onText { ws, text in
            // Broadcast the message to all connected clients
            for client in connectedClients.values {
                client.send(text)
            }
        }

    }
}

struct Greeting: Content {
    var message: String
}
