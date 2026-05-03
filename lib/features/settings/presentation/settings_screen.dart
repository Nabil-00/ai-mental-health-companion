import 'package:buddy/core/theme/app_colors.dart';
import 'package:buddy/core/theme/app_spacing.dart';
import 'package:buddy/core/theme/app_typography.dart';
import 'package:buddy/core/widgets/buddy_avatar.dart';
import 'package:buddy/core/widgets/screen_wrapper.dart';
import 'package:buddy/providers/auth_provider.dart';
import 'package:buddy/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final settings = ref.watch(appSettingsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Settings'),
      ),
      body: ScreenWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 12,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const BuddyAvatar(size: 56, outlined: true),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Buddy User',
                        style: AppTypography.heading3.copyWith(fontSize: 20),
                      ),
                      Text(
                        user?.email ?? '',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Preferences',
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            _Group(
              children: [
                _Tile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  trailing: Switch(
                    value: settings.notificationsEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => ref
                        .read(appSettingsProvider.notifier)
                        .setNotificationsEnabled(v),
                  ),
                ),
                _Tile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: settings.darkMode,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) =>
                        ref.read(appSettingsProvider.notifier).setDarkMode(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'About',
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const BuddyAvatar(size: 44, outlined: true),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buddy',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text('Calm AI companion', style: AppTypography.caption),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _Group(
              children: const [
                _Tile(
                  icon: Icons.info_outline_rounded,
                  title: 'Version',
                  trailing: Text('1.0.0'),
                ),
                _Tile(
                  icon: Icons.article_outlined,
                  title: 'Terms of Service',
                  trailing: Icon(Icons.chevron_right),
                ),
                _Tile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: TextButton(
                onPressed: () async {
                  final should = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Log out?'),
                      content: const Text(
                        'Are you sure you want to log out of Buddy?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => context.pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => context.pop(true),
                          child: const Text('Log out'),
                        ),
                      ],
                    ),
                  );
                  if (should != true) return;
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (!context.mounted) return;
                  context.go('/login');
                },
                child: Text(
                  'Logout',
                  style: AppTypography.body.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  const _Tile({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTypography.body),
      trailing: trailing,
    );
  }
}
