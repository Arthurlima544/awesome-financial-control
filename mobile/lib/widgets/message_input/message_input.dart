import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'message_input_cubit.dart';

class MessageInput extends StatelessWidget {
  final String initialText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onAddAction;

  // Customization
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final Color hintColor;
  final String hintText;

  const MessageInput({
    super.key,
    this.initialText = '',
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onAddAction,
    this.primaryColor = const Color(0xFF2962FF),
    this.backgroundColor = const Color(0xFFF8F9FA),
    this.textColor = const Color(0xFF1F2937),
    this.hintColor = const Color(0xFF9CA3AF),
    this.hintText = 'Type a message...',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MessageInputCubit(initialText: initialText),
      child: _MessageInputView(
        initialText: initialText,
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onAddAction: onAddAction,
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
        textColor: textColor,
        hintColor: hintColor,
        hintText: hintText,
      ),
    );
  }
}

class _MessageInputView extends StatelessWidget {
  final String initialText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onAddAction;
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final Color hintColor;
  final String hintText;

  const _MessageInputView({
    required this.initialText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onAddAction,
    required this.primaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.hintColor,
    required this.hintText,
  });

  void _handleSubmit(BuildContext context, String text) {
    if (text.trim().isNotEmpty) {
      if (onSubmitted != null) onSubmitted!(text);
      context.read<MessageInputCubit>().clear();
      controller?.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MessageInputCubit, MessageInputState>(
      listenWhen: (previous, current) => previous.text != current.text,
      listener: (context, state) {
        if (onChanged != null) onChanged!(state.text);
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth.isInfinite
                ? MediaQuery.of(context).size.width
                : constraints.maxWidth;

            // Responsive relative units
            final double iconSize = (maxWidth * 0.06).clamp(24.0, 32.0);
            final double fontSize = (maxWidth * 0.035).clamp(14.0, 16.0);
            final double padding = (maxWidth * 0.03).clamp(12.0, 16.0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: padding * 0.35,
                        right: padding * 0.6,
                      ),
                      child: Semantics(
                        button: true,
                        label: 'Add attachment',
                        child: InkWell(
                          onTap: onAddAction,
                          borderRadius: BorderRadius.circular(iconSize),
                          child: Icon(
                            Icons.add,
                            color: primaryColor,
                            size: iconSize * 1.1,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                          left: padding * 1.2,
                          right: padding * 0.4,
                          top: padding * 0.2,
                          bottom: padding * 0.2,
                        ),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(30.0),
                          border: state.errorMessage != null
                              ? Border.all(color: Colors.red, width: 1.0)
                              : null,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Focus(
                                onFocusChange: (hasFocus) => context
                                    .read<MessageInputCubit>()
                                    .focusChanged(hasFocus),
                                child: TextFormField(
                                  initialValue: controller == null
                                      ? (initialText.isEmpty
                                            ? null
                                            : initialText)
                                      : null,
                                  controller: controller,
                                  focusNode: focusNode,
                                  onChanged: (val) => context
                                      .read<MessageInputCubit>()
                                      .textChanged(val),
                                  onFieldSubmitted: (val) =>
                                      _handleSubmit(context, val),
                                  minLines: 1,
                                  maxLines: 5,
                                  textInputAction: TextInputAction.send,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    color: textColor,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: hintText,
                                    hintStyle: TextStyle(
                                      color: hintColor,
                                      fontSize: fontSize,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: padding * 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (state.text.trim().isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                  left: padding * 0.5,
                                  bottom: padding * 0.2,
                                ),
                                child: Semantics(
                                  button: true,
                                  label: 'Send message',
                                  child: GestureDetector(
                                    onTap: () =>
                                        _handleSubmit(context, state.text),
                                    child: CircleAvatar(
                                      radius: iconSize * 0.75,
                                      backgroundColor: primaryColor,
                                      child: Icon(
                                        Icons.send,
                                        color: Colors.white,
                                        size: iconSize * 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (state.errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(
                      top: padding * 0.5,
                      left: iconSize * 1.2 + padding * 2,
                    ),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: fontSize * 0.85,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
