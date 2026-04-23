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

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
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
                            children: const [
                              TextSpan(text: "Soy un "),
                              TextSpan(
                                text: "Desarrollador de Software",
                                style: TextStyle(color: AppColors.accentPrimary, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: " apasionado por crear soluciones tecnológicas robustas. "),
                              TextSpan(text: "Actualmente este espacio se encuentra en construcción, pero aquí detallaré mi trayectoria profesional, mis pasiones enfocadas en el ecosistema backend y arquitecturas eficientes, y mi enfoque para resolver problemas complejos.\n\n"),
                              
                              TextSpan(text: "Me gusta trabajar en la constante evolución tecnológica, abarcando desde desarrollo de APIs rápidas hasta interfaces de usuario fluidas preparadas para escala."),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (!isMobile) const SizedBox(width: 60),
                  if (isMobile) const SizedBox(height: 40),
                  
                  // Avatar decorativo abstracto (Silueta cósmica estilizada)
                  Expanded(
                    flex: isMobile ? 0 : 2,
                    child: Center(
                      child: Container(
                        width: isMobile ? 200 : 250,
                        height: isMobile ? 200 : 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accentPrimary.withOpacity(0.5), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentPrimary.withOpacity(0.15),
                              blurRadius: 50,
                              spreadRadius: 10,
                            )
                          ]
                        ),
                        child: Center(
                          // Placeholder para la imagen del usuario o un logo abstracto
                          child: Icon(Icons.person_outline, size: 80, color: AppColors.accentPrimary.withOpacity(0.8)),
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
