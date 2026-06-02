import 'package:flutter_test/flutter_test.dart';
import 'package:resilientbuild_pakistan/core/theme/app_theme_extensions.dart';
import 'package:resilientbuild_pakistan/core/theme/theme_contrast_validator.dart';

void main() {
  test('light and dark token pairs meet WCAG AA', () {
    for (final tokens in [AppThemeTokens.light, AppThemeTokens.dark]) {
      final issues = ThemeContrastValidator.auditTokens(tokens);
      expect(
        issues,
        isEmpty,
        reason: issues.map((i) => '${i.name}: ${i.ratio}').join(', '),
      );
    }
  });
}
