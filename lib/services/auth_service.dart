import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/analytics.dart';
import '../config/app_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn? _googleSignIn;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Lazy initialization for Google Sign-In (not available on web in demo mode)
  GoogleSignIn get googleSignIn {
    if (_googleSignIn == null) {
      if (kIsWeb || AppConfig.demoMode) {
        // On web or in demo mode, don't initialize Google Sign-In
        throw UnsupportedError('Google Sign-In not available in demo mode or on web');
      }
      _googleSignIn = GoogleSignIn();
    }
    return _googleSignIn!;
  }

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password Authentication
  Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        await _createUserProfile(credential.user!, {
          'signup_method': 'email',
        });
        
        await _analytics.logEvent(
          name: AnalyticsEvents.userSignUp,
          parameters: {
            'method': 'email',
            'user_id': credential.user!.uid,
          },
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _analytics.logEvent(
        name: AnalyticsEvents.userLogin,
        parameters: {
          'method': 'email',
          'user_id': credential.user?.uid ?? '',
        },
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Check if Google Sign-In is available
      if (kIsWeb || AppConfig.demoMode) {
        throw UnsupportedError('Google Sign-In not available in demo mode or on web');
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _createUserProfile(userCredential.user!, {
          'signup_method': 'google',
        });
        
        await _analytics.logEvent(
          name: AnalyticsEvents.userLogin,
          parameters: {
            'method': 'google',
            'user_id': userCredential.user!.uid,
          },
        );
      }

      return userCredential;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // Phone Authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential?> signInWithPhoneCredential(
    PhoneAuthCredential credential,
  ) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _createUserProfile(userCredential.user!, {
          'signup_method': 'phone',
        });
        
        await _analytics.logEvent(
          name: AnalyticsEvents.userLogin,
          parameters: {
            'method': 'phone',
            'user_id': userCredential.user!.uid,
          },
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      if (!kIsWeb && !AppConfig.demoMode && _googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
    } catch (e) {
      // Ignore Google Sign-In errors during sign out
    }
    await _auth.signOut();
  }

  // Delete Account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Delete user profile from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete the Firebase Auth account
      await user.delete();
    }
  }

  // Profile Management
  Future<void> _createUserProfile(User user, Map<String, dynamic> metadata) async {
    final appUser = AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
      preferences: const UserPreferences(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(appUser.toJson());
  }

  Future<AppUser?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return AppUser.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> updateUserProfile(AppUser user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.copyWith(updatedAt: DateTime.now()).toJson());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Premium Status
  Future<void> updatePremiumStatus({
    required String userId,
    required bool isPremium,
    DateTime? expiresAt,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isPremium': isPremium,
        'premiumExpiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt) : null,
        'updatedAt': Timestamp.now(),
      });

      await _analytics.logEvent(
        name: AnalyticsEvents.premiumUpgrade,
        parameters: {
          'user_id': userId,
          'is_premium': isPremium,
        },
      );
    } catch (e) {
      throw Exception('Failed to update premium status: $e');
    }
  }

  // Favorite Events
  Future<void> addFavoriteEvent(String userId, String eventId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favoriteEventIds': FieldValue.arrayUnion([eventId]),
        'updatedAt': Timestamp.now(),
      });

      await _analytics.logEvent(
        name: AnalyticsEvents.eventFavorite,
        parameters: {
          'user_id': userId,
          'event_id': eventId,
          'action': 'add',
        },
      );
    } catch (e) {
      throw Exception('Failed to add favorite event: $e');
    }
  }

  Future<void> removeFavoriteEvent(String userId, String eventId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favoriteEventIds': FieldValue.arrayRemove([eventId]),
        'updatedAt': Timestamp.now(),
      });

      await _analytics.logEvent(
        name: AnalyticsEvents.eventFavorite,
        parameters: {
          'user_id': userId,
          'event_id': eventId,
          'action': 'remove',
        },
      );
    } catch (e) {
      throw Exception('Failed to remove favorite event: $e');
    }
  }

  // Update User Location
  Future<void> updateUserLocation(String userId, UserLocation location) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'location': location.toJson(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update user location: $e');
    }
  }

  // Error Handling
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}