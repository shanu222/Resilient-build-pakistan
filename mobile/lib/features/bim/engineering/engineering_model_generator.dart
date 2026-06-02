import '../../bim_simulation/engine/bim_scene_package.dart';
import '../../bim_simulation/engine/bim_entity.dart';
import '../../bim_simulation/engine/math/bim_vec3.dart';
import '../engineering_constraint_engine.dart';
import 'engineering_constraint_solver.dart';
import 'model_centroid_engine.dart';

/// Builds procedural BIM from package rules, centers, and validates.
abstract final class EngineeringModelGenerator {
  static EngineeringSceneResult generate(BimScenePackage package) {
    final raw = package.buildScene();
    final centered = ModelCentroidEngine.centerAtOrigin(raw);
    final validation = EngineeringConstraintSolver.validate(centered.entities);

    return EngineeringSceneResult(
      entities: centered.entities,
      validation: validation,
      structuralCentroid: centered.structuralCentroid,
      crossSectionCenterX: centered.crossSectionCenterX,
      centroidOffset: centered.offset,
    );
  }
}

class EngineeringSceneResult {
  const EngineeringSceneResult({
    required this.entities,
    required this.validation,
    required this.structuralCentroid,
    required this.crossSectionCenterX,
    required this.centroidOffset,
  });

  final List<BimEntity> entities;
  final ConstraintValidationResult validation;
  final BimVec3 structuralCentroid;
  final double crossSectionCenterX;
  final BimVec3 centroidOffset;
}
