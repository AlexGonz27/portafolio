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
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(24.0),
    this.margin,
    this.customBorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: customBorder ?? Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: -5,
                )
              ]
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
