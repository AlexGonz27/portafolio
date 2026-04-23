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

  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _techKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  String _activeSection = "Inicio";

  // Anchos estimados para centrado dinámico (basados en fontSize 11 + padding)
  final Map<String, double> _navWidths = {
    "Inicio": 80.0,
    "Sobre Mí": 95.0,
    "Skills": 85.0,
    "Proyectos": 105.0,
    "Contacto": 100.0,
  };

  void _scrollToSection(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        alignment: 0.5, // Centra la sección en pantalla
      );
    }
  }

  void _onScroll() {
    final keys = {
      "Inicio": _heroKey,
      "Sobre Mí": _aboutKey,
      "Skills": _techKey,
      "Proyectos": _projectsKey,
      "Contacto": _contactKey,
    };

    String detected = _activeSection;
    double minDistance = double.infinity;

    keys.forEach((title, key) {
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero).dy;
        // Buscamos la sección que esté más cerca de la parte superior (umbral 200)
        if (position.abs() < minDistance) {
          minDistance = position.abs();
          detected = title;
        }
      }
    });

    if (detected != _activeSection) {
      setState(() {
        _activeSection = detected;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 10,
      ), // Usamos el ticker para repinte constante
    )..repeat();

    _tickerController.addListener(() {
      // Incremento constante acumulativo para evitar el 'salto' al reiniciar el ciclo
      _timeSeconds += 0.016;
    });

    // Saturno siempre formado desde el inicio
    _formationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      value: 1.0,
    );

    _scrollController.addListener(() {
      _onScroll();
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
    if (_scrollController.hasClients &&
        _scrollController.position.hasContentDimensions) {
      _scrollExtent = _scrollController.position.maxScrollExtent;
    }

    final phaseController = ScrollPhaseController(
      scrollOffset:
          _scrollController.hasClients ? _scrollController.offset : 0.0,
      maxScrollExtent: _scrollExtent > 0 ? _scrollExtent : 3000.0,
    );

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fondo cósmico animado
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _tickerController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: StarFieldPainter(
                      particles: _particles,
                      phaseController: phaseController,
                      timeSeconds:
                          _timeSeconds, // Tiempo acumulativo sin saltos
                      screenSize: size,
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      HeroSection(
                        key: _heroKey,
                        onViewWorkPressed: () => _scrollToSection(_projectsKey),
                      ),
                      const SizedBox(height: 100),
                      AboutSection(key: _aboutKey),
                      const SizedBox(height: 100),
                      TechSection(key: _techKey),
                      const SizedBox(height: 100),
                      ProjectsSection(key: _projectsKey),
                      const SizedBox(height: 100),
                      ContactSection(key: _contactKey),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Índice Lateral (Side Navigation)
          if (size.width > 1000)
            Positioned(
              left: 40,
              top: 0,
              bottom: 0,
              child: Center(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  clipBehavior: Clip.none,
                  children: [
                    // Indicador móvil suave (ahora viaja en X e Y)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                      top: (_getNavIndex() * 56.0) + (56.0 / 2) - (40.0 / 2),
                      // El centro de la palabra está en (ancho_estimado / 2)
                      // Queremos que el centro del indicador (60) coincida con ese punto
                      left: (_navWidths[_activeSection] ?? 80.0) / 2 - 60,
                      child: _RotatingStarsIndicator(
                        animation: _tickerController,
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNavItem("Inicio", _heroKey),
                        _buildNavItem("Sobre Mí", _aboutKey),
                        _buildNavItem("Skills", _techKey),
                        _buildNavItem("Proyectos", _projectsKey),
                        _buildNavItem("Contacto", _contactKey),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _getNavIndex() {
    final sections = ["Inicio", "Sobre Mí", "Skills", "Proyectos", "Contacto"];
    final index = sections.indexOf(_activeSection);
    return index >= 0 ? index : 0;
  }

  Widget _buildNavItem(String label, GlobalKey key) {
    final isActive = _activeSection == label;

    return Container(
      height: 56.0, // Altura fija garantizada para alineación perfecta
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () => _scrollToSection(key),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white38,
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _RotatingStarsIndicator extends StatelessWidget {
  final Animation<double> animation;
  const _RotatingStarsIndicator({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        // Obtenemos el tiempo acumulativo del estado padre para evitar saltos
        final time =
            (context
                .findAncestorStateOfType<_PortfolioScreenState>()
                ?._timeSeconds) ??
            0.0;
        return Container(
          width: 120,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [_buildStar(0, time), _buildStar(pi, time)],
          ),
        );
      },
    );
  }

  Widget _buildStar(double startAngle, double time) {
    final angle = startAngle + time * 2.5;
    // Órbita más ancha para no chocar con palabras largas
    const radiusX = 65.0;
    const radiusY = 18.0;

    return Transform.translate(
      offset: Offset(cos(angle) * radiusX, sin(angle) * radiusY),
      child: Container(
        width: 4, // Un poco más pequeñas para ganar FPS
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFF7EFFF5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7EFFF5).withOpacity(0.5),
              blurRadius: 4, // Menos blur = más FPS en Web
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
