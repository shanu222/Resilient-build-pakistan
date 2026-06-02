import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/shell_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import 'glass_card.dart';
import 'hover_lift.dart';

class GlassSidebar extends ConsumerWidget {
  const GlassSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    required this.items,
    this.forceCollapsed,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final List<GlassSidebarItem> items;
  final bool? forceCollapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure non-null bool for null-safety (web compilation is stricter).
    final bool collapsed =
        (forceCollapsed ?? ref.watch(sidebarCollapsedProvider)) ?? false;
    final bool extended = !collapsed;
    final tokens = context.appTokens;
    final w = extended ? 248.0 : 76.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: w + 24,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: GlassCard(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
          borderRadius: 22,
          child: Column(
            children: [
              _CollapseToggle(extended: extended),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final it = items[i];
                    final active = i == selectedIndex;
                    final tile = _GlassNavTile(
                      extended: extended,
                      active: active,
                      icon: active ? it.selectedIcon : it.icon,
                      label: it.label,
                      emoji: it.emoji,
                      onTap: () => onSelect(i),
                      tokens: tokens,
                    );
                    if (extended) return tile;
                    return Tooltip(message: it.label, preferBelow: false, child: tile);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollapseToggle extends ConsumerWidget {
  const _CollapseToggle({required this.extended});
  final bool extended;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collapsed = ref.watch(sidebarCollapsedProvider);
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        tooltip: collapsed ? 'Expand sidebar' : 'Collapse sidebar',
        onPressed: () => ref.read(sidebarCollapsedProvider.notifier).toggle(),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Icon(
            collapsed ? Icons.menu_open : Icons.menu,
            key: ValueKey(collapsed),
            color: context.appTokens.textSecondary,
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
    this.emoji,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? emoji;
}

class _GlassNavTile extends StatelessWidget {
  const _GlassNavTile({
    required this.extended,
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.tokens,
    this.emoji,
  });

  final bool extended;
  final bool active;
  final IconData icon;
  final String label;
  final String? emoji;
  final VoidCallback onTap;
  final AppThemeTokens tokens;

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
            horizontal: extended ? 12 : 8,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: (active ? tokens.textPrimary : tokens.textSecondary)
                .withValues(alpha: active ? 0.12 : 0.06),
            border: Border.all(
              color: (active ? tokens.textPrimary : tokens.border)
                  .withValues(alpha: active ? 0.35 : 0.55),
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
              if (emoji != null && extended)
                Text(emoji!, style: const TextStyle(fontSize: 16))
              else
                Icon(
                  icon,
                  color: active ? tokens.textPrimary : tokens.textSecondary,
                  size: 22,
                ),
              if (extended) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: active ? tokens.textPrimary : tokens.textSecondary,
                      fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: active ? 8 : 0,
                  height: 8,
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
