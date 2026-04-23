import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'custom_tooltip_cubit.dart';
export 'custom_tooltip_cubit.dart';

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

class _TooltipInternal extends StatefulWidget {
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
  State<_TooltipInternal> createState() => _TooltipInternalState();
}

class _TooltipInternalState extends State<_TooltipInternal> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _showTooltip() {
    _hideTooltip();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    double screenWidth = MediaQuery.of(context).size.width;

    double width = widget.maxWidth ?? (screenWidth * 0.8).clamp(0, 300.0);

    // Calculate horizontal shift to keep within screen bounds
    double targetCenterX = offset.dx + size.width / 2;
    double halfWidth = width / 2;
    double horizontalShift = 0;

    if (targetCenterX - halfWidth < 16) {
      horizontalShift = 16 - (targetCenterX - halfWidth);
    } else if (targetCenterX + halfWidth > screenWidth - 16) {
      horizontalShift = (screenWidth - 16) - (targetCenterX + halfWidth);
    }

    return OverlayEntry(
      builder: (context) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: _getOffset(size).translate(horizontalShift, 0),
          targetAnchor: _getTargetAnchor(),
          followerAnchor: _getFollowerAnchor(),
          child: _TooltipBubble(
            title: widget.title,
            description: widget.description,
            backgroundColor: widget.backgroundColor,
            textColor: widget.textColor,
            maxWidth: width,
            position: widget.position,
            onClose: () => context.read<CustomTooltipCubit>().hide(),
          ),
        ),
      ),
    );
  }

  Offset _getOffset(Size size) {
    switch (widget.position) {
      case TooltipPosition.top:
        return const Offset(0, -8);
      case TooltipPosition.bottom:
        return const Offset(0, 8);
      case TooltipPosition.left:
        return const Offset(-8, 0);
      case TooltipPosition.right:
        return const Offset(8, 0);
    }
  }

  Alignment _getTargetAnchor() {
    switch (widget.position) {
      case TooltipPosition.top:
        return Alignment.topCenter;
      case TooltipPosition.bottom:
        return Alignment.bottomCenter;
      case TooltipPosition.left:
        return Alignment.centerLeft;
      case TooltipPosition.right:
        return Alignment.centerRight;
    }
  }

  Alignment _getFollowerAnchor() {
    switch (widget.position) {
      case TooltipPosition.top:
        return Alignment.bottomCenter;
      case TooltipPosition.bottom:
        return Alignment.topCenter;
      case TooltipPosition.left:
        return Alignment.centerRight;
      case TooltipPosition.right:
        return Alignment.centerLeft;
    }
  }

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomTooltipCubit, CustomTooltipState>(
      listener: (context, state) {
        if (state.isVisible) {
          _showTooltip();
        } else {
          _hideTooltip();
        }
        if (widget.onVisibleChanged != null) widget.onVisibleChanged!();
      },
      builder: (context, state) {
        return CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.read<CustomTooltipCubit>().toggle(),
            child: Semantics(
              label: 'Info icon for ${widget.title}',
              hint: 'Tap to see details',
              child: widget.child,
            ),
          ),
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
  final VoidCallback onClose;

  const _TooltipBubble({
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.textColor,
    required this.maxWidth,
    required this.position,
    required this.onClose,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: Icon(Icons.close, color: textColor, size: 18),
                    ),
                  ],
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
