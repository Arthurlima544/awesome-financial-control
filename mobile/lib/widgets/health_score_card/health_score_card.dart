import 'package:afc/models/health_score_model.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/widgets/app_tooltip_icon/app_tooltip_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HealthScoreCard extends StatelessWidget {
  final HealthScoreModel score;

  const HealthScoreCard({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Color scoreColor;
    String statusText;
    if (score.score >= 80) {
      scoreColor = AppColors.success;
      statusText = l10n.healthScoreExcellent;
    } else if (score.score >= 60) {
      scoreColor = AppColors.warning;
      statusText = l10n.healthScoreGood;
    } else {
      scoreColor = AppColors.error;
      statusText = l10n.healthScoreAttention;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.healthScoreTitle,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppTooltipIcon(
                title: l10n.healthScoreTitle,
                description: l10n.healthScoreTooltip,
                position: TooltipPosition.bottom,
                iconSize: AppSpacing.iconSm,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              TweenAnimationBuilder<double>(
                key: ValueKey(StatefulNavigationShell.of(context).currentIndex),
                tween: Tween<double>(begin: 0, end: score.score / 100),
                duration: const Duration(seconds: 1),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: value,
                          backgroundColor: scoreColor.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                          strokeWidth: 8,
                        ),
                      ),
                      Text(
                        '${(value * 100).toInt()}',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TweenAnimationBuilder<double>(
                      key: ValueKey(
                        StatefulNavigationShell.of(context).currentIndex,
                      ),
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return SizedBox(
                          height: 30,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: SparklinePainter(
                              data: score.historicalScores,
                              color: scoreColor,
                              animationValue: value,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _ScoreFactor(
            label: l10n.healthScoreSavings,
            value: score.savingsScore,
            color: scoreColor,
          ),
          _ScoreFactor(
            label: l10n.healthScoreLimits,
            value: score.limitsScore,
            color: scoreColor,
          ),
          _ScoreFactor(
            label: l10n.healthScoreGoals,
            value: score.goalsScore,
            color: scoreColor,
          ),
          _ScoreFactor(
            label: l10n.healthScoreVariance,
            value: score.varianceScore,
            color: scoreColor,
          ),
        ],
      ),
    );
  }
}

class _ScoreFactor extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ScoreFactor({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              Text(
                l10n.healthScoreSubScorePattern(value),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value / 25,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<int> data;
  final Color color;
  final double animationValue;

  SparklinePainter({
    required this.data,
    required this.color,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (data.length - 1);

    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = (max - min).toDouble();
    final effectiveRange = range == 0 ? 1.0 : range;

    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - min) / effectiveRange * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (animationValue < 1.0) {
      final metrics = path.computeMetrics();
      final extractPath = Path();
      for (final metric in metrics) {
        extractPath.addPath(
          metric.extractPath(0, metric.length * animationValue),
          Offset.zero,
        );
      }
      canvas.drawPath(extractPath, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.color != color ||
        oldDelegate.animationValue != animationValue;
  }
}
