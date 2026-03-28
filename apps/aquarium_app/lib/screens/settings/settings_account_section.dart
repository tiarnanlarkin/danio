import 'package:flutter/material.dart';
import '../../utils/navigation_throttle.dart';
import '../account_screen.dart';
import '../../widgets/core/app_list_tile.dart';

/// Account section tile for the settings screen.
class SettingsAccountSection extends StatelessWidget {
  const SettingsAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return NavListTile(
      icon: Icons.account_circle,
      title: 'Account & Sync',
      subtitle: 'Sign in, backup, multi-device sync',
      onTap: () => NavigationThrottle.push(context, const AccountScreen()),
    );
  }
}
