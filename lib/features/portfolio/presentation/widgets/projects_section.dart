import 'package:flutter/material.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/glassmorphism_card.dart';
import '../../../../core/theme/app_colors.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(number: "03.", title: "Proyectos Destacados"),
        
        // Placeholder animado sugerido en el plan
        GlassmorphismCard(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 64,
                  color: AppColors.accentPrimary.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  "Próximamente",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.accentPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "La colección de proyectos se está ensamblando. Vuelve pronto para ver el código en acción.",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
