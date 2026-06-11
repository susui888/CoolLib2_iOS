//
//  reviewViewModel.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/5/16.
//

import Combine
import SwiftUI

enum ReviewUIState {
    case idle
    case loading
    case success([Review])
    case error(String)
}

@MainActor
class ReviewViewModel: ObservableObject {

    @Published private(set) var state: ReviewUIState = .idle
    @Published var isDeleting: Bool = false

    var isLoggedIn: Bool {
        sessionManager.getToken() != nil
    }

    private let reviewUseCase: ReviewUseCases
    private let sessionManager: SessionManager

    init(reviewUseCase: ReviewUseCases, sessionManager: SessionManager) {
        self.reviewUseCase = reviewUseCase
        self.sessionManager = sessionManager

        loadLocalReviews()
    }

    func loadLocalReviews() {
        Task {
            state = .loading
            do {
                let localReviews = try await reviewUseCase.getAllLocalReviews()
                state = .success(localReviews)
            } catch {
                state = .error(error.localizedDescription)

                TelemetryManager.shared.fireError(
                    TelemetryEvents.Actions.homeDataLoadFailure,
                    message: error.localizedDescription
                )
            }
        }
    }

    func deleteReview(review: Review) {
        Task {
            isDeleting = true
            defer { isDeleting = false }

            do {
                let _ = try await reviewUseCase.deleteReview(review: review)
                
                TelemetryManager.shared.fire(TelemetryEvents.Actions.bookDeleteReviewSuccess, bookId: review.bookId) {
                    [
                        "review_id": String(review.id)
                    ]
                }

                loadLocalReviews()
            } catch {
                print("Failed to delete review: \(error.localizedDescription)")
            }
        }
    }
}
