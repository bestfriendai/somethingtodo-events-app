import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'delight_service.dart';
import 'platform_interactions.dart';

class ShakeDetector {
  static ShakeDetector? _instance;
  static ShakeDetector get instance => _instance ??= ShakeDetector._();
  ShakeDetector._();
  
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _shakeThreshold = 15.0;
  int _shakeCount = 0;
  DateTime? _lastShakeTime;
  
  bool _isListening = false;
  
  void startListening(BuildContext context) {
    if (_isListening) return;
    
    _isListening = true;
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      _detectShake(event, context);
    });
  }
  
  void stopListening() {
    _isListening = false;
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }
  
  void _detectShake(AccelerometerEvent event, BuildContext context) {
    final acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    
    if (acceleration > _shakeThreshold) {
      final now = DateTime.now();
      
      // Prevent multiple shake detections in quick succession
      if (_lastShakeTime != null && 
          now.difference(_lastShakeTime!).inMilliseconds < 1000) {
        return;
      }
      
      _lastShakeTime = now;
      _shakeCount++;
      
      _handleShakeDetected(context);
    }
  }
  
  void _handleShakeDetected(BuildContext context) {
    PlatformInteractions.heavyImpact();
    
    // Different responses based on shake count
    if (_shakeCount == 1) {
      DelightService.instance.onShakeDetected(context);
    } else if (_shakeCount == 5) {
      DelightService.instance.triggerEasterEgg(context, 'shake_master');
    } else if (_shakeCount == 10) {
      DelightService.instance.showConfetti(
        context,
        customMessage: 'Shake it like a Polaroid picture! You are the shake champion! 📸',
      );
    } else {
      final messages = [
        'Shake detected! Someone\'s excited! 😄',
        'Whoa there! Refreshing with style! ✨',
        'Shake it off! Here come fresh events! 🎵',
        'That\'s some serious shaking! We love the energy! 💪',
      ];
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(messages[Random().nextInt(messages.length)]),
          backgroundColor: Colors.blue.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  void reset() {
    _shakeCount = 0;
    _lastShakeTime = null;
  }
}

// Achievement System for Delight Features
class AchievementSystem {
  static AchievementSystem? _instance;
  static AchievementSystem get instance => _instance ??= AchievementSystem._();
  AchievementSystem._();
  
  final Map<String, int> _achievements = {};
  
  void recordAction(String action, BuildContext context) {
    _achievements[action] = (_achievements[action] ?? 0) + 1;
    
    _checkForAchievements(action, context);
  }
  
  void _checkForAchievements(String action, BuildContext context) {
    final count = _achievements[action] ?? 0;
    
    switch (action) {
      case 'like':
        if (count == 10) {
          _showAchievement(context, 'Heart Throb', 'You have liked 10 events!');
        } else if (count == 50) {
          _showAchievement(context, 'Love Machine', 'You have liked 50 events! Spread the love!');
        }
        break;
      case 'share':
        if (count == 5) {
          _showAchievement(context, 'Social Butterfly', 'You have shared 5 events!');
        } else if (count == 25) {
          _showAchievement(context, 'Viral Sensation', 'You have shared 25 events! You are making the world more fun!');
        }
        break;
      case 'search':
        if (count == 20) {
          _showAchievement(context, 'Explorer', 'You have searched 20 times! You know what you want!');
        }
        break;
      case 'refresh':
        if (count == 15) {
          _showAchievement(context, 'Refresh Master', 'You have refreshed 15 times! Persistence pays off!');
        }
        break;
    }
  }
  
  void _showAchievement(BuildContext context, String title, String description) {
    DelightService.instance.showConfetti(
      context,
      customMessage: '$title achieved! $description 🏆',
    );
  }
}

// Sound Effect Service (for future expansion)
class SoundEffectService {
  static SoundEffectService? _instance;
  static SoundEffectService get instance => _instance ??= SoundEffectService._();
  SoundEffectService._();
  
  // Placeholder for future sound effects
  // Could integrate with flutter_sound or similar package
  
  void playSuccess() {
    // Play success sound
    PlatformInteractions.heavyImpact();
  }
  
  void playLike() {
    // Play like sound
    PlatformInteractions.mediumImpact();
  }
  
  void playShare() {
    // Play share sound
    PlatformInteractions.lightImpact();
  }
  
  void playEasterEgg() {
    // Play special easter egg sound
    PlatformInteractions.heavyImpact();
  }
}