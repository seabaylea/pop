import Foundation
import Kitura
import LoggerAPI
import Health
import Configuration
import Generated
import CloudFoundryConfig
import SwiftMetrics
import SwiftMetricsDash

public let router = Router()
public let manager = ConfigurationManager()
public var port: Int = 8080

public func initialize() throws {

    manager.load(file: "config.json", relativeFrom: .project)
           .load(.environmentVariables)

    port = manager.port

    let sm = try SwiftMetrics()
    let _ = try SwiftMetricsDash(swiftMetricsInstance : sm, endpoint: router)

    router.all("/*", middleware: BodyParser())
    router.all("/", middleware: StaticFileServer())

    try initializeCRUDResources(manager: manager, router: router)


    initializeSwaggerRoute(path: ConfigurationManager.BasePath.project.path + "/definitions/tmp.yaml")
    let health = Health()
    
    router.get("/health") { request, response, _ in
        let result = health.status.toSimpleDictionary()
        if health.status.state == .UP {
            try response.send(json: result).end()
        } else {
            try response.status(.serviceUnavailable).send(json: result).end()
        }
    }
}

public func run() throws {
    Kitura.addHTTPServer(onPort: port, with: router)
    Kitura.run()
}
