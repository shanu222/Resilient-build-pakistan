/// Future-ready AI inspection API structure.
/// Replace [analyzeConstructionPhoto] implementation with cloud vision / custom model.
class AiInspectionService {
  Future<AiInspectionResult> analyzeConstructionPhoto({
    required String imagePath,
    AiInspectionOptions? options,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return AiInspectionResult.placeholder();
  }
}

class AiInspectionOptions {
  const AiInspectionOptions({
    this.detectRebar = true,
    this.detectColumns = true,
    this.detectBeams = true,
    this.detectCracks = true,
    this.qualityVerification = true,
  });

  final bool detectRebar;
  final bool detectColumns;
  final bool detectBeams;
  final bool detectCracks;
  final bool qualityVerification;
}

enum InspectionStatus { pass, warning, critical, pending }

class InspectionFinding {
  const InspectionFinding({
    required this.item,
    required this.status,
    required this.details,
    required this.confidence,
  });

  final String item;
  final InspectionStatus status;
  final String details;
  final double confidence;
}

class AiInspectionResult {
  const AiInspectionResult({
    required this.findings,
    required this.processedAt,
    required this.modelVersion,
  });

  final List<InspectionFinding> findings;
  final DateTime processedAt;
  final String modelVersion;

  factory AiInspectionResult.placeholder() {
    return AiInspectionResult(
      processedAt: DateTime.now(),
      modelVersion: 'placeholder-v0.1',
      findings: const [
        InspectionFinding(
          item: 'Rebar Spacing',
          status: InspectionStatus.pass,
          details: 'Spacing within 150–200mm requirement',
          confidence: 0.87,
        ),
        InspectionFinding(
          item: 'Concrete Cover',
          status: InspectionStatus.warning,
          details:
              'Cover appears thin in some areas (35mm detected, 40mm required)',
          confidence: 0.72,
        ),
        InspectionFinding(
          item: 'Beam Dimensions',
          status: InspectionStatus.pass,
          details: 'Dimensions match specification (9" x 12")',
          confidence: 0.81,
        ),
        InspectionFinding(
          item: 'Column Detailing',
          status: InspectionStatus.critical,
          details: 'Missing ties detected in column section',
          confidence: 0.65,
        ),
      ],
    );
  }
}
