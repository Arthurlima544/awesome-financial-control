import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../view_models/privacy/privacy_cubit.dart';

class PrivacyText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  const PrivacyText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrivacyCubit, PrivacyState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            state.isPrivate ? '•••••' : text,
            key: ValueKey<String>(state.isPrivate ? 'private' : text),
            style: style,
            textAlign: textAlign,
            overflow: overflow,
            maxLines: maxLines,
          ),
        );
      },
    );
  }
}
