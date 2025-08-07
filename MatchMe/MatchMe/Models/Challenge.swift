import Foundation

struct Challenge: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let type: ChallengeType
    let createdBy: String // User ID
    let createdAt: Date
    var responses: [ChallengeResponse]
    
    enum ChallengeType: String, Codable, CaseIterable {
        case hypothetical = "hypothetical"
        case puzzle = "puzzle"
        case activity = "activity"
        case question = "question"
        
        var displayName: String {
            switch self {
            case .hypothetical: return "Hypothetical"
            case .puzzle: return "Puzzle"
            case .activity: return "Activity"
            case .question: return "Question"
            }
        }
    }
    
    init(id: String = UUID().uuidString, title: String, description: String, type: ChallengeType, createdBy: String) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.createdBy = createdBy
        self.createdAt = Date()
        self.responses = []
    }
}

struct ChallengeResponse: Codable, Identifiable {
    let id: String
    let challengeId: String
    let userId: String
    let response: String
    let mediaURL: String? // For video/audio responses
    var score: Int? // Score given by the challenger (1-10)
    let respondedAt: Date
    
    init(id: String = UUID().uuidString, challengeId: String, userId: String, response: String, mediaURL: String? = nil) {
        self.id = id
        self.challengeId = challengeId
        self.userId = userId
        self.response = response
        self.mediaURL = mediaURL
        self.score = nil
        self.respondedAt = Date()
    }
} 