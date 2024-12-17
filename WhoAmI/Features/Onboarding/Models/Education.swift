import Foundation

enum Education: String, Codable, CaseIterable {
    case secondaryGeneral = "secondary_general"
    case secondaryVocational = "secondary_vocational"
    case incompleteHigher = "incomplete_higher"
    case bachelors = "bachelors"
    case masters = "masters"
    case doctoral = "doctoral"
    
    var displayText: String {
        switch self {
        case .secondaryGeneral: return "Secondary General"
        case .secondaryVocational: return "Secondary Vocational"
        case .incompleteHigher: return "Incomplete Higher"
        case .bachelors: return "Bachelor's Degree"
        case .masters: return "Master's Degree"
        case .doctoral: return "Doctoral"
        }
    }
} 