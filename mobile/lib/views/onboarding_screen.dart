import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/pagination_dots/pagination_dots_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/app_spacing.dart';
import 'package:afc/utils/config/app_text_styles.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/onboarding/onboarding_cubit.dart';
import 'package:afc/widgets/pagination_dots/pagination_dots.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final PaginationDotsCubit _dotsCubit = PaginationDotsCubit();

  @override
  void dispose() {
    _pageController.dispose();
    _dotsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<OnboardingCubit>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state.isCompleted) {
            context.go('/login');
          }
          _dotsCubit.setPage(state.currentPage, 4);
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => cubit.completeOnboarding(),
                    child: Text(
                      l10n.onboardingSkip,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) => cubit.setPage(index),
                    children: [
                      _OnboardingPage(
                        image: 'assets/images/onboarding_welcome.png',
                        title: l10n.onboardingWelcomeTitle,
                        description: l10n.onboardingWelcomeDesc,
                      ),
                      _OnboardingPage(
                        image: 'assets/images/onboarding_tracking.png',
                        title: l10n.onboardingTrackTitle,
                        description: l10n.onboardingTrackDesc,
                      ),
                      _OnboardingPage(
                        image: 'assets/images/onboarding_goals.png',
                        title: l10n.onboardingInvestTitle,
                        description: l10n.onboardingInvestDesc,
                      ),
                      _OnboardingPage(
                        image: 'assets/images/onboarding_health.png',
                        title: l10n.onboardingHealthTitle,
                        description: l10n.onboardingHealthDesc,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PaginationDots(
                        totalPages: 4,
                        cubit: _dotsCubit,
                        activeColor: AppColors.primary,
                      ),
                      BlocProvider(
                        create: (_) => AdaptiveButtonCubit(),
                        child: AdaptiveButton(
                          text: state.currentPage == 3
                              ? l10n.onboardingStart
                              : l10n.onboardingNext,
                          primaryColor: AppColors.primary,
                          onPressed: () {
                            if (state.currentPage < 3) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              cubit.completeOnboarding();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use a fixed height or Flexible to prevent overflow
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Image.asset(image, fit: BoxFit.contain),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            title,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
