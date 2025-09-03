// ignore_for_file: avoid_print, undefined_getter, undefined_named_parameter, depend_on_referenced_packages, unused_import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/providers/events_provider.dart';
import 'lib/providers/auth_provider.dart';
import 'lib/providers/chat_provider.dart';
import 'lib/services/cache_service.dart';

/// Test script to verify frontend-API integration
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔗 Testing Frontend-API Integration...\n');
  
  // Initialize cache service
  await CacheService.instance.initialize();
  
  // Test Events Provider with Real API
  await testEventsProvider();
  
  // Test Auth Provider Configuration
  await testAuthProvider();
  
  // Test Chat Provider Configuration
  await testChatProvider();
  
  print('\n✅ Frontend-API Integration Test Complete!');
}

/// Test Events Provider with Real API Data
Future<void> testEventsProvider() async {
  print('📅 Testing Events Provider with Real API...');
  
  try {
    final eventsProvider = EventsProvider();
    
    // Initialize with real API data (not demo mode)
    await eventsProvider.initialize(demoMode: false);
    
    print('   ✅ Events Provider initialized successfully');
    print('   📊 Demo Mode: ${eventsProvider.useDemoData}');
    print('   🔌 RapidAPI Enabled: ${eventsProvider.useRapidAPI}');
    
    // Test loading events
    await eventsProvider.loadEvents(
      query: 'music',
      location: 'San Francisco, CA',
    );
    
    final events = eventsProvider.events;
    print('   📍 Events loaded: ${events.length}');
    
    if (events.isNotEmpty) {
      final firstEvent = events.first;
      print('   🎵 Sample Event: ${firstEvent.title}');
      print('   📍 Location: ${firstEvent.location}');
      print('   ✅ Real API data successfully loaded!');
    } else {
      print('   ⚠️  No events loaded - check API configuration');
    }
    
  } catch (e) {
    print('   ❌ Events Provider Error: $e');
  }
}

/// Test Auth Provider Configuration
Future<void> testAuthProvider() async {
  print('\n👤 Testing Auth Provider Configuration...');
  
  try {
    final authProvider = AuthProvider();
    
    // Test guest authentication (should get real API data)
    await authProvider.signInAsGuest();
    
    print('   ✅ Guest authentication successful');
    print('   👤 User ID: ${authProvider.currentUser?.id}');
    print('   🔌 Demo Mode: ${authProvider.isDemoMode}');
    
    if (!authProvider.isDemoMode) {
      print('   ✅ Guest users configured for real API data!');
    } else {
      print('   ⚠️  Guest users still in demo mode - needs fixing');
    }
    
  } catch (e) {
    print('   ❌ Auth Provider Error: $e');
  }
}

/// Test Chat Provider Configuration
Future<void> testChatProvider() async {
  print('\n🤖 Testing Chat Provider Configuration...');
  
  try {
    final chatProvider = ChatProvider();
    
    // Initialize with real API data
    await chatProvider.initialize('test-user-id', demoMode: false);
    
    print('   ✅ Chat Provider initialized successfully');
    print('   🔌 Demo Mode: ${chatProvider.isDemoMode}');
    
    if (!chatProvider.isDemoMode) {
      print('   ✅ Chat configured for real OpenAI API!');
    } else {
      print('   ⚠️  Chat still in demo mode - needs fixing');
    }
    
  } catch (e) {
    print('   ❌ Chat Provider Error: $e');
  }
}
