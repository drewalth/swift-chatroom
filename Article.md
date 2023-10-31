
- For the longest time I always categorized Swift as a client-side programming language that doesn’t belong on the server. But then the other day I had the realization that I write Nodejs services for work all the time. Nodejs, JavaScript a browser language. I’m aware that a lot of folks out there would say that JavaScript also doesn’t belong on the server, but we’re not going to go down that rabbit hole today. Instead, we’re going to give server-side Swift a try and see what all the hubbub is about. 
- One thing I like about Nodejs is the ease of building real-time apps with WebSockets, specifically using the  socket.io framework. Building a simple chat room app with node and React with socket.io is a breeze. So let’s try building a simple chat room iOS app using the Vapor framework for our server. 
- Let’s get started. Head over to https://vapor.codes/ and follow the installation instructions.
- Now let’s create a workspace. On your machine, create a new folder called swift-chatroom and navigate into the directory. `mkdir swift-chatroom && cd swift-chatroom`
- Open Xcode and go to File -> New -> Workspace. And create a new workspace called `swift-chatroom` in the `swift-chatroom/` directory you just created.
- Now in the terminal create the a Vapor server. `vapor new server -n`
- Now add the server to the workspace. File -> Add Package Dependencies -> Add Local, select the new `server` directory and click open. It will take a second for Xcode to load all the other dependencies of vapor. Once complete, run the server by clicking the play button or pressing `cmd + r`. 
- Now lets create the iOS app. File -> New -> Project. Select iOS, call it `SwiftChatroom` and add the project to the `swift-chatroom` workspace. 
- Select the SwiftChatroom scheme and run the app on the simulator of your choosing.
- Lets verify that the iOS app can communnicate with the server. First let's make a couple small changes to the `/hello` route. Open Packages -> server -> Sources -> App -> routes.swift. Here, create a new structure called `Greeting`. 

```swift
struct Greeting: Content {
    var message: String
}
```

and change the handler to: 

```swift
    app.get("hello") { req async -> Greeting in
        Greeting(message: "Hello world!")
    }
```

Select the App scheme then rebuild + run the app, cmd + r. 

Now in the iOS app, open `ContentView.swift`. Lets add a State variable to store our decoded greeting. 

```swift
@State private var message: String = ""
```  

Replace the placeholder "Hello world!" in the Text view with our state variable. The VStack should look like this:

```swift
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(message)
        }
```

Cool. Now lets write our HTTP request and make the call to the server. Add a `Greeting` struct to match the reponse returned by the server and a function called `fetchGreeting`.

```swift
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
```

And lets call this func in a `.task` modifier. Add this to the VStack:

```swift
        .task {
            do {
                self.message = try await fetchGreeting()
            } catch {
                print(error)
            }
        }
```

Select the SwiftChatroom scheme, and refresh the app with cmd + r. If everything is working as expected, you should see something that looks like this: [screenshot](#)

Awesome! Now our server and client are talking to eachother. Now lets set up our chatroom.

## Chatroom

For 
 
