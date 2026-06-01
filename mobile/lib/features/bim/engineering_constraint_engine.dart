import '../bim_simulation/engine/bim_entity.dart';
import '../bim_simulation/engine/math/bim_vec3.dart';

/// Engineering validation result for BIM scenes before render.
class ConstraintValidationResult {
  const ConstraintValidationResult({
    required this.passed,
    required this.errors,
    required this.warnings,
  });

  final bool passed;
  final List<String> errors;
  final List<String> warnings;

  bool get hasIssues => errors.isNotEmpty || warnings.isNotEmpty;
}

/// Footprint and structural grid used for constraint checks.
class BuildingFootprint {
  const BuildingFootprint({
    required this.minX,
    required this.maxX,
    required this.minZ,
    required this.maxZ,
    required this.foundationY,
    required this.beamY,
    required this.wallTopY,
    required this.roofTopY,
    this.columnGrid = const [],
  });

  final double minX;
  final double maxX;
  final double minZ;
  final double maxZ;
  final double foundationY;
  final double beamY;
  final double wallTopY;
  final double roofTopY;
  final List<BimVec3> columnGrid;

  bool containsXZ(double x, double z, {double margin = 0.05}) =>
      x >= minX - margin &&
      x <= maxX + margin &&
      z >= minZ - margin &&
      z <= maxZ + margin;
}

/// Validates foundation, column, wall, beam, roof, and connection rules.
abstract final class EngineeringConstraintEngine {
  static const _tol = 0.12;

  static BuildingFootprint footprintFromEntities(List<BimEntity> entities) {
    var minX = double.infinity;
    var maxX = -double.infinity;
    var minZ = double.infinity;
    var maxZ = -double.infinity;
    var minY = double.infinity;
    var maxY = -double.infinity;

    for (final e in entities) {
      if (e.category == BimEntityCategory.terrain ||
          e.category == BimEntityCategory.excavation) {
        continue;
      }
      final b = e.bounds;
      if (b.min.x < minX) minX = b.min.x;
      if (b.max.x > maxX) maxX = b.max.x;
      if (b.min.z < minZ) minZ = b.min.z;
      if (b.max.z > maxZ) maxZ = b.max.z;
      if (b.min.y < minY) minY = b.min.y;
      if (b.max.y > maxY) maxY = b.max.y;
    }

    if (minX == double.infinity) {
      return const BuildingFootprint(
        minX: -3,
        maxX: 3,
        minZ: -2,
        maxZ: 2,
        foundationY: 0,
        beamY: 3,
        wallTopY: 3,
        roofTopY: 3.5,
      );
    }

    final cols = entities
        .where((e) => _isColumn(e))
        .map((e) => e.bounds.center)
        .toList();

    return BuildingFootprint(
      minX: minX,
      maxX: maxX,
      minZ: minZ,
      maxZ: maxZ,
      foundationY: minY,
      beamY: maxY * 0.85,
      wallTopY: maxY * 0.75,
      roofTopY: maxY,
      columnGrid: cols,
    );
  }

  static ConstraintValidationResult validate(
    List<BimEntity> entities, {
    BuildingFootprint? footprint,
  }) {
    final fp = footprint ?? footprintFromEntities(entities);
    final errors = <String>[];
    final warnings = <String>[];

    for (final e in entities) {
      if (!e.visible && e.minStage > 0) continue;
      final b = e.bounds;
      final cx = b.center.x;
      final cz = b.center.z;

      if (_isWall(e) || _isColumn(e) || _isBeam(e)) {
        if (!fp.containsXZ(cx, cz, margin: _tol * 2)) {
          errors.add('${e.id}: outside foundation footprint');
        }
      }

      if (_isColumn(e)) {
        final baseY = b.min.y;
        final topY = b.max.y;
        final hx = b.max.x - b.min.x;
        final hy = b.max.y - b.min.y;
        final hz = b.max.z - b.min.z;
        if (baseY > fp.foundationY + _tol * 3) {
          errors.add('${e.id}: column floating above foundation');
        }
        if (hx > hy * 0.5 && hz > hy * 0.5) {
          warnings.add('${e.id}: column may not be vertical');
        }
        if (topY < fp.wallTopY - _tol * 4) {
          warnings.add('${e.id}: column may not reach beam level');
        }
      }

      if (_isRoof(e)) {
        final roofCx = (fp.minX + fp.maxX) / 2;
        final roofCz = (fp.minZ + fp.maxZ) / 2;
        if ((cx - roofCx).abs() > (fp.maxX - fp.minX) * 0.35) {
          warnings.add('${e.id}: roof offset from building center');
        }
        if ((cz - roofCz).abs() > (fp.maxZ - fp.minZ) * 0.35) {
          warnings.add('${e.id}: roof offset along depth');
        }
      }
    }

    _validateConnections(entities, fp, errors, warnings);

    return ConstraintValidationResult(
      passed: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  static void _validateConnections(
    List<BimEntity> entities,
    BuildingFootprint fp,
    List<String> errors,
    List<String> warnings,
  ) {
    final foundations = entities.where((e) => _isFoundation(e)).toList();
    final columns = entities.where((e) => _isColumn(e)).toList();
    final walls = entities.where((e) => _isWall(e)).toList();
    final roofs = entities.where((e) => _isRoof(e)).toList();

    if (foundations.isEmpty && columns.isNotEmpty) {
      warnings.add('Columns present without visible foundation');
    }
    if (columns.isEmpty && walls.length > 4) {
      warnings.add('Walls without structural column references');
    }
    if (walls.isNotEmpty && roofs.isEmpty) {
      warnings.add('Walls without roof system');
    }

    for (final c in columns) {
      final nearFoundation = foundations.any((f) {
        final dx = (f.bounds.center.x - c.bounds.center.x).abs();
        final dz = (f.bounds.center.z - c.bounds.center.z).abs();
        return dx < 0.5 && dz < 0.5;
      });
      if (!nearFoundation && foundations.isNotEmpty) {
        warnings.add('${c.id}: column may not connect to foundation');
      }
    }
  }

  static bool _isFoundation(BimEntity e) =>
      e.id.contains('found') ||
      e.id.contains('footing') ||
      e.id.contains('plinth') ||
      e.category == BimEntityCategory.concrete && e.minStage <= 3;

  static bool _isColumn(BimEntity e) {
    if (e.id.contains('column') ||
        e.id.contains('col_') ||
        e.id.startsWith('vbar')) {
      return true;
    }
    if (e.category == BimEntityCategory.concrete && e.mesh.vertices.length < 200) {
      final b = e.bounds;
      return (b.max.y - b.min.y) > (b.max.x - b.min.x);
    }
    return false;
  }

  static bool _isWall(BimEntity e) =>
      e.category == BimEntityCategory.masonry ||
      e.category == BimEntityCategory.earthbag ||
      e.id.startsWith('blk_') ||
      e.id.contains('wall');

  static bool _isBeam(BimEntity e) =>
      e.id.contains('beam') ||
      e.id.contains('band') ||
      e.id.contains('lintel');

  static bool _isRoof(BimEntity e) =>
      e.id.contains('roof') ||
      e.id.contains('slab') ||
      e.id.contains('truss') ||
      e.category == BimEntityCategory.concrete && e.id.contains('roof');
}
