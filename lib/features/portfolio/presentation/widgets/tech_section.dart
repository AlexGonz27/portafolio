import 'package:flutter/material.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/glassmorphism_card.dart';
import '../../../../core/theme/app_colors.dart';

class TechSection extends StatelessWidget {
  const TechSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Info hardcoded for tech skills based on implementation plan
    final techCategories = [
      {'area': 'Lenguajes', 'techs': ['Python', 'Java', 'Node.js', 'Dart', 'C++']},
      {'area': 'Frameworks', 'techs': ['FastAPI', 'Spring Boot', 'Express', 'Dart Frog', 'Flutter']},
      {'area': 'Bases de datos', 'techs': ['PostgreSQL', 'MySQL', 'MongoDB', 'Firebase']},
      {'area': 'Contenedores', 'techs': ['Docker', 'Docker Compose']},
      {'area': 'Cloud', 'techs': ['AWS (EC2, RDS, Lambda, S3)', 'Azure']},
      {'area': 'VPS', 'techs': ['DigitalOcean', 'InterServer', 'Contabo', 'Hostinger']},
      {'area': 'APIs', 'techs': ['REST', 'GraphQL', 'WebSockets']},
      {'area': 'Testing', 'techs': ['Pytest', 'JUnit', 'Postman']},
      {'area': 'Monitoreo', 'techs': ['Prometheus', 'Grafana']},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(number: "02.", title: "Ecosistema Tecnológico"),
        
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: techCategories.map((category) {
            return _TechCategoryCard(
              title: category['area'] as String,
              techs: category['techs'] as List<String>,
            );
          }).toList(),
        )
      ],
    );
  }
}

class _TechCategoryCard extends StatefulWidget {
  final String title;
  final List<String> techs;

  const _TechCategoryCard({
    required this.title,
    required this.techs,
  });

  @override
  State<_TechCategoryCard> createState() => _TechCategoryCardState();
}

class _TechCategoryCardState extends State<_TechCategoryCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 350,
        transform: Matrix4.identity()..translate(0.0, isHovered ? -5.0 : 0.0),
        child: GlassmorphismCard(
          padding: const EdgeInsets.all(24),
          customBorder: Border.all(
            color: isHovered 
              ? AppColors.accentPrimary.withOpacity(0.5) 
              : Colors.white.withOpacity(0.1),
            width: 1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isHovered ? AppColors.accentPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.techs.map((t) => _TechChip(text: t)).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String text;
  const _TechChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.accentPrimary.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}
