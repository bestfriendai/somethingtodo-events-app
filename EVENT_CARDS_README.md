# 🎯 Premium Event Cards for SomethingToDo

Beautiful glassmorphic event cards with premium animations and interactions.

## ✨ Features Implemented

### 🎴 Premium Event Card (`premium_event_card.dart`)
- **Glassmorphic Design**: Blur effects with semi-transparent overlays
- **3D Tilt Effect**: Interactive tilt on pan gestures
- **Parallax Scrolling**: Image moves independently for depth
- **Animated Like Button**: Confetti explosion on like with haptic feedback
- **Share Button**: Ripple effect animation
- **Save Button**: Bookmark rotation animation
- **Premium Glow**: Animated glow effect for premium events
- **Price Tag**: Shimmer effect for premium pricing
- **Distance Indicator**: Pulsing location icon
- **Category Badge**: Gradient backgrounds with slide-in animation
- **Attendee Avatars**: Overlapping avatars with staggered animation

### 📱 Mini Event Card (`mini_event_card.dart`)
- **Compact Design**: Space-efficient for lists
- **Swipe Actions**: Save, Share, and Hide with colored backgrounds
- **Skeleton Loading**: Shimmer loading state
- **Long Press Preview**: Scale and tilt effect on hold
- **Liquid Swipe**: Smooth gesture handling
- **Hero Animation**: Image transitions between screens
- **Premium Badge**: Animated shimmer for premium events

### 🎬 Animations (60 FPS)
- Smooth scale animations on press
- Spring physics for bounce effects
- Staggered animations for elements
- Confetti particle system
- Shimmer effects for loading and premium
- Ripple effects for interactions
- Fade and slide transitions

## 🚀 Usage

### Run the Demo
```bash
flutter run -t lib/main_cards_demo.dart
```

### Basic Implementation

```dart
// Premium Event Card
PremiumEventCard(
  id: 'event1',
  title: 'Music Festival',
  description: 'Amazing experience',
  imageUrl: 'https://example.com/image.jpg',
  category: 'Music',
  price: 99.99,
  distance: '2.5 mi',
  dateTime: DateTime.now(),
  attendeeAvatars: ['url1', 'url2', 'url3'],
  totalAttendees: 250,
  isPremium: true,
  isLiked: false,
  isSaved: false,
  onTap: () => print('Tapped'),
  onLike: () => print('Liked'),
  onShare: () => print('Shared'),
  onSave: () => print('Saved'),
)

// Mini Event Card
MiniEventCard(
  id: 'mini1',
  title: 'Yoga Class',
  subtitle: 'Morning session',
  imageUrl: 'https://example.com/yoga.jpg',
  category: 'Wellness',
  price: 15.0,
  time: '6:00 AM',
  isPremium: false,
  isSaved: false,
  onTap: () => print('Tapped'),
  onSave: () => print('Saved'),
  onShare: () => print('Shared'),
  onHide: () => print('Hidden'),
  onLongPress: () => print('Long pressed'),
)
```

## 🎨 Customization

### Category Colors
The cards automatically assign colors based on categories:
- **Music**: Purple
- **Sports**: Blue
- **Food**: Orange
- **Art**: Pink
- **Tech**: Cyan
- **Business**: Green
- **Default**: Indigo

### Glassmorphic Effect
The cards use a combination of:
- `BackdropFilter` with blur
- Semi-transparent gradients
- Border with opacity
- Multiple shadow layers

### Performance Optimizations
- Cached network images
- Lazy loading for lists
- Optimized animations with `AnimatedBuilder`
- Haptic feedback for better UX
- Efficient state management

## 📦 Dependencies Required

```yaml
dependencies:
  flutter_animate: ^4.5.0
  shimmer: ^3.0.0
  cached_network_image: ^3.4.1
  confetti: ^0.8.0
  flutter_slidable: ^3.1.1
```

## 🎯 Features Breakdown

### Interactive Elements
- ✅ Glassmorphic blur effects
- ✅ 3D tilt on hover/press
- ✅ Parallax image scrolling
- ✅ Animated like with confetti
- ✅ Share button with ripple
- ✅ Save button with rotation
- ✅ Price shimmer for premium
- ✅ Distance pulse animation
- ✅ Category gradient badges
- ✅ Attendee avatar overlap
- ✅ Swipe actions (save/share/hide)
- ✅ Skeleton loading states
- ✅ Long press preview
- ✅ Smooth 60fps animations
- ✅ Liquid swipe gestures

### Visual Effects
- Glow effect for premium events
- Gradient overlays on images
- Shadow and elevation changes
- Spring physics animations
- Staggered entrance animations
- Hero transitions ready
- Shimmer loading placeholders

## 🔧 Integration

To integrate these cards into your existing app:

1. Copy the card widgets to your project
2. Ensure dependencies are added to `pubspec.yaml`
3. Import the cards where needed
4. Customize colors/themes as needed
5. Connect to your data models
6. Add navigation to detail screens

## 🎪 Demo Features

The demo (`event_cards_demo.dart`) includes:
- Toggle between Premium and Mini card views
- Interactive like/save/share functionality
- Hide events with undo
- Modal bottom sheet for details
- Floating action button to scroll top
- Loading skeleton examples
- Multiple event categories

## 📱 Platform Support

- ✅ iOS (Optimized haptics)
- ✅ Android (Material design)
- ✅ Web (Mouse hover support)
- ✅ Desktop (Cursor interactions)

## 🚦 Performance

- Maintains 60 FPS on most devices
- Efficient memory usage with image caching
- Lazy loading for large lists
- Optimized blur rendering
- Hardware acceleration enabled

---

Created with 💜 for SomethingToDo App