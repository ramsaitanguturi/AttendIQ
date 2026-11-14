import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';
import '../../features/settings/presentation/controllers/settings_controller.dart';

/// Navigation item model for ACEDRA's 4 core destinations.
class AcedraNavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AcedraNavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Floating smoked-glass navigation bar featuring a raised translucent
/// optical glass bubble with silver specular reflections and fluid sliding animation,
/// recreated frame-by-frame from the ACEDRA reference video.
class AcedraFloatingBottomBar extends ConsumerStatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const AcedraFloatingBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  static const List<AcedraNavigationItem> items = [
    AcedraNavigationItem(
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    AcedraNavigationItem(
      icon: Icons.calendar_month_rounded,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Timetable',
    ),
    AcedraNavigationItem(
      icon: Icons.insights_rounded,
      activeIcon: Icons.insights_rounded,
      label: 'Analytics',
    ),
    AcedraNavigationItem(
      icon: Icons.group_rounded,
      activeIcon: Icons.group_rounded,
      label: 'Account',
    ),
  ];

  // Track & Bubble Dimensions
  static const double kTrackHeight = 64.0;
  static const double kBubbleHeight = 78.0;
  static const double kBubbleRadius = 32.0;

  /// Total height occupied by the floating bar from the bottom of the screen,
  /// including the raised bubble and bottom margin with system navigation inset.
  static double totalBarHeight(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomMargin = bottomPadding > 0 ? bottomPadding + 6.0 : 16.0;
    return kBubbleHeight + bottomMargin;
  }

  /// Recommended bottom padding for scrollable page content so that the last
  /// card, list item, or footer can scroll completely and comfortably above
  /// the floating navigation bar and its raised bubble / drop shadows.
  static double contentBottomPadding(BuildContext context,
      {double additionalClearance = 24.0}) {
    return totalBarHeight(context) + additionalClearance;
  }

  /// Recommended bottom padding to wrap a FloatingActionButton so it floats
  /// comfortably above the floating navigation bar and its raised bubble without colliding.
  static double fabBottomPadding(BuildContext context,
      {double clearance = 24.0}) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final barBottomMargin = bottomPadding > 0 ? bottomPadding + 6.0 : 16.0;
    // Scaffold default endFloat places the FAB at (bottomPadding + 16.0).
    // To position the FAB at: (barBottomMargin + kBubbleHeight + clearance),
    // the extra bottom padding inside the FAB widget is:
    final targetOffset =
        (barBottomMargin + kBubbleHeight + clearance) - (bottomPadding + 16.0);
    return math.max(88.0, targetOffset);
  }

  @override
  ConsumerState<AcedraFloatingBottomBar> createState() =>
      _AcedraFloatingBottomBarState();
}

class _AcedraFloatingBottomBarState
    extends ConsumerState<AcedraFloatingBottomBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _slideAnimation;

  int _fromIndex = 0;
  int _toIndex = 0;

  // Track & Bubble Dimensions
  static const double kTrackHeight = AcedraFloatingBottomBar.kTrackHeight;
  static const double kBubbleHeight = AcedraFloatingBottomBar.kBubbleHeight;
  static const double kBubbleRadius = AcedraFloatingBottomBar.kBubbleRadius;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.currentIndex;
    _toIndex = widget.currentIndex;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _slideAnimation = Tween<double>(
      begin: _fromIndex.toDouble(),
      end: _toIndex.toDouble(),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Cubic(0.22, 1.0, 0.36, 1.0), // Fluid spring-like ease-out
      ),
    );
  }

  @override
  void didUpdateWidget(AcedraFloatingBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _fromIndex = _slideAnimation.value.round();
      _toIndex = widget.currentIndex;

      _slideAnimation = Tween<double>(
        begin: _slideAnimation.value,
        end: _toIndex.toDouble(),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Cubic(0.22, 1.0, 0.36, 1.0),
        ),
      );

      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTabTap(int index) {
    if (index == widget.currentIndex) {
      HapticFeedback.selectionClick();
      return;
    }
    HapticFeedback.lightImpact();
    widget.onTabSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isGlassy = ref.watch(isGlassyThemeEnabledProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Outer container padding respecting device navigation gestures
    final margin = EdgeInsets.only(
      left: 18.0,
      right: 18.0,
      bottom: bottomPadding > 0 ? bottomPadding + 6.0 : 16.0,
    );

    return Padding(
      padding: margin,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final itemCount = AcedraFloatingBottomBar.items.length;
          final slotWidth = totalWidth / itemCount;

          // Bubble dimensions: comfortable squircle/stadium
          final bubbleWidth = (slotWidth + 2.0).clamp(74.0, 88.0);

          return SizedBox(
            height: kBubbleHeight,
            width: totalWidth,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final currentAnimatedIndex = _slideAnimation.value;

                // Subtle fluid organic stretch during transition
                final travelDistance = (_toIndex - _fromIndex).abs();
                final velocity = math.sin(_controller.value * math.pi);
                final stretchFactor = travelDistance > 0
                    ? (velocity * travelDistance * 0.04).clamp(0.0, 0.09)
                    : 0.0;
                final dynamicBubbleWidth = bubbleWidth * (1.0 + stretchFactor);
                final dynamicBubbleHeight =
                    kBubbleHeight * (1.0 - (stretchFactor * 0.4));

                // Center the bubble horizontally over the animated slot
                final centerOffset = (currentAnimatedIndex + 0.5) * slotWidth;
                final bubbleLeft = centerOffset - (dynamicBubbleWidth / 2.0);
                final bubbleTop = (kBubbleHeight - dynamicBubbleHeight) / 2.0;

                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    // 1. Dark Smoked-Glass Container Track (Pitch-black Obsidian Pill)
                    Positioned(
                      top: (kBubbleHeight - kTrackHeight) / 2.0,
                      left: 0,
                      right: 0,
                      height: kTrackHeight,
                      child: _buildSmokedGlassTrack(isDark, isGlassy),
                    ),

                    // 2. Raised Circular/Capsule Optical Glass Selection Bubble
                    Positioned(
                      top: bubbleTop,
                      left: bubbleLeft,
                      width: dynamicBubbleWidth,
                      height: dynamicBubbleHeight,
                      child: _buildGlassBubble(
                        dynamicBubbleWidth,
                        dynamicBubbleHeight,
                        isDark,
                        isGlassy,
                      ),
                    ),

                    // 3. Interactive Navigation Items (Icons & Smoothly Animated Labels)
                    Positioned.fill(
                      child: Row(
                        children: List.generate(itemCount, (index) {
                          final item = AcedraFloatingBottomBar.items[index];

                          // Active fraction calculation:
                          // Target tab fades in, departure tab fades out, others stay 0
                          double activeFraction;
                          if (_controller.isAnimating) {
                            if (index == _toIndex) {
                              activeFraction = _controller.value;
                            } else if (index == _fromIndex) {
                              activeFraction = 1.0 - _controller.value;
                            } else {
                              activeFraction = 0.0;
                            }
                          } else {
                            activeFraction =
                                index == widget.currentIndex ? 1.0 : 0.0;
                          }

                          return Expanded(
                            child: _buildNavigationItem(
                              index: index,
                              item: item,
                              activeFraction: activeFraction,
                              isDark: isDark,
                              isGlassy: isGlassy,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// The dark/light smoked-glass container pill track.
  Widget _buildSmokedGlassTrack(bool isDark, bool isGlassy) {
    const trackRadius = kTrackHeight / 2.0;

    // Background color matching the monochromatic palette in dark or light mode
    final Color trackBgColor = isDark
        ? (isGlassy
            ? const Color(0xD8212529) // Translucent deep #212529
            : const Color(0xF8212529)) // Solid pitch #212529 smoked glass
        : (isGlassy
            ? const Color(0xEAFAFAFA) // Translucent crisp light #fafafa
            : const Color(0xFFFFFFFF)); // Crisp solid near-white

    final Color borderColor = isDark
        ? const Color(0x38DEE2E6) // Crisp translucent silver edge (#dee2e6)
        : const Color(0x60CED4DA); // Crisp translucent light edge (#ced4da)

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(trackRadius),
        boxShadow: isDark
            ? [
                // Deep ambient occlusion shadow beneath the pill
                BoxShadow(
                  color: Colors.black.withOpacity(0.60),
                  blurRadius: 30.0,
                  spreadRadius: -2.0,
                  offset: const Offset(0, 12),
                ),
                // Soft ambient contact shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 10.0,
                  spreadRadius: 0.0,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                // Light mode subtle elevation drop shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24.0,
                  spreadRadius: -2.0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8.0,
                  spreadRadius: 0.0,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(trackRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            decoration: BoxDecoration(
              color: trackBgColor,
              borderRadius: BorderRadius.circular(trackRadius),
              border: Border.all(
                color: borderColor,
                width: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The raised translucent glass selection bubble with realistic specular highlights.
  Widget _buildGlassBubble(
    double width,
    double height,
    bool isDark,
    bool isGlassy,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? null : const Color(0xE8212529),
        borderRadius: BorderRadius.circular(kBubbleRadius),
        boxShadow: isDark
            ? [
                // Deep ambient drop shadow casting onto track & background
                BoxShadow(
                  color: Colors.black.withOpacity(0.65),
                  blurRadius: 20.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0, 6),
                ),
                // Tight contact shadow for elevated 3D tactile depth
                BoxShadow(
                  color: Colors.black.withOpacity(0.40),
                  blurRadius: 6.0,
                  spreadRadius: 0.0,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                // Light mode distinct shadow under the obsidian selection bubble
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 16.0,
                  spreadRadius: 0.0,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kBubbleRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14.0, sigmaY: 14.0),
          child: CustomPaint(
            size: Size(width, height),
            painter: GlassBubblePainter(
              borderRadius: kBubbleRadius,
              isDark: isDark,
              isGlassy: isGlassy,
            ),
          ),
        ),
      ),
    );
  }

  /// Individual item content: smooth crossfade, glow, label reveal, and touch interaction.
  Widget _buildNavigationItem({
    required int index,
    required AcedraNavigationItem item,
    required double activeFraction,
    required bool isDark,
    required bool isGlassy,
  }) {
    // Unselected color adapts to dark vs light track
    final unselectedColor = isDark
        ? const Color(0x80DEE2E6) // Muted silver for dark mode
        : const Color(0xB0495057); // Charcoal for light mode

    // Colors dynamically lerped based on selection state
    final iconColor = Color.lerp(
      unselectedColor,
      AppColors.gray100, // Glowing pure silver-white inside the raised bubble
      activeFraction,
    )!;

    // When inactive, shift down (+6.5dp) to center icon alone vertically in track
    // When active, shift up (-5.5dp) to center icon+label combo in raised bubble
    final verticalShift = activeFraction > 0.0 ? -5.5 * activeFraction : 6.5;

    return Semantics(
      label: item.label,
      selected: index == widget.currentIndex,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleTabTap(index),
        child: Center(
          child: Transform.translate(
            offset: Offset(0, verticalShift),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with luminous white glow when active
                Container(
                  decoration: activeFraction > 0.1
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gray100
                                  .withOpacity(0.50 * activeFraction),
                              blurRadius: 10.0 * activeFraction,
                              spreadRadius: 1.0 * activeFraction,
                            ),
                          ],
                        )
                      : null,
                  child: Icon(
                    activeFraction > 0.5 ? item.activeIcon : item.icon,
                    size: 23.0,
                    color: iconColor,
                  ),
                ),

                const SizedBox(height: 3.0),

                // Text label (visually only visible when selected / active, hit-testable in tree)
                SizedBox(
                  height: 14.0,
                  child: Opacity(
                    opacity: activeFraction.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.88 + (0.12 * activeFraction),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.gray100,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter replicating the realistic optical glass reflections from the video:
/// - Horizontal silver specular highlight cap along the upper crest
/// - Horizontal silver specular highlight rim along the lower edge
/// - Neutral silver-white meniscus corner reflections
/// - Polished silver gradient perimeter rim
class GlassBubblePainter extends CustomPainter {
  final double borderRadius;
  final bool isDark;
  final bool isGlassy;

  GlassBubblePainter({
    required this.borderRadius,
    this.isDark = true,
    this.isGlassy = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // 1. Clip internal reflections to the bubble's rounded silhouette
    canvas.save();
    canvas.clipRRect(rrect);

    // 2. High-Clarity Obsidian Glass Interior
    // Clean, crystal-clear smoked glass that preserves deep black contrast in center
    final baseGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isGlassy
          ? const [
              Color(0x22FFFFFF), // Subtle top refraction
              Color(0x02FFFFFF), // Near-transparent core for deep contrast
              Color(0x10FFFFFF), // Soft bottom ambient
            ]
          : const [
              Color(0x18FFFFFF),
              Color(0x00FFFFFF),
              Color(0x0CFFFFFF),
            ],
      stops: const [0.0, 0.45, 1.0],
    );

    final basePaint = Paint()..shader = baseGradient.createShader(rect);
    canvas.drawRRect(rrect, basePaint);

    // 3. Top Specular Reflection (Silver Curved Cap Highlight)
    // Matches the wide horizontal silver reflection at the top of the reference bubble
    final topHighlightHeight = size.height * 0.26;
    final topRect = Rect.fromLTWH(0, 0, size.width, topHighlightHeight);

    final topHighlightPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, topHighlightHeight),
        const [
          Color(
              0xC0FFFFFF), // Softened silver-white crest (refined from harsh glare)
          Color(0x55FFFFFF), // Soft mid sheen
          Color(0x00FFFFFF), // Tapers smoothly into dark glass
        ],
        const [0.0, 0.45, 1.0],
      );

    // Flatter horizontal crescent across center with rounded corner curvature
    final topCrescentPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, topHighlightHeight * 0.70)
      ..quadraticBezierTo(
        size.width / 2,
        topHighlightHeight * 0.95,
        0,
        topHighlightHeight * 0.70,
      )
      ..close();

    canvas.drawPath(topCrescentPath, topHighlightPaint);

    // Neutral silver-white optical reflections at top meniscus corners
    final leftCornerSheen = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.12, 3),
        size.width * 0.28,
        const [
          Color(0x45FFFFFF), // Subtle neutral silver sheen
          Color(0x00FFFFFF),
        ],
      );
    canvas.drawRect(topRect, leftCornerSheen);

    final rightCornerSheen = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.88, 3),
        size.width * 0.28,
        const [
          Color(0x45FFFFFF), // Subtle neutral silver sheen
          Color(0x00FFFFFF),
        ],
      );
    canvas.drawRect(topRect, rightCornerSheen);

    // 4. Bottom Specular Reflection (Lower Curved Silver Rim)
    // Matches the matching bottom silver rim of the reference bubble
    final bottomHighlightHeight = size.height * 0.24;
    final bottomRect = Rect.fromLTWH(
      0,
      size.height - bottomHighlightHeight,
      size.width,
      bottomHighlightHeight,
    );

    final bottomHighlightPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width / 2, size.height),
        Offset(size.width / 2, size.height - bottomHighlightHeight),
        const [
          Color(0x9EFFFFFF), // Softened silver reflection along bottom rim
          Color(0x40FFFFFF), // Soft mid sheen
          Color(0x00FFFFFF),
        ],
        const [0.0, 0.45, 1.0],
      );

    final bottomCrescentPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height - bottomHighlightHeight * 0.70)
      ..quadraticBezierTo(
        size.width / 2,
        size.height - bottomHighlightHeight * 0.95,
        0,
        size.height - bottomHighlightHeight * 0.70,
      )
      ..close();

    canvas.drawPath(bottomCrescentPath, bottomHighlightPaint);

    // Bottom subtle neutral silver edge sheen
    final botCornerSheen = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width / 2, size.height),
        size.width * 0.45,
        const [
          Color(0x22FFFFFF), // Subtle neutral silver sheen
          Color(0x00FFFFFF),
        ],
      );
    canvas.drawRect(bottomRect, botCornerSheen);

    // 5. Subtle Inner Lens Bevel Stroke (Reflective 3D Volume)
    final innerBevelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        const [
          Color(0x48FFFFFF),
          Color(0x0AFFFFFF),
          Color(0x38FFFFFF),
        ],
        const [0.0, 0.5, 1.0],
      );
    canvas.drawRRect(rrect.deflate(0.5), innerBevelPaint);

    canvas.restore();

    // 6. Polished Silver Outer Perimeter Rim
    final outerRimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, size.height),
        const [
          Color(0x90FFFFFF), // Polished silver top crest
          Color(0x20FFFFFF), // Sleek lateral translucent edge
          Color(0x60FFFFFF), // Bottom reflective edge
        ],
        const [0.0, 0.5, 1.0],
      );
    canvas.drawRRect(rrect, outerRimPaint);
  }

  @override
  bool shouldRepaint(covariant GlassBubblePainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isGlassy != isGlassy;
  }
}
