import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BrandIcon extends StatelessWidget {
  const BrandIcon({
    super.key,
    this.size = 32,
    this.semanticsLabel = 'Resilient Build Pakistan',
  });

  final double size;
  final String semanticsLabel;

  static const assetPath = 'assets/images/branding/resilient_build_shield.png';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      image: true,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => Icon(
          Icons.shield,
          size: size,
          color: AppColors.orange,
        ),
      ),
    );
  }
}

