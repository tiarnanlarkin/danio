import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/hobby_desk.dart';
import '../../widgets/app_bottom_sheet.dart';

/// Helper to format a DateTime as a friendly relative string.
String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dt.day}/${dt.month}/${dt.year}';
}

/// A parameter row for info sheets.
Widget buildParamRow(BuildContext context, String label, String value, String ideal) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      children: [
        Expanded(child: Text(label, style: AppTypography.bodyMedium)),
        Text(value, style: AppTypography.labelLarge),
        if (ideal.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            '(ideal: $ideal)',
            style: AppTypography.bodySmall.copyWith(color: context.textHint),
          ),
        ],
      ],
    ),
  );
}

/// Generic item detail popup bottom sheet.
void showItemSheet(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color color,
  required List<ItemDetailRow> rows,
}) {
  showAppBottomSheet(
    context: context,
    padding: EdgeInsets.zero,
    child: ItemDetailPopup(
      title: title,
      icon: icon,
      accentColor: color,
      rows: rows,
      onClose: () => Navigator.maybePop(context),
    ),
  );
}
