import 'package:flutter/material.dart';
import 'package:tumbuhkan/screens/chatbot/chatbot_screen.dart';
import 'package:tumbuhkan/screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/controller/controller_screen.dart';
import '../screens/camera/camera_screen.dart';
import '../screens/monitoring/monitoring_screen.dart';
import '../screens/sensor_detail/log_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String controller = '/controller';
  static const String camera = '/camera';
  static const String monitoring = '/monitoring';
  static const String logSensor = '/log';
  static const String chatbot = '/chatbot';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
      controller: (context) => const ControllerScreen(),
      camera: (context) => const CameraScreen(),
      chatbot: (context) => const ChatBotScreen(),
      settings: (context) => const SettingsScreen(),
      monitoring: (context) => const MonitoringScreen(),
      logSensor: (context) => const LogScreen(),
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
      case monitoring:
        return MaterialPageRoute(builder: (_) => const MonitoringScreen());
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
