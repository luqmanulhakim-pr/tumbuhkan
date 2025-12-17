import 'package:flutter/material.dart';
import 'package:tumbuhkan/screens/chatbot/chatbot_screen.dart';
import 'package:tumbuhkan/screens/settings/settings_screen.dart';
import '../screens/schedule/schedule_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/controller/controller_screen.dart';
import '../screens/camera/camera_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String controller = '/controller';
  static const String camera = '/camera';
  static const String sensorDetail = '/sensor-detail';
  static const String schedule = '/schedule';
  static const String chatbot = '/chatbot';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
      controller: (context) => const ControllerScreen(),
      camera: (context) => const CameraScreen(),
      schedule: (context) => const ScheduleScreen(),
      chatbot: (context) => const ChatBotScreen(),
      settings: (context) => const SettingsScreen(),
    };
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case controller:
        return MaterialPageRoute(builder: (_) => const ControllerScreen());
      case camera:
        return MaterialPageRoute(builder: (_) => const CameraScreen());
      case chatbot:
        return MaterialPageRoute(builder: (_) => const ChatBotScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
