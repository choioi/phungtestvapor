import Foundation
import Vapor
import FluentPostgreSQL
final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}
extension User: PostgreSQLUUIDModel {} //Use the FluentPostgreSQL model helpers to make conforming to Model simple. Because the model’s id property is a UUID, you must use PostgreSQLUUIDModel instead of PostgreSQLModel.
extension User: Migration {}
extension User: Content {}
extension User: Parameter {}
extension User {
    //1:Add a computed property to User to get a user’s acronyms. This returns Fluent’s
    //generic Children type.
   
    var acronyms: Children<User, Acronym> {
        //2: Use Fluent’s children(_:) function to retrieve the children. This takes the key path
       // of the user reference on the acronym.
        return children(\.userID)
    }
}
