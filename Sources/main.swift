import Kitura
import HeliumLogger
import LoggerAPI

// Create a new router
let router = Router()

// Initialize HeliumLogger
Log.logger = HeliumLogger()

// Handle HTTP GET requests to /
router.get("/hello") {
    request, response, next in
    response.send("Hello, World!\n")
    Log.info("First route handler for /hello completed")
    next()
}

router.get("/hello") {
  request, response, next in
  response.send("Hello, again!")
  Log.info("Second route handler for /hello completed")
  next()
}

router.get("/ioscon") {
  request, response, next in
  do {
    try response.redirect("https://skillsmatter.com/conferences/8180-ioscon-2017-the-conference-for-ios-and-swift-developers")
  } catch {
    Log.error("Failed to redirect \(error)")
  }
  next()
}

// Uses multiple handler blocks
router.get("/multi", handler: { request, response, next in
    response.status(.OK).send("I'm here!\n")
        next()
            }, { request, response, next in
                    response.send("Me too!\n")
                            next()
            })

router.get("/multi") { request, response, next in
    response.status(.OK).send("I come afterward..\n")
        next()
}

let subrouter = Router()
subrouter.get("/") { _, response, _ in
    try response.send("Hello from subsection").end()
}
subrouter.get("/about") {_, response, _ in
    try response.send("About the subsection").end()
}

router.all("subrouter", middleware: subrouter)

// Reading parameters
// Accepts user as a parameter
router.get("/users/:user") { request, response, next in
    response.headers["Content-Type"] = "text/html; charset=utf-8"
    let p1 = request.parameters["user"] ?? "(nil)"
    do {
        try response.status(.OK).send(
            "<!DOCTYPE html><html><body>" +
                "<b>User:</b> \(p1)" +
            "</body></html>\n\n").end()
    } catch {
        Log.error("Failed to send response \(error)")
    }
}

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8090, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()

