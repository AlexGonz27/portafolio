import 'package:flutter/material.dart';

enum CosmicPhase {
  /// Fase 1: (0% - 15%) Caos estelar puro en el Hero
  chaos,
  
  /// Fase 2: (15% - 40%) Formación de Saturno (antes de Sobre Mí)
  planetaryFormation,
  
  /// Fase 3: (40% - 70%) Estabilidad planetaria y brillo
  planetaryStable,
  
  /// Fase 4: (70% - 100%) Concentración final o disipación (según scroll)
  cosmicExpansion
}

class ScrollPhaseController {
  final double scrollOffset;
  final double maxScrollExtent;

  ScrollPhaseController({
    required this.scrollOffset,
    required this.maxScrollExtent,
  });

  double get totalProgress {
    if (maxScrollExtent <= 0) return 0.0;
    return (scrollOffset / maxScrollExtent).clamp(0.0, 1.0);
  }

  CosmicPhase get currentPhase {
    final p = totalProgress;
    if (p < 0.15) return CosmicPhase.chaos;
    if (p < 0.40) return CosmicPhase.planetaryFormation;
    if (p < 0.70) return CosmicPhase.planetaryStable;
    return CosmicPhase.cosmicExpansion;
  }

  /// Progreso de la formación de planetas (0.0 a 1.0 entre 15% y 40% de scroll)
  double get formationProgress {
    if (totalProgress < 0.15) return 0.0;
    return ((totalProgress - 0.15) / 0.25).clamp(0.0, 1.0);
  }

  /// Fuerza general de gravedad (activada después del Hero)
  double get gravityForce {
    if (totalProgress < 0.10) return 0.0;
    return ((totalProgress - 0.10) / 0.90).clamp(0.0, 1.0);
  }
}
