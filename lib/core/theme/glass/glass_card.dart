import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../colors.dart';
import 'glass_theme_tokens.dart';
import '../../../features/settings/presentation/controllers/settings_controller.dart';

/// Reusable Glass Card supporting both the centralized Glassy Theme (ON)
/// and standard Light/Dark surface design (OFF).
class GlassCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool isElevated;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.borderRadius = 20.0,
    this.borderColor,
    this.onTap,
    this.isElevated = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGlassy = ref.watch(isGlassyThemeEnabledProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget container;

    if (isGlassy) {
      container = Container(
        width: width,
        height: height,
        margin: margin,
        decoration: GlassTokens.glassBoxDecoration(
          borderRadius: borderRadius,
          isElevated: isElevated,
          customBorderColor: borderColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: GlassTokens.blurSigma,
              sigmaY: GlassTokens.blurSigma,
            ),
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ),
      );
    } else {
      // Standard non-glass mode
      container = Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ??
                (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: 1.0,
          ),
          boxShadow: GlassTokens.cardShadows(isGlassy: false),
        ),
        child: child,
      );
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: container,
        ),
      );
    }

    return container;
  }
}
