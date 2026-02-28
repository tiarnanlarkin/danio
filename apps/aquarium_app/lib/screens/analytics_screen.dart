import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Analytics Dashboard Screen — Coming Soon placeholder
/// The original screen caused ANR crashes due to heavy synchronous computation
/// in build/initState. Replaced with polished placeholder until async refactor.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryAlpha10
                      : AppColors.primaryAlpha05,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  size: 64,
                  color: AppColors.accent.withAlpha(180),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Analytics Coming Soon',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Track your learning progress, quiz performance,\nand aquarium stats \u2014 all in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.accentAlpha10
                      : AppColors.accentAlpha10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.accentAlpha20
                        : AppColors.accentAlpha10,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.rocket_launch_outlined,
                        size: 18,
                        color: isDark ? AppColors.accent : AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Launching with our next update',
                      style: TextStyle(
                        color: isDark ? AppColors.accent : AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
