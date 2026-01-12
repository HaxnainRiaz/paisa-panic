import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Custom card widget with consistent styling
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final VoidCallback? onTap;
  final double? elevation;
  final Border? border;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.elevation,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color ?? AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: border ?? Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );

    return card;
  }
}

/// Glassmorphism Card for premium feel
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Abstract decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(
              padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary card widget for displaying financial metrics
class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color? iconColor;
  final Color? amountColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    this.iconColor,
    this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.secondary).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    amount,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: amountColor ?? AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

