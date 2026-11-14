import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../colors.dart';
import 'glass_theme_tokens.dart';
import '../../../features/settings/presentation/controllers/settings_controller.dart';

/// Reusable Glass Dialog widget supporting both the centralized Glassy Theme (ON)
/// and standard Light/Dark surface design (OFF).
class GlassDialog extends ConsumerWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;

  const GlassDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.padding = const EdgeInsets.all(24.0),
    this.borderRadius = 24.0,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGlassy = ref.watch(isGlassyThemeEnabledProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final child = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          DefaultTextStyle(
            style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ) ??
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            child: title!,
          ),
          const SizedBox(height: 16),
        ],
        if (content != null) ...[
          Flexible(
            child: SingleChildScrollView(
              child: DefaultTextStyle(
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ) ??
                    const TextStyle(fontSize: 14),
                child: content!,
              ),
            ),
          ),
        ],
        if (actions != null && actions!.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions!,
          ),
        ],
      ],
    );

    if (isGlassy) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: GlassTokens.blurSigma,
              sigmaY: GlassTokens.blurSigma,
            ),
            child: Container(
              padding: padding,
              decoration: GlassTokens.glassBoxDecoration(
                borderRadius: borderRadius,
                isDark: isDark,
                customBorderColor: borderColor,
              ),
              child: child,
            ),
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: AppColors.surface(isDark),
      elevation: 6,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: borderColor ?? AppColors.border(isDark),
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
