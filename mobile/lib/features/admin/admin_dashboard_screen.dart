import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../bim_simulation/engine/bim_scene_registry.dart';
import '../models/resilient_model_registry.dart';

/// In-app admin scaffold — full CMS requires AWS backend + Cognito roles.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final housesAsync = ref.watch(housesProvider);
    final role = ref.watch(adminRoleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: housesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (houses) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _RoleCard(role: role),
              const SizedBox(height: 16),
              const Text(
                'Resilient Models',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...houses.map((h) {
                final hasBim = BimSceneRegistry.hasBimSimulation(h.id);
                final isCore = ResilientModelRegistry.isCoreModel(h.id);
                return Card(
                  child: ListTile(
                    title: Text(h.name),
                    subtitle: Text(
                      '${h.id}\nBIM: ${hasBim ? "Yes" : "No"} · Core: ${isCore ? "Yes" : "Extended"}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.edit_note),
                    onTap: () => _showEditSheet(context, h.id, hasBim),
                  ),
                );
              }),
              const SizedBox(height: 24),
              const Text(
                'Production actions (requires API + Admin role)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _actionChip('Add Model', Icons.add_home),
                  _actionChip('Upload PDF', Icons.picture_as_pdf),
                  _actionChip('Upload GLB', Icons.view_in_ar),
                  _actionChip('Sync Firestore', Icons.cloud_upload),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _actionChip(String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () {},
    );
  }

  void _showEditSheet(BuildContext context, String modelId, bool hasBim) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit $modelId', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(hasBim
                ? 'BIM JSON: assets/data/bim_*.json\nUpdate via backend admin API or bundled JSON.'
                : 'No BIM package — add scene builder + register in BimSceneRegistry.'),
            const SizedBox(height: 12),
            const Text('Roles: Admin · Editor · Viewer (Cognito groups when enabled)'),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role});

  final AdminRole role;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.navy,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current role',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    role.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum AdminRole { viewer, editor, admin }

extension on AdminRole {
  String get label => switch (this) {
        AdminRole.admin => 'Admin',
        AdminRole.editor => 'Editor',
        AdminRole.viewer => 'Viewer',
      };
}

final adminRoleProvider = StateProvider<AdminRole>((_) => AdminRole.viewer);
