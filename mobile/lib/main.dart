import 'package:afc/shared/components/action_card/action_card.dart';
import 'package:afc/shared/components/action_sheet/action_sheet.dart';
import 'package:afc/shared/components/action_sheet/action_sheet_cubit.dart';
import 'package:afc/shared/components/adaptative_nav_bar/adaptive_nav_bar.dart';
import 'package:afc/shared/components/adaptative_nav_bar/adaptive_nav_bar_cubit.dart';
import 'package:afc/shared/components/adaptive_badge/adaptive_badge.dart';
import 'package:afc/shared/components/adaptive_badge/adaptive_badge_cubit.dart';
import 'package:afc/shared/components/adaptive_button/adaptive_button.dart';
import 'package:afc/shared/components/adaptive_button/adaptive_button_cubit.dart';
import 'package:afc/shared/components/adaptive_checkbox/adaptive_checkbox.dart';
import 'package:afc/shared/components/adaptive_checkbox/adaptive_checkbox_cubit.dart';
import 'package:afc/shared/components/adaptive_chip/adaptive_chip.dart';
import 'package:afc/shared/components/adaptive_chip/adaptive_chip_cubit.dart';
import 'package:afc/shared/components/adaptive_date_picker/adaptive_date_picker.dart';
import 'package:afc/shared/components/adaptive_date_picker/adaptive_date_picker_cubit.dart';
import 'package:afc/shared/components/adaptive_popup/adaptive_popup.dart';
import 'package:afc/shared/components/adaptive_popup/adaptive_popup_cubit.dart';
import 'package:afc/shared/components/adaptive_radio_button/adaptive_radio_button.dart';
import 'package:afc/shared/components/adaptive_radio_button/adaptive_radio_button_cubit.dart';
import 'package:afc/shared/components/adaptive_search_bar/adaptive_search_bar.dart';
import 'package:afc/shared/components/adaptive_search_bar/adaptive_search_bar_cubit.dart';
import 'package:afc/shared/components/adaptive_segmented_control/adaptive_segmented_control.dart';
import 'package:afc/shared/components/adaptive_segmented_control/adaptive_segmented_control_cubit.dart';
import 'package:afc/shared/components/adaptive_slider/adaptive_slider_cubit.dart';
import 'package:afc/shared/components/adaptive_slider/adptive_slider.dart';
import 'package:afc/shared/components/adaptive_stepper/adaptive_stepper.dart';
import 'package:afc/shared/components/adaptive_stepper/adaptive_stepper_cubit.dart';
import 'package:afc/shared/components/adaptive_switch/adaptive_switch.dart';
import 'package:afc/shared/components/adaptive_switch/adaptive_switch_cubit.dart';
import 'package:afc/shared/components/adaptive_text_field/adaptive_text_field.dart';
import 'package:afc/shared/components/adaptive_text_field/adaptive_text_field_cubit.dart';
import 'package:afc/shared/components/circular_button/circular_button.dart';
import 'package:afc/shared/components/circular_button/circular_button_cubit.dart';
import 'package:afc/shared/components/custom_list_tile/custom_list_tile.dart';
import 'package:afc/shared/components/custom_progress_bar/custom_progress_bar.dart';
import 'package:afc/shared/components/custom_snackbar/custom_snackbar.dart';
import 'package:afc/shared/components/custom_stepper/custom_stepper.dart';
import 'package:afc/shared/components/custom_tooltip/custom_tooltip.dart';
import 'package:afc/shared/components/horizontal_date_picker/horizontal_date_picker.dart';
import 'package:afc/shared/components/message_bubble/message_bubble.dart';
import 'package:afc/shared/components/message_input/message_input.dart';
import 'package:afc/shared/components/pagination_dots/pagination_dots.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    final searchFocusNode = FocusNode();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Components Showcase')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BlocProvider(
              create: (_) => AdaptiveNavBarCubit(),
              child: const AdaptiveNavBar(title: 'Adaptive Nav Bar'),
            ),
            const SizedBox(height: 16),
            const ActionCard(
              style: ActionCardStyle.iconHeader,
              title: 'Action Card',
              description: 'Example description for action card.',
              buttonText: 'Continue',
            ),
            const SizedBox(height: 16),
            ActionSheet(
              options: const [
                ActionSheetOption(id: '1', label: 'Option 1'),
                ActionSheetOption(id: '2', label: 'Option 2'),
              ],
              onOptionSelected: (_) {},
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (_) => AdaptiveBadgeCubit(),
              child: const AdaptiveBadge(
                type: AdaptiveBadgeType.status,
                semanticLabel: 'Info badge',
              ),
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (_) => AdaptiveButtonCubit(),
              child: const AdaptiveButton(text: 'Adaptive Button'),
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (_) => AdaptiveCheckboxCubit(),
              child: const AdaptiveCheckbox(semanticLabel: 'Checkbox sample'),
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (_) => AdaptiveChipCubit(),
              child: const AdaptiveChip(label: 'Adaptive Chip'),
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (_) =>
                  AdaptiveDatePickerCubit(initialMonth: DateTime.now()),
              child: const AdaptiveDatePicker(semanticLabel: 'Date picker'),
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (_) => AdaptivePopupCubit(),
              child: const AdaptivePopup(
                title: 'Adaptive Popup',
                description: 'This is a popup component preview.',
                primaryButtonText: 'Confirm',
              ),
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (_) => AdaptiveRadioButtonCubit(),
              child: const AdaptiveRadioButton(
                semanticLabel: 'Radio button sample',
              ),
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (_) => AdaptiveSearchBarCubit(),
              child: AdaptiveSearchBar(
                controller: searchController,
                focusNode: searchFocusNode,
              ),
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (_) => AdaptiveSegmentedControlCubit(),
              child: AdaptiveSegmentedControl(
                segments: ['First', 'Second'],
                semanticLabel: 'Segmented control',
              ),
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (_) => AdaptiveSliderCubit(),
              child: const AdaptiveSlider(semanticLabel: 'Slider sample'),
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (_) => AdaptiveStepperCubit(),
              child: const AdaptiveStepper(semanticLabel: 'Stepper sample'),
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (_) => AdaptiveSwitchCubit(),
              child: const AdaptiveSwitch(semanticLabel: 'Switch sample'),
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (_) => AdaptiveTextFieldCubit(),
              child: const AdaptiveTextField(
                semanticLabel: 'Text field sample',
              ),
            ),
            const SizedBox(height: 16),
            BlocProvider(
              create: (_) => CircularButtonCubit(),
              child: const CircularButton(
                icon: Icons.add,
                semanticLabel: 'Circular button',
              ),
            ),
            const SizedBox(height: 16),
            const CustomListTile(title: 'Custom list tile'),
            const SizedBox(height: 16),
            const CustomProgressBar(initialProgress: 0.4),
            const SizedBox(height: 16),
            const CustomSnackbar(title: 'Custom snackbar'),
            const SizedBox(height: 16),
            CustomStepper(steps: ['One', 'Two', 'Three']),
            const SizedBox(height: 16),
            const CustomTooltip(
              title: 'Tooltip title',
              description: 'Tooltip description',
              child: Icon(Icons.info_outline),
            ),
            const SizedBox(height: 16),
            HorizontalDatePicker(startDate: DateTime.now()),
            const SizedBox(height: 16),
            const MessageBubble(message: 'Message bubble example'),
            const SizedBox(height: 16),
            const MessageInput(),
            const SizedBox(height: 16),
            const PaginationDots(totalPages: 5),
          ],
        ),
      ),
    );
  }
}
