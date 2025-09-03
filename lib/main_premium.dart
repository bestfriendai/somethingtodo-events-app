import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/events_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/demo_mode_provider.dart';
import 'screens/home/premium_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const PremiumApp());
}

class PremiumApp extends StatelessWidget {
  const PremiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => DemoModeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'SomethingToDo Premium',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.purple,
              scaffoldBackgroundColor: Colors.black,
              useMaterial3: true,
              fontFamily: 'SF Pro Display',
            ),
            home: const PremiumHomeScreen(),
          );
        },
      ),
    );
  }
}
