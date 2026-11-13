import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Professional ACEDRA Monogram and Brand Widget.
///
/// Features the minimal, AI-inspired geometric monogram with dark smoked-glass
/// and silver visual aesthetic.
class AcedraLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final Color? wordmarkColor;
  final double spacing;

  const AcedraLogo({
    super.key,
    this.size = 64.0,
    this.showWordmark = false,
    this.wordmarkColor,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = wordmarkColor ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    Widget iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.08),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: size * 0.15,
            offset: Offset.zero,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          'assets/branding/acedra_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Elegant vector fallback in case asset is loading or missing
            return Container(
              color: const Color(0xFF141720),
              alignment: Alignment.center,
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: size * 0.55,
                  fontWeight: FontWeight.w900,
                  color: AppColors.silverReflect,
                  letterSpacing: -1,
                ),
              ),
            );
          },
        ),
      ),
    );

    if (!showWordmark) {
      return iconWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget,
        SizedBox(height: spacing),
        Text(
          'ACEDRA',
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w800,
            letterSpacing: 4.0,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
