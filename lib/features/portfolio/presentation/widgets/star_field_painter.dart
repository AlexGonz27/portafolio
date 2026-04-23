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
    // El ancla del planeta siempre está en su posición final (derecha)
    // Ajustado al 82% para dejar ~65% libre a la izquierda para el contenido
    Offset endCenter = Offset(size.width * 0.82, size.height * 0.50);
    Offset currentPlanetCenter = endCenter; 

    // La formación depende exclusivamente de la animación suavizada por scroll
    final finalFormationT = formationOverride ?? phaseController.formationProgress;
    final gravity = phaseController.gravityForce;

    for (var p in particles) {
      p.lastPosition = p.position;

      double driftAmount = 1.0 - (max(finalFormationT, gravity) * 0.85);
      double brownianX = cos(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20 * driftAmount;
      double brownianY = sin(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20 * driftAmount;
      Offset chaoticPos = Offset(p.origin.dx + brownianX, p.origin.dy + brownianY);

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

        Offset targetPos = currentPlanetCenter + Offset(tx, ty);
        p.position = Offset.lerp(chaoticPos, targetPos, finalFormationT)!;
      } else {
        p.position = chaoticPos;
      }
    }
  }

  void _drawStar(Canvas canvas, StarParticle particle, Paint paint) {
    double currentOpacity = particle.currentOpacity(timeSeconds);
    
    // Core paint
    paint.color = AppColors.starCore.withOpacity(currentOpacity);

    // Glow individual
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = particle.particleColor.withOpacity(currentOpacity * 0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size);

    canvas.save();
    canvas.translate(particle.position.dx, particle.position.dy);
    canvas.rotate(particle.rotationAngle);

    Path starPath;
    switch (particle.starType) {
      case 0: starPath = _createStarPath(5, particle.size, particle.size * 0.4); break;
      case 1: starPath = _createStarPath(4, particle.size * 1.2, particle.size * 0.2); break;
      case 2: starPath = _createStarPath(8, particle.size * 0.9, particle.size * 0.5); break;
      default: 
        canvas.drawCircle(Offset.zero, particle.size * 0.4, glowPaint);
        canvas.drawCircle(Offset.zero, particle.size * 0.4, paint);
        canvas.restore();
        return;
    }

    canvas.drawPath(starPath, glowPaint);
    canvas.drawPath(starPath, paint);
    canvas.restore();
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
           oldDelegate.formationOverride != formationOverride ||
           oldDelegate.screenSize != screenSize;
  }
}
