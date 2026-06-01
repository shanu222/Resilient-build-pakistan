import '../../core/config/app_config.dart';

/// Resolves PDF / GLB / image URLs — local assets or CloudFront CDN.
class ContentCdnService {
  const ContentCdnService();

  String resolveAssetPath(String bundledPath) {
    if (!AppConfig.useRemoteContent) return bundledPath;
    final key = bundledPath.replaceFirst('assets/', '');
    return '${AppConfig.cdnBaseUrl}/$key';
  }

  String pdfUrl(String modelId) => resolveAssetPath('assets/pdfs/${modelId}_guidelines.pdf');

  String glbUrl(String modelFolder) =>
      resolveAssetPath('assets/models/$modelFolder/base.glb');
}
