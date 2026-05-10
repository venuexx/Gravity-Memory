import 'package:flutter/material.dart';
import '../core/constants.dart';

class GmButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool filled;
  final Color? color;
  final double labelSize;

  const GmButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.filled = true,
    this.color,
    this.labelSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? (color ?? AppColors.white) : Colors.transparent;
    final fg = filled ? AppColors.background : (color ?? AppColors.white);
    final border = filled ? null : Border.all(color: AppColors.greyDark, width: 1.5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          color: bg,
          border: border,
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: fg, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTextStyles.body(size: labelSize, color: fg).copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
