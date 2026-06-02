import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/government_header.dart';
import '../../data/models/house_model.dart';

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

  late final Future<Uint8List> _pdfBytes = _loadPdfBytes();

  Future<Uint8List> _loadPdfBytes() async {
    try {
      final data = await rootBundle.load(widget.house.constructionGuidelinesPdfAsset);
      return data.buffer.asUint8List();
    } catch (_) {
      // Graceful fallback if a model PDF is missing in assets. This prevents a blank screen
      // and allows the rest of the platform to remain usable.
      final data = await rootBundle.load('assets/pdfs/interlocking_brick_masonry_construction_guidelines.pdf');
      return data.buffer.asUint8List();
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
      body: FutureBuilder<Uint8List>(
        future: _pdfBytes,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData) {
            return _MissingAsset(
              title: 'Construction Guidelines PDF missing',
              subtitle:
                  'Could not load: ${widget.house.constructionGuidelinesPdfAsset}',
            );
          }

          final bytes = snap.data!;
          final content = isDesktop
              ? _DesktopLayout(
                  house: widget.house,
                  bytes: bytes,
                  pdfController: _pdfController,
                  search: _search,
                  onDownloadPdf: () => _downloadPdf(bytes),
                )
              : _MobileLayout(
                  house: widget.house,
                  bytes: bytes,
                  pdfController: _pdfController,
                  search: _search,
                  onDownloadPdf: () => _downloadPdf(bytes),
                  showSidePanels: isTablet,
                );

          return Container(color: AppColors.background, child: content);
        },
      ),
    );
  }

  Future<void> _downloadPdf(Uint8List bytes) async {
    // Best-effort download/share without forcing a browser redirect.
    // On web, Share.shareXFiles is supported by the plugin for some browsers;
    // otherwise it will no-op gracefully.
    try {
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
    required this.bytes,
    required this.pdfController,
    required this.search,
    required this.onDownloadPdf,
  });

  final HouseModel house;
  final Uint8List bytes;
  final PdfViewerController pdfController;
  final TextEditingController search;
  final VoidCallback onDownloadPdf;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LeftNav(house: house),
        const VerticalDivider(width: 1),
        Expanded(
          child: Column(
            children: [
              _ModelHeaderCard(house: house),
              Expanded(
                child: _PdfCard(
                  bytes: bytes,
                  controller: pdfController,
                  search: search,
                  onDownloadPdf: onDownloadPdf,
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        SizedBox(
          width: 360,
          child: _RightPanel(house: house),
        ),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.house,
    required this.bytes,
    required this.pdfController,
    required this.search,
    required this.onDownloadPdf,
    required this.showSidePanels,
  });

  final HouseModel house;
  final Uint8List bytes;
  final PdfViewerController pdfController;
  final TextEditingController search;
  final VoidCallback onDownloadPdf;
  final bool showSidePanels;

  @override
  Widget build(BuildContext context) {
    // Tablet gets stacked panels, mobile is full screen PDF with a bottom sheet for extras.
    return Column(
      children: [
        _ModelHeaderCard(house: house),
        Expanded(
          child: _PdfCard(
            bytes: bytes,
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
                label: const Text('Infographic & Quick Reference'),
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
    return Container(
      width: 260,
      color: AppColors.navy,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Construction Guidelines',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                house.name,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              _NavItem(
                icon: Icons.picture_as_pdf_outlined,
                title: 'Guidelines PDF',
                subtitle: 'Read + search + zoom',
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
                title: 'Quick reference',
                subtitle: 'Engineering summary',
                onTap: () {},
              ),
              const Spacer(),
              Text(
                'Government of Pakistan · NDMA · PEC-ready formatting',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 10,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
    required this.bytes,
    required this.controller,
    required this.search,
    required this.onDownloadPdf,
  });

  final Uint8List bytes;
  final PdfViewerController controller;
  final TextEditingController search;
  final VoidCallback onDownloadPdf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppBreakpoints.pagePadding(context),
      child: Card(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_outlined, color: AppColors.navy),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: search,
                      decoration: const InputDecoration(
                        hintText: 'Search within PDF…',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
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
                    icon: const Icon(Icons.zoom_in),
                  ),
                  IconButton(
                    tooltip: 'Zoom out',
                    onPressed: () => controller.zoomLevel = (controller.zoomLevel - 0.25).clamp(1.0, 5.0),
                    icon: const Icon(Icons.zoom_out),
                  ),
                  IconButton(
                    tooltip: 'Download / Share',
                    onPressed: onDownloadPdf,
                    icon: const Icon(Icons.download_outlined),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SfPdfViewer.memory(
                bytes,
                controller: controller,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                enableTextSelection: true,
                onDocumentLoadFailed: (d) {
                  if (!kDebugMode) return;
                  // ignore: avoid_print
                  print('PDF load failed: ${d.description}');
                },
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _InfographicCard(house: house),
        const SizedBox(height: 12),
        _RefCard(
          title: 'Construction system',
          lines: [house.category, 'Difficulty: ${house.complexity}'],
          icon: Icons.apartment_outlined,
        ),
        _RefCard(
          title: 'Hazards addressed',
          lines: house.hazardsCovered,
          icon: Icons.warning_amber_outlined,
        ),
        _RefCard(
          title: 'Advantages',
          lines: house.advantages,
          icon: Icons.check_circle_outline,
        ),
        _RefCard(
          title: 'Limitations',
          lines: house.limitations,
          icon: Icons.info_outline,
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
          title: 'Quality control points',
          lines: const [
            'Verify levels and plumbness at every stage',
            'Concrete: correct mix + vibration + curing',
            'Rebar: cover + laps + anchorage',
            'Moisture: DPC + drainage + sealed penetrations',
          ],
          icon: Icons.fact_check_outlined,
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
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.image_outlined, color: AppColors.navy),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Model infographic',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openFullScreen(context),
                  icon: const Icon(Icons.fullscreen),
                  label: const Text('Full screen'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: AppColors.surface,
                  child: Image.asset(
                    house.constructionInfographicAsset,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (_, error, __) {
                      // ignore: avoid_print
                      print(
                        'WARN: infographic missing for ${house.id}: $error',
                      );
                      return const Center(
                        child: Text('Infographic not found in assets.'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
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
  });

  final String title;
  final List<String> lines;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.navy),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 8),
            ...lines.map(
              (l) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $l', style: const TextStyle(fontSize: 12, height: 1.35)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissingAsset extends StatelessWidget {
  const _MissingAsset({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

