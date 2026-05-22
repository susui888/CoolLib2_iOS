//
//  ReviewViewModelTests.swift
//  CoolLib2Tests
//
//  Created by Ryan Su on 2026/5/21.
//

import XCTest
import Combine
@testable import CoolLib2

@MainActor
final class ReviewViewModelTests: XCTestCase {
    
    private var viewModel: ReviewViewModel!
    private var mockRepo: MockReviewRepository!
    private var realSessionManager: SessionManager!
    private let tokenKey = "auth_token_key"
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        // 1. Initialize Mock Repository
        mockRepo = MockReviewRepository()
        
        // 2. Inject into the real ReviewUseCases struct
        let realUseCase = ReviewUseCases(repository: mockRepo)
        
        // 3. Initialize real SessionManager and clear state
        realSessionManager = SessionManager()
        UserDefaults.standard.removeObject(forKey: tokenKey)
        cancellables = []
        
        // 4. Initialize ViewModel
        // Note: This triggers the initial loadLocalReviews() inside init
        viewModel = ReviewViewModel(
            reviewUseCase: realUseCase,
            sessionManager: realSessionManager
        )
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        cancellables = nil
        viewModel = nil
        mockRepo = nil
        realSessionManager = nil
        super.tearDown()
    }
    
    // MARK: - Initial / Async State Evolution Tests
    
    func test_init_automaticallyLoadsLocalReviews_success() async throws {
            // 1. Arrange
            let targetReview = Review(
                id: 42,
                bookId: 1001,
                userId: 123,
                userName: "Ryan Su",
                rating: 5,
                content: "Clean Architecture is elegant."
            )
            mockRepo.stubReviews = [targetReview]
            
            // 1：重置 Mock 计数，彻底抹除 setUp() 里的默认初始化干扰
            mockRepo.getAllLocalReviewsCallCount = 0
            
            var stateHistory: [ReviewUIState] = []
            let realUseCase = ReviewUseCases(repository: mockRepo)
            
            // 2. Act: 先不赋值给全局，通过局部变量安全控制
            let newViewModel = ReviewViewModel(reviewUseCase: realUseCase, sessionManager: realSessionManager)
            
            // 为了防止 Task 开辟瞬间错过了第一个状态，
            // 不使用 .dropFirst()，而是将 newViewModel 的“当前状态”以及“后续状态”全部捕获
            newViewModel.$state
                .sink { stateHistory.append($0) }
                .store(in: &cancellables)
                
            // 更新全局指针以便 tearDown 正常清理
            viewModel = newViewModel
            
            // 3. Wait for the asynchronous Task to finish
            try await Task.sleep(nanoseconds: 200_000_000) // 0.2s
            
            // 4. Assert
            // 确保 getAllLocalReviews 只在当前的这次 init 内部被调用了 1 次
            XCTAssertEqual(mockRepo.getAllLocalReviewsCallCount, 1, "The local data loader should be triggered exactly once.")
            
            // 验证状态演变链条：通过全量捕获，一定能稳定包含 .loading 状态
            XCTAssertTrue(
                stateHistory.contains(where: { if case .loading = $0 { return true }; return false }),
                "The state pipeline should transition through .loading."
            )
            
            switch viewModel.state {
            case .success(let reviews):
                XCTAssertEqual(reviews.count, 1, "The number of loaded reviews should match the mock data.")
                XCTAssertEqual(reviews.first?.id, 42, "The review ID should correctly map to the mocked item.")
                XCTAssertEqual(reviews.first?.content, "Clean Architecture is elegant.")
                
            case .loading:
                XCTFail("Test failed: State is still .loading. Try increasing sleep time.")
            case .error(let message):
                XCTFail("Test failed: Received .error state - \(message)")
            case .idle:
                XCTFail("Test failed: ViewModel is still .idle.")
            }
        }
    
    func test_loadLocalReviews_failure_updatesStateToError() async throws {
        // Arrange
        // Wait for the initialization task to drain first
        try await Task.sleep(nanoseconds: 100_000_000)
        mockRepo.shouldThrowError = true
        
        // Act
        viewModel.loadLocalReviews()
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Assert
        switch viewModel.state {
        case .error(let message):
            XCTAssertFalse(message.isEmpty, "Error message should not be empty on failure.")
        case .success:
            XCTFail("Expected state to be .error, but got .success instead.")
        case .loading:
            XCTFail("Expected state to be .error, but got .loading instead.")
        case .idle:
            XCTFail("Expected state to be .error, but got .idle instead.")
        }
    }
    
    // MARK: - Interaction Tests (deleteReview)
    
    func test_deleteReview_success_callsRepoAndRefreshesState() async throws {
        // Arrange
        try await Task.sleep(nanoseconds: 100_000_000) // Clear initial load
        let reviewToDelete = Review(
            id: 101,
            bookId: 1002,
            userId: 123,
            userName: "Ryan Su",
            rating: 4,
            content: "Temporary Review"
        )
        mockRepo.stubReviews = [reviewToDelete]
        mockRepo.stubDeleteResult = true
        mockRepo.getAllLocalReviewsCallCount = 0
        
        var deletingHistory: [Bool] = []
        viewModel.$isDeleting
            .sink { deletingHistory.append($0) }
            .store(in: &cancellables)
        
        // Act
        viewModel.deleteReview(review: reviewToDelete)
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2s
        
        // Assert
        XCTAssertEqual(mockRepo.deleteReviewCallCount, 1, "The delete operation must talk to the repository layer.")
        XCTAssertEqual(mockRepo.lastCapturedDeleteReview?.id, reviewToDelete.id, "The correct review parameters should be wrapped.")
        XCTAssertEqual(mockRepo.getAllLocalReviewsCallCount, 1, "ViewModel should auto-refresh local storage after a deletion.")
        
        // Verify the dynamic state track of isDeleting: false -> true -> false
        XCTAssertTrue(deletingHistory.contains(true), "isDeleting sequence should transiently switch to true.")
        XCTAssertFalse(viewModel.isDeleting, "isDeleting should always be reset to false via defer block.")
        
        if case .success(let reviews) = viewModel.state {
            XCTAssertTrue(reviews.isEmpty, "Local storage cache should successfully update and appear empty.")
        } else {
            XCTFail("Expected .success state after data reloading.")
        }
    }
    
    // MARK: - Session Verification Tests
    
    func test_isLoggedIn_returnsTrue_whenTokenExists() {
        // Arrange
        UserDefaults.standard.set("cf_jwt_token_xyz", forKey: tokenKey)
        let realUseCase = ReviewUseCases(repository: mockRepo)
        viewModel = ReviewViewModel(reviewUseCase: realUseCase, sessionManager: realSessionManager)
        
        // Act & Assert
        XCTAssertTrue(viewModel.isLoggedIn, "isLoggedIn must return true when token is present inside user defaults.")
    }
    
}
