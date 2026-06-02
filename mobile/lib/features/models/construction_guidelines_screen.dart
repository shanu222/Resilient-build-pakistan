import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/government_header.dart';
import '../../data/models/house_model.dart';
import '../../shared/widgets/fade_slide_in.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/hover_lift.dart';

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
    extends State<ConstructionGuidelinesScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  final TextEditingController _search = TextEditingController();

  late final Future<bool> _pdfExists = _assetExists(widget.house.constructionGuidelinesPdfAsset);

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
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    final isTablet = AppBreakpoints.isTablet(context);

    return Scaffold(
      appBar: const GovernmentHeader(),
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
                  onDownloadPdf: () => _downloadPdfFromAsset(widget.house.constructionGuidelinesPdfAsset),
                )
              : _MobileLayout(
                  house: widget.house,
                  pdfAssetPath: widget.house.constructionGuidelinesPdfAsset,
                  pdfExists: exists,
                  pdfController: _pdfController,
                  search: _search,
                  onDownloadPdf: () => _downloadPdfFromAsset(widget.house.constructionGuidelinesPdfAsset),
                  showSidePanels: isTablet,
                );

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkBackground,
                  AppColors.navyLight,
                  AppColors.navy,
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

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.house,
    required this.pdfAssetPath,
    required this.pdfExists,
    required this.pdfController,
    required this.search,
    required this.onDownloadPdf,
  });

  final HouseModel house;
  final String pdfAssetPath;
  final bool pdfExists;
  final PdfViewerController pdfController;
  final TextEditingController search;
  final VoidCallback onDownloadPdf;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
          child: SizedBox(width: 300, child: _LeftNav(house: house)),
        ),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 12),
                child: FadeSlideIn(child: _ModelHeaderCard(house: house)),
              ),
              Expanded(
                child: _PdfCard(
                  pdfAssetPath: pdfAssetPath,
                  pdfExists: pdfExists,
                  controller: pdfController,
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
            width: 380,
            child: _RightPanel(house: house),
          ),
        ),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.house,
    required this.pdfAssetPath,
    required this.pdfExists,
    required this.pdfController,
    required this.search,
    required this.onDownloadPdf,
    required this.showSidePanels,
  });

  final HouseModel house;
  final String pdfAssetPath;
  final bool pdfExists;
  final PdfViewerController pdfController;
  final TextEditingController search;
  final VoidCallback onDownloadPdf;
  final bool showSidePanels;

  @override
  Widget build(BuildContext context) {
    // Tablet gets stacked panels, mobile is full screen PDF with a bottom sheet for extras.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: FadeSlideIn(child: _ModelHeaderCard(house: house)),
        ),
        Expanded(
          child: _PdfCard(
            pdfAssetPath: pdfAssetPath,
            pdfExists: pdfExists,
            controller: pdfController,
            search: search,
            onDownloadPdf: onDownloadPdf,
          ),
        ),
        if (showSidePanels)
          SizedBox(
            height: 320,
            child: _RightPanel(house: house),
          )
        else
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: HoverLift(
                child: OutlinedButton.icon(
                  onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (_) => SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.75,
                    child: _RightPanel(house: house),
                  ),
                  ),
                  icon: const Icon(Icons.dashboard_customize_outlined),
                  label: const Text('Infographic & Engineering intelligence'),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LeftNav extends StatelessWidget {
  const _LeftNav({required this.house});
  final HouseModel house;

  @override
  Widget build(BuildContext context) {
    // IMPORTANT: No duplicated logos/branding here; the GovernmentHeader is the single source of logos.
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Document Center',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          _ModelThumb(house: house),
          const SizedBox(height: 12),
          _NavItem(
            icon: Icons.picture_as_pdf_outlined,
            title: 'Guidelines',
            subtitle: 'PDF reader',
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.image_outlined,
            title: 'Infographic',
            subtitle: 'High-resolution sheet',
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.fact_check_outlined,
            title: 'Checklist',
            subtitle: 'Stage-by-stage QA',
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.download_outlined,
            title: 'Downloads',
            subtitle: 'Save offline',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          Text(
            'No duplicate branding · NDMA documentation portal',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 10,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withValues(alpha: 0.08),
      shadowColor: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.navy),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
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
  });

  final String pdfAssetPath;
  final bool pdfExists;
  final PdfViewerController controller;
  final TextEditingController search;
  final VoidCallback onDownloadPdf;

  @override
  Widget build(BuildContext context) {
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
            const Divider(height: 1, color: Colors.white24),
            Expanded(
              child: pdfExists
                  ? SfPdfViewer.asset(
                      pdfAssetPath,
                      controller: controller,
                      canShowScrollHead: true,
                      canShowScrollStatus: true,
                      enableTextSelection: true,
                      onDocumentLoadFailed: (d) {
                        if (!kDebugMode) return;
                        // ignore: avoid_print
                        print('PDF load failed: ${d.description}');
                      },
                    )
                  : _MissingAsset(
                      title: 'Document unavailable',
                      subtitle: 'Could not load: $pdfAssetPath',
                      showActions: true,
                      onDownload: onDownloadPdf,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({required this.house});
  final HouseModel house;

  static const _stages = [
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
                      color: Colors.white,
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
                            color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.16),
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
                                  const Text(
                                    'Score',
                                    style: TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                  Text(
                                    '${house.resilienceScore}',
                                    style: const TextStyle(
                                      color: Colors.white,
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
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shield_outlined, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              h,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
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
        _RefCard(
          title: 'Construction stages',
          lines: _stages,
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
    return GlassCard(
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.image_outlined, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Infographic',
                  style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              TextButton.icon(
                onPressed: () => _openFullScreen(context),
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                label: const Text('Preview', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: Colors.white.withValues(alpha: 0.06),
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
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            color: Colors.black,
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
    final accent = switch (tone) {
      _RefTone.success => AppColors.success,
      _RefTone.warning => const Color(0xFFF59E0B),
      _RefTone.info => AppColors.info,
      _RefTone.neutral => Colors.white.withValues(alpha: 0.85),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
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
                    color: Colors.white.withValues(alpha: 0.9),
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
  });
  final String title;
  final String subtitle;
  final bool showActions;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.orange, size: 36),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(subtitle, textAlign: TextAlign.center),
                if (showActions) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: onDownload,
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Download manual'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).maybePop(),
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
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $value',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.10),
              AppColors.orange.withValues(alpha: 0.10),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      house.category,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
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
                errorBuilder: (_, __, ___) => const Icon(Icons.home_work_outlined, color: Colors.white70),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: search,
              decoration: InputDecoration(
                hintText: 'Search document…',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
              ),
              style: const TextStyle(color: Colors.white),
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
            icon: const Icon(Icons.zoom_in, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Zoom out',
            onPressed: () => controller.zoomLevel = (controller.zoomLevel - 0.25).clamp(1.0, 5.0),
            icon: const Icon(Icons.zoom_out, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Fullscreen',
            onPressed: onFullscreen,
            icon: const Icon(Icons.fullscreen, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Download / Share',
            onPressed: onDownloadPdf,
            icon: const Icon(Icons.download_outlined, color: Colors.white),
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
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

