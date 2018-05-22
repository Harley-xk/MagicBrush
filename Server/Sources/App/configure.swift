import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    let mysqlConfig = MySQLDatabaseConfig(hostname: "127.0.0.1",
                                          port: 3306,
                                          username: "root",
                                          password: "123456",
                                          database: "MaLiang")
    let mysql = MySQLDatabase(config: mysqlConfig)

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: mysql, as: .mysql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Todo.self, database: .mysql)
    services.register(migrations)

    /// Create default content config
    var contentConfig = ContentConfig.default()
    
    /// Create custom JSON encoder
    let jsonEncoder = JSONEncoder()
    jsonEncoder.dateEncodingStrategy = .millisecondsSince1970
    
    /// Register JSON encoder and content config
    contentConfig.use(encoder: jsonEncoder, for: .json)
    services.register(contentConfig)

    
}
