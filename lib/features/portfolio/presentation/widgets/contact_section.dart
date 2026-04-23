import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/glassmorphism_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({Key? key}) : super(key: key);

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 800, // Limitar ancho del header en el centro
          child: SectionHeader(number: "04.", title: "¿Hablamos?"),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          "Actualmente estoy abierto a nuevas oportunidades.\nYa sea que tengas una pregunta o simplemente quieras saludar, ¡intentaré responderte lo antes posible!",
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 60),

        Wrap(
          spacing: 32,
          runSpacing: 32,
          alignment: WrapAlignment.center,
          children: [
            _ContactButton(
              icon: Icons.chat_bubble_outline,
              label: "WhatsApp",
              value: "+58 412-353-2703",
              onTap: () => _launchUrl(AppConstants.whatsappUrl),
            ),
            _ContactButton(
              icon: Icons.code, // Placeholder for Github since Icons doesn't have it built-in easily
              label: "GitHub",
              value: "AlexGonz27",
              onTap: () => _launchUrl(AppConstants.githubUrl),
            ),
            _ContactButton(
              icon: Icons.email_outlined,
              label: "Email",
              value: "alexagustingonzalez@gmail.com",
              onTap: () => _launchUrl(AppConstants.emailUrl),
            ),
          ],
        ),
        
        const SizedBox(height: 100),
        
        // Branding del pie de página
        Text(
          "Diseñado y construido por Alexander A. Gonzalez A.",
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "2026",
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

class _ContactButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  State<_ContactButton> createState() => _ContactButtonState();
}

class _ContactButtonState extends State<_ContactButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..translate(0.0, isHovered ? -5.0 : 0.0),
          child: GlassmorphismCard(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            customBorder: Border.all(
              color: isHovered 
                ? AppColors.accentPrimary.withOpacity(0.5) 
                : Colors.white.withOpacity(0.1),
              width: 1,
            ),
            child: Column(
              children: [
                Icon(
                  widget.icon,
                  size: 32,
                  color: isHovered ? AppColors.accentPrimary : AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isHovered ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.value,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isHovered ? AppColors.accentPrimary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
