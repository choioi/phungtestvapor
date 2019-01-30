import Vapor
import Fluent
struct AcronymsController: RouteCollection {
    
    
    
    func boot(router: Router) throws {
        //router.get("api", "acronyms", use: getAllHandler)
        let acronymsRoutes = router.grouped("api", "acronyms")
        acronymsRoutes.get(use: getAllHandler)
        // 1
        //acronymsRoutes.post(use: createHandler)
        acronymsRoutes.post(Acronym.self, use: createHandler)
        // 2
        acronymsRoutes.get(Acronym.parameter, use: getHandler)
        // 3
        acronymsRoutes.put(Acronym.parameter, use: updateHandler)
        // 4
        acronymsRoutes.delete(Acronym.parameter, use: deleteHandler)
        // 5
        acronymsRoutes.get("search", use: searchHandler)
        // 6
        acronymsRoutes.get("first", use: getFirstHandler)
        // 7
        acronymsRoutes.get("sorted", use: sortedHandler)
        
        //api/acronyms/<ACRONYM ID>/user
        acronymsRoutes.get(Acronym.parameter, "user",use: getUserHandler)
        
    }
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    
    //lay content request decode sau do map. va save
    func createHandler(_ req: Request) throws -> Future<Acronym> {
        return try req
            .content
            .decode(Acronym.self)
            .flatMap(to: Acronym.self) { acronym in
                return acronym.save(on: req)
        }
        
    }
    //truyen model luon va save khi co ket qua!
    func createHandler(_ req: Request,acronym: Acronym) throws -> Future<Acronym> {
        return acronym.save(on: req)
    }
    
    
    
    
    func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    func updateHandler(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(
            to: Acronym.self,
            req.parameters.next(Acronym.self),
            req.content.decode(Acronym.self)
        ) { acronym, updatedAcronym in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            acronym.userID = updatedAcronym.userID
            return acronym.save(on: req)
        }
        
    }
    func deleteHandler(_ req: Request)
        throws -> Future<HTTPStatus> {
            return try req
                .parameters
                .next(Acronym.self)
                .delete(on: req)
                .transform(to: HTTPStatus.noContent)
    }
    func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req
            .query[String.self, at: "term"] else {
                throw Abort(.badRequest)
        }
        return Acronym.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
            }.all()
        
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Acronym> {
        return Acronym.query(on: req)
            .first()
            .map(to: Acronym.self) { acronym in
                guard let acronym = acronym else {
                    throw Abort(.notFound)
                }
                return acronym
        }
    }
    func sortedHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).sort(\.short, .ascending).all()
    }
    
    // 1:Define a new route handler, getUserHandler(_:), that returns Future<User>.
    func getUserHandler(_ req: Request) throws -> Future<User> {
        // 2:Fetch the acronym specified in the request’s parameters and unwrap the returned future.
        return try req
            .parameters.next(Acronym.self)
            .flatMap(to: User.self) { acronym in
                // 3:Use the new computed property created above to get the acronym’s owner.
                acronym.user.get(on: req)
        }
    }

    
    
}
