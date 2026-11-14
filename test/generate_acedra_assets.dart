import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'Generate official ACEDRA monochromatic branding and launcher icon assets',
      () async {
    // 1. Standalone / Primary Dark Monogram (512x512)
    await _generateIcon(
      filePath: 'assets/branding/acedra_logo.png',
      dimension: 512,
      isDark: true,
      withBackground: true,
    );

    // 2. Android Mipmap Launcher Icons
    await _generateIcon(
      filePath: 'android/app/src/main/res/mipmap-mdpi/ic_launcher.png',
      dimension: 48,
      isDark: true,
      withBackground: true,
    );
    await _generateIcon(
      filePath: 'android/app/src/main/res/mipmap-hdpi/ic_launcher.png',
      dimension: 72,
      isDark: true,
      withBackground: true,
    );
    await _generateIcon(
      filePath: 'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png',
      dimension: 96,
      isDark: true,
      withBackground: true,
    );
    await _generateIcon(
      filePath: 'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png',
      dimension: 144,
      isDark: true,
      withBackground: true,
    );
    await _generateIcon(
      filePath: 'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
      dimension: 192,
      isDark: true,
      withBackground: true,
    );

    // 3. Web Icons
    await _generateIcon(
      filePath: 'web/favicon.png',
      dimension: 64,
      isDark: true,
      withBackground: true,
    );
    await _generateIcon(
      filePath: 'web/icons/Icon-192.png',
      dimension: 192,
      isDark: true,
      withBackground: true,
    );
    await _generateIcon(
      filePath: 'web/icons/Icon-512.png',
      dimension: 512,
      isDark: true,
      withBackground: true,
    );
    await _generateIcon(
      filePath: 'web/icons/Icon-maskable-192.png',
      dimension: 192,
      isDark: true,
      withBackground: true,
    );
    await _generateIcon(
      filePath: 'web/icons/Icon-maskable-512.png',
      dimension: 512,
      isDark: true,
      withBackground: true,
    );

    expect(File('assets/branding/acedra_logo.png').existsSync(), isTrue);
  });
}

Future<void> _generateIcon({
  required String filePath,
  required int dimension,
  required bool isDark,
  required bool withBackground,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, dimension.toDouble(), dimension.toDouble()),
  );
  final size = Size(dimension.toDouble(), dimension.toDouble());

  _paintAcedraMonogram(
    canvas: canvas,
    size: size,
    isDark: isDark,
    withBackground: withBackground,
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(dimension, dimension);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData != null) {
    final file = File(filePath);
    file.parent.createSync(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List());
  }
}

void _paintAcedraMonogram({
  required Canvas canvas,
  required Size size,
  required bool isDark,
  required bool withBackground,
}) {
  final w = size.width;
  final h = size.height;

  // Monochromatic palette colors
  const gray100 = Color(0xFFF8F9FA); // #f8f9fa
  const gray200 = Color(0xFFE9ECEF); // #e9ecef
  const gray300 = Color(0xFFDEE2E6); // #dee2e6
  const gray400 = Color(0xFFCED4DA); // #ced4da
  const gray500 = Color(0xFFADB5BD); // #adb5bd
  const gray600 = Color(0xFF6C757D); // #6c757d

  if (withBackground) {
    // 1. Smoked Glass Squircle Base
    final radius = Radius.circular(w * 0.22);
    final bgRect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), radius);

    // Deep Obsidian / Smoked Gradient
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(w, h),
        isDark
            ? const [
                Color(0xFF2C3238), // Deep charcoal #343a40 / #212529 mix
                Color(0xFF181B1E), // Deep obsidian
              ]
            : const [
                Color(0xFFFFFFFF), // Pure white
                Color(0xFFE9ECEF), // Light silver
              ],
      );
    canvas.drawRRect(bgRect, bgPaint);

    // Polished Silver Outer Rim
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.024).clamp(1.0, 6.0)
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(w, h),
        isDark
            ? const [
                Color(0x80F8F9FA), // Top specular reflection
                Color(0x20DEE2E6), // Lateral edge
                Color(0x40DEE2E6), // Bottom reflection
              ]
            : const [
                Color(0x80CED4DA),
                Color(0x40ADB5BD),
                Color(0x60CED4DA),
              ],
        const [0.0, 0.5, 1.0],
      );
    canvas.drawRRect(bgRect.deflate(borderPaint.strokeWidth / 2), borderPaint);
  }

  // 2. Precision Geometric Monogram "A"
  // Outer apex, bottom feet, inner aperture
  final apexX = w * 0.50;
  final apexY = h * 0.18;
  final leftFootX = w * 0.18;
  final leftFootY = h * 0.82;
  final rightFootX = w * 0.82;
  final rightFootY = h * 0.82;

  final armThickness = w * 0.145;

  // Left Facet (Brushed Silver Gradient)
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
      const [
        gray600,
        gray400,
        gray200,
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
      const [
        gray100, // #F8F9FA specular highlight
        gray200, // #E9ECEF
        gray400, // #CED4DA
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
      const [
        gray300,
        gray100,
        gray400,
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
      const [
        gray100,
        gray500,
      ],
    );
  canvas.drawPath(diamondPath, diamondPaint);

  // Top Apex Specular Glint
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
