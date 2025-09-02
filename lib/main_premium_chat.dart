import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/chat/premium_chat_screen.dart';
import 'providers/chat_provider.dart';
import 'config/unified_design_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: PremiumChatApp(),
    ),
  );
}

class PremiumChatApp extends ConsumerWidget {
  const PremiumChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'SomethingToDo Premium Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        textTheme: TextTheme(
          displayLarge: UnifiedDesignSystem.displayLarge,
          displayMedium: UnifiedDesignSystem.displayMedium,
          displaySmall: UnifiedDesignSystem.displaySmall,
          headlineLarge: UnifiedDesignSystem.headlineLarge,
          headlineMedium: UnifiedDesignSystem.headlineMedium,
          headlineSmall: UnifiedDesignSystem.headlineSmall,
          titleLarge: UnifiedDesignSystem.titleLarge,
          titleMedium: UnifiedDesignSystem.titleMedium,
          titleSmall: UnifiedDesignSystem.titleSmall,
          bodyLarge: UnifiedDesignSystem.bodyLarge,
          bodyMedium: UnifiedDesignSystem.bodyMedium,
          bodySmall: UnifiedDesignSystem.bodySmall,
        ),
      ),
      home: const ChatDemoScreen(),
    );
  }
}

class ChatDemoScreen extends ConsumerStatefulWidget {
  const ChatDemoScreen({super.key});

  @override
  ConsumerState<ChatDemoScreen> createState() => _ChatDemoScreenState();
}

class _ChatDemoScreenState extends ConsumerState<ChatDemoScreen> {
  String? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Initialize with demo mode
    final chatNotifier = ref.read(chatProvider.notifier);
    
    // Create a demo session
    _currentSessionId = 'demo_session_${DateTime.now().millisecondsSinceEpoch}';
    
    // Add some initial demo messages
    await Future.delayed(const Duration(milliseconds: 500));
    
    chatNotifier.sendMessage(
      sessionId: _currentSessionId!,
      content: "Welcome to SomethingToDo! I'm your AI event assistant. How can I help you discover amazing events today?",
      metadata: {
        'sender': 'assistant',
        'type': 'welcome',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  UnifiedDesignSystem.primaryBrand.withValues(alpha: 0.05),
                  Colors.black,
                  UnifiedDesignSystem.accentBrand.withValues(alpha: 0.03),
                ],
              ),
            ),
          ),
          
          // Chat Screen
          PremiumChatScreen(sessionId: _currentSessionId),
          
          // Floating info button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              onPressed: _showFeatureInfo,
              child: const Icon(
                Icons.info_outline,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatureInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          'Premium Chat Features',
          style: UnifiedDesignSystem.headlineSmall.copyWith(
            color: UnifiedDesignSystem.primaryBrand,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFeatureItem('✨', 'Glassmorphic message bubbles'),
              _buildFeatureItem('💬', 'Typing indicator with animation'),
              _buildFeatureItem('🎤', 'Voice message support'),
              _buildFeatureItem('📸', 'Image/video previews'),
              _buildFeatureItem('⚡', 'Quick reply suggestions'),
              _buildFeatureItem('😊', 'Emoji reactions'),
              _buildFeatureItem('✓', 'Message status indicators'),
              _buildFeatureItem('📅', 'Floating date separators'),
              _buildFeatureItem('🎯', 'Smooth scroll with momentum'),
              _buildFeatureItem('↩️', 'Swipe to reply'),
              _buildFeatureItem('📍', 'Location sharing'),
              _buildFeatureItem('🎟️', 'Event cards inline'),
              _buildFeatureItem('🤖', 'AI assistant with personality'),
              _buildFeatureItem('📱', 'Haptic feedback'),
              _buildFeatureItem('🎨', 'Premium animations'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it!',
              style: TextStyle(
                color: UnifiedDesignSystem.secondaryBrand,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: UnifiedDesignSystem.bodyMedium.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Demo launcher for testing
class PremiumChatLauncher extends StatelessWidget {
  const PremiumChatLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              UnifiedDesignSystem.primaryBrand.withValues(alpha: 0.2),
              Colors.black,
              UnifiedDesignSystem.accentBrand.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: UnifiedDesignSystem.primaryBrand,
                ),
                const SizedBox(height: 24),
                Text(
                  'Premium Chat UI',
                  style: UnifiedDesignSystem.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ChatGPT meets WhatsApp',
                  style: UnifiedDesignSystem.bodyLarge.copyWith(
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProviderScope(
                          child: ChatDemoScreen(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UnifiedDesignSystem.primaryBrand,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Launch Chat',
                    style: UnifiedDesignSystem.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}