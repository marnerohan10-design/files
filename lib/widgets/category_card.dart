import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'scale_tap.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.large = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? subtitle;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(large ? 16 : 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 6))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: large ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Container(
              width: large ? 52 : 42,
              height: large ? 52 : 42,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(large ? 16 : 14),
              ),
              child: Icon(icon, color: AppColors.secondary, size: large ? 26 : 22),
            ),
            SizedBox(height: large ? 14 : 8),
            Text(
              label.capitalized,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: large ? TextAlign.start : TextAlign.center,
              style: TextStyle(
                fontSize: large ? 15 : 11,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}
