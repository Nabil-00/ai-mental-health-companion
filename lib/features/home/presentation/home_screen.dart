import 'package:buddy/core/theme/app_colors.dart';
import 'package:buddy/core/theme/app_spacing.dart';
import 'package:buddy/core/theme/app_typography.dart';
import 'package:buddy/core/widgets/buddy_avatar.dart';
import 'package:buddy/core/widgets/screen_wrapper.dart';
import 'package:buddy/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final name = user?.displayName ?? user?.email?.split('@').first ?? 'friend';
    final date = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ScreenWrapper(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $name 👋',
                          style: AppTypography.heading.copyWith(fontSize: 26),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          date,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const BuddyAvatar(size: 52, outlined: true),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MoodCol(title: 'Today', mood: 'Calm', emoji: '😌'),
                    Container(width: 1, height: 36, color: AppColors.border),
                    _MoodCol(title: 'Target', mood: 'Focused', emoji: '🎯'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Quick Actions', style: AppTypography.heading3),
              const SizedBox(height: AppSpacing.sm),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.24,
                children: [
                  _ActionCard(
                    icon: Icons.chat_rounded,
                    title: 'Chat Buddy',
                    subtitle: 'Start reflection',
                    onTap: () => context.push('/chat'),
                  ),
                  _ActionCard(
                    icon: Icons.mic_rounded,
                    title: 'Call Buddy',
                    subtitle: 'Voice support',
                    onTap: () => context.push('/voice'),
                  ),
                  _ActionCard(
                    icon: Icons.emoji_emotions_rounded,
                    title: 'Mood Check-in',
                    subtitle: 'Track your state',
                    onTap: () => context.push('/mood'),
                  ),
                  _ActionCard(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    subtitle: 'Preferences',
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Conversations', style: AppTypography.heading3),
                  TextButton(
                    onPressed: () => context.push('/history'),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _ConversationCard(
                time: '2:30 PM',
                text:
                    'You shared that your day felt heavy, and we practiced grounding together.',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          onTap: (index) {
            if (index == 1) context.push('/mood');
            if (index == 2) context.push('/settings');
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded),
              label: 'Mood',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodCol extends StatelessWidget {
  final String title;
  final String mood;
  final String emoji;
  const _MoodCol({
    required this.title,
    required this.mood,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.caption),
        const SizedBox(height: 4),
        Text(
          '$emoji  $mood',
          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const Spacer(),
            Text(
              title,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final String time;
  final String text;
  const _ConversationCard({required this.time, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const BuddyAvatar(size: 42),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Buddy',
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(time, style: AppTypography.caption),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
