# Match Me - iOS Dating App

A complete, fully functional iOS dating application built with Swift using the MVC (Model-View-Controller) architecture pattern. The app allows users to compete in challenges to win matches and connect with potential partners.

## Features

### Core Functionality
- **User Profiles**: Create and manage profiles with photos, names, ages, and bios
- **Location-Based Matching**: Find users who have visited the same locations
- **Challenge System**: Create and participate in various types of challenges
- **Group Chat**: Communicate with matched users through text, photos, videos, and audio
- **Scoring System**: Rate responses and get rated by other users
- **Filtering**: Filter potential matches by gender and age

### Technical Features
- **Camera & Microphone Access**: For video, photo, and audio sharing
- **Location Services**: Track visited and saved locations
- **Real-time Chat**: Send and receive messages with media support
- **Modern UI**: Beautiful, responsive interface with smooth animations
- **Data Persistence**: Local data management with mock data

## Architecture

The app follows the MVC (Model-View-Controller) architecture pattern:

### Models
- `User`: User profiles with scores and location data
- `Location`: Geographic locations with coordinates
- `Challenge`: Various types of challenges (hypothetical, puzzle, activity, question)
- `Match`: Matches between users with associated challenges
- `ChatMessage`: Messages in group chats with media support
- `DataManager`: Central data management and business logic

### Views
- `UserCardView`: Profile cards for swiping interface
- `ChatMessageCell`: Individual chat message display
- `MatchTableViewCell`: Match list items
- `LocationTableViewCell`: Location list items
- `ChallengeResponseCell`: Challenge response display

### Controllers
- `MainTabBarController`: Main navigation structure
- `DiscoverViewController`: User discovery and swiping
- `MatchesViewController`: Active matches and challenge creation
- `ChatViewController`: Chat list and conversations
- `ProfileViewController`: User profile management
- `OnboardingViewController`: New user registration
- `ChallengeDetailViewController`: Challenge participation
- `LocationsViewController`: Location management
- `SettingsViewController`: App settings and configuration

## Key Features Implementation

### 1. Location-Based Matching
- Users can only see profiles of people who have visited the same locations
- Automatic location tracking and storage
- Ability to save favorite locations

### 2. Challenge System
- Four challenge types: Hypothetical, Puzzle, Activity, Question
- Users can create challenges for their matches
- Response scoring system (1-10 scale)
- Challenge history and response tracking

### 3. Chat System
- Group chat functionality for matched users
- Support for text, photos, videos, and audio messages
- Real-time message display with timestamps
- Media sharing capabilities

### 4. Scoring System
- Users are scored based on their challenge responses
- High score tracking (7+ ratings)
- Profile visibility of scores and rankings
- Post-date rating system

### 5. User Interface
- Modern, clean design with pink accent color
- Smooth animations and transitions
- Responsive layout for different screen sizes
- Intuitive navigation with tab bar

## Permissions Required

The app requires the following permissions:
- **Camera**: For taking photos and videos
- **Microphone**: For recording audio messages
- **Location**: For location-based matching

## Installation

1. Open the project in Xcode
2. Set your development team in project settings
3. Build and run on iOS device or simulator

## Usage

### First Time Setup
1. Launch the app
2. Complete the onboarding process
3. Grant necessary permissions (camera, microphone, location)
4. Create your profile with name, age, bio, and gender

### Discovering Matches
1. Navigate to the "Discover" tab
2. Swipe right to like, left to pass
3. Use the filter button to adjust preferences
4. When you match, you'll be notified

### Creating Challenges
1. Go to "Matches" tab
2. Select an active match
3. Tap "Challenge" button
4. Choose challenge type and create

### Chatting
1. Navigate to "Chat" tab
2. Select a conversation
3. Send text messages or media
4. Participate in challenges together

### Managing Profile
1. Go to "Profile" tab
2. Edit your information
3. Manage your locations
4. Access settings

## Technical Details

### Dependencies
- UIKit for UI components
- CoreLocation for location services
- AVFoundation for camera and microphone access
- Foundation for data structures

### Data Management
- Singleton pattern for DataManager
- ObservableObject for reactive updates
- Mock data for demonstration
- Local storage for user preferences

### UI Components
- Programmatic UI with Auto Layout
- Custom table view cells
- Animated transitions
- Modern iOS design patterns

## Future Enhancements

- Backend integration for real user data
- Push notifications
- Advanced filtering options
- Video calling features
- Social media integration
- Enhanced security features

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+

## License

This project is for educational and demonstration purposes.

## Support

For questions or issues, please refer to the code comments and documentation within the project. 