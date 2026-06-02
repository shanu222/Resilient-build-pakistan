import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme_extensions.dart';

/// Full-featured zoom / pan / share viewer for guideline infographics.
class ZoomableAssetImage extends StatelessWidget {
  const ZoomableAssetImage({
    super.key,
    required this.assetPath,
    this.semanticsLabel,
    this.minHeight = 280,
  });

  final String assetPath;
  final String? semanticsLabel;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight.isFinite
            ? constraints.maxHeight.clamp(minHeight, 900.0)
            : minHeight;
        return Container(
          height: h,
          decoration: BoxDecoration(
            color: tokens.viewerBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tokens.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 8,
                  child: Center(
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      semanticLabel: semanticsLabel,
                      errorBuilder: (_, __, ___) => _Unavailable(tokens: tokens),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: _Toolbar(assetPath: assetPath, tokens: tokens),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.tokens});
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Infographic unavailable',
        style: TextStyle(color: tokens.textSecondary, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.assetPath, required this.tokens});
  final String assetPath;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.card.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Fullscreen',
            icon: Icon(Icons.fullscreen, color: tokens.textPrimary),
            onPressed: () => _openFullscreen(context),
          ),
          IconButton(
            tooltip: 'Download / share',
            icon: Icon(Icons.download_outlined, color: tokens.textPrimary),
            onPressed: () => _share(context),
          ),
        ],
      ),
    );
  }

  void _openFullscreen(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Infographic'),
          ),
          body: InteractiveViewer(
            minScale: 0.5,
            maxScale: 10,
            child: Center(
              child: Image.asset(assetPath, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    try {
      final data = await rootBundle.load(assetPath);
      await Share.shareXFiles(
        [
          XFile.fromData(
            data.buffer.asUint8List(),
            name: assetPath.split('/').last,
          ),
        ],
        text: 'Construction infographic',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share unavailable: $e')),
      );
    }
  }
}
