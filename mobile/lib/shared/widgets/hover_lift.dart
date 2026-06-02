import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HoverLift extends StatefulWidget {
  const HoverLift({
    super.key,
    required this.child,
    this.enabled = true,
    this.scale = 1.02,
    this.lift = 6,
    this.duration = const Duration(milliseconds: 160),
    this.curve = Curves.easeOut,
  });

  final Widget child;
  final bool enabled;
  final double scale;
  final double lift;
  final Duration duration;
  final Curve curve;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final canHover = widget.enabled && (kIsWeb || {
          TargetPlatform.macOS,
          TargetPlatform.windows,
          TargetPlatform.linux,
        }.contains(defaultTargetPlatform));

    final scale = _hover ? widget.scale : 1.0;
    final dy = _hover ? -widget.lift : 0.0;

    Widget child = AnimatedContainer(
      duration: widget.duration,
      curve: widget.curve,
      transform: Matrix4.translationValues(0, dy, 0),
      child: AnimatedScale(
        duration: widget.duration,
        curve: widget.curve,
        scale: scale,
        child: widget.child,
      ),
    );

    if (!canHover) return child;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: child,
    );
  }
}

