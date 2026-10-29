import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'star_particle.dart';

/// Pintor para las estrellas titilantes y flotantes de fondo.
/// Solo itera sobre las estrellas del cosmos profundo, sin sobrecargar la CPU con Saturno.
class StarFieldPainter extends CustomPainter {
  final List<StarParticle> particles;
  final double timeSeconds;
  final Size screenSize;

  // Cache de Paths para evitar crearlos repetidamente
  static final Map<int, Path> _starPathCache = {};

  StarFieldPainter({
    required this.particles,
    required this.timeSeconds,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      _updateBackgroundParticle(particle, size);
      _drawStar(canvas, particle, paint);
    }
  }

  void _updateBackgroundParticle(StarParticle p, Size size) {
    double brownianX = cos(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20;
    double brownianY = sin(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20;
    p.position = Offset(p.origin.dx + brownianX, p.origin.dy + brownianY);
  }

  void _drawStar(Canvas canvas, StarParticle particle, Paint paint) {
    double currentOpacity = particle.currentOpacity(timeSeconds);
    if (currentOpacity < 0.1) return;

    // Resplandor / Glow con blur para estrellas grandes
    if (particle.hasGlow && particle.size > 3.0) {
      final glowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = particle.particleColor.withOpacity(currentOpacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      canvas.drawCircle(particle.position, particle.size * 1.2, glowPaint);
    }

    paint.color = AppColors.starCore.withOpacity(0.8 * currentOpacity);

    // Formas complejas de estrella (★ ✦ ✧) para estrellas grandes (> 3.0px)
    if (particle.size > 3.0) {
      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotationAngle);

      Path starPath = _getStarPath(particle.starType, particle.size);
      canvas.drawPath(starPath, paint);
      canvas.restore();
    } else {
      // Círculo nítido para estrellas más pequeñas
      canvas.drawCircle(particle.position, particle.size * 0.5, paint);
    }
  }

  Path _getStarPath(int type, double size) {
    int cacheKey = type * 1000 + (size * 10).toInt();
    if (_starPathCache.containsKey(cacheKey)) {
      return _starPathCache[cacheKey]!;
    }

    Path path;
    switch (type) {
      case 0:
        path = _createStarPath(5, size, size * 0.4);
        break;
      case 1:
        path = _createStarPath(4, size * 1.2, size * 0.2);
        break;
      default:
        path = _createStarPath(8, size * 0.9, size * 0.5);
        break;
    }
    _starPathCache[cacheKey] = path;
    return path;
  }

  Path _createStarPath(int points, double outerRadius, double innerRadius) {
    Path path = Path();
    double step = pi / points;
    for (int i = 0; i < 2 * points; i++) {
      double r = (i % 2 == 0) ? outerRadius : innerRadius;
      double theta = i * step - pi / 2;
      double x = r * cos(theta);
      double y = r * sin(theta);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant StarFieldPainter oldDelegate) {
    return oldDelegate.timeSeconds != timeSeconds ||
        oldDelegate.screenSize != screenSize;
  }
}

/// Pintor ultra-eficiente para Saturno:
/// Se dibuja exactamente UNA VEZ en su propio RepaintBoundary.
/// Toda la rotación de Saturno es ejecutada directamente por el compositor de la GPU
/// (sin repintar canvas ni calcular matemáticas en CPU).
class SaturnPicturePainter extends CustomPainter {
  final Picture? picture;

  const SaturnPicturePainter(this.picture);

  @override
  void paint(Canvas canvas, Size size) {
    if (picture == null) return;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.drawPicture(picture!);
  }

  @override
  bool shouldRepaint(covariant SaturnPicturePainter oldDelegate) {
    return oldDelegate.picture != picture;
  }
}
