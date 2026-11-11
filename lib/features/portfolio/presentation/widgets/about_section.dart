import 'package:flutter/material.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/glassmorphism_card.dart';
import '../../../../core/theme/app_colors.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isDark = context.isDark;
    final accentPrimary = context.accentPrimary;
    final accentSecondary = context.accentSecondary;

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: isMobile ? double.infinity : screenWidth * 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(number: "01.", title: "Sobre Mí"),
            
            GlassmorphismCard(
              padding: const EdgeInsets.all(40),
              child: Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  // Texto ocupando mayor parte del espacio
                  Expanded(
                    flex: isMobile ? 0 : 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyLarge,
                            children: [
                              const TextSpan(text: "Soy un "),
                              TextSpan(
                                text: "Desarrollador de Software",
                                style: TextStyle(color: accentPrimary, fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: " apasionado por crear soluciones tecnológicas robustas. "),
                              const TextSpan(text: "Actualmente este espacio se encuentra en construcción, pero aquí detallaré mi trayectoria profesional, mis pasiones enfocadas en el ecosistema backend y arquitecturas eficientes, y mi enfoque para resolver problemas complejos.\n\n"),
                              
                              const TextSpan(text: "Me gusta trabajar en la constante evolución tecnológica, abarcando desde desarrollo de APIs rápidas hasta interfaces de usuario fluidas preparadas para escala."),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (!isMobile) const SizedBox(width: 60),
                  if (isMobile) const SizedBox(height: 40),
                  
                  // Avatar / Foto con marco cósmico y resplandor adaptativo
                  Expanded(
                    flex: isMobile ? 0 : 2,
                    child: Center(
                      child: Container(
                        width: isMobile ? 220 : 270,
                        height: isMobile ? 220 : 270,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentPrimary.withValues(alpha: isDark ? 0.25 : 0.2),
                              blurRadius: 35,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: accentSecondary.withValues(alpha: isDark ? 0.18 : 0.15),
                              blurRadius: 55,
                              spreadRadius: 8,
                            ),
                          ],
                          gradient: SweepGradient(
                            colors: [
                              accentPrimary,
                              accentSecondary,
                              isDark ? const Color(0xFF00B4D8) : const Color(0xFF0369A1),
                              accentPrimary,
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(3.5),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.appBackground,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/profile.jpg',
                              fit: BoxFit.cover,
                              alignment: const Alignment(0.0, -0.1),
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Icon(
                                  Icons.person_outline,
                                  size: 80,
                                  color: accentPrimary.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
