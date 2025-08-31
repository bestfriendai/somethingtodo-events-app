# 🎉 SomethingToDo - Event Discovery App

A complete Flutter application for discovering local events with AI-powered recommendations, built with Firebase backend.

## 🚀 Features

### Core Features
- 📱 **Event Discovery**: Browse and search local events
- 🗺️ **Interactive Map**: View events on a map with clustering
- 🤖 **AI Chat Assistant**: Get personalized event recommendations
- ❤️ **Favorites System**: Save events for later
- 👤 **User Profiles**: Manage preferences and interests
- 💎 **Premium Features**: Advanced filters and early access
- 📲 **Push Notifications**: Never miss an event
- 🌙 **Dark Mode**: Beautiful light and dark themes

### Technical Features
- 🔥 **Firebase Integration**: Complete backend with Firestore, Auth, Functions
- 🔐 **Multiple Auth Methods**: Email, Google, Phone authentication
- 💳 **Stripe Payments**: Premium subscriptions
- 📱 **Cross-Platform**: iOS, Android, and Web support
- 🔄 **Offline Support**: Works without internet
- 📊 **Analytics**: Track user behavior and app performance

## 📦 Installation

### Prerequisites
- Flutter SDK (3.0+)
- Firebase CLI
- Xcode (for iOS)
- Android Studio (for Android)

### Setup Steps

1. **Clone the repository**
```bash
cd somethingtodo
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate code**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. **Configure Firebase**
```bash
flutterfire configure
```

5. **Run the app**
```bash
# iOS
flutter run -d iphone

# Android
flutter run -d android

# Web
flutter run -d chrome
```

## 🏗️ Project Structure

```
lib/
├── config/          # App configuration and themes
├── models/          # Data models (User, Event, Chat)
├── services/        # Firebase and API services
├── providers/       # State management
├── screens/         # UI screens
├── widgets/         # Reusable widgets
└── utils/          # Utility functions

functions/           # Firebase Cloud Functions
├── src/
│   └── index.ts    # Serverless functions
└── package.json
```

## 🔥 Firebase Configuration

The app uses the following Firebase services:
- **Authentication**: User sign-in/sign-up
- **Firestore**: Database for events and user data
- **Cloud Functions**: Backend logic and AI integration
- **Cloud Storage**: Image and file storage
- **Analytics**: User behavior tracking
- **Crashlytics**: Error reporting
- **Cloud Messaging**: Push notifications
- **Remote Config**: Feature flags

## 🎨 Customization

### Theme
Edit `lib/config/theme.dart` to customize:
- Colors
- Typography
- Component styles
- Light/Dark themes

### App Configuration
Edit `lib/config/app_config.dart` to change:
- API endpoints
- Feature flags
- Default settings

## 📱 Screens

1. **Splash Screen**: App loading with logo
2. **Onboarding**: 3-page introduction
3. **Authentication**: Login/Signup screens
4. **Home**: Event feed with categories
5. **Map View**: Interactive event map
6. **Event Details**: Full event information
7. **AI Chat**: Conversational event discovery
8. **Profile**: User settings and preferences
9. **Premium**: Subscription management

## 🧪 Testing

Run tests:
```bash
flutter test
```

Run with coverage:
```bash
flutter test --coverage
```

## 📦 Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🚀 Deployment

### Firebase Hosting (Web)
```bash
firebase deploy --only hosting
```

### Cloud Functions
```bash
cd functions
npm run deploy
```

### Firestore Rules
```bash
firebase deploy --only firestore:rules
```

## 🛠️ Development Tools

Use the included launch script for common tasks:
```bash
./launch.sh setup          # Initial setup
./launch.sh ios           # Run on iOS
./launch.sh android       # Run on Android
./launch.sh web           # Run on web
./launch.sh build-ios     # Build for iOS
./launch.sh build-android # Build for Android
./launch.sh clean         # Clean project
./launch.sh test          # Run tests
```

## 📊 Analytics Events

The app tracks the following events:
- User registration
- Login methods
- Event views
- Search queries
- Chat interactions
- Premium conversions
- App crashes

## 🔐 Security

- Firestore security rules enforce user isolation
- API keys are stored securely
- User data is encrypted
- PII is handled according to privacy policy

## 📝 Environment Variables

Create a `.env` file:
```env
OPENAI_API_KEY=your_openai_key
STRIPE_PUBLISHABLE_KEY=your_stripe_key
GOOGLE_MAPS_API_KEY=your_maps_key
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a pull request

## 📄 License

This project is proprietary and confidential.

## 🆘 Support

For issues or questions:
- Create an issue in the repository
- Contact the development team

## 🎯 Roadmap

- [ ] Social features (friend invites)
- [ ] Event creation for organizers
- [ ] Advanced AI personalization
- [ ] Multi-language support
- [ ] Augmented reality features

---

Built with ❤️ using Flutter and Firebase