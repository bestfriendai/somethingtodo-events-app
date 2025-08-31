# SomethingToDo - Event Discovery App 🎉

A comprehensive Flutter application for discovering and planning events with AI-powered chat features and real-time interactions.

## Features ✨

### 🔍 Event Discovery
- Browse events by category, location, and date
- Advanced search with filters (price, distance, time)
- Featured events and personalized recommendations
- Interactive map view with event clustering
- Real-time event updates

### 🤖 AI Chat Assistant
- Natural language event search and recommendations
- Personalized suggestions based on user preferences
- Event planning assistance and itinerary creation
- Multi-session chat history

### 👤 User Management
- Email/password authentication
- Google Sign-In integration
- Phone number verification
- User profiles with preferences and interests
- Premium subscription tiers

### 📍 Location Services
- Real-time location tracking
- Nearby events discovery
- Distance calculations and routing
- Geocoding and reverse geocoding

### 🔔 Smart Notifications
- Push notifications for nearby events
- Personalized event recommendations
- Category-based notification topics
- Local notification scheduling

### 💳 Premium Features
- Advanced filtering options
- Priority customer support
- Exclusive event access
- Enhanced AI chat capabilities

## Tech Stack 🛠️

### Frontend
- **Flutter** - Cross-platform mobile development
- **Provider** - State management
- **Riverpod** - Advanced state management
- **Freezed** - Immutable data classes
- **Flutter Animate** - Smooth animations

### Backend Services
- **Firebase Auth** - Authentication
- **Cloud Firestore** - Real-time database
- **Cloud Functions** - Serverless backend
- **Firebase Storage** - File storage
- **Firebase Analytics** - User analytics
- **Firebase Crashlytics** - Crash reporting

### AI & APIs
- **OpenAI GPT-4** - Chat assistant
- **Google Maps API** - Location services
- **Stripe** - Payment processing

### Local Storage
- **Hive** - Offline data caching
- **Shared Preferences** - User settings

## Project Structure 📁

```
lib/
├── config/           # App configuration and themes
├── models/           # Data models with Freezed
├── services/         # Business logic and API services
├── providers/        # State management providers
├── screens/          # UI screens and pages
├── widgets/          # Reusable UI components
├── utils/            # Helper functions and utilities
└── main.dart         # App entry point

functions/            # Firebase Cloud Functions
├── src/              # TypeScript source code
└── package.json      # Node.js dependencies

assets/
├── images/           # App images and icons
├── icons/            # Custom icons
└── animations/       # Lottie animations
```

## Setup Instructions 🚀

### Prerequisites
- Flutter SDK (3.8.0+)
- Firebase CLI
- Node.js (18+) for Cloud Functions
- OpenAI API key
- Google Maps API key
- Stripe keys

### 1. Clone and Install Dependencies
```bash
flutter pub get
```

### 2. Generate Model Files
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 3. Environment Configuration
Set up your environment variables for:
- OPENAI_API_KEY
- GOOGLE_MAPS_API_KEY
- STRIPE_PUBLISHABLE_KEY

### 4. Firebase Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Deploy Firestore rules and indexes
firebase deploy --only firestore
```

### 5. Deploy Cloud Functions
```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

### 6. Run the App
```bash
flutter run
```

## Key Features Implementation 🔧

### Authentication Flow
```dart
// Email/Password, Google, Phone authentication
final authProvider = Provider.of<AuthProvider>(context);
await authProvider.signInWithEmailPassword(email, password);
```

### Event Discovery
```dart
// Search events with filters
final eventsProvider = Provider.of<EventsProvider>(context);
await eventsProvider.searchEvents(
  query: 'music concert',
  category: EventCategory.music,
  latitude: userLat,
  longitude: userLng,
);
```

### AI Chat Integration
```dart
// Send message to AI assistant
final chatProvider = Provider.of<ChatProvider>(context);
await chatProvider.sendMessage(content: 'Find jazz concerts this weekend');
```

### Real-time Location
```dart
// Get user location
final locationService = LocationService();
final position = await locationService.getCurrentPosition();
```

## Security & Permissions 🔒

### Firestore Security Rules
- User data isolation
- Role-based access control
- Input validation
- Rate limiting

### Required Permissions
- Location access
- Camera (for profile photos)
- Notifications
- Storage access

## Performance Optimizations ⚡

- **Image Caching** - Network images cached locally
- **Pagination** - Lazy loading for event lists
- **Offline Support** - Hive database for offline access
- **State Management** - Efficient provider updates
- **Memory Management** - Proper disposal of resources

## Analytics & Monitoring 📊

### Tracked Events
- User engagement
- Event views and favorites
- Search queries
- Chat interactions
- Premium conversions

### Performance Metrics
- App launch time
- Screen load times
- API response times
- Crash rates

## Deployment 🚀

### Android Release Build
```bash
flutter build appbundle --release
```

### iOS Release Build
```bash
flutter build ipa --release
```

### Firebase Hosting (Web)
```bash
flutter build web
firebase deploy --only hosting
```

## Testing 🧪

### Unit Tests
```bash
flutter test
```

### Firebase Emulator Testing
```bash
firebase emulators:start
```

---

**Built with ❤️ using Flutter and Firebase**
