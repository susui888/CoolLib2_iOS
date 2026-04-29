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

    @Published private(set) var reviews: [Review] = []
    @Published var isPosting: Bool = false

    private let usecase: BookUseCases
    private let reviewUseCase: ReviewUseCases

    init(usecase: BookUseCases, reviewUseCase: ReviewUseCases) {
        self.usecase = usecase
        self.reviewUseCase = reviewUseCase
    }

    func getBook(id: Int) {
        Task {
            state = .loading
            do {
                let book = try await usecase.getBookById(id: id)
                state = .success(book)

                await loadReviews(bookId: id)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    func loadReviews(bookId: Int) async {
        do {
            self.reviews = try await reviewUseCase.getReviewsByBook(
                bookId: bookId
            )
        } catch {
            print("Failed to load reviews: \(error.localizedDescription)")
            self.reviews = []
        }
    }
    
    func postReview(bookId: Int, rating: Int, content: String) {
            Task {
                isPosting = true
                
                let newReview = Review(
                    id: nil,
                    bookId: bookId,
                    userId: 0,
                    userName: "",
                    rating: rating,
                    content: content,
                    createdAt: Date()
                )
                
                do {
                    let result = try await reviewUseCase.createReview(review: newReview)
                    if result != nil {
                        await loadReviews(bookId: bookId)
                    }
                } catch {
                    print("Failed to post review: \(error.localizedDescription)")
                }
                
                isPosting = false
            }
        }
}
