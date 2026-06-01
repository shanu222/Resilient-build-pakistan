import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/responsive_page.dart';
import '../../core/widgets/section_header.dart';
import '../../providers/app_providers.dart';
import '../downloads/download_center_screen.dart';
import '../pdf/pdf_viewer_screen.dart';

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
                    title: 'Document categories',
                    subtitle: 'Filter by publication type',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Construction', 'Engineering', 'Specifications']
                        .map(
                          (c) => FilterChip(
                            label: Text(c),
                            selected: _category == c,
                            onSelected: (_) => setState(() => _category = c),
                          ),
                        )
                        .toList(),
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
              var docs = houses.where((h) => h.pdfAsset.isNotEmpty);
              if (_query.isNotEmpty) {
                docs = docs.where(
                  (h) =>
                      h.name.toLowerCase().contains(_query) ||
                      h.category.toLowerCase().contains(_query),
                );
              }
              if (_category != 'All') {
                docs = docs.where(
                  (h) => h.category.toLowerCase().contains(_category.toLowerCase()),
                );
              }
              final list = docs.toList();

              return SliverPadding(
                padding: AppBreakpoints.pagePadding(context),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final h = list[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.hazardLight,
                            child: const Icon(Icons.picture_as_pdf, color: AppColors.hazard, size: 22),
                          ),
                          title: Text(h.name),
                          subtitle: Text(h.category),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PdfViewerScreen(
                                  assetPath: h.pdfAsset,
                                  title: h.name,
                                ),
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
}
