import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'custom_tooltip_cubit.dart';

class CustomTooltip extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;
  final TooltipPosition position;
  final Color backgroundColor;
  final Color textColor;
  final double? maxWidth;
  final VoidCallback? onVisibleChanged;

  const CustomTooltip({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.position = TooltipPosition.top,
    this.backgroundColor = const Color(0xFF2D2E33),
    this.textColor = Colors.white,
    this.maxWidth,
    this.onVisibleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomTooltipCubit(),
      child: _TooltipInternal(
        title: title,
        description: description,
        position: position,
        backgroundColor: backgroundColor,
        textColor: textColor,
        maxWidth: maxWidth,
        onVisibleChanged: onVisibleChanged,
        child: child,
      ),
    );
  }
}

class _TooltipInternal extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;
  final TooltipPosition position;
  final Color backgroundColor;
  final Color textColor;
  final double? maxWidth;
  final VoidCallback? onVisibleChanged;

  const _TooltipInternal({
    required this.title,
    required this.description,
    required this.child,
    required this.position,
    required this.backgroundColor,
    required this.textColor,
    this.maxWidth,
    this.onVisibleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomTooltipCubit, CustomTooltipState>(
      listener: (context, state) {
        if (onVisibleChanged != null) onVisibleChanged!();
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final computedMaxWidth =
                maxWidth ?? (isMobile ? constraints.maxWidth * 0.8 : 300.0);

            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.read<CustomTooltipCubit>().toggle(),
                  child: Semantics(
                    label: 'Info icon for $title',
                    hint: 'Tap to see details',
                    child: child,
                  ),
                ),
                if (state.isVisible)
                  Positioned(
                    bottom: position == TooltipPosition.top ? 40 : null,
                    top: position == TooltipPosition.bottom ? 40 : null,
                    left: position == TooltipPosition.right ? 40 : null,
                    right: position == TooltipPosition.left ? 40 : null,
                    child: _TooltipBubble(
                      title: title,
                      description: description,
                      backgroundColor: backgroundColor,
                      textColor: textColor,
                      maxWidth: computedMaxWidth,
                      position: position,
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

class _TooltipBubble extends StatelessWidget {
  final String title;
  final String description;
  final Color backgroundColor;
  final Color textColor;
  final double maxWidth;
  final TooltipPosition position;

  const _TooltipBubble({
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.textColor,
    required this.maxWidth,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (position == TooltipPosition.bottom) _buildArrow(),
          Container(
            width: maxWidth,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black26,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (position == TooltipPosition.top) _buildArrow(),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return CustomPaint(
      size: const Size(12, 8),
      painter: _ArrowPainter(color: backgroundColor, position: position),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final TooltipPosition position;

  _ArrowPainter({required this.color, required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (position == TooltipPosition.top) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    } else {
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
