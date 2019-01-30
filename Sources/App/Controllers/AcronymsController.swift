import Vapor
import Fluent
struct AcronymsController: RouteCollection {
    
    let acronymsRoutes = router.grouped("api", "acronyms")
    func boot(router: Router) throws {
        //router.get("api", "acronyms", use: getAllHandler)
        acronymsRoutes.get(use: getAllHandler)
        // 1
        acronymsRoutes.post(use: createHandler)
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
        
    }
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
}
