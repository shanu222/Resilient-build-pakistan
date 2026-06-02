import '../../bim_simulation/engine/bim_entity.dart';
import '../../bim_simulation/engine/bim_simulation_controller.dart';
import 'digital_twin_manifest.dart';

enum BimComponentType {
  foundation,
  plinth,
  columns,
  beams,
  walls,
  bands,
  openings,
  roofStructure,
  roofCover,
  drainage,
  reinforcement,
  connections,
  other,
}

class BimComponent {
  BimComponent({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.stageIndex,
    required this.inspectionNotes,
    required this.engineeringNotes,
  });

  final String id;
  final String name;
  final BimComponentType type;
  final String description;
  final int? stageIndex;
  final String inspectionNotes;
  final String engineeringNotes;
}

class BimComponentRegistry {
  BimComponentRegistry({required this.components});

  final Map<String, BimComponent> components;

  List<BimComponent> get all => components.values.toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  BimComponent? byId(String? id) => id == null ? null : components[id];

  static BimComponentRegistry fromManifest(DigitalTwinManifest manifest) {
    final out = <String, BimComponent>{};
    for (final entry in manifest.components.entries) {
      final id = entry.key;
      final doc = entry.value is Map<String, dynamic>
          ? (entry.value as Map<String, dynamic>)
          : <String, dynamic>{};
      final title = (doc['title']?.toString() ?? id).replaceAll('_', ' ');
      out[id] = BimComponent(
        id: id,
        name: title,
        type: _inferTypeFromId(id),
        description: doc['description']?.toString() ?? '',
        stageIndex: _tryParseInt(doc['stage']),
        inspectionNotes: doc['inspectionNotes']?.toString() ?? '',
        engineeringNotes: doc['engineeringNotes']?.toString() ?? '',
      );
    }
    return BimComponentRegistry(components: out);
  }

  static BimComponentRegistry fromProceduralBim(
    BimSimulationController bim,
  ) {
    final out = <String, BimComponent>{};

    // Prefer authoritative component docs from BIM JSON.
    final docs = bim.componentDocs;
    for (final entry in docs.entries) {
      final id = entry.key;
      final doc = entry.value is Map<String, dynamic>
          ? (entry.value as Map<String, dynamic>)
          : <String, dynamic>{};
      final name = (doc['title']?.toString() ?? id).replaceAll('_', ' ');
      out[id] = BimComponent(
        id: id,
        name: name,
        type: _inferTypeFromId(id),
        description: doc['description']?.toString() ?? '',
        stageIndex: _tryParseInt(doc['stage']),
        inspectionNotes: doc['inspectionNotes']?.toString() ?? '',
        engineeringNotes: doc['engineeringNotes']?.toString() ?? '',
      );
    }

    // Fill gaps from generated entities (componentId/category/minStage).
    for (final e in bim.entities) {
      final cid = e.componentId;
      if (cid == null || cid.trim().isEmpty) continue;
      out.putIfAbsent(
        cid,
        () => BimComponent(
          id: cid,
          name: (e.label.isEmpty ? cid : e.label).replaceAll('_', ' '),
          type: _inferTypeFromEntity(e),
          description: '',
          stageIndex: e.minStage,
          inspectionNotes: '',
          engineeringNotes: '',
        ),
      );
    }

    return BimComponentRegistry(components: out);
  }

  Map<BimComponentType, List<BimComponent>> grouped() {
    final map = <BimComponentType, List<BimComponent>>{};
    for (final c in components.values) {
      map.putIfAbsent(c.type, () => []).add(c);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    return map;
  }
}

int? _tryParseInt(Object? v) => switch (v) {
      int i => i,
      String s => int.tryParse(s),
      _ => null,
    };

BimComponentType _inferTypeFromEntity(BimEntity e) {
  final id = (e.componentId ?? e.id).toLowerCase();
  if (id.contains('found') || id.contains('foot') || id.contains('pcc')) {
    return BimComponentType.foundation;
  }
  if (id.contains('plinth') || id.contains('dpc')) return BimComponentType.plinth;
  if (id.contains('col')) return BimComponentType.columns;
  if (id.contains('beam') || id.contains('lintel')) return BimComponentType.beams;
  if (id.contains('wall') || id.contains('masonry') || id.contains('brick')) {
    return BimComponentType.walls;
  }
  if (id.contains('band') || id.contains('tie')) return BimComponentType.bands;
  if (id.contains('door') || id.contains('window') || id.contains('opening')) {
    return BimComponentType.openings;
  }
  if (id.contains('roof') || id.contains('truss') || id.contains('purlin')) {
    return BimComponentType.roofStructure;
  }
  if (e.category == BimEntityCategory.drainage || id.contains('drain')) {
    return BimComponentType.drainage;
  }
  if (e.category == BimEntityCategory.rebar || id.contains('rebar')) {
    return BimComponentType.reinforcement;
  }
  if (id.contains('anchor') ||
      id.contains('bolt') ||
      id.contains('gusset') ||
      id.contains('connector')) {
    return BimComponentType.connections;
  }
  return BimComponentType.other;
}

BimComponentType _inferTypeFromId(String id) {
  final s = id.toLowerCase();
  if (s.contains('found') || s.contains('foot') || s.contains('pcc')) {
    return BimComponentType.foundation;
  }
  if (s.contains('plinth') || s.contains('dpc')) return BimComponentType.plinth;
  if (s.contains('col')) return BimComponentType.columns;
  if (s.contains('beam') || s.contains('lintel')) return BimComponentType.beams;
  if (s.contains('wall') || s.contains('masonry') || s.contains('brick')) {
    return BimComponentType.walls;
  }
  if (s.contains('band') || s.contains('tie')) return BimComponentType.bands;
  if (s.contains('door') || s.contains('window') || s.contains('opening')) {
    return BimComponentType.openings;
  }
  if (s.contains('roof') || s.contains('truss') || s.contains('purlin')) {
    return BimComponentType.roofStructure;
  }
  if (s.contains('drain')) return BimComponentType.drainage;
  if (s.contains('rebar')) return BimComponentType.reinforcement;
  if (s.contains('anchor') ||
      s.contains('bolt') ||
      s.contains('gusset') ||
      s.contains('connector')) {
    return BimComponentType.connections;
  }
  return BimComponentType.other;
}

