import Foundation
import CoreLocation

class DataManager: NSObject, ObservableObject {
    static let shared = DataManager()
    
    @Published var currentUser: User?
    @Published var availableUsers: [User] = []
    @Published var matches: [Match] = []
    @Published var challenges: [Challenge] = []
    @Published var chatMessages: [ChatMessage] = []
    @Published var userLocation: CLLocation?
    
    private let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
        setupLocationManager()
        loadMockData()
    }
    
    // MARK: - Location Management
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - User Management
    
    func createUser(name: String, age: Int, bio: String, gender: User.Gender) -> User {
        let user = User(name: name, age: age, bio: bio, gender: gender)
        currentUser = user
        return user
    }
    
    func updateUserProfile(_ user: User) {
        currentUser = user
    }
    
    func getUsersWithSharedLocations() -> [User] {
        guard let currentUser = currentUser else { return [] }
        
        return availableUsers.filter { user in
            // Filter by shared locations
            let sharedLocations = Set(currentUser.visitedLocations.map { $0.id })
            let userLocations = Set(user.visitedLocations.map { $0.id })
            return !sharedLocations.intersection(userLocations).isEmpty
        }
    }
    
    func filterUsers(by gender: User.Gender? = nil, minAge: Int? = nil, maxAge: Int? = nil) -> [User] {
        var filteredUsers = getUsersWithSharedLocations()
        
        if let gender = gender {
            filteredUsers = filteredUsers.filter { $0.gender == gender }
        }
        
        if let minAge = minAge {
            filteredUsers = filteredUsers.filter { $0.age >= minAge }
        }
        
        if let maxAge = maxAge {
            filteredUsers = filteredUsers.filter { $0.age <= maxAge }
        }
        
        return filteredUsers
    }
    
    // MARK: - Challenge Management
    
    func createChallenge(title: String, description: String, type: Challenge.ChallengeType) -> Challenge {
        guard let currentUser = currentUser else {
            fatalError("No current user")
        }
        
        let challenge = Challenge(title: title, description: description, type: type, createdBy: currentUser.id)
        challenges.append(challenge)
        return challenge
    }
    
    func addResponse(to challengeId: String, response: String, mediaURL: String? = nil) -> ChallengeResponse {
        guard let currentUser = currentUser else {
            fatalError("No current user")
        }
        
        let challengeResponse = ChallengeResponse(challengeId: challengeId, userId: currentUser.id, response: response, mediaURL: mediaURL)
        
        if let index = challenges.firstIndex(where: { $0.id == challengeId }) {
            challenges[index].responses.append(challengeResponse)
        }
        
        return challengeResponse
    }
    
    func scoreResponse(_ response: ChallengeResponse, score: Int) {
        guard let challengeIndex = challenges.firstIndex(where: { $0.id == response.challengeId }),
              let responseIndex = challenges[challengeIndex].responses.firstIndex(where: { $0.id == response.id }) else {
            return
        }
        
        challenges[challengeIndex].responses[responseIndex].score = max(1, min(10, score))
    }
    
    // MARK: - Match Management
    
    func createMatch(participants: [String], challengeId: String) -> Match {
        let match = Match(participants: participants, challengeId: challengeId)
        matches.append(match)
        return match
    }
    
    func createGroupMatch(selectedUsers: [User], challengeId: String) -> Match {
        var participants = selectedUsers.map { $0.id }
        if let currentUserId = currentUser?.id {
            participants.insert(currentUserId, at: 0)
        }
        return createMatch(participants: participants, challengeId: challengeId)
    }
    
    func getActiveMatches() -> [Match] {
        return matches.filter { $0.isActive }
    }
    
    func getGroupMatches() -> [Match] {
        return matches.filter { $0.participants.count > 2 && $0.isActive }
    }
    
    func endMatch(_ matchId: String, winnerId: String) {
        if let index = matches.firstIndex(where: { $0.id == matchId }) {
            matches[index].isActive = false
            matches[index].winnerId = winnerId
            
            // If this was a group match, create a final 1-on-1 match with the winner
            if matches[index].participants.count > 2 {
                let finalParticipants = [currentUser?.id ?? "", winnerId]
                let finalChallenge = createChallenge(
                    title: "Congratulations on winning!",
                    description: "You've won the challenge! Let's get to know each other better.",
                    type: .question
                )
                _ = createMatch(participants: finalParticipants, challengeId: finalChallenge.id)
            }
        }
    }
    
    // MARK: - Chat Management
    
    func sendMessage(to matchId: String, message: String, messageType: ChatMessage.MessageType = .text, mediaURL: String? = nil) -> ChatMessage {
        guard let currentUser = currentUser else {
            fatalError("No current user")
        }
        
        let chatMessage = ChatMessage(matchId: matchId, senderId: currentUser.id, message: message, messageType: messageType, mediaURL: mediaURL)
        chatMessages.append(chatMessage)
        return chatMessage
    }
    
    func getMessages(for matchId: String) -> [ChatMessage] {
        return chatMessages.filter { $0.matchId == matchId }.sorted { $0.timestamp < $1.timestamp }
    }
    
    // MARK: - Location Management
    
    func addVisitedLocation(_ location: Location) {
        guard var currentUser = currentUser else { return }
        currentUser.visitedLocations.append(location)
        self.currentUser = currentUser
    }
    
    func addSavedLocation(_ location: Location) {
        guard var currentUser = currentUser else { return }
        currentUser.savedLocations.append(location)
        self.currentUser = currentUser
    }
    
    // MARK: - Date Scoring
    
    func scoreDate(fromUserId: String, toUserId: String, score: Int, comment: String? = nil) {
        let dateScore = DateScore(fromUserId: fromUserId, toUserId: toUserId, score: score, comment: comment)
        
        // Update the target user's score
        if let userIndex = availableUsers.firstIndex(where: { $0.id == toUserId }) {
            availableUsers[userIndex].score = (availableUsers[userIndex].score + Double(score)) / 2.0
            
            if score >= 7 {
                availableUsers[userIndex].highScoreCount += 1
            }
        }
    }
    
    // MARK: - Mock Data
    
    private func loadMockData() {
        // Create a default current user if none exists
        if currentUser == nil {
            currentUser = User(name: "You", age: 25, bio: "Looking for meaningful connections!", gender: .male)
        }
        
        // Create extensive mock users
        var mockUsers = [
            User(name: "Sarah", age: 25, bio: "Love hiking and coffee ☕️ Weekend adventures are my thing!", gender: .female),
            User(name: "Mike", age: 28, bio: "Tech enthusiast and foodie 🍕 Always looking for the next great restaurant", gender: .male),
            User(name: "Emma", age: 23, bio: "Artist and traveler ✈️ 20 countries and counting!", gender: .female),
            User(name: "Alex", age: 27, bio: "Fitness coach and dog lover 🐕 Early morning runs keep me sane", gender: .male),
            User(name: "Jessica", age: 26, bio: "Bookworm and yoga instructor 🧘‍♀️ Currently reading Murakami", gender: .female),
            User(name: "David", age: 29, bio: "Photographer 📸 Capturing moments and making memories", gender: .male),
            User(name: "Olivia", age: 24, bio: "Medical student by day, salsa dancer by night 💃", gender: .female),
            User(name: "James", age: 31, bio: "Chef and wine enthusiast 🍷 Let me cook for you!", gender: .male),
            User(name: "Sophia", age: 22, bio: "Environmental activist 🌱 Making the world a better place", gender: .female),
            User(name: "Daniel", age: 30, bio: "Startup founder 💡 Building the future of AI", gender: .male),
            User(name: "Isabella", age: 27, bio: "Musician and songwriter 🎸 Jazz is my passion", gender: .female),
            User(name: "William", age: 26, bio: "Rock climber and adventurer 🧗‍♂️ Seeking new heights", gender: .male),
            User(name: "Ava", age: 25, bio: "Fashion designer ✨ Creating sustainable fashion", gender: .female),
            User(name: "Lucas", age: 28, bio: "Marine biologist 🐠 Protecting our oceans", gender: .male),
            User(name: "Mia", age: 24, bio: "Dancer and choreographer 🩰 Movement is my language", gender: .female),
            User(name: "Ethan", age: 29, bio: "Game developer 🎮 Creating worlds, one pixel at a time", gender: .male),
            User(name: "Charlotte", age: 23, bio: "Veterinarian in training 🐾 Animals are my life", gender: .female),
            User(name: "Noah", age: 32, bio: "Architect 🏗️ Designing spaces that inspire", gender: .male),
            User(name: "Amelia", age: 26, bio: "Pilot ✈️ Sky is not the limit, it's home", gender: .female),
            User(name: "Mason", age: 27, bio: "Stand-up comedian 🎤 Making people laugh is my superpower", gender: .male),
            User(name: "Harper", age: 25, bio: "Data scientist 📊 Finding patterns in chaos", gender: .female),
            User(name: "Logan", age: 30, bio: "Personal trainer 💪 Your fitness journey starts here", gender: .male),
            User(name: "Ella", age: 24, bio: "Interior designer 🏡 Creating beautiful spaces", gender: .female),
            User(name: "Jackson", age: 28, bio: "Bartender and mixologist 🍸 Crafting the perfect drink", gender: .male),
            User(name: "Lily", age: 22, bio: "Psychology student 🧠 Understanding the human mind", gender: .female)
        ]
        
        // Randomize scores and high scores for variety
        for i in 0..<mockUsers.count {
            mockUsers[i].score = Double.random(in: 3.0...5.0)
            mockUsers[i].highScoreCount = Int.random(in: 0...15)
        }
        
        availableUsers = mockUsers
        
        // Create more diverse mock locations
        let mockLocations = [
            Location(name: "Central Park", latitude: 40.7829, longitude: -73.9654),
            Location(name: "Times Square", latitude: 40.7580, longitude: -73.9855),
            Location(name: "Brooklyn Bridge", latitude: 40.7061, longitude: -73.9969),
            Location(name: "Starbucks Downtown", latitude: 40.7589, longitude: -73.9851),
            Location(name: "LA Fitness", latitude: 40.7614, longitude: -73.9776),
            Location(name: "Whole Foods Market", latitude: 40.7697, longitude: -73.9735),
            Location(name: "Museum of Modern Art", latitude: 40.7614, longitude: -73.9776),
            Location(name: "Madison Square Garden", latitude: 40.7505, longitude: -73.9934),
            Location(name: "High Line Park", latitude: 40.7480, longitude: -74.0048),
            Location(name: "Chelsea Market", latitude: 40.7424, longitude: -74.0061)
        ]
        
        // Add multiple locations to users for better matching
        for i in 0..<availableUsers.count {
            let numLocations = Int.random(in: 2...4)
            var userLocations: [Location] = []
            for _ in 0..<numLocations {
                let randomLocation = mockLocations.randomElement()!
                if !userLocations.contains(where: { $0.id == randomLocation.id }) {
                    userLocations.append(randomLocation)
                }
            }
            availableUsers[i].visitedLocations = userLocations
            
            // Add some saved locations too
            if Bool.random() {
                availableUsers[i].savedLocations = Array(userLocations.prefix(2))
            }
        }
        
        // Create some mock matches and conversations
        createMockMatches()
    }
    
    private func createMockMatches() {
        // Create a few mock matches with challenges
        if availableUsers.count >= 5 {
            // Match 1
            let challenge1 = createChallenge(
                title: "Desert Island Question",
                description: "If you were stuck on a desert island, what 3 items would you bring?",
                type: .hypothetical
            )
            let match1 = createMatch(
                participants: [currentUser?.id ?? "user", availableUsers[0].id],
                challengeId: challenge1.id
            )
            
            // Add some messages
            _ = sendMessage(to: match1.id, message: "Hey! Great to match with you 😊", messageType: .text, mediaURL: nil)
            _ = sendMessage(to: match1.id, message: "Hi! Love your profile! How's your day going?", messageType: .text, mediaURL: nil)
            
            // Match 2
            let challenge2 = createChallenge(
                title: "Coffee or Tea?",
                description: "Are you a coffee person or a tea person? And what's your go-to order?",
                type: .question
            )
            let match2 = createMatch(
                participants: [currentUser?.id ?? "user", availableUsers[1].id],
                challengeId: challenge2.id
            )
            
            _ = sendMessage(to: match2.id, message: "Coffee all the way! ☕", messageType: .text, mediaURL: nil)
            
            // Match 3 with more messages
            let challenge3 = createChallenge(
                title: "Perfect Weekend",
                description: "Describe your perfect weekend",
                type: .activity
            )
            let match3 = createMatch(
                participants: [currentUser?.id ?? "user", availableUsers[2].id],
                challengeId: challenge3.id
            )
            
            _ = sendMessage(to: match3.id, message: "Matched! 🎉", messageType: .text, mediaURL: nil)
            _ = sendMessage(to: match3.id, message: "Your bio is amazing!", messageType: .text, mediaURL: nil)
            _ = sendMessage(to: match3.id, message: "Want to grab coffee sometime?", messageType: .text, mediaURL: nil)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension DataManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        
        // Add current location to visited locations
        let currentLocation = Location(
            name: "Current Location",
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        addVisitedLocation(currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
    }
} 