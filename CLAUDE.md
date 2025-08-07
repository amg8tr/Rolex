# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MatchMe is an iOS dating application built with Swift using the MVC architecture pattern. The app features a unique challenge-based matching system where users compete in challenges to win matches with potential partners.

## Project Structure

```
MatchMe/
├── MatchMe.xcodeproj/       # Xcode project configuration
└── MatchMe/MatchMe/
    ├── Controllers/         # View Controllers managing UI and user interaction
    ├── Models/             # Data models and business logic
    ├── Views/              # Custom UI views and cells
    ├── AppDelegate.swift
    ├── SceneDelegate.swift
    └── Info.plist
```

## Development Commands

### Building & Running
```bash
# Open project in Xcode (from project root)
open -a Xcode MatchMe.xcodeproj

# Alternative: open workspace if it exists
open -a Xcode MatchMe.xcworkspace

# Build via command line
xcodebuild -project MatchMe.xcodeproj -scheme MatchMe -configuration Debug build

# In Xcode:
# Build: Cmd+B
# Run: Cmd+R
# Clean: Cmd+Shift+K
# Stop: Cmd+.
```

### Project Settings
- **iOS Deployment Target**: 14.0
- **Swift Version**: 5.0
- **Interface**: Programmatic UI (no storyboards except LaunchScreen)
- **Supported Orientations**: Portrait only (iPhone), all orientations (iPad)

## Architecture & Key Components

### Central Data Management
**DataManager.swift** - Singleton managing all app state:
- `DataManager.shared` - Global instance
- `@Published` properties for reactive updates
- Methods: `getUsersWithSharedLocations()`, `createChallenge()`, `scoreResponse()`, `createMatch()`
- Location services via CLLocationManager delegate

### Navigation Flow
**MainTabBarController** - Root navigation with 4 tabs:
1. **DiscoverViewController** - Swipe cards for user discovery
2. **MatchesViewController** - Active matches and challenge management  
3. **ChatViewController** - Chat list and conversations
4. **ProfileViewController** - User profile and settings

Each tab wrapped in UINavigationController for push navigation.

### Data Models
- **User**: `id`, `name`, `age`, `bio`, `gender`, `visitedLocations`, `savedLocations`, `score`, `highScores`
- **Challenge**: `id`, `title`, `description`, `type` (enum), `createdBy`, `responses`
- **Match**: `id`, `users` array, `challenge`, `timestamp`, `isActive`
- **ChatMessage**: `id`, `matchId`, `senderId`, `text`, `messageType` (text/photo/video/audio), `mediaURL`, `timestamp`

### UI Patterns
All views use programmatic Auto Layout with consistent patterns:
- Lazy var properties for UI components
- `setupUI()` method for view hierarchy
- `setupConstraints()` method for Auto Layout
- Delegation pattern for user interactions (e.g., `UserCardViewDelegate`)

## Key Method Signatures

### DataManager Core Methods
```swift
// User Management
func createUser(name: String, age: Int, bio: String, gender: User.Gender) -> User
func getUsersWithSharedLocations() -> [User]
func filterUsers(by gender: User.Gender?, minAge: Int?, maxAge: Int?) -> [User]

// Challenge Management  
func createChallenge(title: String, description: String, type: Challenge.ChallengeType) -> Challenge
func addResponse(to challengeId: String, response: String, mediaURL: String?) -> ChallengeResponse
func scoreResponse(_ responseId: String, score: Int)

// Match Management
func createMatch(with users: [User], challenge: Challenge) -> Match
func getMatches(for userId: String) -> [Match]

// Chat Management
func sendMessage(text: String, to matchId: String, type: MessageType, mediaURL: String?)
func getMessages(for matchId: String) -> [ChatMessage]
```

## Permissions Configuration

Info.plist contains required usage descriptions:
- `NSCameraUsageDescription` - Camera access for photos/videos
- `NSMicrophoneUsageDescription` - Microphone for audio messages
- `NSLocationWhenInUseUsageDescription` - Location tracking for matching
- `NSLocationAlwaysAndWhenInUseUsageDescription` - Background location updates

## Important Implementation Details

### Location-Based Matching Logic
Users only see profiles who visited same locations:
- Tracked via `User.visitedLocations` array
- Filtered in `DataManager.getUsersWithSharedLocations()`
- Uses Set intersection for efficient matching

### Challenge Response Scoring
- Responses scored 1-10 by other users
- Scores stored in `ChallengeResponse.scores` dictionary
- Average score calculated for winner determination
- High scores (7+) tracked in `User.highScores`

### View Controller Lifecycle
All controllers follow pattern:
1. `viewDidLoad()` - Initial setup
2. `setupNavigationBar()` - Navigation configuration
3. `setupUI()` - Build view hierarchy
4. `setupConstraints()` - Auto Layout
5. `loadData()` - Fetch from DataManager

### Mock Data
Currently uses mock data via `DataManager.loadMockData()`. No backend integration yet.

## Code Style Conventions

- Use `UIColor.systemPink` as primary accent color
- Follow existing lazy var pattern for UI components
- Use `translatesAutoresizingMaskIntoConstraints = false` for all programmatic views
- Delegate protocols named as `<ClassName>Delegate`
- All data operations through `DataManager.shared`