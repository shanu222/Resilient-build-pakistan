import '../../bim_simulation/engine/bim_entity.dart';
import '../../bim_simulation/engine/math/bim_vec3.dart';
import '../../bim_simulation/engine/rendering/bim_scene_bounds.dart';

/// Centers structural geometry at world origin with ground at Y = 0.
abstract final class ModelCentroidEngine {
  static const _structuralCategories = {
    BimEntityCategory.concrete,
    BimEntityCategory.masonry,
    BimEntityCategory.earthbag,
    BimEntityCategory.rebar,
    BimEntityCategory.timber,
    BimEntityCategory.bamboo,
    BimEntityCategory.formwork,
    BimEntityCategory.finishing,
    BimEntityCategory.wire,
  };

  static CentroidResult centerAtOrigin(List<BimEntity> entities) {
    final structural = entities.where(_isStructuralForCentroid).toList();
    final bounds = BimSceneBounds.fromEntities(
      structural.isEmpty ? entities : structural,
      structuralOnly: false,
    );

    final dx = -bounds.center.x;
    final dy = -bounds.min.y;
    final dz = -bounds.center.z;
    final offset = BimVec3(dx, dy, dz);

    final centered = entities.map((e) => _translateEntity(e, offset)).toList();
    final newBounds = BimSceneBounds.fromEntities(centered, structuralOnly: true);

    return CentroidResult(
      entities: centered,
      offset: offset,
      structuralCentroid: newBounds.center,
      crossSectionCenterX: 0,
    );
  }

  static BimAabb _meshBounds(BimEntity e) {
    var minX = double.infinity;
    var minY = double.infinity;
    var minZ = double.infinity;
    var maxX = -double.infinity;
    var maxY = -double.infinity;
    var maxZ = -double.infinity;
    for (final v in e.mesh.vertices) {
      minX = minX < v.x ? minX : v.x;
      minY = minY < v.y ? minY : v.y;
      minZ = minZ < v.z ? minZ : v.z;
      maxX = maxX > v.x ? maxX : v.x;
      maxY = maxY > v.y ? maxY : v.y;
      maxZ = maxZ > v.z ? maxZ : v.z;
    }
    return BimAabb(BimVec3(minX, minY, minZ), BimVec3(maxX, maxY, maxZ));
  }

  static bool _isNearZero(BimVec3 v, {double eps = 1e-6}) =>
      v.x.abs() < eps && v.y.abs() < eps && v.z.abs() < eps;

  /// Heuristic: some scenes author meshes in absolute/world coordinates (entity.position == 0),
  /// while others author meshes locally and place them via entity.position.
  /// To avoid double-translating, we shift either mesh vertices or entity.position depending on
  /// which one appears to carry the placement.
  static bool _meshIsLocalSpace(BimEntity e) {
    final meshCenter = _meshBounds(e).center;
    // Local meshes tend to be centered near origin; world-authored meshes have large offsets.
    return meshCenter.length < 0.25 && !_isNearZero(e.position);
  }

  static bool _isStructuralForCentroid(BimEntity e) {
    if (e.category == BimEntityCategory.terrain ||
        e.category == BimEntityCategory.excavation ||
        e.category == BimEntityCategory.grid ||
        e.category == BimEntityCategory.survey ||
        e.category == BimEntityCategory.annotation ||
        e.category == BimEntityCategory.equipment) {
      return false;
    }
    if (e.id.contains('ghost') || e.id.contains('_hint')) return false;
    return _structuralCategories.contains(e.category) ||
        e.id.startsWith('blk_') ||
        e.id.contains('column') ||
        e.id.contains('beam') ||
        e.id.contains('roof') ||
        e.id.contains('truss');
  }

  static BimEntity _translateEntity(BimEntity e, BimVec3 offset) {
    final translateViaPosition = _meshIsLocalSpace(e);
    final translatedMesh = translateViaPosition
        ? e.mesh
        : BimMesh(
            vertices: e.mesh.vertices.map((v) => v + offset).toList(),
            indices: e.mesh.indices,
            edges: e.mesh.edges,
          );
    return BimEntity(
      id: e.id,
      label: e.label,
      mesh: translatedMesh,
      color: e.color,
      category: e.category,
      position: BimVec3(
        e.position.x + (translateViaPosition ? offset.x : 0),
        e.position.y + (translateViaPosition ? offset.y : 0),
        e.position.z + (translateViaPosition ? offset.z : 0),
      ),
      explodeGroup: e.explodeGroup,
      minStage: e.minStage,
      opacity: e.opacity,
      visible: e.visible,
      pickable: e.pickable,
      componentId: e.componentId,
      buildProgress: e.buildProgress,
    );
  }
}

class CentroidResult {
  const CentroidResult({
    required this.entities,
    required this.offset,
    required this.structuralCentroid,
    required this.crossSectionCenterX,
  });

  final List<BimEntity> entities;
  final BimVec3 offset;
  final BimVec3 structuralCentroid;
  final double crossSectionCenterX;
}
