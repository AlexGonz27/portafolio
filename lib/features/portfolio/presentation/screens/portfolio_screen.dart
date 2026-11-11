import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/star_particle.dart';
import '../widgets/star_field_painter.dart';
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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _tickerController;

  List<StarParticle> _backgroundParticles = [];
  ui.Picture? _planetBodyPicture;
  ui.Picture? _planetRingsPicture;
  double _timeSeconds = 0.0;

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
    WidgetsBinding.instance.addObserver(this);

    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _tickerController.addListener(() {
      _timeSeconds += 0.016;
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_tickerController.isAnimating) {
        _tickerController.repeat();
      }
    } else {
      if (_tickerController.isAnimating) {
        _tickerController.stop();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_backgroundParticles.isEmpty) {
      _initCosmicScene(MediaQuery.of(context).size);
    }
  }

  void _bakePlanetLayers(List<StarParticle> planetParticles) {
    // 1. Hornear el CUERPO de Saturno con máxima fidelidad
    final bodyRecorder = ui.PictureRecorder();
    final bodyCanvas = Canvas(bodyRecorder);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in planetParticles) {
      if (p.isPlanet && !p.isRing) {
        _drawFidelityParticle(bodyCanvas, p, paint);
      }
    }
    _planetBodyPicture = bodyRecorder.endRecording();

    // 2. Hornear los ANILLOS de Saturno con máxima fidelidad
    final ringsRecorder = ui.PictureRecorder();
    final ringsCanvas = Canvas(ringsRecorder);

    for (var p in planetParticles) {
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

  void _initCosmicScene(Size size) {
    Random r = Random();
    int numGroups = 8;
    int totalStars = 1200;
    int planetStarsCount = 900;

    double bodyRadius = 138.0;

    List<StarParticle> planetParticles = [];
    _backgroundParticles = [];

    for (int index = 0; index < totalStars; index++) {
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

      final particle = StarParticle(
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

      if (isPlanet) {
        planetParticles.add(particle);
      } else {
        _backgroundParticles.add(particle);
      }
    }

    _bakePlanetLayers(planetParticles);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tickerController.dispose();
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

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fondo cósmico animado (solo estrellas de fondo, ligero para la CPU)
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _tickerController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: StarFieldPainter(
                      particles: _backgroundParticles,
                      timeSeconds: _timeSeconds,
                      screenSize: size,
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Saturno (Capa independiente en GPU - Hardware Compositing con 100% nitidez)
          if (_planetBodyPicture != null && _planetRingsPicture != null)
            Positioned(
              left: size.width * 0.82 - 350,
              top: size.height * 0.50 - 350,
              width: 700,
              height: 700,
              child: IgnorePointer(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Cuerpo de Saturno (rotación pura de GPU sin repintar canvas)
                    AnimatedBuilder(
                      animation: _tickerController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _timeSeconds * 0.15,
                          child: child,
                        );
                      },
                      child: RepaintBoundary(
                        child: CustomPaint(
                          size: const Size(700, 700),
                          painter: SaturnPicturePainter(_planetBodyPicture),
                        ),
                      ),
                    ),

                    // Anillos de Saturno (perspectiva elíptica + rotación en GPU)
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateZ(0.20)
                        ..scale(1.0, 0.32, 1.0),
                      child: AnimatedBuilder(
                        animation: _tickerController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _timeSeconds * 0.3,
                            child: child,
                          );
                        },
                        child: RepaintBoundary(
                          child: CustomPaint(
                            size: const Size(700, 700),
                            painter: SaturnPicturePainter(_planetRingsPicture),
                          ),
                        ),
                      ),
                    ),
                  ],
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
