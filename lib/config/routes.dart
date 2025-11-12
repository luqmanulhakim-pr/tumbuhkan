import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/controller/controller_screen.dart';
import '../screens/camera/camera_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String controller = '/controller';
  static const String camera = '/camera';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
      controller: (context) => const ControllerScreen(),
      camera: (context) => const CameraScreen(),
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
