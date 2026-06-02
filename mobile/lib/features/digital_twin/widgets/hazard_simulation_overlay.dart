import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extensions.dart';

/// Educational hazard visualization overlay on the BIM viewer.
class HazardSimulationOverlay extends StatelessWidget {
  const HazardSimulationOverlay({
    super.key,
    required this.mode,
    this.explanation,
    this.progress = 0.0,
  });

  final String mode;
  final String? explanation;
  final double progress;

  @override
  Widget build(BuildContext context) {
    if (mode == 'none') return const SizedBox.shrink();

    final config = _config(mode);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (mode == 'flood') _FloodOverlay(level: progress.clamp(0, 1)),
        if (mode == 'earthquake') _EarthquakeOverlay(phase: progress),
        if (mode == 'wind') _WindOverlay(phase: progress),
        if (mode == 'landslide') _LandslideOverlay(phase: progress),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: _ExplanationCard(
            title: config.title,
            subtitle: config.subtitle,
            detail: explanation ?? config.defaultDetail,
            color: config.color,
            icon: config.icon,
          ),
        ),
      ],
    );
  }

  _HazardConfig _config(String mode) => switch (mode) {
        'earthquake' => _HazardConfig(
            title: 'Earthquake simulation',
            subtitle: 'Lateral forces · Box action · Band continuity',
            defaultDetail:
                'Seismic bands and ring beams tie walls into a rigid box. Reinforcement cages transfer inertial forces to the foundation.',
            color: AppColors.hazard,
            icon: Icons.sensors,
          ),
        'flood' => _HazardConfig(
            title: 'Flood simulation',
            subtitle: 'Water rise · Elevated platform · Buoyancy',
            defaultDetail:
                'Raised plinth and amphibious systems keep living space above design flood level. Buoyant modules reduce hydrostatic pressure on walls.',
            color: const Color(0xFF0369A1),
            icon: Icons.waves,
          ),
        'wind' => _HazardConfig(
            title: 'Wind simulation',
            subtitle: 'Uplift · Roof anchorage · Wall ties',
            defaultDetail:
                'Roof diaphragm and wall-to-roof connections resist suction. Light-gauge and timber roofs require enhanced edge fastening.',
            color: const Color(0xFF7C3AED),
            icon: Icons.air,
          ),
        'landslide' => _HazardConfig(
            title: 'Landslide simulation',
            subtitle: 'Slope stability · Geogrid tension',
            defaultDetail:
                'Geogrid layers mobilize soil arching and tensile resistance along the failure plane, reducing driving forces on the structure.',
            color: AppColors.orange,
            icon: Icons.terrain,
          ),
        _ => _HazardConfig(
            title: 'Hazard view',
            subtitle: '',
            defaultDetail: '',
            color: AppColors.mutedForeground,
            icon: Icons.warning,
          ),
      };
}

class _HazardConfig {
  const _HazardConfig({
    required this.title,
    required this.subtitle,
    required this.defaultDetail,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String defaultDetail;
  final Color color;
  final IconData icon;
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String detail;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      color: AppColors.navy.withValues(alpha: 0.92),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: tokens.textOnHero,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 11),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    detail,
                    style: TextStyle(
                      color: tokens.textOnHeroMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloodOverlay extends StatelessWidget {
  const _FloodOverlay({required this.level});

  final double level;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.15 + level * 0.45,
        widthFactor: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0369A1).withValues(alpha: 0.0),
                const Color(0xFF0369A1).withValues(alpha: 0.35 + level * 0.25),
              ],
            ),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'DESIGN FLOOD LEVEL',
                style: TextStyle(
                  color: context.appTokens.textOnHeroMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EarthquakeOverlay extends StatelessWidget {
  const _EarthquakeOverlay({required this.phase});

  final double phase;

  @override
  Widget build(BuildContext context) {
    final offset = 4 * math.sin(phase * 6.28);
    return Transform.translate(
      offset: Offset(offset, 0),
      child: CustomPaint(
        painter: _ForcePathPainter(phase: phase),
        size: Size.infinite,
      ),
    );
  }
}

class _WindOverlay extends StatelessWidget {
  const _WindOverlay({required this.phase});

  final double phase;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WindArrowPainter(phase: phase),
      size: Size.infinite,
    );
  }
}

class _LandslideOverlay extends StatelessWidget {
  const _LandslideOverlay({required this.phase});

  final double phase;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 8 + phase * 24,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.orange.withValues(alpha: 0.6),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _ForcePathPainter extends CustomPainter {
  _ForcePathPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.hazard.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final base = size.height * 0.75;
    final path = Path()
      ..moveTo(cx - 60, base)
      ..lineTo(cx - 60, base - 120)
      ..lineTo(cx + 60, base - 120)
      ..lineTo(cx + 60, base);
    canvas.drawPath(path, paint);

    final arrow = Paint()
      ..color = AppColors.orange.withValues(alpha: 0.7 + 0.3 * math.sin(phase))
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(cx + 80 + 10 * math.sin(phase), base - 60),
      Offset(cx + 40 + 10 * math.sin(phase), base - 60),
      arrow,
    );
  }

  @override
  bool shouldRepaint(covariant _ForcePathPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _WindArrowPainter extends CustomPainter {
  _WindArrowPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7C3AED).withValues(alpha: 0.4)
      ..strokeWidth = 2;
    for (var i = 0; i < 5; i++) {
      final y = size.height * 0.2 + i * size.height * 0.12;
      final x = size.width * 0.7 + 20 * math.sin(phase + i);
      canvas.drawLine(Offset(x, y), Offset(x - 40, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WindArrowPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
