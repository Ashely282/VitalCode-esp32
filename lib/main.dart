import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/emotion_provider.dart';
import 'presentation/providers/medicine_provider.dart';
import 'presentation/providers/mqtt_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/routes/app_router.dart';
import 'services/mqtt_service.dart' as new_mqtt;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HealthcareCompanionApp());
}

class HealthcareCompanionApp extends StatelessWidget {
  const HealthcareCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MqttProvider()),
        Provider<new_mqtt.MqttService>(
          create: (_) {
            final service = new_mqtt.MqttService(robotId: 'ROBOT_123');
            service.connect('test.mosquitto.org', 1883); // Using default fallback
            return service;
          },
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProxyProvider<MqttProvider, EmotionProvider>(
          create: (_) => EmotionProvider(),
          update: (_, mqttProvider, emotionProvider) {
            emotionProvider!.init(mqttProvider.mqttService);
            return emotionProvider;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'CareCompanion AI',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
