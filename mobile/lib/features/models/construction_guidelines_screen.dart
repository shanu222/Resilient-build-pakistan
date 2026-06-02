import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../core/navigation/app_breadcrumbs.dart';
import '../../core/layout/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../core/widgets/government_header.dart';
import '../../core/widgets/model_pager_bar.dart';
import '../../data/models/house_model.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/fade_slide_in.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/hover_lift.dart';
import '../../shared/widgets/zoomable_asset_image.dart';

class ConstructionGuidelinesScreen extends StatefulWidget {
  const ConstructionGuidelinesScreen({
    super.key,
    required this.house,
  });

  final HouseModel house;

  @override
  State<ConstructionGuidelinesScreen> createState() =>
      _ConstructionGuidelinesScreenState();
}

class _ConstructionGuidelinesScreenState
    extends State<ConstructionGuidelinesScreen>
    with SingleTickerProviderStateMixin {
  final PdfViewerController _pdfController = PdfViewerController();
  final TextEditingController _search = TextEditingController();
  late final TabController _tabController;

  late final Future<bool> _pdfExists = _assetExists(widget.house.constructionGuidelinesPdfAsset);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    final isTablet = AppBreakpoints.isTablet(context);
    final tokens = context.appTokens;

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: GovernmentHeader(
          title: widget.house.name,
          showBack: true,
          breadcrumbs: [
            const BreadcrumbSegment(label: 'Home', path: '/home'),
            const BreadcrumbSegment(label: 'Models', path: '/models'),
            BreadcrumbSegment(label: widget.house.name, path: '/model/${widget.house.id}'),
            const BreadcrumbSegment(label: 'Guidelines'),
          ],
        ),
        body: FutureBuilder<bool>(
          future: _pdfExists,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const _DocLoadingSkeleton();
            }
            final exists = snap.data ?? false;
            final content = isDesktop
                ? _DesktopLayout(
                    house: widget.house,
                    pdfAssetPath: widget.house.constructionGuidelinesPdfAsset,
                    pdfExists: exists,
                    pdfController: _pdfController,
                    search: _search,
                    tabController: _tabController,
                    onDownloadPdf: () =>
                        _downloadPdfFromAsset(widget.house.constructionGuidelinesPdfAsset),
                  )
                : _MobileLayout(
                    house: widget.house,
                    pdfAssetPath: widget.house.constructionGuidelinesPdfAsset,
                    pdfExists: exists,
                    pdfController: _pdfController,
                    search: _search,
                    tabController: _tabController,
                    onDownloadPdf: () =>
                        _downloadPdfFromAsset(widget.house.constructionGuidelinesPdfAsset),
                    showSidePanels: isTablet,
                  );

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tokens.surface,
                    tokens.primary.withValues(alpha: 0.92),
                    tokens.primary,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: content,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _downloadPdfFromAsset(String assetPath) async {
    // Best-effort download/share without forcing a browser redirect.
    // On web, Share.shareXFiles is supported by the plugin for some browsers;
    // otherwise it will no-op gracefully.
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      await Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            mimeType: 'application/pdf',
            name: '${widget.house.id}_construction_guidelines.pdf',
          ),
        ],
        text: '${widget.house.name} — Construction Guidelines',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download not available on this platform: $e'),
          backgroundColor: AppColors.navy,
        ),
      );
    }
  }
}

class _DesktopLayout extends ConsumerWidget {
  const _DesktopLayout({
    required this.house,
    required this.pdfAssetPath,
    required this.pdfExists,
    required this.pdfController,
    required this.search,
    required this.onDownloadPdf,
    required this.tabController,
  });

  final HouseModel house;
  final String pdfAssetPath;
  final bool pdfExists;
  final PdfViewerController pdfController;
  final TextEditingController search;
  final VoidCallback onDownloadPdf;
  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final models = ref.watch(housesProvider).valueOrNull ?? const [];
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
          child: SizedBox(
            width: 280,
            child: _LeftNav(
              house: house,
              selectedIndex: tabController.index,
              onSelect: (i) => tabController.animateTo(i),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
                child: FadeSlideIn(child: _ModelHeaderCard(house: house)),
              ),
              ModelPagerBar(
                models: models,
                current: house,
                onNavigate: (m) => context.go('/model/${m.id}/guidelines'),
              ),
              Expanded(
                child: _CenterTabBody(
                  house: house,
                  tabIndex: tabController.index,
                  pdfAssetPath: pdfAssetPath,
                  pdfExists: pdfExists,
                  pdfController: pdfController,
                  search: search,
                  onDownloadPdf: onDownloadPdf,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 16, 16, 16),
          child: SizedBox(
            width: 360,
            child: _RightPanel(house: house, compact: true),
          ),
        ),
      ],
    );
  }
}

class _MobileLayout extends ConsumerWidget {
  const _MobileLayout({
    required this.house,
    required this.pdfAssetPath,
    required this.pdfExists,
    required this.pdfController,
    required this.search,
    required this.onDownloadPdf,
    required this.showSidePanels,
    required this.tabController,
  });

  final HouseModel house;
  final String pdfAssetPath;
  final bool pdfExists;
  final PdfViewerController pdfController;
  final TextEditingController search;
  final VoidCallback onDownloadPdf;
  final bool showSidePanels;
  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final models = ref.watch(housesProvider).valueOrNull ?? const [];
    final tokens = context.appTokens;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: FadeSlideIn(child: _ModelHeaderCard(house: house)),
        ),
        ModelPagerBar(
          models: models,
          current: house,
          onNavigate: (m) => context.go('/model/${m.id}/guidelines'),
        ),
        TabBar(
          controller: tabController,
          isScrollable: true,
          labelColor: tokens.textOnPrimary,
          unselectedLabelColor: tokens.textOnPrimary.withValues(alpha: 0.65),
          indicatorColor: AppColors.orange,
          tabs: const [
            Tab(text: 'Guidelines'),
            Tab(text: 'Infographic'),
            Tab(text: 'Quick ref'),
            Tab(text: 'Checklist'),
          ],
        ),
        Expanded(
          child: _CenterTabBody(
            house: house,
            tabIndex: tabController.index,
            pdfAssetPath: pdfAssetPath,
            pdfExists: pdfExists,
            pdfController: pdfController,
            search: search,
            onDownloadPdf: onDownloadPdf,
          ),
        ),
        if (showSidePanels)
          SizedBox(
            height: 280,
            child: _RightPanel(house: house, compact: true),
          ),
      ],
    );
  }
}

class _CenterTabBody extends StatelessWidget {
  const _CenterTabBody({
    required this.house,
    required this.tabIndex,
    required this.pdfAssetPath,
    required this.pdfExists,
    required this.pdfController,
    required this.search,
    required this.onDownloadPdf,
  });

  final HouseModel house;
  final int tabIndex;
  final String pdfAssetPath;
  final bool pdfExists;
  final PdfViewerController pdfController;
  final TextEditingController search;
  final VoidCallback onDownloadPdf;

  @override
  Widget build(BuildContext context) {
    return switch (tabIndex) {
      0 => _PdfCard(
          pdfAssetPath: pdfAssetPath,
          pdfExists: pdfExists,
          controller: pdfController,
          search: search,
          onDownloadPdf: onDownloadPdf,
          house: house,
        ),
      1 => Padding(
          padding: const EdgeInsets.all(12),
          child: ZoomableAssetImage(
            assetPath: house.constructionInfographicAsset,
            semanticsLabel: '${house.name} infographic',
            minHeight: 320,
          ),
        ),
      2 => _QuickReferencePanel(house: house),
      _ => _ChecklistPanel(house: house),
    };
  }
}

class _LeftNav extends StatelessWidget {
  const _LeftNav({
    required this.house,
    required this.selectedIndex,
    required this.onSelect,
  });

  final HouseModel house;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static const _items = [
    (Icons.picture_as_pdf_outlined, 'Guidelines', 'PDF reader'),
    (Icons.image_outlined, 'Infographic', 'Visual sheet'),
    (Icons.menu_book_outlined, 'Quick reference', 'Stages & materials'),
    (Icons.fact_check_outlined, 'Checklist', 'QA inspection'),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Document Center',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: tokens.textOnPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          _ModelThumb(house: house),
          const SizedBox(height: 12),
          for (var i = 0; i < _items.length; i++)
            _NavItem(
              icon: _items[i].$1,
              title: _items[i].$2,
              subtitle: _items[i].$3,
              selected: selectedIndex == i,
              onTap: () => onSelect(i),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: tokens.textOnPrimary.withValues(alpha: selected ? 0.14 : 0.07),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          dense: true,
          onTap: onTap,
          leading: Icon(icon, color: tokens.textOnPrimary),
          title: Text(
            title,
            style: TextStyle(
              color: tokens.textOnPrimary,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: tokens.textOnPrimary.withValues(alpha: 0.72)),
          ),
          trailing: Icon(
            selected ? Icons.radio_button_checked : Icons.chevron_right,
            color: selected ? AppColors.orange : tokens.textOnPrimary,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _ModelHeaderCard extends StatelessWidget {
  const _ModelHeaderCard({required this.house});
  final HouseModel house;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppBreakpoints.pagePadding(context),
      child: Card(
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                house.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              _Chip(label: house.category, icon: Icons.category_outlined),
              _Chip(
                label: 'Hazards: ${house.hazardsCovered.join(', ')}',
                icon: Icons.warning_amber_outlined,
              ),
              _Chip(
                label: 'Score: ${house.resilienceScore}',
                icon: Icons.shield_outlined,
              ),
              _Chip(
                label: 'Difficulty: ${house.complexity}',
                icon: Icons.construction_outlined,
              ),
              _Chip(
                label: 'Est. cost: PKR ${house.totalEstimatedCostPkr}',
                icon: Icons.payments_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border.all(color: tokens.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tokens.textPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: tokens.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _QuickReferencePanel extends StatelessWidget {
  const _QuickReferencePanel({required this.house});
  final HouseModel house;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _RefCard(
          title: 'Construction stages',
          lines: _RightPanel.stages,
          icon: Icons.view_timeline_outlined,
        ),
        _RefCard(
          title: 'Key materials',
          lines: house.materialIds.map((e) => e.replaceAll('_', ' ')).toList(),
          icon: Icons.category_outlined,
        ),
        _RefCard(
          title: 'Hazards covered',
          lines: house.hazardsCovered,
          icon: Icons.shield_outlined,
        ),
        _RefCard(
          title: 'Advantages',
          lines: house.advantages,
          icon: Icons.check_circle_outline,
          tone: _RefTone.success,
        ),
        _RefCard(
          title: 'Limitations',
          lines: house.limitations,
          icon: Icons.info_outline,
          tone: _RefTone.warning,
        ),
      ],
    );
  }
}

class _ChecklistPanel extends StatelessWidget {
  const _ChecklistPanel({required this.house});
  final HouseModel house;

  static const _checks = [
    'Site layout verified against drawings',
    'Excavation depth and bearing stratum confirmed',
    'Foundation levels, plumb, and reinforcement inspected',
    'Column/beam reinforcement: cover, laps, anchorage',
    'Masonry bond pattern and vertical alignment',
    'Lintels and bands continuous at openings',
    'Roof structure connections and bracing',
    'DPC, drainage, and moisture control',
    'Services penetrations sealed',
    'Final NDMA resilience checklist signed',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inspection checklist — ${house.name}',
                style: TextStyle(
                  color: tokens.textOnPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              ..._checks.map(
                (c) => CheckboxListTile(
                  value: false,
                  onChanged: (_) {},
                  dense: true,
                  title: Text(
                    c,
                    style: TextStyle(
                      color: tokens.textOnPrimary.withValues(alpha: 0.92),
                      fontSize: 13,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PdfCard extends StatelessWidget {
  const _PdfCard({
    required this.pdfAssetPath,
    required this.pdfExists,
    required this.controller,
    required this.search,
    required this.onDownloadPdf,
    required this.house,
  });

  final String pdfAssetPath;
  final bool pdfExists;
  final PdfViewerController controller;
  final TextEditingController search;
  final VoidCallback onDownloadPdf;
  final HouseModel house;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _PdfToolbar(
              controller: controller,
              search: search,
              onDownloadPdf: onDownloadPdf,
              onFullscreen: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _FullscreenPdf(
                      title: 'Construction Guidelines',
                      assetPath: pdfAssetPath,
                    ),
                  ),
                );
              },
            ),
            Divider(height: 1, color: tokens.border.withValues(alpha: 0.35)),
            Expanded(
              child: pdfExists
                  ? ColoredBox(
                      color: tokens.viewerBackground,
                      child: SfPdfViewer.asset(
                        pdfAssetPath,
                        controller: controller,
                        canShowScrollHead: true,
                        canShowScrollStatus: true,
                        canShowPaginationDialog: true,
                        enableTextSelection: true,
                        onDocumentLoadFailed: (d) {
                          if (!kDebugMode) return;
                          // ignore: avoid_print
                          print('PDF load failed: ${d.description}');
                        },
                      ),
                    )
                  : _MissingAsset(
                      title: 'Engineering manual unavailable',
                      subtitle:
                          'The bundled PDF for this model could not be loaded. Use Quick Reference or download the offline package.',
                      showActions: true,
                      onDownload: onDownloadPdf,
                      onQuickRef: () {},
                      house: house,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({required this.house, this.compact = false});
  final HouseModel house;
  final bool compact;

  static const stages = [
    '1. Site Layout',
    '2. Excavation',
    '3. Foundation',
    '4. Columns',
    '5. Plinth Beam',
    '6. Floor System',
    '7. Walls',
    '8. Openings',
    '9. Lintel Band',
    '10. Roof Structure',
    '11. Roof Cover',
    '12. Services',
    '13. Final Inspection',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        FadeSlideIn(child: _InfographicCard(house: house)),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Engineering intelligence',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: SfRadialGauge(
                      axes: [
                        RadialAxis(
                          minimum: 0,
                          maximum: 100,
                          showTicks: false,
                          showLabels: false,
                          axisLineStyle: AxisLineStyle(
                            thickness: 0.18,
                            thicknessUnit: GaugeSizeUnit.factor,
                            color: tokens.border.withValues(alpha: isDark ? 0.55 : 0.85),
                          ),
                          pointers: [
                            RangePointer(
                              value: house.resilienceScore.toDouble(),
                              width: 0.18,
                              sizeUnit: GaugeSizeUnit.factor,
                              gradient: const SweepGradient(
                                colors: [AppColors.orange, AppColors.info, AppColors.success],
                              ),
                              cornerStyle: CornerStyle.bothCurve,
                            ),
                          ],
                          annotations: [
                            GaugeAnnotation(
                              widget: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Score',
                                    style: TextStyle(color: tokens.textSecondary, fontSize: 11),
                                  ),
                                  Text(
                                    '${house.resilienceScore}',
                                    style: TextStyle(
                                      color: tokens.textPrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              angle: 90,
                              positionFactor: 0.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BadgeRow(
                          icon: Icons.construction_outlined,
                          label: 'Difficulty',
                          value: house.complexity,
                        ),
                        const SizedBox(height: 6),
                        _BadgeRow(
                          icon: Icons.payments_outlined,
                          label: 'Est. Cost',
                          value: 'PKR ${house.totalEstimatedCostPkr}',
                        ),
                        const SizedBox(height: 6),
                        _BadgeRow(
                          icon: Icons.schedule,
                          label: 'Duration',
                          value: '${house.constructionDurationDays} days',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: house.hazardsCovered
                    .map(
                      (h) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: tokens.chipBackground,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: tokens.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined, size: 14, color: tokens.chipForeground),
                            const SizedBox(width: 6),
                            Text(
                              h,
                              style: TextStyle(
                                color: tokens.chipForeground,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FadeSlideIn(
          delay: const Duration(milliseconds: 40),
          child: _RefCard(
            title: 'Advantages',
            lines: house.advantages,
            icon: Icons.check_circle_outline,
            tone: _RefTone.success,
          ),
        ),
        FadeSlideIn(
          delay: const Duration(milliseconds: 70),
          child: _RefCard(
            title: 'Limitations',
            lines: house.limitations,
            icon: Icons.info_outline,
            tone: _RefTone.warning,
          ),
        ),
        if (!compact)
          _RefCard(
            title: 'Construction stages',
            lines: stages,
            icon: Icons.view_timeline_outlined,
          ),
        _RefCard(
          title: 'Key materials',
          lines: house.materialIds.map((e) => e.replaceAll('_', ' ')).toList(),
          icon: Icons.category_outlined,
        ),
        _RefCard(
          title: 'Inspection notes',
          lines: const [
            'Verify levels and plumbness at every stage',
            'Concrete: correct mix + vibration + curing',
            'Rebar: cover + laps + anchorage',
            'Moisture: DPC + drainage + sealed penetrations',
          ],
          icon: Icons.fact_check_outlined,
          tone: _RefTone.info,
        ),
        _RefCard(
          title: 'Expected service life',
          lines: const ['Typically 30–60 years (maintenance dependent)'],
          icon: Icons.timelapse_outlined,
        ),
        _RefCard(
          title: 'Applicable codes',
          lines: const [
            'Building Code of Pakistan (BCP)',
            'Seismic Provisions (BCP / international equivalents)',
            'NDMA resilient housing guidance',
          ],
          icon: Icons.rule_folder_outlined,
        ),
      ],
    );
  }
}

class _InfographicCard extends StatelessWidget {
  const _InfographicCard({required this.house});
  final HouseModel house;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GlassCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.image_outlined, color: tokens.textPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Infographic',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: tokens.textPrimary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _openFullScreen(context),
                icon: Icon(Icons.fullscreen, color: tokens.textPrimary),
                label: Text('Preview', style: TextStyle(color: tokens.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: tokens.fillSubtle,
                child: Image.asset(
                  house.constructionInfographicAsset,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, error, __) {
                    // ignore: avoid_print
                    print('WARN: infographic missing for ${house.id}: $error');
                    return _MissingAsset(
                      title: 'Infographic unavailable',
                      subtitle: 'Could not load: ${house.constructionInfographicAsset}',
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreen(BuildContext context) {
    final tokens = context.appTokens;
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            color: tokens.viewerBackground,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 6,
              child: Center(
                child: Image.asset(
                  house.constructionInfographicAsset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RefCard extends StatelessWidget {
  const _RefCard({
    required this.title,
    required this.lines,
    required this.icon,
    this.tone = _RefTone.neutral,
  });

  final String title;
  final List<String> lines;
  final IconData icon;
  final _RefTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final accent = switch (tone) {
      _RefTone.success => tokens.success,
      _RefTone.warning => tokens.warning,
      _RefTone.info => tokens.info,
      _RefTone.neutral => tokens.textSecondary,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accent),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: tokens.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...lines.map(
              (l) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $l',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: tokens.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingAsset extends StatelessWidget {
  const _MissingAsset({
    required this.title,
    required this.subtitle,
    this.showActions = false,
    this.onDownload,
    this.onQuickRef,
    this.house,
  });
  final String title;
  final String subtitle;
  final bool showActions;
  final VoidCallback? onDownload;
  final VoidCallback? onQuickRef;
  final HouseModel? house;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          color: tokens.card,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.picture_as_pdf_outlined, color: tokens.warning, size: 40),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: tokens.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: tokens.textSecondary, height: 1.35),
                ),
                if (showActions) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: onDownload,
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Download package'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _RefTone { neutral, success, warning, info }

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Row(
      children: [
        Icon(icon, size: 16, color: tokens.textOnPrimary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: TextStyle(
              color: tokens.textOnPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ModelThumb extends StatelessWidget {
  const _ModelThumb({required this.house});
  final HouseModel house;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tokens.fillSubtle,
              AppColors.orange.withValues(alpha: 0.10),
            ],
          ),
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      house.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      house.category,
                      style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 90,
              child: Image.asset(
                house.resolvedThumbnailAsset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.home_work_outlined,
                  color: tokens.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfToolbar extends StatelessWidget {
  const _PdfToolbar({
    required this.controller,
    required this.search,
    required this.onDownloadPdf,
    required this.onFullscreen,
  });

  final PdfViewerController controller;
  final TextEditingController search;
  final VoidCallback onDownloadPdf;
  final VoidCallback onFullscreen;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf_outlined, color: tokens.textPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: search,
              decoration: InputDecoration(
                hintText: 'Search document…',
                hintStyle: TextStyle(color: tokens.textMuted),
                prefixIcon: Icon(Icons.search, color: tokens.textSecondary),
                isDense: true,
                filled: true,
                fillColor: tokens.chipBackground,
              ),
              style: TextStyle(color: tokens.textPrimary),
              onSubmitted: (q) {
                final t = q.trim();
                if (t.isEmpty) return;
                controller.searchText(t);
              },
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Zoom in',
            onPressed: () => controller.zoomLevel = (controller.zoomLevel + 0.25).clamp(1.0, 5.0),
            icon: Icon(Icons.zoom_in, color: tokens.textPrimary),
          ),
          IconButton(
            tooltip: 'Zoom out',
            onPressed: () => controller.zoomLevel = (controller.zoomLevel - 0.25).clamp(1.0, 5.0),
            icon: Icon(Icons.zoom_out, color: tokens.textPrimary),
          ),
          IconButton(
            tooltip: 'Fullscreen',
            onPressed: onFullscreen,
            icon: Icon(Icons.fullscreen, color: tokens.textPrimary),
          ),
          IconButton(
            tooltip: 'Download / Share',
            onPressed: onDownloadPdf,
            icon: Icon(Icons.download_outlined, color: tokens.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _FullscreenPdf extends StatelessWidget {
  const _FullscreenPdf({required this.title, required this.assetPath});
  final String title;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final controller = PdfViewerController();
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SfPdfViewer.asset(
        assetPath,
        controller: controller,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableTextSelection: true,
      ),
    );
  }
}

class _DocLoadingSkeleton extends StatelessWidget {
  const _DocLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              minHeight: 4,
              borderRadius: BorderRadius.circular(4),
              color: AppColors.orange,
              backgroundColor: tokens.chipBackground,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading engineering manual…',
              style: TextStyle(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

