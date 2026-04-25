import 'package:flutter/material.dart';

import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/widgets/privacy_text/privacy_text.dart';
import 'package:afc/models/limit_progress_model.dart';

class MonthLimitView extends StatelessWidget {
  const MonthLimitView({super.key, required this.limit});

  final LimitProgressModel limit;

  @override
  Widget build(BuildContext context) {
    final isOver = limit.percentage >= 100;
    final isWarning = limit.percentage >= 80 && !isOver;

    final barColor = isOver
        ? AppColors.error
        : isWarning
        ? const Color(0xFFF59E0B) // Warning orange
        : AppColors.success;

    // Determine icon based on category name roughly
    IconData icon;
    final name = limit.categoryName.toLowerCase();
    if (name.contains('aliment')) {
      icon = Icons.local_cafe;
    } else if (name.contains('lazer')) {
      icon = Icons.play_arrow;
    } else if (name.contains('moradia')) {
      icon = Icons.home; // Better than share icon
    } else if (name.contains('saúde') || name.contains('saude')) {
      icon = Icons.favorite;
    } else if (name.contains('transporte')) {
      icon = Icons.directions_car;
    } else {
      icon = Icons.category;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      limit.categoryName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D253F),
                      ),
                    ),
                    if (isOver)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Excedido',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                PrivacyText(
                  '${limit.spentFormatted} de ${limit.limitAmountFormatted}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final progressWidth = width * limit.progress;
                    return Stack(
                      children: [
                        Container(
                          height: 4,
                          width: width,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Container(
                          height: 4,
                          width: progressWidth,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
