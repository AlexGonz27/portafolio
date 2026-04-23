import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
  ui.Picture? _planetBodyPicture;
  ui.Picture? _planetRingsPicture;
  double _timeSeconds = 0.0;
  double _scrollExtent = 3000.0;

  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _techKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  final ValueNotifier<String> _activeSectionNotifier = ValueNotifier<String>("Inicio");

  void _scrollToSection(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        alignment: 0.5,
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

    String detected = _activeSectionNotifier.value;
    double minDistance = double.infinity;

    keys.forEach((title, key) {
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero).dy;
        if (position.abs() < minDistance) {
          minDistance = position.abs();
          detected = title;
        }
      }
    });

    if (detected != _activeSectionNotifier.value) {
      _activeSectionNotifier.value = detected;
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

    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_particles.isEmpty) {
      _initParticles(MediaQuery.of(context).size);
      _bakePlanetLayers();
    }
  }

  void _bakePlanetLayers() {
    // 1. Hornear el CUERPO
    final bodyRecorder = ui.PictureRecorder();
    final bodyCanvas = Canvas(bodyRecorder);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in _particles) {
      if (p.isPlanet && !p.isRing) {
        _drawFidelityParticle(bodyCanvas, p, paint);
      }
    }
    _planetBodyPicture = bodyRecorder.endRecording();

    // 2. Hornear los ANILLOS
    final ringsRecorder = ui.PictureRecorder();
    final ringsCanvas = Canvas(ringsRecorder);

    for (var p in _particles) {
      if (p.isRing) {
        _drawFidelityParticle(ringsCanvas, p, paint);
      }
    }
    _planetRingsPicture = ringsRecorder.endRecording();
    _bakePathCache.clear(); // Limpiar cache tras el horneado
  }

  void _drawFidelityParticle(Canvas canvas, StarParticle p, Paint paint) {
    if (p.planetRadius == null || p.planetAngle == null) return;
    if (p.baseOpacity < 0.1) return; // Saltar estrellas casi invisibles en el bake
    
    final pos = Offset(
      p.planetRadius! * cos(p.planetAngle!),
      p.planetRadius! * sin(p.planetAngle!),
    );

    // Glow ultra-optimizado para el bake
    if (p.hasGlow && p.size > 3.0) {
      final glowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = p.particleColor.withOpacity(p.baseOpacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      canvas.drawCircle(pos, p.size * 1.2, glowPaint);
    }

    paint.color = AppColors.starCore.withOpacity(p.baseOpacity);
    
    if (p.size > 3.0) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.rotationAngle);
      
      // Usamos el mismo generador de paths (que ahora tiene cache en el pintor)
      // O podemos implementar una versión simple aquí para el bake inicial
      Path starPath = _getStarPath(p.starType, p.size);
      canvas.drawPath(starPath, paint);
      canvas.restore();
    } else {
      canvas.drawCircle(pos, p.size * 0.5, paint);
    }
  }

  // Cache temporal para el proceso de baking
  final Map<int, Path> _bakePathCache = {};

  Path _getStarPath(int type, double size) {
    int cacheKey = type * 1000 + (size * 10).toInt();
    if (_bakePathCache.containsKey(cacheKey)) return _bakePathCache[cacheKey]!;
    
    Path path = _createStarPath(
      type == 0 ? 5 : (type == 1 ? 4 : 8),
      type == 1 ? size * 1.2 : (type == 0 ? size : size * 0.9),
      type == 1 ? size * 0.2 : (type == 0 ? size * 0.4 : size * 0.5),
    );
    _bakePathCache[cacheKey] = path;
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _activeSectionNotifier.dispose();
    _planetBodyPicture?.dispose();
    _planetRingsPicture?.dispose();
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
                animation: Listenable.merge([_tickerController, _scrollController]),
                builder: (context, _) {
                  final phaseController = ScrollPhaseController(
                    scrollOffset: _scrollController.hasClients ? _scrollController.offset : 0.0,
                    maxScrollExtent: _scrollController.hasClients && _scrollController.position.hasContentDimensions 
                        ? _scrollController.position.maxScrollExtent 
                        : 3000.0,
                  );
                  return CustomPaint(
                    painter: StarFieldPainter(
                      particles: _particles,
                      phaseController: phaseController,
                      timeSeconds: _timeSeconds,
                      screenSize: size,
                      formationOverride: 1.0,
                      planetBodyPicture: _planetBodyPicture,
                      planetRingsPicture: _planetRingsPicture,
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
                  padding: const EdgeInsets.only(
                    left: 44.0,
                    right: 24.0,
                  ), // +20px a la derecha
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
          // 3. Índice Lateral (Side Navigation) - Restaurado a la izquierda con más margen
          if (size.width > 1000)
            ValueListenableBuilder<String>(
              valueListenable: _activeSectionNotifier,
              builder: (context, activeSection, _) {
                return Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Indicador móvil suave vertical
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutBack,
                          top: (_getNavIndex(activeSection) * 56.0) + (56.0 / 2) - (40.0 / 2),
                          left: 10.0,
                          child: _RotatingStarsIndicator(
                            animation: _tickerController,
                            activeSection: activeSection,
                          ),
                        ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildNavItem("Inicio", _heroKey, activeSection),
                            _buildNavItem("Sobre Mí", _aboutKey, activeSection),
                            _buildNavItem("Skills", _techKey, activeSection),
                            _buildNavItem("Proyectos", _projectsKey, activeSection),
                            _buildNavItem("Contacto", _contactKey, activeSection),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
        ],
      ),
    );
  }

  int _getNavIndex(String activeSection) {
    final sections = ["Inicio", "Sobre Mí", "Skills", "Proyectos", "Contacto"];
    final index = sections.indexOf(activeSection);
    return index >= 0 ? index : 0;
  }

  Widget _buildNavItem(String label, GlobalKey key, String activeSection) {
    final isActive = activeSection == label;

    return Container(
      width: 140.0, // Ancho fijo para centrado perfecto
      height: 56.0,
      alignment: Alignment.center,
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
  final String activeSection;

  // Radios de órbita individuales para cada sección
  static const Map<String, double> _radiiX = {
    "Inicio": 35.0,
    "Sobre Mí": 45.0,
    "Skills": 35.0,
    "Proyectos": 50.0,
    "Contacto": 45.0,
  };

  static const Map<String, double> _radiiY = {
    "Inicio": 15.0,
    "Sobre Mí": 15.0,
    "Skills": 15.0,
    "Proyectos": 15.0,
    "Contacto": 15.0,
  };

  const _RotatingStarsIndicator({
    required this.animation,
    required this.activeSection,
  });

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
            children: [
              _buildStar(0, time, _radiiX[activeSection] ?? 50.0, _radiiY[activeSection] ?? 15.0),
              _buildStar(pi, time, _radiiX[activeSection] ?? 50.0, _radiiY[activeSection] ?? 15.0)
            ],
          ),
        );
      },
    );
  }

  Widget _buildStar(double startAngle, double time, double radiusX, double radiusY) {
    final angle = startAngle + time * 2.5;

    return Transform.translate(
      offset: Offset(cos(angle) * radiusX, sin(angle) * radiusY),
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFF7EFFF5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7EFFF5).withOpacity(0.5),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
