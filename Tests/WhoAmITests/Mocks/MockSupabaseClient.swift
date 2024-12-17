import Foundation
import Supabase
@testable import WhoAmI

class MockSupabaseClient: SupabaseClientProtocol {
    var mockError: Error?
    var mockAuthResponse: AuthResponse?
    var mockSession: Session?
    
    var signUpCalled = false
    var signInCalled = false
    var signOutCalled = false
    var lastEmail: String?
    var lastPassword: String?
    
    func signUp(email: String, password: String) async throws -> AuthResponse {
        signUpCalled = true
        lastEmail = email
        lastPassword = password
        
        if let error = mockError {
            throw error
        }
        
        return mockAuthResponse ?? AuthResponse(user: nil, session: nil)
    }
    
    func signIn(email: String, password: String) async throws -> AuthResponse {
        signInCalled = true
        lastEmail = email
        lastPassword = password
        
        if let error = mockError {
            throw error
        }
        
        return mockAuthResponse ?? AuthResponse(user: nil, session: nil)
    }
    
    func signOut() async throws {
        signOutCalled = true
        
        if let error = mockError {
            throw error
        }
    }
    
    var auth: AuthClient {
        MockAuthClient(client: self)
    }
    
    var database: PostgrestClient {
        MockPostgrestClient()
    }
    
    var realtime: RealtimeClient {
        MockRealtimeClient()
    }
    
    var storage: StorageClient {
        MockStorageClient()
    }
    
    var functions: FunctionsClient {
        MockFunctionsClient()
    }
}

class MockAuthClient: AuthClientProtocol {
    private let client: MockSupabaseClient
    
    init(client: MockSupabaseClient) {
        self.client = client
    }
    
    var session: Session? {
        client.mockSession
    }
    
    func signUp(email: String, password: String) async throws -> AuthResponse {
        try await client.signUp(email: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws -> AuthResponse {
        try await client.signIn(email: email, password: password)
    }
    
    func signOut() async throws {
        try await client.signOut()
    }
}

class MockPostgrestClient: PostgrestClientProtocol {
    var mockResponse: Any?
    var mockError: Error?
    
    func from(_ table: String) -> PostgrestQueryBuilder {
        MockPostgrestQueryBuilder(mockResponse: mockResponse, mockError: mockError)
    }
}

class MockPostgrestQueryBuilder: PostgrestQueryBuilder {
    private let mockResponse: Any?
    private let mockError: Error?
    
    init(mockResponse: Any?, mockError: Error?) {
        self.mockResponse = mockResponse
        self.mockError = mockError
        super.init()
    }
    
    override func execute<T>() async throws -> PostgrestResponse<T> where T : Decodable {
        if let error = mockError {
            throw error
        }
        
        if let response = mockResponse as? T {
            return PostgrestResponse(data: response)
        }
        
        throw ServiceError.invalidData
    }
}

class MockRealtimeClient: RealtimeClientProtocol {
    func connect() {}
    func disconnect() {}
}

class MockStorageClient: StorageClientProtocol {
    func from(_ bucket: String) -> StorageFileApi {
        MockStorageFileApi()
    }
}

class MockStorageFileApi: StorageFileApi {
    var mockError: Error?
    var mockUploadResponse: String?
    
    func upload(path: String, file: Data, fileOptions: FileOptions?) async throws -> String {
        if let error = mockError {
            throw error
        }
        return mockUploadResponse ?? "mock_file_path"
    }
    
    func download(path: String) async throws -> Data {
        if let error = mockError {
            throw error
        }
        return Data()
    }
    
    func remove(paths: [String]) async throws {
        if let error = mockError {
            throw error
        }
    }
}

class MockFunctionsClient: FunctionsClientProtocol {
    func invoke<T, R>(_ functionName: String, invokeOptions: FunctionInvokeOptions<T>) async throws -> R where T : Encodable, R : Decodable {
        throw ServiceError.notImplemented
    }
} 