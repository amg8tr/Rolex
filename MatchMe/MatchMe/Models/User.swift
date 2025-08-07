import Foundation
import CoreLocation

struct User: Codable, Identifiable {
    let id: String
    var name: String
    var age: Int
    var bio: String
    var profileImageURL: String?
    var gender: Gender
    var score: Double
    var highScoreCount: Int // Number of times scored 7 or higher
    var visitedLocations: [Location]
    var savedLocations: [Location]
    var matches: [String] // Array of user IDs
    var dateCreated: Date
    
    enum Gender: String, Codable, CaseIterable {
        case male = "male"
        case female = "female"
        case other = "other"
        
        var displayName: String {
            switch self {
            case .male: return "Male"
            case .female: return "Female"
            case .other: return "Other"
            }
        }
    }
    
    init(id: String = UUID().uuidString, name: String, age: Int, bio: String, gender: Gender) {
        self.id = id
        self.name = name
        self.age = age
        self.bio = bio
        self.gender = gender
        self.score = 0.0
        self.highScoreCount = 0
        self.visitedLocations = []
        self.savedLocations = []
        self.matches = []
        self.dateCreated = Date()
    }
}

struct Location: Codable, Identifiable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let address: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(id: String = UUID().uuidString, name: String, latitude: Double, longitude: Double, address: String? = nil) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
} 