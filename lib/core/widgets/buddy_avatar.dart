import 'package:buddy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BuddyAvatar extends StatelessWidget {
  final double size;
  final bool outlined;

  const BuddyAvatar({super.key, this.size = 40, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
          border: outlined
              ? Border.all(color: AppColors.border, width: 1.5)
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.08),
          child: Image.asset(
            'assets/images/buddy_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
