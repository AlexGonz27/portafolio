import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'star_particle.dart';

/// Helper singleton para generar y cachear el atlas de texturas de estrellas en la GPU.
/// Permite dibujar cientos de estrellas en una sola llamada 'canvas.drawRawAtlas'
/// sin recrear Paths, sin usar 'save/restore' y sin sobrecargar la CPU.
class StarAtlasHelper {
  static ui.Image? _cachedAtlas;
  static bool _isGenerating = false;

  /// Retorna la textura atlas de 256x64 px con los 4 sprites vectoriales anti-alias.
  static Future<ui.Image> getAtlas() async {
    if (_cachedAtlas != null) return _cachedAtlas!;
    if (_isGenerating) {
      while (_cachedAtlas == null) {
        await Future.delayed(const Duration(milliseconds: 16));
      }
      return _cachedAtlas!;
    }
    _isGenerating = true;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Slot 0 (x: 0..64): Punto circular anti-alias
    canvas.drawCircle(const Offset(32, 32), 16.0, paint);

    // Slot 1 (x: 64..128): Estrella de 5 puntas ★
    canvas.save();
    canvas.translate(96, 32);
    canvas.drawPath(_createStarPath(5, 20.0, 8.0), paint);
    canvas.restore();

    // Slot 2 (x: 128..192): Estrella de 4 puntas ✦
    canvas.save();
    canvas.translate(160, 32);
    canvas.drawPath(_createStarPath(4, 24.0, 4.8), paint);
    canvas.restore();

    // Slot 3 (x: 192..256): Estrella de 8 puntas ✧
    canvas.save();
    canvas.translate(224, 32);
    canvas.drawPath(_createStarPath(8, 20.0, 10.0), paint);
    canvas.restore();

    final picture = recorder.endRecording();
    _cachedAtlas = await picture.toImage(256, 64);
    _isGenerating = false;
    return _cachedAtlas!;
  }

  static Path _createStarPath(int points, double outerRadius, double innerRadius) {
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
}

/// Pintor ultra-eficiente para la capa estática del fondo estelar.
/// Se hornea una sola vez en un ui.Picture; su 'shouldRepaint' devuelve 'false',
/// por lo que la GPU conserva el render en caché con CERO trabajo de CPU por frame.
class StaticStarFieldPainter extends CustomPainter {
  final ui.Picture? picture;

  const StaticStarFieldPainter(this.picture);

  @override
  void paint(Canvas canvas, Size size) {
    if (picture != null) {
      canvas.drawPicture(picture!);
    }
  }

  @override
  bool shouldRepaint(covariant StaticStarFieldPainter oldDelegate) {
    return oldDelegate.picture != picture;
  }
}

/// Pintor dinámico optimizado con 'drawRawAtlas' para las estrellas titilantes.
/// Agrupa todas las estrellas dinámicas en una única llamada de dibujo a la GPU.
class DynamicStarFieldPainter extends CustomPainter {
  final List<StarParticle> particles;
  final double timeSeconds;
  final Size screenSize;
  final bool isDark;
  final ui.Image? atlasImage;

  // Buffers tipados reutilizados para cero asignación de memoria y cero GC
  static Float32List? _rstTransforms;
  static Float32List? _rects;
  static Int32List? _colors;
  static final Paint _atlasPaint = Paint();
  static final Paint _fallbackPaint = Paint()..style = PaintingStyle.fill;

  DynamicStarFieldPainter({
    required this.particles,
    required this.timeSeconds,
    required this.screenSize,
    required this.isDark,
    this.atlasImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    if (atlasImage != null) {
      _paintWithAtlas(canvas, size);
    } else {
      _paintFallback(canvas, size);
    }
  }

  void _paintWithAtlas(Canvas canvas, Size size) {
    final int count = particles.length;
    final int requiredTransformSize = count * 4;

    if (_rstTransforms == null || _rstTransforms!.length < requiredTransformSize) {
      _rstTransforms = Float32List(requiredTransformSize);
      _rects = Float32List(requiredTransformSize);
      _colors = Int32List(count);
    }

    final transforms = _rstTransforms!;
    final rects = _rects!;
    final colors = _colors!;

    int tIdx = 0;
    int rIdx = 0;
    int cIdx = 0;

    for (int i = 0; i < count; i++) {
      final p = particles[i];

      // Movimiento browniano suave
      double brownianX = cos(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20;
      double brownianY = sin(p.brownianAngle + timeSeconds * 0.8) * p.brownianSpeed * 20;
      double posX = p.origin.dx + brownianX;
      double posY = p.origin.dy + brownianY;

      double opacity = p.currentOpacity(timeSeconds);

      if (opacity < 0.1) {
        // Descartar estrella invisible sin costo de dibujo
        transforms[tIdx++] = 0.0;
        transforms[tIdx++] = 0.0;
        transforms[tIdx++] = 0.0;
        transforms[tIdx++] = 0.0;

        rects[rIdx++] = 0.0;
        rects[rIdx++] = 0.0;
        rects[rIdx++] = 64.0;
        rects[rIdx++] = 64.0;

        colors[cIdx++] = 0;
        continue;
      }

      int slot;
      double scale;
      double angle;

      if (p.size > 3.0) {
        slot = (p.starType == 0) ? 1 : (p.starType == 1 ? 2 : 3);
        scale = p.size / 20.0;
        angle = p.rotationAngle;
      } else {
        slot = 0;
        scale = (p.size * 0.5) / 16.0;
        angle = 0.0;
      }

      // Rectángulo de origen en el atlas (256x64 px)
      rects[rIdx++] = slot * 64.0;
      rects[rIdx++] = 0.0;
      rects[rIdx++] = (slot + 1) * 64.0;
      rects[rIdx++] = 64.0;

      // Transformación RSTransform (scale*cos, scale*sin, tx, ty con centro en (32, 32))
      double scos = scale * cos(angle);
      double ssin = scale * sin(angle);
      transforms[tIdx++] = scos;
      transforms[tIdx++] = ssin;
      transforms[tIdx++] = posX - scos * 32.0 + ssin * 32.0;
      transforms[tIdx++] = posY - ssin * 32.0 - scos * 32.0;

      // Color/Alpha (0xAARRGGBB)
      int alpha = (0.8 * opacity * 255).toInt().clamp(0, 255);
      if (isDark) {
        colors[cIdx++] = (alpha << 24) | 0x00FFFFFF;
      } else {
        colors[cIdx++] = (alpha << 24) | 0x00000000;
      }
    }

    canvas.drawRawAtlas(
      atlasImage!,
      transforms,
      rects,
      colors,
      BlendMode.srcIn,
      null,
      _atlasPaint,
    );
  }

  void _paintFallback(Canvas canvas, Size size) {
    final coreColor = isDark ? AppColors.starCore : const Color(0xFF000000);
    for (var particle in particles) {
      double brownianX = cos(particle.brownianAngle + timeSeconds * 0.8) * particle.brownianSpeed * 20;
      double brownianY = sin(particle.brownianAngle + timeSeconds * 0.8) * particle.brownianSpeed * 20;
      final pos = Offset(particle.origin.dx + brownianX, particle.origin.dy + brownianY);

      double opacity = particle.currentOpacity(timeSeconds);
      if (opacity < 0.1) continue;

      _fallbackPaint.color = coreColor.withValues(alpha: 0.8 * opacity);
      canvas.drawCircle(pos, particle.size * 0.5, _fallbackPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DynamicStarFieldPainter oldDelegate) {
    return oldDelegate.timeSeconds != timeSeconds ||
        oldDelegate.atlasImage != atlasImage ||
        oldDelegate.isDark != isDark;
  }
}

/// Pintor ultra-eficiente para Saturno:
/// Se dibuja exactamente UNA VEZ en su propio RepaintBoundary.
/// Toda la rotación de Saturno es ejecutada directamente por el compositor de la GPU
/// (sin repintar canvas ni calcular matemáticas en CPU).
class SaturnPicturePainter extends CustomPainter {
  final ui.Picture? picture;

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

/// Alias para compatibilidad hacia atrás si es necesario
typedef StarFieldPainter = DynamicStarFieldPainter;
