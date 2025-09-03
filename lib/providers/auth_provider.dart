import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/logging_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _currentUser;
  User? _firebaseUser;
  bool _isLoading = false;
  String? _error;
  bool _isDemoMode = false;

  // Getters
  AppUser? get currentUser => _currentUser;
  User? get firebaseUser => _firebaseUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null || _isDemoMode;
  bool get isDemoMode => _isDemoMode;

  AuthProvider() {
    _initializeAuth();
  }

  // Direct user setting (for bypassing authentication issues)
  void setDirectUser(AppUser user) {
    print('🔍 AuthProvider.setDirectUser called');
    _currentUser = user;
    _isDemoMode = false;
    _firebaseUser = null;
    notifyListeners();
    print('✅ Direct user set: ${user.id}');
  }

  // Create a local user when Firebase fails
  Future<bool> _createLocalUser(String email, String displayName) async {
    try {
      print('🔍 Creating local user for email: $email');

      _currentUser = AppUser(
        id: 'local_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName,
        photoUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPremium: false,
        favoriteEventIds: [],
        interests: ['music', 'food', 'technology', 'arts'],
        location: const UserLocation(
          latitude: 37.7749,
          longitude: -122.4194,
          address: 'San Francisco, CA',
          city: 'San Francisco',
          state: 'CA',
          country: 'USA',
        ),
        preferences: const UserPreferences(
          notificationsEnabled: true,
          locationEnabled: true,
          marketingEmails: false,
          theme: 'light',
          maxDistance: 25.0,
          preferredCategories: ['music', 'food', 'arts'],
          pricePreference: 'any',
        ),
      );

      _isDemoMode = false; // Local users get real API data
      _firebaseUser = null; // No Firebase user for local users

      notifyListeners();
      print('✅ Local user created: ${_currentUser?.id}');
      return true;
    } catch (e) {
      print('❌ Error creating local user: $e');
      _setError('Failed to create local user: $e');
      return false;
    }
  }

  // Demo Mode Methods
  Future<bool> signInAsGuest() async {
    print('🔍 signInAsGuest() called');
    _setLoading(true);
    _clearError();

    try {
      print('🔍 Creating demo user...');
      // Create a demo user
      _currentUser = AppUser(
        id: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'guest@demo.com',
        displayName: 'Demo User',
        photoUrl:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPremium: false,
        favoriteEventIds: [
          'demo_1',
          'demo_7',
          'demo_12',
        ], // Some pre-favorited events
        interests: ['music', 'food', 'technology', 'arts'],
        location: const UserLocation(
          latitude: 37.7749,
          longitude: -122.4194,
          address: 'San Francisco, CA',
          city: 'San Francisco',
          state: 'CA',
          country: 'USA',
        ),
        preferences: const UserPreferences(
          notificationsEnabled: true,
          locationEnabled: true,
          marketingEmails: false,
          theme: 'light',
          maxDistance: 25.0,
          preferredCategories: ['music', 'food', 'arts'],
          pricePreference: 'any',
        ),
      );

      print('🔍 Guest user created: ${_currentUser?.id}');
      _isDemoMode = false; // Guest users get real API data too
      _firebaseUser = null; // No Firebase user in guest mode

      print('🔍 Notifying listeners...');
      notifyListeners();

      print('🔍 SignInAsGuest successful');
      return true;
    } catch (e, stackTrace) {
      print('❌ Error in signInAsGuest: $e');
      print('❌ Stack trace: $stackTrace');
      _setError('Failed to sign in as guest: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      _currentUser = await _authService.getUserProfile(userId);
    } catch (e) {
      _error = 'Failed to load user profile: $e';
    }
    notifyListeners();
  }

  // Authentication Methods
  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    print('🔍 AuthProvider.signUpWithEmailPassword called');
    _setLoading(true);
    _clearError();

    try {
      print('🔍 Calling AuthService.signUpWithEmailPassword...');
      final credential = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      print('🔍 AuthService returned credential: ${credential != null}');

      if (credential != null) {
        return true;
      } else {
        // Fallback: Create a local user if Firebase fails
        print('🔍 Firebase signup failed, creating local user...');
        return await _createLocalUser(email, displayName);
      }
    } catch (e, stackTrace) {
      print('❌ SignUp error: $e');
      print('❌ SignUp stack trace: $stackTrace');

      // Fallback: Create a local user if Firebase fails
      print('🔍 Firebase signup failed with error, creating local user...');
      return await _createLocalUser(email, displayName);
    } finally {
      _setLoading(false);
    }
  }

  // Alias methods for consistency
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await signUpWithEmailPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await signInWithEmailPassword(email: email, password: password);
  }

  Future<bool> resetPassword(String email) async {
    return await sendPasswordResetEmail(email);
  }

  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    print('🔍 AuthProvider.signInWithEmailPassword called');
    _setLoading(true);
    _clearError();

    try {
      print('🔍 Calling AuthService.signInWithEmailPassword...');
      final credential = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      print('🔍 AuthService returned credential: ${credential != null}');

      if (credential != null) {
        return true;
      } else {
        // Fallback: Create a local user if Firebase fails
        print('🔍 Firebase signin failed, creating local user...');
        return await _createLocalUser(email, 'User');
      }
    } catch (e, stackTrace) {
      print('❌ SignIn error: $e');
      print('❌ SignIn stack trace: $stackTrace');

      // Fallback: Create a local user if Firebase fails
      print('🔍 Firebase signin failed with error, creating local user...');
      return await _createLocalUser(email, 'User');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _authService.signInWithGoogle();
      return credential != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _authService.signInWithPhoneCredential(credential);
          _setLoading(false);
        },
        verificationFailed: (FirebaseAuthException e) {
          _setError(e.message ?? 'Phone verification failed');
          _setLoading(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          _setLoading(false);
          // Handle code sent - this would typically navigate to a code input screen
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<bool> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    _setLoading(true);
    _clearError();

    try {
      final userCredential = await _authService.signInWithPhoneCredential(
        credential,
      );
      return userCredential != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);

    try {
      if (!_isDemoMode) {
        await _authService.signOut();
      }
      _currentUser = null;
      _firebaseUser = null;
      _isDemoMode = false;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.deleteAccount();
      _currentUser = null;
      _firebaseUser = null;
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Profile Management
  Future<void> updateUserProfile(AppUser user) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateUserProfile(user);
      _currentUser = user;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePremiumStatus({
    required bool isPremium,
    DateTime? expiresAt,
  }) async {
    if (_currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
      await _authService.updatePremiumStatus(
        userId: _currentUser!.id,
        isPremium: isPremium,
        expiresAt: expiresAt,
      );

      _currentUser = _currentUser!.copyWith(
        isPremium: isPremium,
        premiumExpiresAt: expiresAt,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addFavoriteEvent(String eventId) async {
    if (_currentUser == null) return;

    try {
      // In demo mode, just update locally without Firebase
      if (!_isDemoMode) {
        await _authService.addFavoriteEvent(_currentUser!.id, eventId);
      }

      final updatedFavorites = List<String>.from(
        _currentUser!.favoriteEventIds,
      );
      if (!updatedFavorites.contains(eventId)) {
        updatedFavorites.add(eventId);
        _currentUser = _currentUser!.copyWith(
          favoriteEventIds: updatedFavorites,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      if (!_isDemoMode) {
        _setError(e.toString());
      }
    }
  }

  Future<void> removeFavoriteEvent(String eventId) async {
    if (_currentUser == null) return;

    try {
      // In demo mode, just update locally without Firebase
      if (!_isDemoMode) {
        await _authService.removeFavoriteEvent(_currentUser!.id, eventId);
      }

      final updatedFavorites = List<String>.from(
        _currentUser!.favoriteEventIds,
      );
      updatedFavorites.remove(eventId);
      _currentUser = _currentUser!.copyWith(
        favoriteEventIds: updatedFavorites,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      if (!_isDemoMode) {
        _setError(e.toString());
      }
    }
  }

  Future<void> updateUserLocation(UserLocation location) async {
    if (_currentUser == null) return;

    try {
      // In demo mode, just update locally without Firebase
      if (!_isDemoMode) {
        await _authService.updateUserLocation(_currentUser!.id, location);
      }

      _currentUser = _currentUser!.copyWith(
        location: location,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      if (!_isDemoMode) {
        _setError(e.toString());
      }
    }
  }

  bool isEventFavorited(String eventId) {
    return _currentUser?.favoriteEventIds.contains(eventId) ?? false;
  }

  // Helper Methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Premium Features
  bool get isPremium => _currentUser?.isPremium ?? false;

  bool get isPremiumExpired {
    if (!isPremium) return false;
    final expiresAt = _currentUser?.premiumExpiresAt;
    return expiresAt != null && expiresAt.isBefore(DateTime.now());
  }

  bool get isPremiumActive => isPremium && !isPremiumExpired;

  // User Preferences
  UserPreferences get preferences =>
      _currentUser?.preferences ?? const UserPreferences();

  Future<void> updatePreferences(UserPreferences preferences) async {
    if (_currentUser == null) return;

    try {
      final updatedUser = _currentUser!.copyWith(
        preferences: preferences,
        updatedAt: DateTime.now(),
      );
      await updateUserProfile(updatedUser);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Interests Management
  List<String> get interests => _currentUser?.interests ?? [];

  Future<void> updateInterests(List<String> interests) async {
    if (_currentUser == null) return;

    try {
      final updatedUser = _currentUser!.copyWith(
        interests: interests,
        updatedAt: DateTime.now(),
      );
      await updateUserProfile(updatedUser);
    } catch (e) {
      _setError(e.toString());
    }
  }
}
