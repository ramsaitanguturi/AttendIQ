import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Professional ACEDRA Monogram and Brand Widget.
///
/// Features the precision-engineered geometric "A" monogram with dark smoked-glass
/// and metallic silver reflection aesthetics, adhering strictly to the official
/// 9-color monochromatic palette.
class AcedraLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final Color? wordmarkColor;
  final double spacing;
  final bool? isDark;
  final bool withContainer;

  const AcedraLogo({
    super.key,
    this.size = 64.0,
    this.showWordmark = false,
    this.wordmarkColor,
    this.spacing = 12.0,
    this.isDark,
    this.withContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDark =
        isDark ?? (Theme.of(context).brightness == Brightness.dark);
    final textColor = wordmarkColor ??
        (effectiveDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary);

    Widget iconWidget = Container(
      width: size,
      height: size,
      decoration: withContainer
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(effectiveDark ? 0.35 : 0.08),
                  blurRadius: size * 0.2,
                  offset: Offset(0, size * 0.06),
                ),
                if (effectiveDark)
                  BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: size * 0.12,
                    offset: Offset.zero,
                  ),
              ],
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: CustomPaint(
          size: Size(size, size),
          painter: AcedraMonogramPainter(
            isDark: effectiveDark,
            withBackground: withContainer,
          ),
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

/// Custom painter rendering the precision-cut ACEDRA metallic silver monogram:
/// - Smoked obsidian / bright silver glass squircle base
/// - Polished silver outer perimeter rim
/// - Dual faceted structural arms with realistic metallic gradients
/// - Dimensional cross-strut and floating precision diamond core
/// - Specular apex glint
class AcedraMonogramPainter extends CustomPainter {
  final bool isDark;
  final bool withBackground;

  const AcedraMonogramPainter({
    this.isDark = true,
    this.withBackground = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    const gray100 = AppColors.gray100; // #F8F9FA
    const gray200 = AppColors.gray200; // #E9ECEF
    const gray300 = AppColors.gray300; // #DEE2E6
    const gray400 = AppColors.gray400; // #CED4DA
    const gray500 = AppColors.gray500; // #ADB5BD
    const gray600 = AppColors.gray600; // #6C757D
    const gray700 = AppColors.gray700; // #495057
    const gray800 = AppColors.gray800; // #343A40
    const gray900 = AppColors.gray900; // #212529

    if (withBackground) {
      // 1. Smoked Glass Squircle Base
      final radius = Radius.circular(w * 0.22);
      final bgRect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), radius);

      final bgPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(w, h),
          isDark
              ? const [
                  Color(0xFF2C3238), // Deep charcoal #343a40 / #212529 blend
                  Color(0xFF181B1E), // Deep obsidian
                ]
              : const [
                  Color(0xFFFFFFFF), // Pure white
                  Color(0xFFE9ECEF), // Light silver #E9ECEF
                ],
        );
      canvas.drawRRect(bgRect, bgPaint);

      // Polished Silver Outer Rim
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (w * 0.024).clamp(0.8, 5.0)
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(w, h),
          isDark
              ? const [
                  Color(0x90F8F9FA), // Top specular reflection
                  Color(0x28DEE2E6), // Lateral edge
                  Color(0x50DEE2E6), // Bottom reflection
                ]
              : const [
                  Color(0x90CED4DA),
                  Color(0x40ADB5BD),
                  Color(0x70CED4DA),
                ],
          const [0.0, 0.5, 1.0],
        );
      canvas.drawRRect(
          bgRect.deflate(borderPaint.strokeWidth / 2), borderPaint);
    }

    // 2. Precision Geometric Monogram "A"
    final apexX = w * 0.50;
    final apexY = h * 0.18;
    final leftFootX = w * 0.18;
    final leftFootY = h * 0.82;
    final rightFootX = w * 0.82;
    final rightFootY = h * 0.82;

    final armThickness = w * 0.145;

    // Left Facet (Brushed Metallic Silver Gradient)
    final leftArmPath = Path()
      ..moveTo(apexX, apexY)
      ..lineTo(apexX - armThickness * 0.45, apexY + armThickness * 0.55)
      ..lineTo(leftFootX, leftFootY)
      ..lineTo(leftFootX + armThickness, leftFootY)
      ..lineTo(apexX, apexY + armThickness * 1.55)
      ..close();

    final leftArmPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(leftFootX, leftFootY),
        Offset(apexX, apexY),
        isDark
            ? const [
                gray600,
                gray400,
                gray200,
              ]
            : const [
                gray700,
                gray500,
                gray300,
              ],
        const [0.0, 0.55, 1.0],
      );
    canvas.drawPath(leftArmPath, leftArmPaint);

    // Right Facet (Specular Luminous Silver Gradient)
    final rightArmPath = Path()
      ..moveTo(apexX, apexY)
      ..lineTo(rightFootX, rightFootY)
      ..lineTo(rightFootX - armThickness, rightFootY)
      ..lineTo(apexX, apexY + armThickness * 1.55)
      ..close();

    final rightArmPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(apexX, apexY),
        Offset(rightFootX, rightFootY),
        isDark
            ? const [
                gray100, // #F8F9FA specular highlight
                gray200, // #E9ECEF
                gray400, // #CED4DA
              ]
            : const [
                gray800,
                gray700,
                gray500,
              ],
        const [0.0, 0.45, 1.0],
      );
    canvas.drawPath(rightArmPath, rightArmPaint);

    // Geometric Cross-Strut with Dimensional Floating Bevel
    final crossBarTop = h * 0.54;
    final crossBarBottom = h * 0.64;
    final crossLeft = w * 0.285;
    final crossRight = w * 0.715;

    final crossPath = Path()
      ..moveTo(crossLeft, crossBarTop)
      ..lineTo(crossRight, crossBarTop)
      ..lineTo(crossRight - armThickness * 0.35, crossBarBottom)
      ..lineTo(crossLeft + armThickness * 0.35, crossBarBottom)
      ..close();

    final crossPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(crossLeft, crossBarTop),
        Offset(crossRight, crossBarBottom),
        isDark
            ? const [
                gray300,
                gray100,
                gray400,
              ]
            : const [
                gray400,
                gray200,
                gray500,
              ],
        const [0.0, 0.5, 1.0],
      );
    canvas.drawPath(crossPath, crossPaint);

    // Central Floating Precision Diamond (Inner Core)
    final coreCenterY = h * 0.42;
    final coreRadius = w * 0.07;
    final diamondPath = Path()
      ..moveTo(apexX, coreCenterY - coreRadius)
      ..lineTo(apexX + coreRadius * 0.85, coreCenterY)
      ..lineTo(apexX, coreCenterY + coreRadius)
      ..lineTo(apexX - coreRadius * 0.85, coreCenterY)
      ..close();

    final diamondPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(apexX, coreCenterY - coreRadius),
        Offset(apexX, coreCenterY + coreRadius),
        isDark ? const [gray100, gray500] : const [gray900, gray600],
      );
    canvas.drawPath(diamondPath, diamondPaint);

    // Top Apex Specular Glint
    if (isDark) {
      final glintPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(apexX, apexY),
          w * 0.12,
          [
            gray100.withOpacity(0.85),
            gray100.withOpacity(0.0),
          ],
        );
      canvas.drawCircle(Offset(apexX, apexY), w * 0.12, glintPaint);
    }
  }

  @override
  bool shouldRepaint(covariant AcedraMonogramPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.withBackground != withBackground;
  }
}
