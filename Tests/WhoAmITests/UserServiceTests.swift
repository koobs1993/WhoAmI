import XCTest
@testable import WhoAmI

final class UserServiceTests: XCTestCase {
    var sut: UserService!
    var mockSupabase: MockSupabaseClient!
    var mockBaseService: BaseService!
    
    override func setUp() {
        super.setUp()
        mockSupabase = MockSupabaseClient()
        mockBaseService = BaseService(supabase: mockSupabase)
        sut = UserService(baseService: mockBaseService)
    }
    
    override func tearDown() {
        sut = nil
        mockBaseService = nil
        mockSupabase = nil
        super.tearDown()
    }
    
    func testFetchUserProfileSuccess() async throws {
        // Given
        let userId = UUID()
        let expectedProfile = UserProfile(
            id: userId,
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            gender: .male,
            role: .user,
            avatarUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let mockPostgrest = MockPostgrestClient()
        mockPostgrest.mockResponse = expectedProfile
        
        // When
        let result = try await sut.fetchUserProfile(userId: userId)
        
        // Then
        XCTAssertEqual(result.id, expectedProfile.id)
        XCTAssertEqual(result.firstName, expectedProfile.firstName)
        XCTAssertEqual(result.lastName, expectedProfile.lastName)
        XCTAssertEqual(result.email, expectedProfile.email)
        XCTAssertEqual(result.gender, expectedProfile.gender)
        XCTAssertEqual(result.role, expectedProfile.role)
    }
    
    func testFetchUserProfileFailure() async {
        // Given
        let userId = UUID()
        let mockPostgrest = MockPostgrestClient()
        mockPostgrest.mockError = ServiceError.notFound
        
        // When/Then
        do {
            _ = try await sut.fetchUserProfile(userId: userId)
            XCTFail("Expected fetchUserProfile to fail")
        } catch {
            XCTAssertTrue(error is ServiceError)
            XCTAssertEqual(error as? ServiceError, .notFound)
        }
    }
    
    func testUpdateUserProfileSuccess() async throws {
        // Given
        let userId = UUID()
        let updatedProfile = UserProfile(
            id: userId,
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            gender: .male,
            role: .user,
            avatarUrl: "new_avatar.jpg",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let mockPostgrest = MockPostgrestClient()
        mockPostgrest.mockResponse = updatedProfile
        
        // When
        let result = try await sut.updateUserProfile(userId: userId, profile: updatedProfile)
        
        // Then
        XCTAssertEqual(result.id, updatedProfile.id)
        XCTAssertEqual(result.firstName, updatedProfile.firstName)
        XCTAssertEqual(result.lastName, updatedProfile.lastName)
        XCTAssertEqual(result.email, updatedProfile.email)
        XCTAssertEqual(result.gender, updatedProfile.gender)
        XCTAssertEqual(result.role, updatedProfile.role)
        XCTAssertEqual(result.avatarUrl, updatedProfile.avatarUrl)
    }
    
    func testUpdateUserProfileFailure() async {
        // Given
        let userId = UUID()
        let updatedProfile = UserProfile(
            id: userId,
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            gender: .male,
            role: .user,
            avatarUrl: "new_avatar.jpg",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let mockPostgrest = MockPostgrestClient()
        mockPostgrest.mockError = ServiceError.invalidData
        
        // When/Then
        do {
            _ = try await sut.updateUserProfile(userId: userId, profile: updatedProfile)
            XCTFail("Expected updateUserProfile to fail")
        } catch {
            XCTAssertTrue(error is ServiceError)
            XCTAssertEqual(error as? ServiceError, .invalidData)
        }
    }
    
    func testDeleteUserProfileSuccess() async throws {
        // Given
        let userId = UUID()
        let mockPostgrest = MockPostgrestClient()
        
        // When/Then
        XCTAssertNoThrow(try await sut.deleteUserProfile(userId: userId))
    }
    
    func testDeleteUserProfileFailure() async {
        // Given
        let userId = UUID()
        let mockPostgrest = MockPostgrestClient()
        mockPostgrest.mockError = ServiceError.notFound
        
        // When/Then
        do {
            try await sut.deleteUserProfile(userId: userId)
            XCTFail("Expected deleteUserProfile to fail")
        } catch {
            XCTAssertTrue(error is ServiceError)
            XCTAssertEqual(error as? ServiceError, .notFound)
        }
    }
} 