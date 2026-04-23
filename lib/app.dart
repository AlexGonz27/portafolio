import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/portfolio/presentation/screens/portfolio_screen.dart';

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alexander A. Gonzalez A. | Portafolio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const PortfolioScreen(),
    );
  }
}
