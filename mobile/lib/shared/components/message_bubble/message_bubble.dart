import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'message_bubble_cubit.dart';

enum MessageBubbleType { sent, received }

class MessageBubble extends StatelessWidget {
  final String message;
  final MessageBubbleType type;
  final bool hasTail;
  final ValueChanged<bool>? onSelectionChanged;
  final VoidCallback? onTap;

  // Customization
  final Color sentBackgroundColor;
  final Color receivedBackgroundColor;
  final Color sentTextColor;
  final Color receivedTextColor;
  final Color selectedOverlayColor;
  final FocusNode? focusNode;

  const MessageBubble({
    super.key,
    required this.message,
    this.type = MessageBubbleType.received,
    this.hasTail = true,
    this.onSelectionChanged,
    this.onTap,
    this.sentBackgroundColor = const Color(0xFF3B82F6), // Blue
    this.receivedBackgroundColor = const Color(0xFFF8F9FA), // Light Gray
    this.sentTextColor = Colors.white,
    this.receivedTextColor = const Color(0xFF1F2937),
    this.selectedOverlayColor = const Color(
      0x33000000,
    ), // Semi-transparent black
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MessageBubbleCubit(),
      child: _MessageBubbleView(
        message: message,
        type: type,
        hasTail: hasTail,
        onSelectionChanged: onSelectionChanged,
        onTap: onTap,
        sentBackgroundColor: sentBackgroundColor,
        receivedBackgroundColor: receivedBackgroundColor,
        sentTextColor: sentTextColor,
        receivedTextColor: receivedTextColor,
        selectedOverlayColor: selectedOverlayColor,
        focusNode: focusNode,
      ),
    );
  }
}

class _MessageBubbleView extends StatelessWidget {
  final String message;
  final MessageBubbleType type;
  final bool hasTail;
  final ValueChanged<bool>? onSelectionChanged;
  final VoidCallback? onTap;
  final Color sentBackgroundColor;
  final Color receivedBackgroundColor;
  final Color sentTextColor;
  final Color receivedTextColor;
  final Color selectedOverlayColor;
  final FocusNode? focusNode;

  const _MessageBubbleView({
    required this.message,
    required this.type,
    required this.hasTail,
    this.onSelectionChanged,
    this.onTap,
    required this.sentBackgroundColor,
    required this.receivedBackgroundColor,
    required this.sentTextColor,
    required this.receivedTextColor,
    required this.selectedOverlayColor,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adaptive sizing
        final maxWidth = constraints.maxWidth;
        final maxBubbleWidth =
            maxWidth * 0.75; // Bubble takes max 75% of screen width
        final double relativePaddingHorizontal = (maxWidth * 0.04).clamp(
          16.0,
          24.0,
        );
        final double relativePaddingVertical = (maxWidth * 0.03).clamp(
          12.0,
          18.0,
        );
        final double fontSize = (maxWidth * 0.04).clamp(14.0, 18.0);
        final double borderRadiusValue = (maxWidth * 0.06).clamp(20.0, 32.0);

        final isSent = type == MessageBubbleType.sent;
        final alignment = isSent ? Alignment.centerRight : Alignment.centerLeft;
        final backgroundColor = isSent
            ? sentBackgroundColor
            : receivedBackgroundColor;
        final textColor = isSent ? sentTextColor : receivedTextColor;

        // Determine border radius based on type and tail configuration
        final borderRadius = BorderRadius.only(
          topLeft: Radius.circular(borderRadiusValue),
          topRight: Radius.circular(borderRadiusValue),
          bottomLeft: Radius.circular(
            !isSent && hasTail ? 0.0 : borderRadiusValue,
          ),
          bottomRight: Radius.circular(
            isSent && hasTail ? 0.0 : borderRadiusValue,
          ),
        );

        return BlocBuilder<MessageBubbleCubit, MessageBubbleState>(
          builder: (context, state) {
            return Align(
              alignment: alignment,
              child: Semantics(
                label: '${isSent ? 'Sent' : 'Received'} message: $message',
                selected: state.isSelected,
                button: true,
                child: Focus(
                  focusNode: focusNode,
                  child: GestureDetector(
                    onTap: () {
                      if (onTap != null) onTap!();
                    },
                    onLongPress: () {
                      context.read<MessageBubbleCubit>().toggleSelection();
                      if (onSelectionChanged != null) {
                        onSelectionChanged!(!state.isSelected);
                      }
                    },
                    child: Column(
                      crossAxisAlignment: isSent
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                          padding: EdgeInsets.symmetric(
                            horizontal: relativePaddingHorizontal,
                            vertical: relativePaddingVertical,
                          ),
                          decoration: BoxDecoration(
                            color: state.isSelected
                                ? Color.alphaBlend(
                                    selectedOverlayColor,
                                    backgroundColor,
                                  )
                                : backgroundColor,
                            borderRadius: borderRadius,
                          ),
                          child: Text(
                            message,
                            style: TextStyle(
                              color: textColor,
                              fontSize: fontSize,
                              height: 1.4,
                            ),
                          ),
                        ),
                        if (state.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              state.errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
