import Vapor
import Fluent
import AVFoundation


/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    
    //ADD
    router.post("api", "acronyms") { req -> Future<Acronym> in
        // 2
        return try req.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
                // 3
                return acronym.save(on: req)
        }
        
    }
    
    //Retrieve all
    router.get("api", "acronyms") { (req) -> Future<[Acronym]> in
        return Acronym.query(on: req).all()
    }
    
    
    //Retrieve a single
    //1 Register a route at /api/acronyms/<ID> to handle a GET request. The route takes the acronym’s id property as the final path segment. This returns Future<Acronym>.
    router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        //2
        return try req.parameters.next(Acronym.self)
    }
    
    
    //Update : PUT http://localhost:8080/api/acronyms/10
    // => Tìm model có id 10, tìm được đặt tên model này là acronym,
    // => get json từ body user muốn update => model này là updatedAcronym,
    // => update acronym
    // 1 : Register a route for a PUT request to /api/acronyms/<ID> that returns Future<Acronym>.
    router.put("api", "acronyms", Acronym.parameter) {
        req -> Future<Acronym> in
        // 2 Use flatMap(to:_:_:), the dual future form of flatMap, to wait for both the parameter extraction and content decoding to complete. This provides both the acronym from the database and acronym from the request body to the closure.
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self),
                           req.content.decode(Acronym.self)) { acronym, updatedAcronym in
                            // 3 Update the acronym’s properties with the new values.
                            acronym.short = updatedAcronym.short
                            acronym.long = updatedAcronym.long
                            // 4 Save the acronym and return the result
                            return acronym.save(on: req)
        }
    }
    
    
    //Delete /api/acronyms/<ID> trả về http status code,hoac 2 cai String
    // 1 : Register a route for a DELETE request to /api/acronyms/<ID> that returns Future<HTTPStatus>.
    router.delete("api", "acronyms", Acronym.parameter) {
        req -> Future<String> in //Future<HTTPStatus> in
        // 2 tìm thấy model đó xong, delete nó , del xong trả ra status code
        //return try req.parameters.next(Acronym.self).delete(on: req).transform(to: HTTPStatus.noContent)
        return try req.parameters.next(Acronym.self)
            .delete(on: req).transform(to: "Thanks")
    }
    
    
    
    //Filter result array SEARCHING http://localhost:8080/api/acronyms/search?term=OMG
    // 1Register a new route handler for /api/acronyms/search that returns Future<[Acronym]>.
    router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
        // 2: Từ khóa trên URL chứa string cần serach là "term"
        guard let searchTerm = req.query[String.self, at: "term"] else {
                throw Abort(.badRequest)
        }
        // 3 tìm từ khóa trong file short , tìm chính xác, kết quả tất cả trả ra 1 mãng mode tìm thấy
        //return Acronym.query(on: req).filter(\.short == searchTerm).all()
        
        return Acronym.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
            
        }.all()
    
    }
    
    
    //Filter first result SEARCHING http://localhost:8080/api/acronyms/search?term=OMG
    // 1Register a new route handler for /api/acronyms/search that returns Future<[Acronym]>.
    router.get("api", "acronyms", "first") { req -> Future<Acronym> in
        return Acronym.query(on: req).first().map(to: Acronym.self) { (acronym) in
            guard let acronym = acronym else {
                throw Abort(.notFound)
            }
            return acronym
        }
    }
    
    
    //Sorting results
    router.get("api","acronyms","sortedup") { req -> Future<[Acronym]> in
        return Acronym.query(on: req).sort(\.short, .descending).all()
        
    }
    router.get("api","acronyms","sorteddown") { req -> Future<[Acronym]> in
        return Acronym.query(on: req).sort(\.short, .ascending).all()
        
    }
    
    //vapor cloud deploy --env=production --build=incremental -y
    
    
}
