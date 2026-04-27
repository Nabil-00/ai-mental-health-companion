import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:buddy/core/theme/app_colors.dart';
import 'package:buddy/core/theme/app_spacing.dart';
import 'package:buddy/core/theme/app_typography.dart';
import 'package:buddy/core/widgets/buttons.dart';
import 'package:buddy/providers/mood_provider.dart';
import 'package:buddy/models/mood_entry_model.dart';

class MoodCheckInScreen extends ConsumerStatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  ConsumerState<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends ConsumerState<MoodCheckInScreen> {
  int _currentStep = 0;
  MoodLevel? _currentMood;
  MoodLevel? _targetMood;
  bool _isSaving = false;

  static const List<MoodOption> _currentMoodOptions = [
    MoodOption(mood: MoodLevel.veryGood, label: 'Happy', icon: '😊'),
    MoodOption(mood: MoodLevel.good, label: 'Good', icon: '🙂'),
    MoodOption(mood: MoodLevel.neutral, label: 'Okay', icon: '😐'),
    MoodOption(mood: MoodLevel.bad, label: 'Sad', icon: '😢'),
    MoodOption(mood: MoodLevel.veryBad, label: 'Stressed', icon: '😰'),
  ];

  static const List<MoodOption> _targetMoodOptions = [
    MoodOption(mood: MoodLevel.veryGood, label: 'Happy', icon: '😊'),
    MoodOption(mood: MoodLevel.good, label: 'Calm', icon: '😌'),
    MoodOption(mood: MoodLevel.neutral, label: 'Energized', icon: '⚡'),
    MoodOption(mood: MoodLevel.bad, label: 'Focused', icon: '🎯'),
    MoodOption(mood: MoodLevel.veryBad, label: 'Peaceful', icon: '🕊️'),
  ];

  List<MoodOption> get _options =>
      _currentStep == 0 ? _currentMoodOptions : _targetMoodOptions;

  MoodLevel? get _selectedMood =>
      _currentStep == 0 ? _currentMood : _targetMood;

  String get _stepTitle =>
      _currentStep == 0 ? 'How do you feel?' : 'How do you want to feel?';

  String get _stepSubtitle => _currentStep == 0
      ? 'Select the emotion that best describes how you feel right now'
      : 'Select how you\'d like to feel';

  Future<void> _next() async {
    if (_isSaving) return;

    if (_currentStep == 0) {
      if (_currentMood == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a mood')));
        return;
      }
      setState(() {
        _currentStep = 1;
      });
    } else {
      if (_targetMood == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a target mood')),
        );
        return;
      }
      await _saveMoodEntry();
    }
  }

  Future<void> _saveMoodEntry() async {
    if (_currentMood == null || _targetMood == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(moodNotifierProvider.notifier)
          .addMoodEntry(
            mood: _currentMood!,
            note: 'Target: ${_targetMood!.name}',
            tags: {'targetMood': _targetMood!.name},
          );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mood saved!')));
      context.go('/chat');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save mood: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _selectMood(MoodLevel mood) {
    setState(() {
      if (_currentStep == 0) {
        _currentMood = mood;
      } else {
        _targetMood = mood;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(_currentStep == 0 ? Icons.close : Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: List.generate(2, (index) {
            final isActive = index <= _currentStep;
            return Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(
                _stepTitle,
                style: AppTypography.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _stepSubtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.42,
                  ),
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    final isSelected = _selectedMood == option.mood;
                    return _MoodCard(
                      option: option,
                      isSelected: isSelected,
                      onTap: () => _selectMood(option.mood),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: _currentStep == 0 ? 'Continue' : 'Save & Chat',
                onPressed: _selectedMood == null ? null : _next,
                isLoading: _isSaving,
                isFullWidth: true,
              ),
              if (_currentStep == 1) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => context.go('/chat'),
                  child: Center(
                    child: Text(
                      'Skip & Chat Now',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MoodOption {
  final MoodLevel mood;
  final String label;
  final String icon;

  const MoodOption({
    required this.mood,
    required this.label,
    required this.icon,
  });
}

class _MoodCard extends StatelessWidget {
  final MoodOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withValues(alpha: 0.2)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(option.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              option.label,
              style: AppTypography.bodySmall.copyWith(
                height: 1.1,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
