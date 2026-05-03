import 'package:buddy/core/theme/app_colors.dart';
import 'package:buddy/core/theme/app_spacing.dart';
import 'package:buddy/core/theme/app_typography.dart';
import 'package:buddy/core/widgets/mood_card.dart';
import 'package:buddy/core/widgets/pill_button.dart';
import 'package:buddy/core/widgets/screen_wrapper.dart';
import 'package:buddy/models/mood_entry_model.dart';
import 'package:buddy/providers/mood_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MoodCheckInScreen extends ConsumerStatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  ConsumerState<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends ConsumerState<MoodCheckInScreen> {
  int step = 0;
  MoodLevel? currentMood;
  MoodLevel? targetMood;
  bool saving = false;

  static const options = [
    ('😊', 'Happy', MoodLevel.veryGood),
    ('🙂', 'Good', MoodLevel.good),
    ('😐', 'Okay', MoodLevel.neutral),
    ('😢', 'Sad', MoodLevel.bad),
    ('😰', 'Stressed', MoodLevel.veryBad),
    ('😌', 'Calm', MoodLevel.good),
  ];

  Future<void> _next() async {
    if (step == 0) {
      if (currentMood == null) return;
      setState(() => step = 1);
      return;
    }
    if (targetMood == null) return;
    setState(() => saving = true);
    await ref
        .read(moodNotifierProvider.notifier)
        .addMoodEntry(
          mood: currentMood!,
          note: 'Target: ${targetMood!.name}',
          tags: {'targetMood': targetMood!.name},
        );
    if (!mounted) return;
    setState(() => saving = false);
    context.go('/chat');
  }

  @override
  Widget build(BuildContext context) {
    final selected = step == 0 ? currentMood : targetMood;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            2,
            (index) => Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index <= step ? AppColors.primary : AppColors.border,
              ),
            ),
          ),
        ),
      ),
      body: ScreenWrapper(
        child: Column(
          children: [
            Text(
              step == 0 ? 'How are you feeling?' : 'How do you want to feel?',
              style: AppTypography.heading.copyWith(fontSize: 26),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              step == 0
                  ? 'Right now, in this moment'
                  : 'Set an intention for this session',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: GridView.builder(
                itemCount: options.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (_, i) {
                  final item = options[i];
                  final isSelected = selected == item.$3;
                  return MoodCard(
                    emoji: item.$1,
                    label: item.$2,
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        if (step == 0) {
                          currentMood = item.$3;
                        } else {
                          targetMood = item.$3;
                        }
                      });
                    },
                  );
                },
              ),
            ),
            PillButton(
              label: step == 0 ? 'Continue' : 'Save & Chat',
              onPress: selected == null ? null : _next,
              disabled: selected == null,
              loading: saving,
            ),
            if (step == 1) ...[
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () => context.go('/chat'),
                child: Text(
                  'Skip & Chat Now',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
