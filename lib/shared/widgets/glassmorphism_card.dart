import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Border? customBorder;

  const GlassmorphismCard({
    Key? key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.05,
    this.borderRadius = 2.0,
    this.padding = const EdgeInsets.all(24.0),
    this.margin,
    this.customBorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.background.withValues(alpha: opacity)
                  : Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(borderRadius),
              border: customBorder ??
                  Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : const Color(0xFF0F172A).withValues(alpha: 0.08),
                    width: 1.0,
                  ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.1)
                      : const Color(0xFF0F172A).withValues(alpha: 0.06),
                  blurRadius: 20,
                  spreadRadius: isDark ? -5 : 0,
                  offset: isDark ? Offset.zero : const Offset(0, 4),
                )
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
