// 1
import FluentPostgreSQL
import Vapor
import Leaf

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
    ) throws { // 2
    try services.register(FluentPostgreSQLProvider())
    try services.register(LeafProvider())
    
    
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)
    // Configure a database
    var databases = DatabasesConfig()
    // 3
    let hostname = Environment.get("DATABASE_HOSTNAME")
        ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    
    let databaseName: String
    let databasePort: Int
    // 1If you’re running in the .testing environment, set the database name and port to different values.
    if (env == .testing) {
        databaseName = "vapor-test"
        databasePort = 5433
    } else {
        databaseName = Environment.get("DATABASE_DB") ?? "vapor"
        databasePort = 5432
    }
    
    
    let password = Environment.get("DATABASE_PASSWORD")
        ?? "password"
    
    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: hostname,
        // 2 Configure the database port in the PostgreSQLDatabaseConfig.
        port: databasePort,
        username: username,
        database: databaseName,
        password: password)
    
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)
    
    var migrations = MigrationConfig()
    // vi tri rat quan trong trong viec thiet lap khoa ngoai
    migrations.add(model: User.self, database: .psql)//vi tri thu 1
    migrations.add(model: Acronym.self, database: .psql) // vi tri thu 2
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: AcronymCategoryPivot.self,database: .psql)
    
    
    services.register(migrations)
    
    // 1
    var commandConfig = CommandConfig.default()
    // 2
    commandConfig.useFluentCommands()
    // 3
    services.register(commandConfig)
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    
}
