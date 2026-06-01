import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          const GradientHeader(title: 'Profile', subtitle: 'Account & settings'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Guest User'),
                  subtitle: Text('Sign in with Firebase Auth (configure firebase_options.dart)'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Download Center'),
                  onTap: () => context.push('/downloads'),
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: const Text('Materials Library'),
                  onTap: () => context.push('/materials'),
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Market Prices'),
                  onTap: () => context.push('/prices'),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('AI Site Inspection'),
                  onTap: () => context.push('/inspection'),
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_off),
                  title: const Text('Offline Mode'),
                  subtitle: const Text('PDFs, 3D models, and saved data cached locally'),
                ),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('Admin Dashboard'),
                  subtitle: const Text('Content management (staging)'),
                  onTap: () => context.push('/admin'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
