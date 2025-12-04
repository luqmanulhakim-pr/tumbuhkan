import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'services/mqtt_service.dart';
import 'services/schedule_service.dart';

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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MqttService()),
        ChangeNotifierProvider(
            create: (_) => ScheduleService()..loadDummyData()),
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
