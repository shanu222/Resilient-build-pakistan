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
    return BimEntity(
      id: e.id,
      label: e.label,
      mesh: e.mesh,
      color: e.color,
      category: e.category,
      position: BimVec3(
        e.position.x + offset.x,
        e.position.y + offset.y,
        e.position.z + offset.z,
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
