import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/medicine.dart';
import '../providers/auth_provider.dart';
import '../screens/welcome_screen.dart';
import '../screens/auth_choice_screen.dart';
import '../screens/register_screen.dart';
import '../screens/robot_pairing_screen.dart';
import '../screens/home_dashboard_screen.dart';
import '../screens/add_medicine_screen.dart';
import '../screens/logs_screen.dart';
import '../screens/about_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/main_layout_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/welcome',
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isAuthRoute = state.matchedLocation == '/welcome' ||
          state.matchedLocation == '/auth-choice' ||
          state.matchedLocation == '/register';

      if (!authProvider.isAuthenticated && !isAuthRoute) {
        return '/auth-choice';
      }
      return null;
    },
    routes: [
      // Page 1: Welcome Screen
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Page 2: Auth Choice Screen (Login / Choice)
      GoRoute(
        path: '/auth-choice',
        builder: (context, state) => const AuthChoiceScreen(),
      ),

      // Page 3: Registration Screen
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Page 4: Robot Connection / Pairing Screen
      GoRoute(
        path: '/pair',
        builder: (context, state) => const RobotPairingScreen(),
      ),

      // App Settings Screen
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Page 6: Add / Edit Medicine Screen
      GoRoute(
        path: '/add-medicine',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final medicine = state.extra as Medicine?;
          return AddMedicineScreen(medicine: medicine);
        },
      ),

      // Persistent Shell Navigation for Pages 5, 7, 8
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayoutScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0 (Page 5: Home Dashboard Screen)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const HomeDashboardScreen(),
              ),
            ],
          ),

          // Branch 1 (Page 7: Medicine & Emotion Log Screen)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/logs',
                builder: (context, state) => const LogsScreen(),
              ),
            ],
          ),

          // Branch 2 (Page 8: About Screen)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/about',
                builder: (context, state) => const AboutScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
