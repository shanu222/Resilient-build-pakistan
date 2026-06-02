import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../navigation/model_navigation.dart';
import '../theme/app_theme_extensions.dart';
import '../../data/models/house_model.dart';

/// Previous / next model controls for guidelines and model flows.
class ModelPagerBar extends StatelessWidget {
  const ModelPagerBar({
    super.key,
    required this.models,
    required this.current,
    this.onNavigate,
  });

  final List<HouseModel> models;
  final HouseModel current;
  final void Function(HouseModel model)? onNavigate;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final neighbors = ModelNavigation.neighbors(models, current.id);
    if (neighbors.prev == null && neighbors.next == null) {
      return const SizedBox.shrink();
    }

    void go(HouseModel? m) {
      if (m == null) return;
      if (onNavigate != null) {
        onNavigate!(m);
      } else {
        context.go('/model/${m.id}');
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: _PagerButton(
              enabled: neighbors.prev != null,
              icon: Icons.chevron_left,
              label: neighbors.prev?.name ?? 'Previous',
              alignStart: true,
              tokens: tokens,
              onTap: () => go(neighbors.prev),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PagerButton(
              enabled: neighbors.next != null,
              icon: Icons.chevron_right,
              label: neighbors.next?.name ?? 'Next',
              alignStart: false,
              tokens: tokens,
              onTap: () => go(neighbors.next),
            ),
          ),
        ],
      ),
    );
  }
}

class _PagerButton extends StatelessWidget {
  const _PagerButton({
    required this.enabled,
    required this.icon,
    required this.label,
    required this.alignStart,
    required this.tokens,
    required this.onTap,
  });

  final bool enabled;
  final IconData icon;
  final String label;
  final bool alignStart;
  final AppThemeTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = enabled ? tokens.textPrimary : tokens.textSecondary;
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        minimumSize: const Size(0, 44),
        side: BorderSide(color: tokens.border),
      ),
      child: Row(
        mainAxisAlignment:
            alignStart ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (!alignStart)
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
              ),
            ),
          if (!alignStart) const SizedBox(width: 4),
          Icon(icon, size: 18, color: fg),
          if (alignStart) const SizedBox(width: 4),
          if (alignStart)
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
              ),
            ),
        ],
      ),
    );
  }
}
