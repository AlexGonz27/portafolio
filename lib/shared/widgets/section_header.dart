import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String number;
  final String title;

  const SectionHeader({
    Key? key,
    required this.number,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            number,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.accentPrimary,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentPrimary.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
