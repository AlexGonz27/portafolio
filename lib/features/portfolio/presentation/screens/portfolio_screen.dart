import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/star_particle.dart';
import '../widgets/star_field_painter.dart';
import '../widgets/scroll_phase_controller.dart';
import '../widgets/hero_section.dart';
import '../widgets/about_section.dart';
import '../widgets/tech_section.dart';
import '../widgets/projects_section.dart';
import '../widgets/contact_section.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _tickerController;
  late AnimationController _formationController;

  List<StarParticle> _particles = [];
  double _timeSeconds = 0.0;
  double _scrollExtent = 3000.0;

  @override
  void initState() {
    super.initState();

    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _tickerController.addListener(() {
      setState(() {
        _timeSeconds += 0.016;
      });
    });

    // Saturno siempre formado desde el inicio
    _formationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      value: 1.0,
    );

    _scrollController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_particles.isEmpty) {
      _initParticles(MediaQuery.of(context).size);
    }
  }

  void _initParticles(Size size) {
    Random r = Random();
    int numGroups = 8;
    int totalStars = 1200; 
    int planetStarsCount = 900; 

    double bodyRadius = 138.0;

    _particles = List.generate(totalStars, (index) {
      bool isPlanet = index < planetStarsCount;
      bool isRing = isPlanet && index >= 300; 

      Offset origin = Offset(
        r.nextDouble() * max(size.width, 3000.0),
        r.nextDouble() * max(size.height, 2000.0),
      );

      double? planetRadius;
      double? planetAngle;
      Color pColor = const Color(0xFF7EFFF5);
      double pSize = r.nextDouble() * 3.0 + 0.5;

      if (isPlanet) {
        if (!isRing) {
          // CUERPO DE SATURNO (300 partículas en el BORDE)
          planetRadius = (0.85 + r.nextDouble() * 0.15) * bodyRadius;
          planetAngle = r.nextDouble() * pi * 2;

          pColor = const Color(0xFFFFE4B5);
          pSize = r.nextDouble() * 2.5 + 1.5;
        } else {
          // ANILLOS DE SATURNO (600 partículas)
          bool isInnerRing = index < 600; 
          double ringInner = isInnerRing ? 187.5 : 240.0;
          double ringOuter = isInnerRing ? 240.0 : 300.0;

          planetRadius = ringInner + r.nextDouble() * (ringOuter - ringInner);
          planetAngle = r.nextDouble() * pi * 2;

          pColor =
              isInnerRing ? const Color(0xFFFFF8DC) : const Color(0xFFEBC79E);
          pSize = r.nextDouble() * 1.0 + 0.5;
        }
      }

      return StarParticle(
        origin: origin,
        size: pSize,
        baseOpacity: r.nextDouble() * 0.6 + 0.4,
        starType: isPlanet ? 0 : r.nextInt(3),
        rotationAngle: r.nextDouble() * pi,
        twinkleOffset: r.nextDouble() * pi * 2,
        glowColor: pColor,
        attractionGroupId: r.nextInt(numGroups),
        brownianSpeed: r.nextDouble() * 0.4 + 0.1,
        brownianAngle: r.nextDouble() * pi * 2,
        isPlanet: isPlanet,
        isRing: isRing,
        hasGlow: !isRing && r.nextDouble() < 0.65,
        planetRadius: planetRadius,
        planetAngle: planetAngle,
        particleColor: pColor,
      );
    });
  }

  @override
  void dispose() {
    _tickerController.dispose();
    _formationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Evitar acceder a maxScrollExtent antes del primer layout para prevenir 'Unexpected null value'
    if (_scrollController.hasClients && _scrollController.position.hasContentDimensions) {
      _scrollExtent = _scrollController.position.maxScrollExtent;
    }

    final phaseController = ScrollPhaseController(
      scrollOffset: _scrollController.hasClients ? _scrollController.offset : 0.0,
      maxScrollExtent: _scrollExtent > 0 ? _scrollExtent : 3000.0,
    );

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fondo cósmico animado
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _formationController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: StarFieldPainter(
                      particles: _particles,
                      phaseController: phaseController,
                      timeSeconds: _timeSeconds,
                      screenSize: size,
                      // Sobrescribimos el progreso del scroll con nuestra animación fluida
                      formationOverride: 1.0,
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Contenido scrolleable
          SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.desktopMaxWidth,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      HeroSection(),
                      SizedBox(height: 100),
                      AboutSection(),
                      SizedBox(height: 100),
                      TechSection(),
                      SizedBox(height: 100),
                      ProjectsSection(),
                      SizedBox(height: 100),
                      ContactSection(),
                      SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
