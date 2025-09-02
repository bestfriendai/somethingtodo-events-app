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

  // Demo Mode Methods
  Future<bool> signInAsGuest() async {
    LoggingService.debug('signInAsGuest() called', tag: 'AuthProvider');
    _setLoading(true);
    _clearError();

    try {
      LoggingService.debug('Creating demo user...', tag: 'AuthProvider');
      // Create a demo user
      _currentUser = AppUser(
        id: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'guest@demo.com',
        displayName: 'Demo User',
        photoUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPremium: false,
        favoriteEventIds: ['demo_1', 'demo_7', 'demo_12'], // Some pre-favorited events
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
      
      LoggingService.info('Demo user created: ${_currentUser?.id}', tag: 'AuthProvider');
      _isDemoMode = true; // Enable demo mode for guest authentication
      _firebaseUser = null; // No Firebase user in guest mode
      
      LoggingService.debug('Notifying listeners...', tag: 'AuthProvider');
      notifyListeners();
      
      LoggingService.info('SignInAsGuest successful', tag: 'AuthProvider');
      return true;
    } catch (e) {
      LoggingService.error('Error in signInAsGuest', tag: 'AuthProvider', error: e);
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
    _setLoading(true);
    _clearError();

    try {
      final credential = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      return credential != null;
    } catch (e) {
      _setError(e.toString());
      return false;
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
    return await signInWithEmailPassword(
      email: email,
      password: password,
    );
  }

  Future<bool> resetPassword(String email) async {
    return await sendPasswordResetEmail(email);
  }

  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      
      return credential != null;
    } catch (e) {
      _setError(e.toString());
      return false;
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
      final userCredential = await _authService.signInWithPhoneCredential(credential);
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
      
      final updatedFavorites = List<String>.from(_currentUser!.favoriteEventIds);
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
      
      final updatedFavorites = List<String>.from(_currentUser!.favoriteEventIds);
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
  UserPreferences get preferences => _currentUser?.preferences ?? const UserPreferences();

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