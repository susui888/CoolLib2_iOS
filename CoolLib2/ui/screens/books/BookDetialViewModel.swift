import Combine
import PhotosUI
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

    func postReview(
        bookId: Int,
        rating: Int,
        content: String,
        items: [PhotosPickerItem]
    ) {
        Task {
            do {

                var images: [UIImage] = []
                for item in items {
                    if let data = try await item.loadTransferable(
                        type: Data.self
                    ),
                        let image = UIImage(data: data)
                    {
                        images.append(image)
                    }
                }

                let imageUrls: [String]
                if !images.isEmpty {
                    imageUrls = try await reviewUseCase.uploadImages(
                        images: images
                    )
                } else {
                    imageUrls = []
                }

                let newReview = Review(
                    id: nil,
                    bookId: bookId,
                    userId: 0,
                    userName: "",
                    rating: rating,
                    content: content,
                    imageUrls: imageUrls,
                    createdAt: Date()
                )

                let result = try await reviewUseCase.createReview(
                    review: newReview
                )

                if result != nil {
                    await loadReviews(bookId: bookId)
                }

            } catch {

                print("Failed to post review: \(error.localizedDescription)")
            }
        }
    }
}
