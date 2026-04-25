import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/feedback/feedback_cubit.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/widgets/adaptive_text_field/adaptive_text_field_cubit.dart';
import 'package:afc/widgets/custom_snackbar/custom_snackbar.dart';

class FeedbackSheet extends StatelessWidget {
  const FeedbackSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FeedbackSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => sl<FeedbackCubit>(),
      child: BlocListener<FeedbackCubit, FeedbackState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          if (state.status == FeedbackStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: CustomSnackbar(
                  title: l10n.feedbackSuccess,
                  backgroundColor: AppColors.success,
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            );
            Navigator.of(context).pop();
          } else if (state.status == FeedbackStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: CustomSnackbar(
                  title: state.errorMessage!,
                  backgroundColor: AppColors.error,
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.feedbackTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.feedbackLabel,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              const _RatingRow(),
              const SizedBox(height: 24),
              const _MessageField(),
              const SizedBox(height: 32),
              const _SubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedbackCubit, FeedbackState>(
      buildWhen: (p, c) => p.rating != c.rating,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final isSelected = starIndex <= state.rating;

            return IconButton(
              onPressed: () =>
                  context.read<FeedbackCubit>().updateRating(starIndex),
              icon: Icon(
                isSelected ? Icons.star : Icons.star_border,
                color: isSelected ? Colors.amber : Colors.grey[400],
                size: 40,
              ),
            );
          }),
        );
      },
    );
  }
}

class _MessageField extends StatelessWidget {
  const _MessageField();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => AdaptiveTextFieldCubit(),
      child: AdaptiveTextField(
        hintText: l10n.feedbackMessageHint,
        maxLines: 4,
        onChanged: (val) => context.read<FeedbackCubit>().updateMessage(val),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<FeedbackCubit, FeedbackState>(
      builder: (context, state) {
        return BlocProvider(
          create: (_) =>
              AdaptiveButtonCubit()
                ..setLoading(state.status == FeedbackStatus.submitting),
          child: AdaptiveButton(
            text: l10n.feedbackSubmit,
            onPressed:
                state.rating == 0 || state.status == FeedbackStatus.submitting
                ? null
                : () => context.read<FeedbackCubit>().submit(),
          ),
        );
      },
    );
  }
}
