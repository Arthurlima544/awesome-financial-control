import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import 'package:afc/utils/config/app_colors.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/utils/l10n/generated/app_localizations.dart';
import 'package:afc/view_models/import/import_bloc.dart';
import 'package:afc/view_models/import/import_event.dart';
import 'package:afc/view_models/import/import_state.dart';
import 'package:afc/services/import_parser_service.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button.dart';
import 'package:afc/widgets/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/widgets/adaptive_badge/adaptive_badge.dart';
import 'package:afc/widgets/adaptive_badge/adaptive_badge_cubit.dart';
import 'package:afc/widgets/adaptive_checkbox/adaptive_checkbox.dart';
import 'package:afc/widgets/adaptive_checkbox/adaptive_checkbox_cubit.dart';
import 'package:afc/widgets/custom_snackbar/custom_snackbar.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ImportBloc>(),
      child: const _ImportView(),
    );
  }
}

class _ImportView extends StatelessWidget {
  const _ImportView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ImportBloc, ImportState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == ImportStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomSnackbar(
                title: l10n.importSuccess,
                backgroundColor: AppColors.success,
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          );
          Navigator.of(context).pop();
        } else if (state.status == ImportStatus.failure &&
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
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.importTitle)),
        body: BlocBuilder<ImportBloc, ImportState>(
          builder: (context, state) {
            if (state.status == ImportStatus.initial ||
                state.status == ImportStatus.failure) {
              return _buildSelectStep(context, state, l10n);
            }
            if (state.status == ImportStatus.parsing) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ImportStatus.reviewing ||
                state.status == ImportStatus.submitting) {
              return _buildReviewStep(context, state, l10n);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSelectStep(
    BuildContext context,
    ImportState state,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.importProfileLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<ImportProfile>(
            initialValue: state.profile,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              DropdownMenuItem(
                value: ImportProfile.ofxDefault,
                child: Text(l10n.importProfileOfx),
              ),
              DropdownMenuItem(
                value: ImportProfile.nubankExtrato,
                child: Text(l10n.importProfileNubankExtrato),
              ),
              DropdownMenuItem(
                value: ImportProfile.nubankFatura,
                child: Text(l10n.importProfileNubankFatura),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                context.read<ImportBloc>().add(ImportProfileSelected(value));
              }
            },
          ),
          const SizedBox(height: 32),
          BlocProvider(
            create: (_) => AdaptiveButtonCubit(),
            child: AdaptiveButton(
              text: l10n.importPickFile,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final importBloc = context.read<ImportBloc>();

                try {
                  final result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['csv', 'ofx'],
                  );

                  if (result != null &&
                      result.files.isNotEmpty &&
                      result.files.first.path != null) {
                    final file = File(result.files.first.path!);
                    final content = await file.readAsString();
                    importBloc.add(ImportFileSelected(content));
                  }
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: CustomSnackbar(
                        title: 'Error: $e',
                        backgroundColor: AppColors.error,
                      ),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep(
    BuildContext context,
    ImportState state,
    AppLocalizations l10n,
  ) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.importReviewTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              BlocProvider(
                key: ValueKey(
                  '${state.selectedCount}_${state.candidates.length}',
                ),
                create: (_) => AdaptiveBadgeCubit(
                  initialLabel:
                      '${state.selectedCount} / ${state.candidates.length}',
                ),
                child: const AdaptiveBadge(
                  type: AdaptiveBadgeType.status,
                  semanticLabel: 'Selected Count',
                  baseColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: state.candidates.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = state.candidates[index];
              final amountColor = c.type == TransactionType.income
                  ? AppColors.success
                  : AppColors.error;

              return ListTile(
                leading: BlocProvider(
                  key: ValueKey('checkbox_$index'),
                  create: (_) =>
                      AdaptiveCheckboxCubit(initialChecked: c.isSelected),
                  child: AdaptiveCheckbox(
                    semanticLabel: 'Select',
                    onChanged: (_) {
                      context.read<ImportBloc>().add(
                        ImportCandidateToggled(index),
                      );
                    },
                  ),
                ),
                title: Text(
                  c.description,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateFormatter.format(c.occurredAt)),
                    if (c.isDuplicate)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: BlocProvider(
                          create: (_) => AdaptiveBadgeCubit(
                            initialLabel: l10n.importDuplicate,
                          ),
                          child: const AdaptiveBadge(
                            type: AdaptiveBadgeType.status,
                            semanticLabel: 'Duplicate Warning',
                            baseColor: AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: Text(
                  currencyFormatter.format(c.amount),
                  style: TextStyle(
                    color: amountColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  context.read<ImportBloc>().add(ImportCandidateToggled(index));
                },
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocProvider(
              create: (_) =>
                  AdaptiveButtonCubit()
                    ..setLoading(state.status == ImportStatus.submitting),
              child: AdaptiveButton(
                text: l10n.importSubmit(state.selectedCount.toString()),
                onPressed:
                    state.selectedCount == 0 ||
                        state.status == ImportStatus.submitting
                    ? null
                    : () {
                        context.read<ImportBloc>().add(
                          const ImportSubmitRequested(),
                        );
                      },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
