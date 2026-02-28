import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/mascot/mascot_widgets.dart';

class EmptyRoomScene extends StatelessWidget {
  final VoidCallback onCreateTank;
  final VoidCallback onLoadDemo;

  const EmptyRoomScene({super.key, required this.onCreateTank, required this.onLoadDemo});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF0D1B2A), const Color(0xFF1B2838)]
              : [const Color(0xFFE8F4FD), const Color(0xFFF0F7FB)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Water drop icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppOverlays.primary10,
                    border: Border.all(color: AppOverlays.primary30, width: 2),
                  ),
                  child: const Icon(
                    Icons.water_drop_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Finn greeting
                MascotBubble.fromContext(
                  context: MascotContext.noTanks,
                  size: MascotSize.small,
                ),
                const SizedBox(height: 16),

                Text(
                  'Welcome to your aquarium!',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first tank to start tracking\nwater parameters, livestock, and more.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onCreateTank,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Your Tank'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onLoadDemo,
                  child: const Text('Try a sample tank'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
