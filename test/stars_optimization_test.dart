import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portafolio/features/portfolio/presentation/widgets/star_field_painter.dart';
import 'package:portafolio/features/portfolio/presentation/widgets/star_particle.dart';

void main() {
  test('StarAtlasHelper generates 256x64 atlas image', () async {
    final image = await StarAtlasHelper.getAtlas();
    expect(image.width, 256);
    expect(image.height, 64);
  });

  testWidgets('StaticStarFieldPainter draws picture', (tester) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawCircle(const Offset(10, 10), 5, Paint());
    final picture = recorder.endRecording();

    await tester.pumpWidget(
      CustomPaint(
        size: const Size(100, 100),
        painter: StaticStarFieldPainter(picture),
      ),
    );

    expect(find.byType(CustomPaint), findsOneWidget);
  });

  testWidgets('DynamicStarFieldPainter paints via drawRawAtlas', (tester) async {
    final atlas = await StarAtlasHelper.getAtlas();
    final particles = [
      StarParticle(
        origin: const Offset(50, 50),
        size: 2.0,
        baseOpacity: 0.8,
        starType: 0,
        rotationAngle: 0.0,
        twinkleOffset: 0.0,
        glowColor: Colors.white,
        attractionGroupId: 0,
        brownianSpeed: 0.2,
        brownianAngle: 0.0,
        hasGlow: false,
        particleColor: Colors.white,
      ),
      StarParticle(
        origin: const Offset(80, 80),
        size: 4.0,
        baseOpacity: 1.0,
        starType: 1,
        rotationAngle: 0.5,
        twinkleOffset: 1.0,
        glowColor: Colors.white,
        attractionGroupId: 0,
        brownianSpeed: 0.3,
        brownianAngle: 0.5,
        hasGlow: true,
        particleColor: Colors.white,
      ),
    ];

    await tester.pumpWidget(
      CustomPaint(
        size: const Size(200, 200),
        painter: DynamicStarFieldPainter(
          particles: particles,
          timeSeconds: 1.5,
          screenSize: const Size(200, 200),
          isDark: false,
          atlasImage: atlas,
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsOneWidget);
  });
}

