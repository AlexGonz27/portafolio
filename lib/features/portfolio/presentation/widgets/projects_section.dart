import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/glassmorphism_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  int _selectedProjectIndex = 0;

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(number: "03.", title: "Proyectos Destacados"),
        const SizedBox(height: 12),
        Text(
          "Selección de proyectos en producción y desarrollos de software reales con foco en arquitectura, rendimiento y soluciones prácticas.",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 32),

        // Navigation Tabs / Project Selector
        _buildProjectSelector(context, isMobile),

        const SizedBox(height: 24),

        // Active Project Card
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey<int>(_selectedProjectIndex),
            child: _buildCurrentProjectCard(context, isMobile),
          ),
        ),

        const SizedBox(height: 20),

        // Project Pager Controls (Prev / Next)
        _buildPagerFooter(context),
      ],
    );
  }

  Widget _buildProjectSelector(BuildContext context, bool isMobile) {
    final projects = [
      {
        "name": "Kamsis",
        "category": "PropTech / FinTech",
        "tag": "Producción",
        "tagColor": const Color(0xFF00C897),
        "icon": Icons.apartment_rounded,
      },
      {
        "name": "Plataforma Lectoescritura",
        "category": "EdTech / Offline AI",
        "tag": "Desarrollo",
        "tagColor": AppColors.accentSecondary,
        "icon": Icons.school_rounded,
      },
      {
        "name": "PlayLot App",
        "category": "POS / Taquilla Móvil",
        "tag": "Integración",
        "tagColor": const Color(0xFFFFB800),
        "icon": Icons.confirmation_number_rounded,
      },
    ];

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(projects.length, (index) {
            final p = projects[index];
            final isSelected = _selectedProjectIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _buildSelectorPill(
                index: index,
                title: p["name"] as String,
                tag: p["tag"] as String,
                tagColor: p["tagColor"] as Color,
                icon: p["icon"] as IconData,
                isSelected: isSelected,
              ),
            );
          }),
        ),
      );
    }

    return Row(
      children: List.generate(projects.length, (index) {
        final p = projects[index];
        final isSelected = _selectedProjectIndex == index;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 2 ? 12.0 : 0.0),
            child: _buildSelectorCardTab(
              index: index,
              name: p["name"] as String,
              category: p["category"] as String,
              tag: p["tag"] as String,
              tagColor: p["tagColor"] as Color,
              icon: p["icon"] as IconData,
              isSelected: isSelected,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSelectorPill({
    required int index,
    required String title,
    required String tag,
    required Color tagColor,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedProjectIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentPrimary.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accentPrimary.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: tagColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorCardTab({
    required int index,
    required String name,
    required String category,
    required String tag,
    required Color tagColor,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedProjectIndex = index),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentPrimary.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.accentPrimary.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentPrimary.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: tagColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? AppColors.accentPrimary.withValues(alpha: 0.8)
                          : Colors.white38,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentProjectCard(BuildContext context, bool isMobile) {
    switch (_selectedProjectIndex) {
      case 0:
        return _buildKamsisCard(context, isMobile);
      case 1:
        return _buildAppInfantilCard(context, isMobile);
      case 2:
      default:
        return _buildPlayLotCard(context, isMobile);
    }
  }

  // ==========================================
  // 1. KAMSIS PROJECT CARD
  // ==========================================
  Widget _buildKamsisCard(BuildContext context, bool isMobile) {
    return GlassmorphismCard(
      padding: EdgeInsets.all(isMobile ? 24.0 : 36.0),
      blur: 20,
      opacity: 0.08,
      customBorder: Border.all(
        color: AppColors.accentPrimary.withValues(alpha: 0.35),
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildPillTag(
                      "PRODUCCIÓN",
                      const Color(0xFF00C897),
                      isFilled: true,
                    ),
                    _buildPillTag(
                      "PROPTECH / FINTECH",
                      AppColors.accentSecondary,
                    ),
                    _buildPillTag(
                      "FULL-STACK DART",
                      AppColors.accentPrimary,
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _launchUrl(AppConstants.kamsisUrl),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text("Visitar kamsis.online"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary.withValues(alpha: 0.15),
                  foregroundColor: AppColors.accentPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: AppColors.accentPrimary.withValues(alpha: 0.5),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Title & Subtitle
          Text(
            "Kamsis",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 6),
          ShaderMask(
            shaderCallback: (bounds) => AppColors.cyanGradient.createShader(bounds),
            child: Text(
              "Sistema Integral de Gestión y Administración Fiduciaria de Condominios",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
            ),
          ),

          const SizedBox(height: 20),

          // Core Problem & Solution Text
          Text(
            "Plataforma modular de misión crítica desarrollada para resolver la problemática contable y administrativa de condominios en economías bimonetarias. Automatiza la emisión de avisos de cobro, conciliación de pagos multimoneda y consulta en tiempo real para propietarios y administradores.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
          ),

          const SizedBox(height: 24),

          // Key Engineering Highlights (Clean bullets)
          _buildHighlightsGrid(
            context,
            isMobile,
            [
              _HighlightItem(
                icon: Icons.currency_exchange,
                title: "Bimonetarismo Oficial BCV:",
                description:
                    "Facturación y cobranza en USD y VES con sincronización de la tasa oficial del Banco Central e histórico de tasas.",
              ),
              _HighlightItem(
                icon: Icons.shield_outlined,
                title: "Multi-Tenant & Seguridad:",
                description:
                    "Almacenamiento fiduciario segregado por condominio, control de acceso basado en roles (RBAC) y prevención de IDOR.",
              ),
              _HighlightItem(
                icon: Icons.pie_chart_outline_rounded,
                title: "Alícuotas & Fondos de Reserva:",
                description:
                    "Cálculo exacto sobre cuotas de mantenimiento, fondos de contingencia fiduciarios y conciliación automatizada.",
              ),
              _HighlightItem(
                icon: Icons.fact_check_outlined,
                title: "Tests Unitarios y de Integración:",
                description:
                    "Batería de pruebas automatizadas que cubren endpoints de autenticación, inquilinos, cobros y reportes.",
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tech Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _ProjectTechChip("Flutter (Web/Mobile)"),
              _ProjectTechChip("Dart Frog REST API"),
              _ProjectTechChip("PostgreSQL"),
              _ProjectTechChip("Tasa Oficial BCV"),
              _ProjectTechChip("Multi-Tenant"),
              _ProjectTechChip("RBAC"),
              _ProjectTechChip("Tests Unitarios & Integración"),
              _ProjectTechChip("Recibos PDF Vectoriales"),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. APP INFANTIL (LECTOESCRITURA)
  // ==========================================
  Widget _buildAppInfantilCard(BuildContext context, bool isMobile) {
    return GlassmorphismCard(
      padding: EdgeInsets.all(isMobile ? 24.0 : 36.0),
      blur: 20,
      opacity: 0.08,
      customBorder: Border.all(
        color: AppColors.accentSecondary.withValues(alpha: 0.35),
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildPillTag(
                      "DESARROLLO MÓVIL",
                      AppColors.accentSecondary,
                      isFilled: true,
                    ),
                    _buildPillTag(
                      "EDTECH / EDUCACIÓN",
                      AppColors.accentPrimary,
                    ),
                    _buildPillTag(
                      "OFFLINE-FIRST",
                      const Color(0xFF00C897),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.code_rounded, size: 14, color: AppColors.textSecondary),
                    SizedBox(width: 6),
                    Text(
                      "Apoyo en Desarrollo",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Title & Subtitle
          Text(
            "Plataforma Educativa de Lectoescritura",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 6),
          ShaderMask(
            shaderCallback: (bounds) => AppColors.purpleGradient.createShader(bounds),
            child: Text(
              "Aplicación Móvil Interactiva para Aprendizaje Infantil con Guía por Voz e Inferencia ONNX",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
            ),
          ),

          const SizedBox(height: 20),

          // Context & Role Description
          Text(
            "Proyecto de innovación educativa orientado a la enseñanza y refuerzo de lectoescritura en niños mediante un avatar interactivo y gamificación. Mi participación consistió en apoyar en el desarrollo de la aplicación móvil en Flutter, implementando la lógica de funcionamiento offline-first, módulos de trazado interactivo y soporte de audio local.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
          ),

          const SizedBox(height: 24),

          // Key Engineering Highlights
          _buildHighlightsGrid(
            context,
            isMobile,
            [
              _HighlightItem(
                icon: Icons.memory_rounded,
                title: "Edge AI & Audio Offline:",
                description:
                    "Integración de inferencia local con modelos ONNX y reproducción de audios educativos sin dependencia de red.",
              ),
              _HighlightItem(
                icon: Icons.draw_outlined,
                title: "Trazado y Dibujo Caligráfico:",
                description:
                    "Módulos táctiles para el trazo guiado de letras y números con validación de precisión motriz infantil.",
              ),
              _HighlightItem(
                icon: Icons.storage_rounded,
                title: "Persistencia Local SQLite:",
                description:
                    "Almacenamiento seguro de avances y lecciones completadas con sqflite para seguimiento continuo sin conexión.",
              ),
              _HighlightItem(
                icon: Icons.insights_rounded,
                title: "Métricas y Analíticas:",
                description:
                    "Visualización del progreso del niño mediante gráficos vectoriales con fl_chart y animaciones con Lottie.",
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tech Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _ProjectTechChip("Flutter (Android)"),
              _ProjectTechChip("SQLite (sqflite)"),
              _ProjectTechChip("Modelos ONNX"),
              _ProjectTechChip("Speech-to-Text"),
              _ProjectTechChip("Lottie Animations"),
              _ProjectTechChip("fl_chart"),
              _ProjectTechChip("Gamificación"),
              _ProjectTechChip("Arquitectura Offline"),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. PLAYLOT (APP MÓVIL TAQUILLA)
  // ==========================================
  Widget _buildPlayLotCard(BuildContext context, bool isMobile) {
    return GlassmorphismCard(
      padding: EdgeInsets.all(isMobile ? 24.0 : 36.0),
      blur: 20,
      opacity: 0.08,
      customBorder: Border.all(
        color: const Color(0xFFFFB800).withValues(alpha: 0.35),
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildPillTag(
                      "DESARROLLO MÓVIL",
                      const Color(0xFFFFB800),
                      isFilled: true,
                    ),
                    _buildPillTag(
                      "PUNTO DE VENTA (POS)",
                      AppColors.accentPrimary,
                    ),
                    _buildPillTag(
                      "INTEGRACIÓN WEB API",
                      AppColors.accentSecondary,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.handshake_outlined, size: 14, color: AppColors.textSecondary),
                    SizedBox(width: 6),
                    Text(
                      "Desarrollo de App Cliente",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Title & Subtitle
          Text(
            "PlayLot App",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 6),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFFB800), Color(0xFFFF7A00)],
            ).createShader(bounds),
            child: Text(
              "Punto de Venta Móvil y Operación de Taquilla de Loterías",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
            ),
          ),

          const SizedBox(height: 20),

          // Context & Role Description
          Text(
            "PlayLot es un sistema comercial que cuenta con su plataforma web central de administración. Mi labor se centró específicamente en el desarrollo de la aplicación cliente en Flutter (Android), creando la interfaz y flujo de trabajo para operadores de taquilla, emisión ágil de tickets e integración directa con las APIs del sistema web.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
          ),

          const SizedBox(height: 24),

          // Key Engineering Highlights
          _buildHighlightsGrid(
            context,
            isMobile,
            [
              _HighlightItem(
                icon: Icons.confirmation_number_outlined,
                title: "Gestión de Taquilla en Vivo:",
                description:
                    "Emisión ágil de jugadas, anulación de tickets con control de tiempo límite, repetición y verificación de ganadores.",
              ),
              _HighlightItem(
                icon: Icons.cloud_sync_outlined,
                title: "Integración con API Web:",
                description:
                    "Consumo de endpoints REST del backend web con manejo seguro de sesiones con flutter_secure_storage.",
              ),
              _HighlightItem(
                icon: Icons.flash_on_rounded,
                title: "Caché Local con Hive:",
                description:
                    "Persistencia de configuración, loterías activas y horarios para garantizar tiempos de respuesta instantáneos.",
              ),
              _HighlightItem(
                icon: Icons.share_outlined,
                title: "Formato y Envío de Tickets:",
                description:
                    "Generación visual estructurada de comprobantes y opciones para compartir tickets digitales con clientes.",
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tech Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _ProjectTechChip("Flutter (Android)"),
              _ProjectTechChip("REST API Integration"),
              _ProjectTechChip("Provider"),
              _ProjectTechChip("Hive Cache"),
              _ProjectTechChip("Secure Storage"),
              _ProjectTechChip("POS & Taquilla"),
              _ProjectTechChip("Formatos de Ticket"),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SHARED HELPERS
  // ==========================================
  Widget _buildHighlightsGrid(
    BuildContext context,
    bool isMobile,
    List<_HighlightItem> items,
  ) {
    if (isMobile) {
      return Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildHighlightRow(context, item),
              ),
            )
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildHighlightRow(context, items[0]),
              const SizedBox(height: 12),
              _buildHighlightRow(context, items[1]),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _buildHighlightRow(context, items[2]),
              const SizedBox(height: 12),
              _buildHighlightRow(context, items[3]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightRow(BuildContext context, _HighlightItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 18, color: AppColors.accentPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      height: 1.45,
                    ),
                children: [
                  TextSpan(
                    text: "${item.title} ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: item.description,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagerFooter(BuildContext context) {
    final titles = ["Kamsis", "Plataforma Lectoescritura", "PlayLot App"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: _selectedProjectIndex > 0
              ? () => setState(() => _selectedProjectIndex--)
              : null,
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: Text(
            _selectedProjectIndex > 0
                ? "Anterior: ${titles[_selectedProjectIndex - 1]}"
                : "Primer proyecto",
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Text(
          "${_selectedProjectIndex + 1} de ${titles.length}",
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontFamily: 'FiraCode',
          ),
        ),
        TextButton.icon(
          onPressed: _selectedProjectIndex < titles.length - 1
              ? () => setState(() => _selectedProjectIndex++)
              : null,
          label: Text(
            _selectedProjectIndex < titles.length - 1
                ? "Siguiente: ${titles[_selectedProjectIndex + 1]}"
                : "Último proyecto",
            style: const TextStyle(fontSize: 12),
          ),
          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
        ),
      ],
    );
  }

  Widget _buildPillTag(String label, Color color, {bool isFilled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFilled
            ? color.withValues(alpha: 0.18)
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isFilled ? color.withValues(alpha: 0.6) : color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _HighlightItem {
  final IconData icon;
  final String title;
  final String description;

  _HighlightItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _ProjectTechChip extends StatelessWidget {
  final String text;
  const _ProjectTechChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.accentPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textPrimary,
              fontSize: 11,
            ),
      ),
    );
  }
}
