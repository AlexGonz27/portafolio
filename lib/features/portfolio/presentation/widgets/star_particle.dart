import 'package:flutter/material.dart';
import 'dart:math';

class StarParticle {
  // Posiciones
  late Offset position;       // Posición actual
  final Offset origin;        // Posición inicial (Caos)
  
  // Propiedades visuales
  final double size;          // 1.0 - 5.0
  final double baseOpacity;   // Opacidad base constante
  final int starType;         // 0-4 para diferentes formas de estrella (★ ✦ ✧ ✶ ✷)
  final double rotationAngle; // Rotación estética para las estrellas
  final double twinkleOffset; // Desfase para el titileo suave
  final Color glowColor;      // Color del brillo de la estrella
  
  // Propiedades de interacción y fase
  Offset? target;             
  final int attractionGroupId; 
  
  // Planeta
  final bool isPlanet;        
  final bool isRing;          // Si es parte de los anillos (para efectos específicos)
  double? planetRadius;       // Radio respecto al centro del planeta
  double? planetAngle;        // Ángulo inicial (para rotación orbital)
  final bool hasGlow;
  final Color particleColor;  // Color específico asignado en la creación

  // Para efectos de rastro (opcional)
  Offset? lastPosition;

  // Variables de movimiento browniano
  final double brownianSpeed;
  final double brownianAngle;

  StarParticle({
    required this.origin,
    required this.size,
    required this.baseOpacity,
    required this.starType,
    required this.rotationAngle,
    required this.twinkleOffset,
    required this.glowColor,
    required this.attractionGroupId,
    required this.brownianSpeed,
    required this.brownianAngle,
    required this.hasGlow,
    required this.particleColor,
    this.isPlanet = false,
    this.isRing = false,
    this.planetRadius,
    this.planetAngle,
  }) {
    position = origin;
    lastPosition = origin;
  }

  // Factor de destello dinámico por el tiempo
  double currentOpacity(double timeSeconds) {
    // Oscilación suave con onda seno
    double twinkle = (sin(timeSeconds * 2 + twinkleOffset) + 1) / 2; // 0.0 a 1.0
    // Limitamos la caída de opacidad para que no desaparezca del todo
    double minOpacity = baseOpacity * 0.3;
    return minOpacity + (baseOpacity - minOpacity) * twinkle;
  }
}
