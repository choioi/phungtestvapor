import Vapor
import FluentPostgreSQL
final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    var userID: User.ID
    init(short: String, long: String, userID: User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}
extension Acronym: PostgreSQLModel {}
extension Acronym: Content {}
extension Acronym: Parameter {}
extension Acronym {
    //1:Add a computed property to Acronym to get the User object of the acronym’s owner.
    //This returns Fluent’s generic Parent type.
    var user: Parent<Acronym, User> {
        //2:Use Fluent’s parent(_:) function to retrieve the parent.
        //This takes the key path of the user reference on the acronym.
        return parent(\.userID)
    }
}
extension Acronym: Migration {
    // 2 Implement prepare(on:) as required by Migration. This overrides the default implementation.
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        // 3 Create the table for Acronym in the database
        return Database.create(self, on: connection) { builder in
            // 4 Use addProperties(to:) to add all the fields to the database. This means you don’t
           // need to add each column manually.
            try addProperties(to: builder)
            // 5:Add a reference between the userID property on Acronym and the id property on
            //User. This sets up the foreign key constraint between the two tables.
            builder.reference(from: \.userID, to: \User.id)
        }
        
    }
}
