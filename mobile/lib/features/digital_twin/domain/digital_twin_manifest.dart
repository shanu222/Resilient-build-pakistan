/// Digital twin construction sequence loaded from generated BIM pipeline JSON.
class DigitalTwinManifest {
  DigitalTwinManifest({
    required this.modelId,
    required this.displayName,
    required this.masterGlb,
    required this.stages,
    required this.hazardSimulations,
    required this.components,
  });

  factory DigitalTwinManifest.fromJson(Map<String, dynamic> json) {
    return DigitalTwinManifest(
      modelId: json['modelId'] as String,
      displayName: json['displayName'] as String? ?? json['modelId'] as String,
      masterGlb: json['masterGlb'] as String,
      stages: (json['stages'] as List)
          .map((e) => DigitalTwinStage.fromJson(e as Map<String, dynamic>))
          .toList(),
      hazardSimulations: Map<String, dynamic>.from(
        json['hazardSimulations'] as Map? ?? {},
      ),
      components: Map<String, dynamic>.from(
        json['components'] as Map? ?? {},
      ),
    );
  }

  final String modelId;
  final String displayName;
  final String masterGlb;
  final List<DigitalTwinStage> stages;
  final Map<String, dynamic> hazardSimulations;
  final Map<String, dynamic> components;
}

class DigitalTwinStage {
  DigitalTwinStage({
    required this.index,
    required this.key,
    required this.title,
    required this.timelineLabel,
    required this.durationMs,
    required this.glb,
    required this.narration,
    required this.explanation,
    required this.engineeringPrinciple,
    required this.constructionActivity,
    required this.inspectionChecklist,
    required this.commonMistakes,
    required this.resilienceBenefits,
    required this.highlights,
  });

  factory DigitalTwinStage.fromJson(Map<String, dynamic> json) {
    return DigitalTwinStage(
      index: json['index'] as int,
      key: json['key'] as String,
      title: json['title'] as String,
      timelineLabel: json['timelineLabel'] as String,
      durationMs: json['durationMs'] as int,
      glb: json['glb'] as String,
      narration: json['narration'] as String,
      explanation: json['explanation'] as String,
      engineeringPrinciple: json['engineeringPrinciple'] as String? ??
          json['explanation'] as String,
      constructionActivity: json['constructionActivity'] as String? ??
          json['title'] as String,
      inspectionChecklist: json['inspectionChecklist'] as String? ?? '',
      commonMistakes: List<String>.from(
        json['commonMistakes'] as List? ?? const [],
      ),
      resilienceBenefits: List<String>.from(
        json['resilienceBenefits'] as List? ?? json['highlights'] as List? ?? const [],
      ),
      highlights: List<String>.from(json['highlights'] as List? ?? const []),
    );
  }

  final int index;
  final String key;
  final String title;
  final String timelineLabel;
  final int durationMs;
  final String glb;
  final String narration;
  final String explanation;
  final String engineeringPrinciple;
  final String constructionActivity;
  final String inspectionChecklist;
  final List<String> commonMistakes;
  final List<String> resilienceBenefits;
  final List<String> highlights;
}
