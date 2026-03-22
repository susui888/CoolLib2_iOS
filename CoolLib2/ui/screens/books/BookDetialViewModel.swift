import Combine
import SwiftUI

enum DetailState {
    case loading
    case success(Book)
    case error(String)
}

@MainActor
class BookDetailViewModel: ObservableObject {

    @Published private(set) var state: DetailState = .loading

    private let usecase: BookUseCases

    init(usecase: BookUseCases) {
        self.usecase = usecase
    }

    func getBook(id: Int) {
        Task {
            state = .loading
            do {
                let book = try await usecase.getBookById(id: id)
                state = .success(book)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}
