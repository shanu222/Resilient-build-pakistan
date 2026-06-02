import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared page transition curves for navigation polish.
abstract final class AppPageTransitions {
  static CustomTransitionPage<T> fadeSlide<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 320),
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static CustomTransitionPage<T> scaleFade<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

/// Staggered fade-in for list/grid cards.
class AnimatedFadeSlide extends StatefulWidget {
  const AnimatedFadeSlide({
    super.key,
    required this.child,
    this.index = 0,
    this.delayMs = 40,
  });

  final Widget child;
  final int index;
  final int delayMs;

  @override
  State<AnimatedFadeSlide> createState() => _AnimatedFadeSlideState();
}

class _AnimatedFadeSlideState extends State<AnimatedFadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future<void>.delayed(
      Duration(milliseconds: widget.index * widget.delayMs),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

/// Animated timeline stage chip highlight.
class AnimatedStageChip extends StatelessWidget {
  const AnimatedStageChip({
    super.key,
    required this.label,
    required this.title,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String title;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 88,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE85D04).withValues(alpha: 0.12) : const Color(0xFFE8EDF3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? const Color(0xFFE85D04) : const Color(0xFFE2E8F0),
              width: active ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: active ? const Color(0xFFE85D04) : const Color(0xFF64748B),
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
