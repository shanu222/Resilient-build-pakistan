import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/repositories/local_storage_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = LocalStorageRepository();
  await storage.init();

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase optional for local/offline dev without google-services.json
  }

  runApp(const ProviderScope(child: ResilientBuildApp()));
}
