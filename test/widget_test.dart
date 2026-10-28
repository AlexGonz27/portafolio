import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portafolio/features/portfolio/presentation/widgets/projects_section.dart';

void main() {
  testWidgets('ProjectsSection renders Kamsis and switches to other projects', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectsSection(),
          ),
        ),
      ),
    );

    // Initial state: Kamsis
    expect(find.text('Kamsis'), findsNWidgets(2)); // in tab selector and in card title
    expect(find.text('Visitar kamsis.online'), findsOneWidget);
    expect(find.text('Tests Unitarios & Integración'), findsOneWidget);

    // Switch to Plataforma Lectoescritura
    await tester.tap(find.text('Plataforma Lectoescritura').first);
    await tester.pumpAndSettle();
    expect(find.text('DESARROLLO MÓVIL'), findsOneWidget);
    expect(find.text('OFFLINE-FIRST'), findsOneWidget);
    expect(find.text('Modelos ONNX'), findsOneWidget);

    // Switch to PlayLot App
    await tester.tap(find.text('PlayLot App').first);
    await tester.pumpAndSettle();
    expect(find.text('PUNTO DE VENTA (POS)'), findsOneWidget);
    expect(find.text('Desarrollo de App Cliente'), findsOneWidget);
  });
}
