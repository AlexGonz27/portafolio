import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/portfolio/presentation/screens/portfolio_screen.dart';

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({Key? key}) : super(key: key);

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: PortfolioApp.themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Alexander A. Gonzalez A. | Portafolio',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const PortfolioScreen(),
        );
      },
    );
  }
}
