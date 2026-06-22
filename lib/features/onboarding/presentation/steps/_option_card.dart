import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.navy : AppColors.grey.withAlpha(60),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.green.withAlpha(40)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: selected ? AppColors.green : AppColors.grey, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.navy,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: selected
                          ? Colors.white.withAlpha(180)
                          : AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.green, size: 22),
          ],
        ),
      ),
    );
  }
}
