import 'package:buddy/core/theme/app_colors.dart';
import 'package:buddy/core/theme/app_spacing.dart';
import 'package:buddy/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class PillButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPress;
  final bool disabled;
  final bool loading;

  const PillButton({
    super.key,
    required this.label,
    required this.onPress,
    this.disabled = false,
    this.loading = false,
  });

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final inactive =
        widget.disabled || widget.loading || widget.onPress == null;
    return GestureDetector(
      onTapDown: inactive ? null : (_) => setState(() => _scale = 0.98),
      onTapCancel: inactive ? null : () => setState(() => _scale = 1),
      onTapUp: inactive
          ? null
          : (_) {
              setState(() => _scale = 1);
              widget.onPress?.call();
            },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
          decoration: BoxDecoration(
            color: inactive ? AppColors.disabled : AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  widget.label,
                  style: AppTypography.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
