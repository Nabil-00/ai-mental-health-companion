import 'package:buddy/core/theme/app_colors.dart';
import 'package:buddy/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assistantColor = isDark
        ? const Color(0xFF1E2B28).withValues(alpha: 0.92)
        : const Color(0xFFF9FFFB).withValues(alpha: 0.94);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? null : assistantColor,
          gradient: isUser
              ? const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF23927F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser
              ? null
              : Border.all(color: AppColors.border.withValues(alpha: 0.45)),
          boxShadow: isUser
              ? const [
                  BoxShadow(
                    color: Color(0x1A1A7A6E),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 12,
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        child: Text(
          text,
          style: AppTypography.body.copyWith(
            color: isUser
                ? Colors.white
                : isDark
                ? const Color(0xFFE6EFEC)
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
