import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // ← Add this
import 'config/routes.dart';
import 'config/theme.dart';
import 'services/mqtt_service.dart'; // ← Add this

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    // ← Wrap with MultiProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MqttService()),
      ],
      child: const TumbuhkanApp(),
    ),
  );
}

class TumbuhkanApp extends StatelessWidget {
  const TumbuhkanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tumbuhkan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
