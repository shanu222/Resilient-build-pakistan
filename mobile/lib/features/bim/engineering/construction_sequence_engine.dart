import '../../bim_simulation/engine/bim_entity.dart';
import '../../bim_simulation/engine/math/bim_vec3.dart';
import '../construction_assembly_animator.dart';

/// Construction staging yards and delivery sequencing (Phase 4).
abstract final class ConstructionSequenceEngine {
  static const appearEnd = 0.08;
  static const travelEnd = 0.35;
  static const alignEnd = 0.55;
  static const lowerEnd = 0.82;
  static const snapEnd = 1.0;

  static StagingYard stagingYardFor(BimEntity e) {
    if (e.id.contains('found') ||
        e.id.contains('footing') ||
        e.id.contains('excav') ||
        e.id.contains('pcc')) {
      return StagingYard.foundation;
    }
    if (e.id.contains('column') ||
        e.id.contains('beam') ||
        e.id.contains('band') ||
        e.id.startsWith('col_') ||
        e.category == BimEntityCategory.rebar) {
      return StagingYard.structural;
    }
    if (e.id.startsWith('blk_') ||
        e.category == BimEntityCategory.masonry ||
        e.category == BimEntityCategory.earthbag) {
      return StagingYard.walls;
    }
    if (e.id.contains('roof') ||
        e.id.contains('truss') ||
        e.id.contains('purlin') ||
        e.id.contains('sheet')) {
      return StagingYard.roof;
    }
    if (e.id.contains('door') || e.id.contains('window') || e.id.contains('opening')) {
      return StagingYard.openings;
    }
    return StagingYard.general;
  }

  static ConstructionPhase phaseFor(double buildProgress) {
    final p = buildProgress.clamp(0.0, 1.0);
    if (p <= appearEnd) return ConstructionPhase.appear;
    if (p <= travelEnd) return ConstructionPhase.travel;
    if (p <= alignEnd) return ConstructionPhase.align;
    if (p <= lowerEnd) return ConstructionPhase.lower;
    if (p < snapEnd) return ConstructionPhase.snap;
    return ConstructionPhase.complete;
  }

  static BimVec3 assemblyOffset(BimEntity e, double buildProgress) =>
      ConstructionAssemblyAnimator.assemblyOffset(e, buildProgress);

  static double assemblyRotation(BimEntity e, double buildProgress) =>
      ConstructionAssemblyAnimator.assemblyRotation(e, buildProgress);

  static double assemblyOpacity(BimEntity e, double buildProgress) =>
      ConstructionAssemblyAnimator.assemblyOpacity(e, buildProgress);

  /// Connection highlight intensity 0–1 during snap phase.
  static double connectionHighlight(BimEntity e, double buildProgress) {
    final phase = phaseFor(buildProgress);
    if (phase != ConstructionPhase.snap) return 0;
    final p = buildProgress.clamp(0.0, 1.0);
    final t = (p - lowerEnd) / (snapEnd - lowerEnd);
    return (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
  }
}

enum StagingYard {
  foundation,
  structural,
  walls,
  roof,
  openings,
  general,
}

enum ConstructionPhase {
  appear,
  travel,
  align,
  lower,
  snap,
  complete,
}
