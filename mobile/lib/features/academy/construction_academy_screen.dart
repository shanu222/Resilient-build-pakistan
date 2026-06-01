import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_header.dart';
import '../../providers/app_providers.dart';

class ConstructionAcademyScreen extends ConsumerWidget {
  const ConstructionAcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(jsonRepoProvider).getAcademy(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final data = snap.data!;
        final modes = data['learningModes'] as List;
        final courses = data['courses'] as List;
        final storage = ref.watch(localStorageProvider);

        return Scaffold(
          body: Column(
            children: [
              const GradientHeader(
                title: 'Construction Academy',
                subtitle: 'Learn resilient building practices',
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Card(
                      color: Colors.green.shade50,
                      child: const ListTile(
                        leading: Icon(Icons.emoji_events, color: AppColors.success),
                        title: Text('Your Progress',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('0 courses completed • 0 certificates earned'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Choose Your Learning Path',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    ...modes.map((m) {
                      final map = m as Map<String, dynamic>;
                      final progress =
                          storage.getAcademyProgress(map['id'] as String);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Color(
                                  int.parse(
                                    (map['color'] as String)
                                        .replaceFirst('#', '0xFF'),
                                  ),
                                ),
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(map['title'] as String,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(map['description'] as String,
                                        style: const TextStyle(
                                            color: AppColors.mutedForeground,
                                            fontSize: 13)),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(value: progress / 100),
                                    Text('$progress% • ${map['lessonCount']} lessons',
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    const Text('Featured Courses',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    ...courses.map((c) {
                      final map = c as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(Icons.play_circle, color: AppColors.orange),
                          title: Text(map['title'] as String),
                          subtitle: Text(
                            '${map['duration']} • ${map['lessonCount']} lessons • ${map['level']}',
                          ),
                          trailing: map['hasQuiz'] == true
                              ? const Chip(label: Text('Quiz'))
                              : null,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
