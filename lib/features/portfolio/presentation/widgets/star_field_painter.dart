import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'scroll_phase_controller.dart';
import 'star_particle.dart';

class StarFieldPainter extends CustomPainter {
  final List<StarParticle> particles;
  final ScrollPhaseController phaseController;
  final double timeSeconds;
  final Size screenSize;
  final double? formationOverride;
  final Picture? planetBodyPicture;
  final Picture? planetRingsPicture;

  // Cache de Paths para evitar crearlos 60 veces por segundo por cada estrella
  static final Map<int, Path> _starPathCache = {};

  StarFieldPainter({
    required this.particles,
    required this.phaseController,
    required this.timeSeconds,
    required this.screenSize,
    this.formationOverride,
    this.planetBodyPicture,
    this.planetRingsPicture,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;
    
    final finalFormationT = formationOverride ?? phaseController.formationProgress;
    final bool canUseBaking = finalFormationT >= 1.0 && planetBodyPicture != null && planetRingsPicture != null;

    if (canUseBaking) {
      // 1. Dibujar estrellas de fondo
      for (var particle in particles) {
        if (!particle.isPlanet) {
          _updateBackgroundParticle(particle, size);
          _drawStar(canvas, particle, paint);
        }
      }
      // 2. Dibujar Saturno "Horneado"
      _drawBakedPlanet(canvas, size);
    } else {
      _updateParticlePositions(size);
      for (var particle in particles) {
        _drawStar(canvas, particle, paint);
      }
    }
  }

  void _updateBackgroundParticle(StarParticle p, Size size) {
    double brownianX = cos(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20;
    double brownianY = sin(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20;
    p.position = Offset(p.origin.dx + brownianX, p.origin.dy + brownianY);
  }

  void _drawBakedPlanet(Canvas canvas, Size size) {
    Offset endCenter = Offset(size.width * 0.82, size.height * 0.50);

    canvas.save();
    canvas.translate(endCenter.dx, endCenter.dy);
    canvas.rotate(timeSeconds * 0.15); 
    canvas.drawPicture(planetBodyPicture!);
    canvas.restore();

    canvas.save();
    canvas.translate(endCenter.dx, endCenter.dy);
    canvas.rotate(0.20); 
    canvas.scale(1.0, 0.32); 
    canvas.rotate(timeSeconds * 0.3); 
    canvas.drawPicture(planetRingsPicture!);
    canvas.restore();
  }

  void _updateParticlePositions(Size size) {
    Offset endCenter = Offset(size.width * 0.82, size.height * 0.50);
    final finalFormationT = formationOverride ?? phaseController.formationProgress;
    final isFullyFormed = finalFormationT >= 1.0;

    for (var p in particles) {
      p.lastPosition = p.position;

      if (p.isPlanet && p.planetRadius != null && p.planetAngle != null) {
        double orbitSpeed = p.isRing ? 0.3 : 0.15;
        double currentAngle = p.planetAngle! + timeSeconds * orbitSpeed;

        double tx = p.planetRadius! * cos(currentAngle);
        double ty = p.planetRadius! * sin(currentAngle);

        if (p.isRing) {
          double py = ty * 0.32;
          double tilt = 0.20;
          double rotatedX = tx * cos(tilt) - py * sin(tilt);
          double rotatedY = tx * sin(tilt) + py * cos(tilt);
          tx = rotatedX;
          ty = rotatedY;
        }

        Offset targetPos = endCenter + Offset(tx, ty);

        if (isFullyFormed) {
          p.position = targetPos;
        } else {
          double driftAmount = 1.0 - (finalFormationT * 0.85);
          double brownianX = cos(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20 * driftAmount;
          double brownianY = sin(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20 * driftAmount;
          Offset chaoticPos = Offset(p.origin.dx + brownianX, p.origin.dy + brownianY);
          p.position = Offset.lerp(chaoticPos, targetPos, finalFormationT)!;
        }
      } else {
        double brownianX = cos(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20;
        double brownianY = sin(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20;
        p.position = Offset(p.origin.dx + brownianX, p.origin.dy + brownianY);
      }
    }
  }

  void _drawStar(Canvas canvas, StarParticle particle, Paint paint) {
    double currentOpacity = particle.currentOpacity(timeSeconds);
    if (currentOpacity < 0.1) return; // Umbral de opacidad más alto para saltar estrellas tenues

    // Glow ultra-optimizado: Solo para estrellas muy grandes
    if (particle.hasGlow && particle.size > 3.0) {
      final glowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = particle.particleColor.withOpacity(currentOpacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0); // Blur fijo y pequeño
      canvas.drawCircle(particle.position, particle.size * 1.2, glowPaint);
    }

    paint.color = (particle.isPlanet
            ? AppColors.starCore
            : AppColors.starCore.withOpacity(0.8))
        .withOpacity(currentOpacity);

    // Solo usar paths para estrellas grandes (> 3.0px)
    if (particle.size > 3.0) {
      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotationAngle);

      // Usar cache de Path
      Path starPath = _getStarPath(particle.starType, particle.size);
      canvas.drawPath(starPath, paint);
      canvas.restore();
    } else {
      // Círculo simple para la gran mayoría
      canvas.drawCircle(particle.position, particle.size * 0.5, paint);
    }
  }

  Path _getStarPath(int type, double size) {
    // Generar una llave única para el cache (tipo + tamaño aproximado)
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
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant StarFieldPainter oldDelegate) {
    return oldDelegate.timeSeconds != timeSeconds ||
        oldDelegate.screenSize != screenSize ||
        oldDelegate.phaseController.scrollOffset != phaseController.scrollOffset;
  }
}
