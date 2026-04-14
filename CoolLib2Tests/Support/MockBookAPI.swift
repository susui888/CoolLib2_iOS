import Foundation
@testable import CoolLib2

final class MockBookAPI: BookAPI {
   
    
    // --- Stubs (Stub Data) ---
    // Defaulting to the lists defined in your MockBooks and MockCategories
    var stubSearchBooks: [BookDTO] = MockBooks.dtoList
    var stubBookById: BookDTO? = MockBooks.dtoList.first
    var stubBookByISBN: BookDTO? = MockBooks.dtoList.first
    var stubCategories: [CategoryDTO] = MockCategories.dtoList
    var stubNewestBooks: [BookDTO] = MockBooks.dtoList.shuffled()
    
    // --- Error Simulation ---
    var shouldThrowError = false
    var customError: Error = NSError(
        domain: "MockError",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Network connection failed"]
    )

    // MARK: - Protocol Implementation

    func searchBooks(
        category: Int?,
        author: String?,
        publisher: String?,
        year: Int?,
        searchTerm: String?
    ) async throws -> [BookDTO] {
        if shouldThrowError { throw customError }
        return stubSearchBooks
    }

    func getBookById(id: Int) async throws -> BookDTO {
        if shouldThrowError { throw customError }
        
        // Return a specific stub if provided by the test
        if let stub = stubBookById { return stub }
        
        // Otherwise, attempt to find a book with a matching ID in the search list
        if let found = stubSearchBooks.first(where: { $0.id == id }) {
            return found
        }
        
        throw NSError(
            domain: "MockBookAPI",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "Book with ID \(id) not found"]
        )
    }

    func getCategory() async throws -> [CategoryDTO] {
        if shouldThrowError { throw customError }
        return stubCategories
    }

    func getNewestBooks() async throws -> [BookDTO] {
        if shouldThrowError { throw customError }
        return stubNewestBooks
    }
    
    func getBookByISBN(isbn: String) async throws -> BookDTO {
        if shouldThrowError { throw customError }
        return stubBookByISBN!
    }
}
