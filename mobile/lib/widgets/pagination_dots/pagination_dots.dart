import 'package:flutter/material.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'pagination_dots_cubit.dart';

class PaginationDots extends StatelessWidget {
  final int totalPages;
  final int initialPage;
  final ValueChanged<int>? onPageSelected;
  final Color activeColor;
  final Color inactiveColor;
  final FocusNode? focusNode;
  final PaginationDotsCubit? cubit;

  const PaginationDots({
    super.key,
    required this.totalPages,
    this.initialPage = 0,
    this.onPageSelected,
    this.activeColor = AppColors.brandBlue,
    this.inactiveColor = AppColors.neutral200,
    this.focusNode,
    this.cubit,
  }) : assert(totalPages > 0, 'totalPages must be greater than 0');

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(
        value: cubit!,
        child: _PaginationDotsView(
          totalPages: totalPages,
          onPageSelected: onPageSelected,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          focusNode: focusNode,
        ),
      );
    }
    return BlocProvider(
      create: (_) => PaginationDotsCubit(initialPage: initialPage),
      child: _PaginationDotsView(
        totalPages: totalPages,
        onPageSelected: onPageSelected,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        focusNode: focusNode,
      ),
    );
  }
}

class _PaginationDotsView extends StatelessWidget {
  final int totalPages;
  final ValueChanged<int>? onPageSelected;
  final Color activeColor;
  final Color inactiveColor;
  final FocusNode? focusNode;

  const _PaginationDotsView({
    required this.totalPages,
    this.onPageSelected,
    required this.activeColor,
    required this.inactiveColor,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adaptive sizing based on available width
        final double maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 300.0;
        // Calculate relative dot size and spacing, clamped to reasonable minimums/maximums
        final double dotSize = (maxWidth * 0.03).clamp(8.0, 16.0);
        final double activeDotSize =
            dotSize * 1.2; // Active dot is slightly larger
        final double spacing = (maxWidth * 0.02).clamp(6.0, 12.0);

        return BlocBuilder<PaginationDotsCubit, PaginationDotsState>(
          builder: (context, state) {
            return Focus(
              focusNode: focusNode,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalPages, (index) {
                      final bool isActive = index == state.currentPage;
                      final bool isInteractive = onPageSelected != null;

                      return Semantics(
                        button: isInteractive,
                        selected: isActive,
                        label: 'Page ${index + 1} of $totalPages',
                        child: GestureDetector(
                          onTap: isInteractive
                              ? () {
                                  context.read<PaginationDotsCubit>().setPage(
                                    index,
                                    totalPages,
                                  );
                                  onPageSelected!(index);
                                }
                              : null,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing / 2,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: isActive ? activeDotSize : dotSize,
                              height: isActive ? activeDotSize : dotSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive ? activeColor : inactiveColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 12.0),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
