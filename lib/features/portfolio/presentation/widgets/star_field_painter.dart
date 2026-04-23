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

  StarFieldPainter({
    required this.particles,
    required this.phaseController,
    required this.timeSeconds,
    required this.screenSize,
    this.formationOverride,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;
    
    _updateParticlePositions(size);

    for (var particle in particles) {
      _drawStar(canvas, particle, paint);
    }
  }

  void _updateParticlePositions(Size size) {
    // Posición fija optimizada
    Offset endCenter = Offset(size.width * 0.82, size.height * 0.50);
    
    final finalFormationT = formationOverride ?? phaseController.formationProgress;
    final isFullyFormed = finalFormationT >= 1.0;

    for (var p in particles) {
      p.lastPosition = p.position;

      if (p.isPlanet && p.planetRadius != null && p.planetAngle != null) {
        // CÁLCULO DE ROTACIÓN ORBITAL
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
          // OPTIMIZACIÓN: Saltamos el lerp si ya está formado
          p.position = targetPos;
        } else {
          // Solo calculamos el caos si es necesario
          double driftAmount = 1.0 - (finalFormationT * 0.85);
          double brownianX = cos(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20 * driftAmount;
          double brownianY = sin(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20 * driftAmount;
          Offset chaoticPos = Offset(p.origin.dx + brownianX, p.origin.dy + brownianY);
          p.position = Offset.lerp(chaoticPos, targetPos, finalFormationT)!;
        }
      } else {
        // Estrellas de fondo
        double brownianX = cos(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20;
        double brownianY = sin(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20;
        p.position = Offset(p.origin.dx + brownianX, p.origin.dy + brownianY);
      }
    }
  }

  void _drawStar(Canvas canvas, StarParticle particle, Paint paint) {
    double currentOpacity = particle.currentOpacity(timeSeconds);
    if (currentOpacity < 0.05) return; 

    // Glow selectivo: Solo para estrellas marcadas y con tamaño suficiente
    if (particle.hasGlow && particle.size > 1.5) {
      final glowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = particle.particleColor.withOpacity(currentOpacity * 0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.8);
      canvas.drawCircle(particle.position, particle.size * 1.5, glowPaint);
    }

    paint.color = (particle.isPlanet ? AppColors.starCore : AppColors.starCore.withOpacity(0.8))
        .withOpacity(currentOpacity);

    // Solo usar paths de estrellas para las más grandes (> 2.5px)
    if (particle.size > 2.5) {
      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotationAngle);
      
      Path starPath;
      switch (particle.starType) {
        case 0: starPath = _createStarPath(5, particle.size, particle.size * 0.4); break;
        case 1: starPath = _createStarPath(4, particle.size * 1.2, particle.size * 0.2); break;
        default: starPath = _createStarPath(8, particle.size * 0.9, particle.size * 0.5); break;
      }
      canvas.drawPath(starPath, paint);
      canvas.restore();
    } else {
      canvas.drawCircle(particle.position, particle.size * 0.5, paint);
    }
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
           oldDelegate.screenSize != screenSize;
  }
}
