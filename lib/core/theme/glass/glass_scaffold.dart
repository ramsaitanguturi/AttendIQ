import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../colors.dart';
import '../../../features/settings/presentation/controllers/settings_controller.dart';

/// Scaffolding wrapper providing the ambient smoked-glass background atmosphere
/// when Glassy Interface is enabled.
class GlassScaffold extends ConsumerWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;

  const GlassScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGlassy = ref.watch(isGlassyThemeEnabledProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget contentBody = body;

    if (isGlassy) {
      contentBody = Stack(
        children: [
          // Ambient Smoked/Light Grayscale background
          Positioned.fill(
            child: Container(
              color:
                  isDark ? AppColors.darkBackground : AppColors.lightBackground,
            ),
          ),
          // Soft ambient top-right specular gradient
          Positioned(
            top: -120,
            right: -100,
            width: 380,
            height: 380,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? AppColors.gray100 : AppColors.gray300)
                        .withOpacity(isDark ? 0.04 : 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Soft ambient mid-left neutral silver glow
          Positioned(
            top: 280,
            left: -140,
            width: 420,
            height: 420,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? AppColors.gray300 : AppColors.gray200)
                        .withOpacity(isDark ? 0.03 : 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content on top of ambient canvas
          contentBody,
        ],
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: appBar,
      body: contentBody,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
