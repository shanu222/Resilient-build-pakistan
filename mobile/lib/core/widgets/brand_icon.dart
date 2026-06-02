import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../../shared/widgets/app_brand_logo.dart';

class BrandIcon extends StatelessWidget {
  const BrandIcon({
    super.key,
    this.size = 32,
    this.semanticsLabel = 'Resilient Build Pakistan',
  });

  final double size;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    // Backwards-compatible wrapper: prefer the official brand logo.
    return SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.contain,
        child: AppBrandLogo(
          size: size,
          semanticsLabel: semanticsLabel,
        ),
      ),
    );
  }
}

