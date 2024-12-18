import Foundation
import Supabase

extension SupabaseClient {
    func database(_ table: String) async -> PostgrestQueryBuilder {
        return await self.database.from(table)
    }
    
    func from(_ table: String) async -> PostgrestQueryBuilder {
        return await self.database.from(table)
    }
}

class BaseService {
    let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    // Helper method to handle database errors
    func handleDatabaseError(_ error: Error) -> Error {
        print("Database error: \(error)")
        if let postgrestError = error as? PostgrestError {
            let message = String(describing: postgrestError)
            return NSError(domain: "DatabaseError", code: 1001, userInfo: [
                NSLocalizedDescriptionKey: "Database error: \(message)"
            ])
        }
        return error
    }
    
    // Helper method to format dates for database
    func formatDate(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
    
    // Helper method to parse dates from database
    func parseDate(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string)
    }
    
    // Helper method to convert values to strings for database
    func toString(_ value: Any?) -> String? {
        guard let value = value else { return nil }
        return String(describing: value)
    }
}
