import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/repositories/local_storage_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  await Hive.initFlutter();
  final storage = LocalStorageRepository();
  await storage.init();
  runApp(const ProviderScope(child: ResilientBuildApp()));
}
