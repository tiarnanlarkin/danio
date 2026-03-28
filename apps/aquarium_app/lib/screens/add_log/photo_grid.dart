import 'dart:io';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Grid of attached photo thumbnails with remove buttons.
class AddLogPhotoGrid extends StatelessWidget {
  final List<String> paths;
  final ValueChanged<String> onRemove;

  const AddLogPhotoGrid({
    super.key,
    required this.paths,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: paths.map((path) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: AppRadius.mediumRadius,
              child: Image.file(
                File(path),
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                semanticLabel: 'Tank log photo',
                cacheWidth:
                    (96 * MediaQuery.of(context).devicePixelRatio).round(),
                cacheHeight:
                    (96 * MediaQuery.of(context).devicePixelRatio).round(),
                errorBuilder: (_, __, ___) => Container(
                  width: 96,
                  height: 96,
                  color: context.surfaceVariant,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Semantics(
                button: true,
                label: 'Remove photo',
                child: InkWell(
                  onTap: () => onRemove(path),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppOverlays.black60,
                          borderRadius: AppRadius.pillRadius,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: AppIconSizes.xs,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
