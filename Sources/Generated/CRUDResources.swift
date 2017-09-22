import Kitura
import Configuration

public func initializeCRUDResources(manager: ConfigurationManager, router: Router) throws {
    let factory = AdapterFactory(manager: manager)
    try ServerMealResource(factory: factory).setupRoutes(router: router)
}
