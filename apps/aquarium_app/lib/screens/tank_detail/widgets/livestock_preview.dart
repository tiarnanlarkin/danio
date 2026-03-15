import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../widgets/core/app_card.dart';
import '../../../widgets/empty_state.dart';
import '../../../theme/app_theme.dart';

class LivestockPreview extends StatelessWidget {
  final List<Livestock> livestock;

  const LivestockPreview({super.key, required this.livestock});

  @override
  Widget build(BuildContext context) {
    if (livestock.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: AppCard(
          padding: AppCardPadding.spacious,
          child: CompactEmptyState(
            icon: Icons.set_meal,
            message: 'Your tank is waiting for its first residents!',
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: livestock.length,
        itemBuilder: (context, index) {
          final l = livestock[index];
          return Container(
            width: 120,
            margin: EdgeInsets.only(
              right: index < livestock.length - 1 ? 12 : 0,
            ),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.set_meal, color: AppColors.primary),
                    const Spacer(),
                    Text(
                      l.commonName,
                      style: AppTypography.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('×${l.count}', style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
