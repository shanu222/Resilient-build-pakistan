import 'package:flutter/material.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import 'glass_card.dart';
import 'hover_lift.dart';

class GlassSidebar extends StatelessWidget {
  const GlassSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.items,
    this.header,
    this.extended = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final List<GlassSidebarItem> items;
  final Widget? header;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final w = extended ? 260.0 : 92.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      child: SizedBox(
        width: w,
        child: GlassCard(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
          borderRadius: 22,
          child: Column(
            children: [
              if (header != null) ...[
                header!,
                const SizedBox(height: 12),
              ],
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final it = items[i];
                    final active = i == selectedIndex;
                    return _GlassNavTile(
                      extended: extended,
                      active: active,
                      icon: active ? it.selectedIcon : it.icon,
                      label: it.label,
                      onTap: () => onSelect(i),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              if (AppBreakpoints.isLargeDesktop(context))
                Text(
                  'NDMA',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassSidebarItem {
  const GlassSidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _GlassNavTile extends StatelessWidget {
  const _GlassNavTile({
    required this.extended,
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool extended;
  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final glow = AppColors.orange.withValues(alpha: active ? 0.30 : 0.0);
    return HoverLift(
      enabled: !active,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: extended ? 12 : 10,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: active ? 0.10 : 0.06),
            border: Border.all(
              color: Colors.white.withValues(alpha: active ? 0.20 : 0.12),
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: glow,
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment:
                extended ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              if (extended) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: active ? 10 : 0,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

