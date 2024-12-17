import XCTest
@testable import WhoAmI

final class BaseServiceTests: XCTestCase {
    var sut: BaseService!
    var mockSupabase: MockSupabaseClient!
    
    override func setUp() {
        super.setUp()
        mockSupabase = MockSupabaseClient()
        sut = BaseService(supabase: mockSupabase)
    }
    
    override func tearDown() {
        sut = nil
        mockSupabase = nil
        super.tearDown()
    }
    
    func testSelectOneSuccess() async throws {
        // Given
        struct TestModel: Codable {
            let id: Int
            let name: String
        }
        
        let expectedModel = TestModel(id: 1, name: "Test")
        let mockPostgrest = MockPostgrestClient()
        mockPostgrest.mockResponse = expectedModel
        
        // When
        let result: TestModel = try await sut.selectOne(from: "test_table", id: 1)
        
        // Then
        XCTAssertEqual(result.id, expectedModel.id)
        XCTAssertEqual(result.name, expectedModel.name)
    }
    
    func testSelectOneFailure() async {
        // Given
        struct TestModel: Codable {
            let id: Int
            let name: String
        }
        
        let mockPostgrest = MockPostgrestClient()
        mockPostgrest.mockError = ServiceError.notFound
        
        // When/Then
        do {
            let _: TestModel = try await sut.selectOne(from: "test_table", id: 999)
            XCTFail("Expected selectOne to fail")
        } catch {
            XCTAssertTrue(error is ServiceError)
            XCTAssertEqual(error as? ServiceError, .notFound)
        }
    }
    
    func testInsertSuccess() async throws {
        // Given
        struct TestModel: Codable {
            let id: Int
            let name: String
        }
        
        let modelToInsert = TestModel(id: 1, name: "Test")
        let mockPostgrest = MockPostgrestClient()
        mockPostgrest.mockResponse = modelToInsert
        
        // When
        let result: TestModel = try await sut.insert(into: "test_table", value: modelToInsert)
        
        // Then
        XCTAssertEqual(result.id, modelToInsert.id)
        XCTAssertEqual(result.name, modelToInsert.name)
    }
    
    func testInsertFailure() async {
        // Given
        struct TestModel: Codable {
            let id: Int
            let name: String
        }
        
        let modelToInsert = TestModel(id: 1, name: "Test")
        let mockPostgrest = MockPostgrestClient()
        mockPostgrest.mockError = ServiceError.invalidData
        
        // When/Then
        do {
            let _: TestModel = try await sut.insert(into: "test_table", value: modelToInsert)
            XCTFail("Expected insert to fail")
        } catch {
            XCTAssertTrue(error is ServiceError)
            XCTAssertEqual(error as? ServiceError, .invalidData)
        }
    }
    
    func testUpdateSuccess() async throws {
        // Given
        struct TestModel: Codable {
            let id: Int
            let name: String
        }
        
        let modelToUpdate = TestModel(id: 1, name: "Updated")
        let mockPostgrest = MockPostgrestClient()
        mockPostgrest.mockResponse = modelToUpdate
        
        // When
        let result: TestModel = try await sut.update(in: "test_table", id: 1, value: modelToUpdate)
        
        // Then
        XCTAssertEqual(result.id, modelToUpdate.id)
        XCTAssertEqual(result.name, modelToUpdate.name)
    }
    
    func testUpdateFailure() async {
        // Given
        struct TestModel: Codable {
            let id: Int
            let name: String
        }
        
        let modelToUpdate = TestModel(id: 1, name: "Updated")
        let mockPostgrest = MockPostgrestClient()
        mockPostgrest.mockError = ServiceError.notFound
        
        // When/Then
        do {
            let _: TestModel = try await sut.update(in: "test_table", id: 999, value: modelToUpdate)
            XCTFail("Expected update to fail")
        } catch {
            XCTAssertTrue(error is ServiceError)
            XCTAssertEqual(error as? ServiceError, .notFound)
        }
    }
    
    func testDeleteSuccess() async throws {
        // Given
        let mockPostgrest = MockPostgrestClient()
        
        // When/Then
        XCTAssertNoThrow(try await sut.delete(from: "test_table", id: 1))
    }
    
    func testDeleteFailure() async {
        // Given
        let mockPostgrest = MockPostgrestClient()
        mockPostgrest.mockError = ServiceError.notFound
        
        // When/Then
        do {
            try await sut.delete(from: "test_table", id: 999)
            XCTFail("Expected delete to fail")
        } catch {
            XCTAssertTrue(error is ServiceError)
            XCTAssertEqual(error as? ServiceError, .notFound)
        }
    }
} 