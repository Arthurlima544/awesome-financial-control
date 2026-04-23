import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'adaptive_popup_cubit.dart';

class AdaptivePopup extends StatelessWidget {
  final String title;
  final String description;
  final String primaryButtonText;
  final String? secondaryButtonText;

  final void Function(String inputValue)? onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  final Widget? headerImage;
  final Widget? centeredIcon;

  final bool showInputField;
  final String? inputHintText;
  final TextEditingController? textController;
  final FocusNode? focusNode;

  final Color? primaryColor;
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;

  const AdaptivePopup({
    super.key,
    required this.title,
    required this.description,
    required this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.headerImage,
    this.centeredIcon,
    this.showInputField = false,
    this.inputHintText,
    this.textController,
    this.focusNode,
    this.primaryColor,
    this.backgroundColor,
    this.titleStyle,
    this.descriptionStyle,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final themePrimaryColor = primaryColor ?? const Color(0xFF624BFF);
    final themeBgColor = backgroundColor ?? Colors.white;

    return BlocBuilder<AdaptivePopupCubit, AdaptivePopupState>(
      builder: (context, state) {
        // Responsive width clamping
        final double rawWidth = screenSize.width * 0.85;
        final double popupWidth = rawWidth.clamp(280.0, 400.0);

        // Responsive padding and font sizes
        final double basePadding = popupWidth * 0.06;
        final double titleFontSize = popupWidth * 0.055 > 22.0
            ? 22.0
            : popupWidth * 0.055;
        final double descFontSize = popupWidth * 0.035 > 16.0
            ? 16.0
            : popupWidth * 0.035;
        final double buttonHeight = popupWidth * 0.12 > 48.0
            ? 48.0
            : popupWidth * 0.12;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: popupWidth,
              decoration: BoxDecoration(
                color: themeBgColor,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16.0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Optional Header Image (edge-to-edge at top)
                  if (headerImage != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16.0),
                      ),
                      child: SizedBox(
                        height: popupWidth * 0.4,
                        width: double.infinity,
                        child: FittedBox(fit: BoxFit.cover, child: headerImage),
                      ),
                    ),

                  Padding(
                    padding: EdgeInsets.all(basePadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Optional Centered Icon
                        if (centeredIcon != null) ...[
                          Container(
                            width: popupWidth * 0.2,
                            height: popupWidth * 0.2,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Center(child: centeredIcon),
                          ),
                          SizedBox(height: basePadding),
                        ],

                        // Text Content
                        Semantics(
                          header: true,
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style:
                                titleStyle ??
                                TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                          ),
                        ),
                        SizedBox(height: basePadding * 0.5),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style:
                              descriptionStyle ??
                              TextStyle(
                                fontSize: descFontSize,
                                fontWeight: FontWeight.w400,
                                color: Colors.black54,
                              ),
                        ),
                        SizedBox(height: basePadding),

                        // Optional Input Field
                        if (showInputField) ...[
                          Semantics(
                            textField: true,
                            label: 'Popup Input Field',
                            child: TextField(
                              controller: textController,
                              focusNode: focusNode,
                              onChanged: (val) {
                                context
                                    .read<AdaptivePopupCubit>()
                                    .onInputChanged(val);
                              },
                              decoration: InputDecoration(
                                hintText: inputHintText ?? 'Input text',
                                errorText: state.errorMessage,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: basePadding,
                                  vertical: basePadding * 0.8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color: themePrimaryColor,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: basePadding),
                        ],

                        // Primary Action Button
                        Semantics(
                          button: true,
                          label: primaryButtonText,
                          child: SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
                            child: ElevatedButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () {
                                      onPrimaryAction?.call(state.inputValue);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themePrimaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    24.0,
                                  ), // Pill shape
                                ),
                                elevation: 0,
                              ),
                              child: state.isLoading
                                  ? SizedBox(
                                      height: buttonHeight * 0.5,
                                      width: buttonHeight * 0.5,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      primaryButtonText,
                                      style: TextStyle(
                                        fontSize: descFontSize,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        // Secondary Action Button (Optional)
                        if (secondaryButtonText != null) ...[
                          SizedBox(height: basePadding * 0.5),
                          Semantics(
                            button: true,
                            label: secondaryButtonText,
                            child: SizedBox(
                              width: double.infinity,
                              height: buttonHeight,
                              child: TextButton(
                                onPressed: state.isLoading
                                    ? null
                                    : onSecondaryAction,
                                style: TextButton.styleFrom(
                                  foregroundColor: themePrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                                child: Text(
                                  secondaryButtonText!,
                                  style: TextStyle(
                                    fontSize: descFontSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
