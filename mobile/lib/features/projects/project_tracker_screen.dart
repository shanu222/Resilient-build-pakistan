import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_header.dart';
import '../../providers/app_providers.dart';

class ProjectTrackerScreen extends ConsumerWidget {
  const ProjectTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(localStorageProvider);
    final projects = storage.getProjects();
    final location = ref.watch(locationProvider);

    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(
            title: 'My Projects',
            subtitle: 'Saved locations and construction progress',
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton.icon(
              onPressed: () async {
                final profile = location.profile;
                await storage.saveProject({
                  'id': const Uuid().v4(),
                  'name': profile?.displayName ?? 'New Project',
                  'regionId': profile?.regionId,
                  'modelId': ref.read(selectedModelIdProvider),
                  'createdAt': DateTime.now().toIso8601String(),
                  'progress': 0,
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Project saved')),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Save Current Site'),
            ),
          ),
          Expanded(
            child: projects.isEmpty
                ? const Center(
                    child: Text('No saved projects yet',
                        style: TextStyle(color: AppColors.mutedForeground)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: projects.length,
                    itemBuilder: (_, i) {
                      final p = projects[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(p['name']?.toString() ?? 'Project'),
                          subtitle: Text(p['createdAt']?.toString() ?? ''),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/report/${p['id']}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
