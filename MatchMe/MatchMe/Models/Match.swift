import Foundation

struct Match: Codable, Identifiable {
    let id: String
    let participants: [String] // Array of user IDs
    let challengeId: String
    let createdAt: Date
    var isActive: Bool
    var winnerId: String? // The user who won the challenge
    var dateScore: DateScore? // Score given after going on a date
    
    init(id: String = UUID().uuidString, participants: [String], challengeId: String) {
        self.id = id
        self.participants = participants
        self.challengeId = challengeId
        self.createdAt = Date()
        self.isActive = true
        self.winnerId = nil
        self.dateScore = nil
    }
}

struct DateScore: Codable {
    let fromUserId: String
    let toUserId: String
    let score: Int // 1-10 scale
    let comment: String?
    let scoredAt: Date
    
    init(fromUserId: String, toUserId: String, score: Int, comment: String? = nil) {
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.score = max(1, min(10, score)) // Ensure score is between 1-10
        self.comment = comment
        self.scoredAt = Date()
    }
}

struct ChatMessage: Codable, Identifiable {
    let id: String
    let matchId: String
    let senderId: String
    let message: String
    let messageType: MessageType
    let mediaURL: String? // For photos, videos, audio
    let timestamp: Date
    
    enum MessageType: String, Codable {
        case text = "text"
        case photo = "photo"
        case video = "video"
        case audio = "audio"
    }
    
    init(id: String = UUID().uuidString, matchId: String, senderId: String, message: String, messageType: MessageType = .text, mediaURL: String? = nil) {
        self.id = id
        self.matchId = matchId
        self.senderId = senderId
        self.message = message
        self.messageType = messageType
        self.mediaURL = mediaURL
        self.timestamp = Date()
    }
} 