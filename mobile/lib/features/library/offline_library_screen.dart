import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/responsive_page.dart';
import '../../core/widgets/section_header.dart';
import '../../providers/app_providers.dart';
import '../downloads/download_center_screen.dart';
import '../pdf/pdf_viewer_screen.dart';
import '../models/construction_guidelines_screen.dart';

/// Bundled PDFs, engineering manuals, and offline references.
class OfflineLibraryScreen extends ConsumerStatefulWidget {
  const OfflineLibraryScreen({super.key});

  @override
  ConsumerState<OfflineLibraryScreen> createState() => _OfflineLibraryScreenState();
}

class _OfflineLibraryScreenState extends ConsumerState<OfflineLibraryScreen> {
  final _search = TextEditingController();
  String _query = '';
  String _category = 'All';

  static const _categories = [
    'All',
    'Construction Guidelines',
    'Engineering Standards',
    'Construction Checklists',
    'Hazard Mitigation',
    'Model Reference Guides',
  ];

  static const _guidelineTopics = [
    ('Foundations', 'Strip, isolated, raft, elevated foundations'),
    ('Masonry', 'Brick, block, interlocking, rat-trap bond'),
    ('Bamboo Construction', 'Treatment, joints, bracing, roofing'),
    ('Adobe Construction', 'Block making, walling, reinforcement'),
    ('Earthbag Construction', 'Bags, compaction, barbed wire, ring beam'),
    ('Timber Construction', 'Framing, connections, bracing, roof'),
    ('Flood Resilient Housing', 'Raised plinth, elevated, amphibious, drainage'),
    ('Seismic Resistant Housing', 'Load path, ductility, bands, confinement'),
  ];

  static const _standardsTopics = [
    ('Building Planning', 'Setbacks, layout grids, circulation'),
    ('Structural Systems', 'Frames, walls, diaphragms, bracing'),
    ('Reinforcement Principles', 'Anchorage, laps, cover, detailing'),
    ('Load Transfer', 'Roof→walls/frame→bands/beams→foundation→soil'),
    ('Foundations', 'Bearing, settlement, groundwater, scour'),
    ('Retaining Structures', 'Earth pressure, drainage, geogrid, stability'),
  ];

  static const _checklists = [
    ('Foundation Inspection Checklist', 'Excavation, PCC, rebar, concrete'),
    ('Reinforcement Inspection Checklist', 'Cover, laps, hooks, tying'),
    ('Masonry Inspection Checklist', 'Plumb, level, joints, curing'),
    ('Roof Inspection Checklist', 'Anchorage, bracing, fasteners'),
    ('Final Completion Checklist', 'Load path continuity, QA sign-off'),
  ];

  static const _hazardMitigation = [
    ('Earthquake Resistant Construction', 'Ductility, bands, confinement, bracing'),
    ('Flood Resistant Construction', 'Raised plinth, elevated floors, drainage'),
    ('Wind Resistant Construction', 'Roof anchoring, bracing, connections'),
    ('Landslide Risk Reduction', 'Slope drainage, retaining systems, setbacks'),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final housesAsync = ref.watch(housesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.heroGradient),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: AppBreakpoints.pagePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guidance library',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Construction guides, engineering manuals, and model specifications',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _search,
                        decoration: InputDecoration(
                          hintText: 'Search documents…',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: AppColors.surface,
                        ),
                        onChanged: (v) => setState(() => _query = v.toLowerCase()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ResponsivePage(
              scrollable: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Card(
                    color: AppColors.navy,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.cloud_off, color: AppColors.orange),
                      ),
                      title: const Text(
                        'Offline-first',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'All models, BIM sequences, and PDFs are bundled. No login required.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.folder_open_outlined),
                    title: const Text('Downloaded content'),
                    subtitle: const Text('Saved PDFs on this device'),
                    trailing: const Icon(Icons.chevron_right),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DownloadCenterScreen()),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(
                    title: 'Engineering library',
                    subtitle: 'Construction guidelines, standards, checklists, and model guides',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _categories
                        .map(
                          (c) => FilterChip(
                            label: Text(c),
                            selected: _category == c,
                            onSelected: (_) => setState(() => _category = c),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  _LibrarySection(
                    title: 'Construction Guidelines',
                    subtitle: 'Step-by-step procedures used on site',
                    icon: Icons.construction_outlined,
                    visible: _category == 'All' || _category == 'Construction Guidelines',
                    items: _guidelineTopics,
                    onOpen: (title) => _openManual(context, title),
                  ),
                  _LibrarySection(
                    title: 'Engineering Standards',
                    subtitle: 'Structural principles and detailing rules',
                    icon: Icons.rule_folder_outlined,
                    visible: _category == 'All' || _category == 'Engineering Standards',
                    items: _standardsTopics,
                    onOpen: (title) => _openManual(context, title),
                  ),
                  _LibrarySection(
                    title: 'Construction Checklists',
                    subtitle: 'Inspection-ready QA lists',
                    icon: Icons.fact_check_outlined,
                    visible: _category == 'All' || _category == 'Construction Checklists',
                    items: _checklists,
                    onOpen: (title) => _openManual(context, title),
                  ),
                  _LibrarySection(
                    title: 'Hazard Mitigation',
                    subtitle: 'How to build for earthquake, flood, wind and landslide hazards',
                    icon: Icons.warning_amber_outlined,
                    visible: _category == 'All' || _category == 'Hazard Mitigation',
                    items: _hazardMitigation,
                    onOpen: (title) => _openManual(context, title),
                  ),
                ],
              ),
            ),
          ),
          housesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('$e'))),
            data: (houses) {
              final filteredModels = houses.where((h) => h.pdfAsset.isNotEmpty);
              if (_query.isNotEmpty) {
                // Filter both by model name/category and our section titles.
                // Model guides are searched by model metadata.
                final q = _query;
                if (!_manualMatchesQuery(q)) {
                  // No-op: model filter below will still apply.
                }
                // Apply model filtering.
                // ignore: prefer_final_locals
                // (kept readable)
                // continue
              }

              var docs = filteredModels;
              if (_query.isNotEmpty) {
                docs = docs.where(
                  (h) =>
                      h.name.toLowerCase().contains(_query) ||
                      h.category.toLowerCase().contains(_query),
                );
              }
              final list = docs.toList();

              return SliverPadding(
                padding: AppBreakpoints.pagePadding(context),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final h = list[i];
                      final show =
                          _category == 'All' || _category == 'Model Reference Guides';
                      if (!show) return const SizedBox.shrink();
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.hazardLight,
                            child: const Icon(Icons.picture_as_pdf, color: AppColors.hazard, size: 22),
                          ),
                          title: Text(h.name),
                          subtitle: Text('Model reference guide · ${h.category}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ConstructionGuidelinesScreen(house: h),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: list.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  bool _manualMatchesQuery(String q) {
    if (q.isEmpty) return true;
    for (final (title, desc) in _guidelineTopics) {
      if (title.toLowerCase().contains(q) || desc.toLowerCase().contains(q)) return true;
    }
    for (final (title, desc) in _standardsTopics) {
      if (title.toLowerCase().contains(q) || desc.toLowerCase().contains(q)) return true;
    }
    for (final (title, desc) in _checklists) {
      if (title.toLowerCase().contains(q) || desc.toLowerCase().contains(q)) return true;
    }
    for (final (title, desc) in _hazardMitigation) {
      if (title.toLowerCase().contains(q) || desc.toLowerCase().contains(q)) return true;
    }
    return false;
  }

  void _openManual(BuildContext context, String topicTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Open a model manual from “Model Reference Guides” to view engineering PDFs.'),
        backgroundColor: AppColors.navy,
      ),
    );
  }
}

class _LibrarySection extends StatelessWidget {
  const _LibrarySection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.visible,
    required this.items,
    required this.onOpen,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool visible;
  final List<(String, String)> items;
  final void Function(String title) onOpen;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(child: Icon(icon)),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(subtitle),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (it) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(it.$1),
              subtitle: Text(it.$2),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onOpen(it.$1),
            ),
          ),
        ),
      ],
    );
  }
}
