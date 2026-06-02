import 'package:flutter/foundation.dart';

/// Resolves bundled asset paths for static hosting (Flutter Web on Vercel).
///
/// Pubspec assets are served under `/assets/<path>` on web builds.
String webAssetUrl(String assetPath) {
  if (!kIsWeb) return assetPath;
  final normalized =
      assetPath.startsWith('assets/') ? assetPath : 'assets/$assetPath';
  return Uri.base.resolve(normalized).toString();
}
