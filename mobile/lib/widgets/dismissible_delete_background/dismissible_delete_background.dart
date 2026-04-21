import 'package:flutter/material.dart';

import 'package:afc/utils/config/app_colors.dart';

class DismissibleDeleteBackground extends StatelessWidget {
  const DismissibleDeleteBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.error,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete_outline, color: AppColors.onError),
    );
  }
}
