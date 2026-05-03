import 'package:buddy/core/theme/app_colors.dart';
import 'package:buddy/core/theme/app_typography.dart';
import 'package:buddy/core/widgets/buddy_avatar.dart';
import 'package:buddy/providers/voice_call_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class VoiceCallScreen extends ConsumerStatefulWidget {
  const VoiceCallScreen({super.key});

  @override
  ConsumerState<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends ConsumerState<VoiceCallScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceCallProvider.notifier).resetSession();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      ref.read(voiceCallProvider.notifier).stopActiveAudio();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(voiceCallProvider.notifier).stopActiveAudio();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _endCall() async {
    await ref.read(voiceCallProvider.notifier).endCall();
    if (!mounted) return;
    context.pop();
  }

  String _statusLabel(VoiceCallState state) {
    if (state.isListening) return 'Listening...';
    if (state.isThinking) return 'Thinking...';
    if (state.isSpeaking) return 'Buddy is speaking...';
    return 'Tap to talk';
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(voiceCallProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1,
            colors: [Color(0xFF17655B), AppColors.callBackground],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _endCall,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
              const SizedBox(height: 6),
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, child) {
                  final glow = 98 + (_pulse.value * 28);
                  return Container(
                    width: glow,
                    height: glow,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    child: const Center(child: BuddyAvatar(size: 82)),
                  );
                },
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  _statusLabel(callState),
                  key: ValueKey(_statusLabel(callState)),
                  style: AppTypography.heading3.copyWith(color: Colors.white),
                ),
              ),
              if (callState.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  callState.errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
              if (callState.lastRecognizedText.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    callState.lastRecognizedText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: callState.callMessages.isEmpty
                      ? Center(
                          child: Text(
                            'Your voice conversation appears here.',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: callState.callMessages.length,
                          itemBuilder: (_, index) {
                            final message = callState.callMessages[index];
                            final isUser = message.role == 'user';
                            return Align(
                              alignment: isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(10),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.76,
                                ),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? AppColors.primary.withValues(alpha: 0.9)
                                      : Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(14),
                                    topRight: const Radius.circular(14),
                                    bottomLeft: Radius.circular(
                                      isUser ? 14 : 4,
                                    ),
                                    bottomRight: Radius.circular(
                                      isUser ? 4 : 14,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.content,
                                      style: AppTypography.body.copyWith(
                                        color: isUser
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat(
                                        'h:mm a',
                                      ).format(message.timestamp),
                                      style: AppTypography.caption.copyWith(
                                        color: isUser
                                            ? Colors.white.withValues(
                                                alpha: 0.8,
                                              )
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: callState.isThinking
                    ? null
                    : () => ref
                          .read(voiceCallProvider.notifier)
                          .toggleListening(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: callState.isListening
                          ? AppColors.callStop
                          : AppColors.primary,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    callState.isListening
                        ? Icons.stop_rounded
                        : Icons.mic_rounded,
                    color: callState.isListening
                        ? AppColors.callStop
                        : AppColors.primary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: _endCall,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.callStop),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'End Call',
                  style: TextStyle(color: AppColors.callStop),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  'Buddy can support you, but it isn\'t a replacement for professional help.',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
