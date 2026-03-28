import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/room_theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';
import '../../widgets/app_bottom_sheet.dart';

/// Room theme picker bottom sheet.
void showThemePicker(BuildContext context, WidgetRef ref) {
  showAppBottomSheet(
    context: context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Row(
            children: [
              const Icon(Icons.palette, size: AppIconSizes.md),
              const SizedBox(width: AppSpacing.sm2),
              Semantics(
                header: true,
                child: Text('Room Theme', style: AppTypography.headlineSmall),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg2),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: RoomThemeType.values.map((type) {
              final theme = RoomTheme.fromType(type);
              final isSelected = ref.watch(roomThemeProvider) == type;
              return Semantics(
                label: '${theme.name} theme${isSelected ? ', selected' : ''}',
                button: true,
                selected: isSelected,
                child: GestureDetector(
                  onTap: () {
                    ref.read(roomThemeProvider.notifier).setTheme(type);
                    Navigator.maybePop(context);
                  },
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(AppSpacing.sm2),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: isSelected ? theme.accentBlob : context.borderColor,
                        width: isSelected ? 3 : 1,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [theme.background1, theme.background2],
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(radius: 8, backgroundColor: theme.accentBlob),
                            const SizedBox(width: AppSpacing.xs),
                            CircleAvatar(radius: 8, backgroundColor: theme.waterMid),
                            const SizedBox(width: AppSpacing.xs),
                            CircleAvatar(radius: 8, backgroundColor: theme.plantPrimary),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          theme.name,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          theme.description,
                          style: Theme.of(context).textTheme.labelSmall!.copyWith(color: theme.textSecondary),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
  );
}
