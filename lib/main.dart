import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/menu_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/path_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/placement_test_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/voice_settings_screen.dart';
import 'models/learning_path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'English Learning Adventure',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFF5F7FF),
        ),
        home: const RootScreen(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/setup':
              return MaterialPageRoute(
                builder: (context) => const ProfileSetupScreen(),
              );

            case '/placement':
              return MaterialPageRoute(
                builder: (context) => const PlacementTestScreen(),
              );

            case '/path':
              return MaterialPageRoute(
                builder: (context) => const PathScreen(),
              );

            case '/quiz':
              final args = settings.arguments as Map<String, dynamic>;
              final unit = args['unit'] as PathUnit;
              return MaterialPageRoute(
                builder: (context) => QuizScreen(unit: unit),
              );
            
            case '/chat':
              return MaterialPageRoute(
                builder: (context) => const ChatScreen(),
              );
            
            case '/progress':
              return MaterialPageRoute(
                builder: (context) => const ProgressScreen(),
              );

            case '/profile':
              return MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              );

            case '/voice-setup':
              return MaterialPageRoute(
                builder: (context) => const VoiceSettingsScreen(isOnboarding: true),
              );

            case '/voice-settings':
              return MaterialPageRoute(
                builder: (context) => const VoiceSettingsScreen(),
              );

            default:
              return MaterialPageRoute(
                builder: (context) => const RootScreen(),
              );
          }
        },
      ),
    );
  }
}

/// Decides which screen to show: setup, placement, or menu
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (appState.needsSetup) {
          return const ProfileSetupScreen();
        }

        if (appState.needsPlacement) {
          return const PlacementTestScreen();
        }

        return const MenuScreen();
      },
    );
  }
}
