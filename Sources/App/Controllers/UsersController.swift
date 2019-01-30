
import Vapor

struct UsersController: RouteCollection {

    func boot(router: Router) throws {

        let usersRoute = router.grouped("api", "users")

        usersRoute.post(User.self, use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.parameter, use: getHandler)
        usersRoute.get(User.parameter, "acronyms",use: getAcronymsHandler)
    }

    func createHandler(_ req: Request,user: User) throws -> Future<User> {

        return user.save(on: req)
    }
    func getAllHandler(_ req: Request) throws -> Future<[User]> {

        return User.query(on: req).all()
    }

    func getHandler(_ req: Request) throws -> Future<User> {

        return try req.parameters.next(User.self)
    }
    //1:Define a new route handler, getAcronymsHandler(_:), that returns
   // Future<[Acronym]>.
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        // 2 Fetch the user specified in the request’s parameters and unwrap the returned future.
            return try req
                .parameters.next(User.self)
                .flatMap(to: [Acronym].self) { user in
                    // 3 Use the new computed property created above to get the acronyms using a Fluent query to return all the acronyms.
                    try user.acronyms.query(on: req).all()
            }
    }
}
