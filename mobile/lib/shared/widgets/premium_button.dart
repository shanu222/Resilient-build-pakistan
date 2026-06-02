import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import 'hover_lift.dart';

enum PremiumButtonVariant { orange, blue }

class PremiumButton extends StatelessWidget {
  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = PremiumButtonVariant.orange,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PremiumButtonVariant variant;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = context.appTokens;

    final gradient = switch (variant) {
      PremiumButtonVariant.orange => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.orange, AppColors.orangeLight],
        ),
      PremiumButtonVariant.blue => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
        ),
    };

    final child = Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: enabled ? gradient : null,
        color: enabled
            ? null
            : (isDark ? AppColors.darkPanel : AppColors.muted),
        borderRadius: BorderRadius.circular(14),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: (variant == PremiumButtonVariant.orange
                          ? AppColors.orange
                          : AppColors.info)
                      .withValues(alpha: isDark ? 0.25 : 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
        border: Border.all(
          color: tokens.textOnPrimary.withValues(alpha: enabled ? 0.14 : 0.10),
        ),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: tokens.textOnPrimary, size: 18),
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: TextStyle(
              color: tokens.textOnPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    return HoverLift(
      enabled: enabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: child,
        ),
      ),
    );
  }
}

