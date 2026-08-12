import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/dark_mode_switch_card.dart';
import '../widgets/profile_summary_card.dart';
import '../widgets/theme_mode_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final currentThemeMode = themeProvider.themeMode;
    final isDarkMode = currentThemeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings & Preferences',
                style: AppTypography.displayLarge.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage app theme mode, display contrast, and account session.',
                style: AppTypography.bodyMedium,
              ),

              const SizedBox(height: 24),

              // Account Profile Card
              ProfileSummaryCard(auth: auth),

              const SizedBox(height: 24),

              // Quick Dark Mode Switch Card
              DarkModeSwitchCard(
                isDarkMode: isDarkMode,
                themeProvider: themeProvider,
              ),

              const SizedBox(height: 28),

              // SECTION: Theme Controls
              Text(
                'APPEARANCE & CONTRAST PRESETS',
                style: AppTypography.caption.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  children: [
                    ThemeModeTile(
                      title: 'High Contrast Dark Mode',
                      subtitle:
                          'Dark obsidian background with vibrant HSL purple accents.',
                      icon: Icons.dark_mode_rounded,
                      mode: ThemeMode.dark,
                      currentMode: currentThemeMode,
                      onSelect: () =>
                          themeProvider.setThemeMode(ThemeMode.dark),
                    ),
                    const Divider(height: 24),
                    ThemeModeTile(
                      title: 'Low Contrast Light Mode',
                      subtitle:
                          'Soft light gray background designed for easy daytime viewing.',
                      icon: Icons.light_mode_rounded,
                      mode: ThemeMode.light,
                      currentMode: currentThemeMode,
                      onSelect: () =>
                          themeProvider.setThemeMode(ThemeMode.light),
                    ),
                    const Divider(height: 24),
                    ThemeModeTile(
                      title: 'System Default',
                      subtitle:
                          'Automatically follow system light/dark appearance settings.',
                      icon: Icons.settings_brightness_rounded,
                      mode: ThemeMode.system,
                      currentMode: currentThemeMode,
                      onSelect: () =>
                          themeProvider.setThemeMode(ThemeMode.system),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // SECTION: Log Out Option
              Center(
                child: CompactOutlinedLogoutButton(
                  onPressed: () {
                    auth.logout();
                    context.go('/welcome');
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class CompactOutlinedLogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CompactOutlinedLogoutButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.vitalRed,
        side: BorderSide(
          color: AppColors.vitalRed.withValues(alpha: 0.5),
          width: 1.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: const Text(
        'Sign Out',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      onPressed: onPressed,
    );
  }
}
