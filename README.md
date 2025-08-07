# MatchMe - iOS Dating App

A unique iOS dating application that uses challenge-based competitions and location matching to connect users. Built with Swift and UIKit using the MVC architecture.

## 🎯 Key Features

### Group Matching System
- Select 3 profiles to compete in challenges
- Users compete for a chance to match
- Winner gets exclusive match with selector

### Challenge-Based Interactions
- Create hypothetical scenarios, puzzles, or questions
- Score responses from 1-10
- Multiple challenge types supported

### Media Support
- Record and send video messages
- Audio message recording
- Photo capture and sharing
- Integrated camera and microphone access

### Location-Based Discovery
- Matches users who visited same locations
- Save favorite meeting spots
- Track visited locations for better matching

### Post-Date Rating
- Rate your dates from 1-10
- Track high-performing users (7+ ratings)
- Build reputation through positive feedback

## 📱 Screenshots

### Main Features
- **Discover**: Swipe through profiles with scoring display
- **Group Match**: Select 3 profiles for challenge competition  
- **Challenges**: Create and respond to various challenge types
- **Chat**: Send text, photos, videos, and audio messages
- **Profile**: View scores and high ratings

## 🛠 Technical Stack

- **Language**: Swift 5.0
- **UI Framework**: UIKit (Programmatic)
- **Architecture**: MVC
- **Minimum iOS**: 14.0
- **Dependencies**: None (Pure Swift)

## 📦 Installation

1. Clone the repository:
```bash
git clone https://github.com/amg8tr/Rolex.git
cd Rolex
```

2. Open in Xcode:
```bash
open MatchMe.xcodeproj
```

3. Select your development team in project settings

4. Build and run (⌘R)

## 🏗 Project Structure

```
MatchMe/
├── Controllers/
│   ├── MainTabBarController.swift      # Root navigation
│   ├── DiscoverViewController.swift    # Swipe cards
│   ├── GroupMatchViewController.swift  # 3-profile selection
│   ├── GroupChallengeViewController.swift # Challenge competition
│   ├── MatchesViewController.swift     # Active matches
│   ├── ChatDetailViewController.swift  # Messaging
│   ├── MediaCaptureViewController.swift # Media recording
│   ├── DateScoreViewController.swift   # Date rating
│   └── ProfileViewController.swift     # User profile
├── Models/
│   ├── User.swift                      # User data model
│   ├── Match.swift                     # Match & chat models
│   ├── Challenge.swift                 # Challenge system
│   └── DataManager.swift               # Singleton data manager
├── Views/
│   ├── UserCardView.swift              # Swipeable cards
│   ├── MatchTableViewCell.swift        # Match list cells
│   └── ChatMessageCell.swift           # Chat bubbles
└── Info.plist                          # App permissions
```

## 🎮 How It Works

### For Users
1. **Create Profile**: Set up name, age, bio, and gender
2. **Discover Mode**: 
   - Swipe right to like
   - Swipe left to pass
   - Swipe up for super like
   - Tap "Group Match" for competition mode
3. **Group Match Mode**:
   - Select 3 profiles you're interested in
   - Create a challenge for them
   - Score their responses
   - Highest scorer wins exclusive match
4. **Chat & Connect**: Message matches with text, photos, videos, or audio
5. **Rate Dates**: After meeting, rate each other 1-10

### Scoring System
- **User Score**: Average rating from dates (1-10 scale)
- **High Scores**: Count of 7+ ratings received
- **Badge System**: Visual indicators for high performers (5+ high scores)

## 🔑 Permissions Required

The app requires the following permissions:
- **Camera**: For photo/video capture
- **Microphone**: For audio messages
- **Location**: For location-based matching
- **Photo Library**: For media selection (optional)

## 🚀 Features Overview

### Implemented
- ✅ Group matching (3 profiles at once)
- ✅ Challenge creation and scoring
- ✅ Media recording (photo/video/audio)
- ✅ Real-time chat with multimedia
- ✅ Location-based discovery
- ✅ Post-date rating system
- ✅ User scores and badges
- ✅ Swipe gestures with animations
- ✅ Filter by age and gender

### Coming Soon
- 🔄 Backend integration
- 🔄 Push notifications
- 🔄 Real photo uploads
- 🔄 Video calling
- 🔄 Premium features

## 💻 Development

### Requirements
- Xcode 14.0+
- iOS 14.0+
- Swift 5.0+

### Build & Run
1. Open `MatchMe.xcodeproj` in Xcode
2. Select a simulator or device
3. Press ⌘R to build and run

### Testing
The app includes mock data for testing:
- 25+ sample user profiles
- Pre-configured locations
- Sample matches and conversations

## 📄 License

This project is proprietary software. All rights reserved.

## 🤝 Contributing

Please contact the repository owner for contribution guidelines.

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

Built with ❤️ using Swift and UIKit