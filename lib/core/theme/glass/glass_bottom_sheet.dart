import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../colors.dart';
import 'glass_theme_tokens.dart';
import '../../../features/settings/presentation/controllers/settings_controller.dart';

/// Modal bottom sheet wrapper with dark smoked-glass effect when Glassy Interface is ON.
class GlassBottomSheetContainer extends ConsumerWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const GlassBottomSheetContainer({
    super.key,
    required this.child,
    this.borderRadius = 28.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGlassy = ref.watch(isGlassyThemeEnabledProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isGlassy) {
      return ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: GlassTokens.blurSigma,
            sigmaY: GlassTokens.blurSigma,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: isDark
                  ? GlassTokens.surfaceGradient
                  : GlassTokens.lightSurfaceGradient,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(borderRadius)),
              border: Border.all(
                color: isDark
                    ? GlassTokens.silverBorder
                    : GlassTokens.lightGlassBorder,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.6)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: child,
          ),
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
        border: Border.all(
          color: AppColors.border(isDark),
        ),
      ),
      child: child,
    );
  }
}
