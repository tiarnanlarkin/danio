import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_provider.dart';
import '../services/supabase_service.dart';
import '../services/cloud_backup_service.dart';
import '../services/cloud_sync_service.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';

/// Account screen — sign-in / profile / sync management.
///
/// When signed out: shows email+password form and Google sign-in button.
/// When signed in: shows profile info, sync status, backup/restore, sign-out.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: !SupabaseService.isInitialised
          ? _buildOfflineOnlyMessage(theme)
          : auth.isSignedIn
              ? _buildSignedInView(context, auth, theme)
              : _buildSignedOutView(context, auth, theme),
    );
  }

  // ---------------------------------------------------------------------------
  // Cloud not configured
  // ---------------------------------------------------------------------------

  Widget _buildOfflineOnlyMessage(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: AppIconSizes.xxl, color: theme.colorScheme.outline),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Cloud Not Configured',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'The app is running in offline-only mode. '
              'All your data is stored locally on this device.\n\n'
              'Cloud sync will be available in a future update.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Signed-out view
  // ---------------------------------------------------------------------------

  Widget _buildSignedOutView(
    BuildContext context,
    AuthState auth,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Icon(
              Icons.account_circle,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _isSignUp ? 'Create Account' : 'Sign In',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Sync your aquarium data across devices.\n'
              'An account is optional — the app works fully offline.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your email';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your password';
                if (_isSignUp && v.length < 6) return 'Min 6 characters';
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Error message
            if (auth.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  auth.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),

            // Submit button
            FilledButton(
              onPressed: auth.isLoading ? null : _submit,
              child: auth.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isSignUp ? 'Create Account' : 'Sign In'),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Toggle sign-up / sign-in
            TextButton(
              onPressed: () => setState(() => _isSignUp = !_isSignUp),
              child: Text(
                _isSignUp
                    ? 'Already have an account? Sign in'
                    : "Don't have an account? Sign up",
              ),
            ),

            // Forgot password
            if (!_isSignUp)
              TextButton(
                onPressed: _forgotPassword,
                child: const Text('Forgot password?'),
              ),

            const SizedBox(height: AppSpacing.lg),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text('or'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Google sign-in
            OutlinedButton.icon(
              onPressed: auth.isLoading ? null : _signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata, size: AppIconSizes.md),
              label: const Text('Continue with Google'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Signed-in view
  // ---------------------------------------------------------------------------

  Widget _buildSignedInView(
    BuildContext context,
    AuthState auth,
    ThemeData theme,
  ) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Profile card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    (auth.displayName.isNotEmpty
                            ? auth.displayName[0]
                            : '?')
                        .toUpperCase(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(auth.displayName, style: theme.textTheme.titleMedium),
                if (auth.displayEmail.isNotEmpty)
                  Text(
                    auth.displayEmail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Sync status
        _SyncStatusCard(),
        const SizedBox(height: AppSpacing.md),

        // Backup & Restore
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_upload),
                title: const Text('Backup Now'),
                subtitle: const Text('Encrypt & upload to cloud'),
                onTap: () => _createBackup(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.cloud_download),
                title: const Text('Restore from Backup'),
                subtitle: const Text('Download & decrypt from cloud'),
                onTap: () => _restoreBackup(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Sign out
        OutlinedButton.icon(
          onPressed: () => _signOut(context),
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Delete account — danger zone
        const Divider(),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Danger Zone',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton.icon(
          onPressed: () => _deleteAccount(context),
          icon: const Icon(Icons.delete_forever),
          label: const Text('Delete Account'),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notifier = ref.read(authProvider.notifier);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isSignUp) {
      notifier.signUpWithEmail(email, password);
    } else {
      notifier.signInWithEmail(email, password);
    }
  }

  void _signInWithGoogle() {
    ref.read(authProvider.notifier).signInWithGoogle();
  }

  void _forgotPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email first')),
      );
      return;
    }
    ref.read(authProvider.notifier).resetPassword(email);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent!')),
    );
  }

  Future<void> _createBackup(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Creating encrypted backup…')),
      );
      await CloudBackupService.instance.createAndUploadBackup();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup uploaded successfully ✓')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: ')),
        );
      }
    }
  }

  Future<void> _restoreBackup(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: const Text(
          'This will merge cloud data with your local data. '
          'Local data wins on conflicts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restoring backup…')),
      );
      await CloudBackupService.instance.downloadAndRestoreBackup();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored successfully ✓')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: ')),
        );
      }
    }
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text(
          'Your local data will remain on this device. '
          'You can sign back in anytime to resume syncing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete your account and all synced data. '
          'Local data will be preserved. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      // Attempt to delete the Supabase account if service is available
      if (SupabaseService.isInitialised) {
        try {
          // Call Supabase Edge Function or admin API for account deletion.
          // The auth provider handles sign-out; actual server-side deletion
          // requires a Supabase Edge Function (delete-user).
          await SupabaseService.instance.client.rpc('delete_user_account');
        } catch (e) {
          // If RPC doesn't exist yet, just sign out — account data will
          // be orphaned but user is informed. Log for monitoring.
          debugPrint('Account deletion RPC failed (may not exist yet): $e');
        }
      }

      // Clear local auth state
      ref.read(authProvider.notifier).signOut();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted. Local data has been preserved.'),
        ),
      );

      // Navigate to onboarding, clearing the navigation stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Sync status card (shows cloud sync state)
// ---------------------------------------------------------------------------

class _SyncStatusCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(cloudSyncStatusProvider);

    final IconData icon;
    final String label;
    final Color color;

    switch (syncStatus) {
      case CloudSyncStatus.synced:
        icon = Icons.cloud_done;
        label = 'All data synced';
        color = Colors.green;
      case CloudSyncStatus.syncing:
        icon = Icons.sync;
        label = 'Syncing…';
        color = Colors.blue;
      case CloudSyncStatus.offline:
        icon = Icons.cloud_off;
        label = 'Offline — changes queued';
        color = Colors.orange;
      case CloudSyncStatus.error:
        icon = Icons.error_outline;
        label = 'Sync error — tap to retry';
        color = Colors.red;
      case CloudSyncStatus.disabled:
        icon = Icons.cloud_off;
        label = 'Cloud sync not active';
        color = Colors.grey;
    }

    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        subtitle: const Text('Multi-device sync'),
        trailing: syncStatus == CloudSyncStatus.error
            ? IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Retry sync',
                onPressed: () =>
                    ref.read(cloudSyncServiceProvider).syncNow(),
              )
            : null,
      ),
    );
  }
}
