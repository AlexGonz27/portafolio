import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback? onViewWorkPressed;
  
  const HeroSection({
    Key? key,
    this.onViewWorkPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ... resto del build ...
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: screenHeight,
        width: isMobile ? double.infinity : screenWidth * 0.65,
        padding: const EdgeInsets.only(top: 80.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo
            Text(
              "Hola, soy",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.accentPrimary,
              ),
            ).animate().fade(duration: 800.ms).slideY(begin: 0.5, end: 0),
            
            const SizedBox(height: 16),
            
            // Nombre Principal
            Text(
              "Alexander A. Gonzalez A.",
              style: isMobile 
                ? Theme.of(context).textTheme.displayMedium 
                : Theme.of(context).textTheme.displayLarge,
            )
            .animate(delay: 300.ms)
            .fade(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 8),
            
            // Título
            ShaderMask(
              shaderCallback: (bounds) => AppColors.cyanGradient.createShader(bounds),
              child: Text(
                "Desarrollador de Software",
                style: isMobile 
                  ? Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white)
                  : Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white),
              ),
            )
            .animate(delay: 600.ms)
            .fade(duration: 800.ms)
            .slideX(begin: -0.1, end: 0),
            
            const SizedBox(height: 32),
            
            // Subtítulo breve
            SizedBox(
              width: 600,
              child: Text(
                "Construyendo experiencias digitales eficientes, escalables y visualmente impactantes. Especializado en backend, frontend y arquitecturas en la nube.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
            .animate(delay: 900.ms)
            .fade(duration: 800.ms),
            
            const SizedBox(height: 48),
            
            // Call to Action
            ElevatedButton(
              onPressed: onViewWorkPressed,
              child: const Text('Ver mi trabajo'),
            )
            .animate(delay: 1200.ms)
            .fade()
            .scale(curve: Curves.easeOutBack),
          ],
        ),
      ),
    );
  }
}
