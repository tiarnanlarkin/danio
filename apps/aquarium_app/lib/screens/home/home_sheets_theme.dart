import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/app_bottom_sheet.dart';
import 'theme_picker_sheet.dart';

/// Room theme picker bottom sheet.
///
/// Shows a stacked-card browser where each card displays the room's
/// background image with a painted mini-aquarium overlay. Swipe to
/// browse themes, tap to select.
void showThemePicker(BuildContext context, WidgetRef ref) {
  showAppBottomSheet(
    context: context,
    maxHeightFraction: 0.75,
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: const ThemePickerSheet(),
  );
}
