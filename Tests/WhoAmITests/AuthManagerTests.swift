import XCTest
@testable import WhoAmI

final class AuthManagerTests: XCTestCase {
    var sut: AuthManager!
    var mockSupabase: MockSupabaseClient!
    
    override func setUp() {
        super.setUp()
        mockSupabase = MockSupabaseClient()
        sut = AuthManager(supabase: mockSupabase)
    }
    
    override func tearDown() {
        sut = nil
        mockSupabase = nil
        super.tearDown()
    }
    
    func testSignUpSuccess() async throws {
        // Given
        let signUpData = SignUpData(
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            password: "Password123!",
            confirmPassword: "Password123!",
            gender: .male,
            role: .user
        )
        
        mockSupabase.mockAuthResponse = AuthResponse(
            user: User(id: UUID(), email: signUpData.email),
            session: nil
        )
        
        // When
        try await sut.signUp(data: signUpData)
        
        // Then
        XCTAssertTrue(mockSupabase.signUpCalled)
        XCTAssertEqual(mockSupabase.lastEmail, signUpData.email)
        XCTAssertEqual(mockSupabase.lastPassword, signUpData.password)
    }
    
    func testSignUpFailure() async {
        // Given
        let signUpData = SignUpData(
            firstName: "John",
            lastName: "Doe",
            email: "invalid",
            password: "short",
            confirmPassword: "short",
            gender: .male,
            role: .user
        )
        
        // When/Then
        do {
            try await sut.signUp(data: signUpData)
            XCTFail("Expected sign up to fail")
        } catch {
            XCTAssertTrue(error is AuthError)
        }
    }
    
    func testSignInSuccess() async throws {
        // Given
        let signInData = SignInData(
            email: "john@example.com",
            password: "Password123!"
        )
        
        let mockUser = User(id: UUID(), email: signInData.email)
        mockSupabase.mockAuthResponse = AuthResponse(
            user: mockUser,
            session: Session(accessToken: "token", refreshToken: "refresh")
        )
        
        // When
        try await sut.signIn(data: signInData)
        
        // Then
        XCTAssertTrue(mockSupabase.signInCalled)
        XCTAssertEqual(mockSupabase.lastEmail, signInData.email)
        XCTAssertEqual(mockSupabase.lastPassword, signInData.password)
        XCTAssertEqual(sut.currentUser?.email, signInData.email)
        XCTAssertTrue(sut.isAuthenticated)
    }
    
    func testSignInFailure() async {
        // Given
        let signInData = SignInData(
            email: "nonexistent@example.com",
            password: "wrongpassword"
        )
        
        mockSupabase.mockError = AuthError.invalidCredentials
        
        // When/Then
        do {
            try await sut.signIn(data: signInData)
            XCTFail("Expected sign in to fail")
        } catch let error as AuthError {
            XCTAssertEqual(error, AuthError.invalidCredentials)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testSignOut() async throws {
        // Given
        sut.isAuthenticated = true
        sut.currentUser = User(id: UUID(), email: "test@example.com")
        
        // When
        try await sut.signOut()
        
        // Then
        XCTAssertTrue(mockSupabase.signOutCalled)
        XCTAssertNil(sut.currentUser)
        XCTAssertFalse(sut.isAuthenticated)
    }
} 