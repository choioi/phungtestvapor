import Vapor
import Fluent
import FluentSQL

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
        
        //
        acronymsRoutes.get(Acronym.parameter, "user",use: getUserHandler)
        
        acronymsRoutes.post(Acronym.parameter,"categories",Category.parameter,use: addCategoriesHandler)
        
        acronymsRoutes.get(Acronym.parameter,"categories",use: getCategoriesHandler)
    
        acronymsRoutes.delete(Acronym.parameter,"categories",Category.parameter,use: removeCategoriesHandler)
    
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
            or.filter(\.short ~~ searchTerm)
            or.filter(\.long ~~ searchTerm)
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
    
    //1:Define a new route handler, addCategoriesHandler(_:), that returns a
    //Future<HTTPStatus>.
    func addCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
        // 2:Use flatMap(to:_:_:) to extract both the acronym and category from the request’s parameters
        return try flatMap(
            to: HTTPStatus.self,
            req.parameters.next(Acronym.self),
            req.parameters.next(Category.self)) { acronym, category in
                // 3 Use attach(_:on:) to set up the relationship between acronym and category. This creates a pivot model and saves it in the database. Transform the result into a 201 Created response.
                return acronym.categories.attach(category, on: req).transform(to: .created)
        }
    }
    
    func getCategoriesHandler(_ req: Request) throws -> Future<[Category]> {
        // 2
        return try req.parameters.next(Acronym.self)
            .flatMap(to: [Category].self) { acronym in
                // 3
                try acronym.categories.query(on: req).all()
        }
    }
    /*
     Here’s what this does:
     1. Defines route handler getCategoriesHandler(_:) returning Future<[Category]>.
     2. Extract the acronym from the request’s parameters and unwrap the returned future.
     3. Use the new computed property to get the categories. Then use a Fluent query to return all the categories.
     */
    
    
    //1
    func removeCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
        // 2
        return try flatMap(
            to: HTTPStatus.self,
            req.parameters.next(Acronym.self),
            req.parameters.next(Category.self)
        ) { acronym, category in
            //3
            return acronym.categories
                .detach(category, on: req)
                .transform(to: .noContent)
        }
        
    }
    /*
     Here’s what the new route handler does:
     1. Define a new route handler, removeCategoriesHandler(_:), that returns a
     Future<HTTPStatus>.
     2. Use flatMap(to:_:_:) to extract both the acronym and category from the request’s
     parameters.
     3. Use detach(_:on:) to remove the relationship between acronym and category. This finds the pivot model in the database and deletes it. Transform the result into a 204 No Content response.
     */
}
