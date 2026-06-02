import 'dart:math' as math;

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

  bool get hasColumnFloat =>
      errors.any((e) => e.contains('column floating'));
}

/// Footprint and structural grid used for constraint checks.
class BuildingFootprint {
  const BuildingFootprint({
    required this.minX,
    required this.maxX,
    required this.minZ,
    required this.maxZ,
    required this.groundY,
    required this.foundationContactY,
    required this.beamY,
    required this.wallTopY,
    required this.roofTopY,
    this.columnGrid = const [],
  });

  final double minX;
  final double maxX;
  final double minZ;
  final double maxZ;
  final double groundY;
  final double foundationContactY;
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
  static const _tol = 0.15;

  static BuildingFootprint footprintFromEntities(List<BimEntity> entities) {
    var minX = double.infinity;
    var maxX = -double.infinity;
    var minZ = double.infinity;
    var maxZ = -double.infinity;
    var maxY = -double.infinity;

    for (final e in entities) {
      if (_isNonStructural(e)) continue;
      final b = e.bounds;
      if (b.min.x < minX) minX = b.min.x;
      if (b.max.x > maxX) maxX = b.max.x;
      if (b.min.z < minZ) minZ = b.min.z;
      if (b.max.z > maxZ) maxZ = b.max.z;
      if (b.max.y > maxY) maxY = b.max.y;
    }

    if (minX == double.infinity) {
      return const BuildingFootprint(
        minX: -3,
        maxX: 3,
        minZ: -2,
        maxZ: 2,
        groundY: 0,
        foundationContactY: 0,
        beamY: 3,
        wallTopY: 3,
        roofTopY: 3.5,
      );
    }

    final groundY = _groundPlaneY(entities);
    final contactY = _foundationContactY(entities, groundY);
    final cols = entities.where(_isColumn).map((e) => e.bounds.center).toList();
    final beamY = _beamLevel(entities, contactY);
    final wallTop = _wallTopLevel(entities, contactY);

    return BuildingFootprint(
      minX: minX,
      maxX: maxX,
      minZ: minZ,
      maxZ: maxZ,
      groundY: groundY,
      foundationContactY: contactY,
      beamY: beamY,
      wallTopY: wallTop,
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
      if (_isNonStructural(e) || !_isColumn(e)) continue;

      final baseY = e.bounds.min.y;
      final cx = e.bounds.center.x;
      final cz = e.bounds.center.z;
      var anchored = false;

      if (e.id.startsWith('col_concrete') || e.id.startsWith('rcc_column')) {
        final idxMatch = RegExp(r'_(\d+)$').firstMatch(e.id);
        if (idxMatch != null) {
          final pedId = 'pedestal_${idxMatch.group(1)}';
          for (final f in entities) {
            if (f.id != pedId) continue;
            if ((baseY - f.bounds.max.y).abs() <= _tol * 2) {
              anchored = true;
              break;
            }
          }
        }
        if (!anchored) {
          for (final f in entities) {
            if (!f.id.contains('pedestal')) continue;
            if (!_overlapsXZ(f, cx, cz, margin: 0.65)) continue;
            if ((baseY - f.bounds.max.y).abs() <= _tol * 2) {
              anchored = true;
              break;
            }
          }
        }
      }

      if (!anchored && e.id.contains('timber_column')) {
        for (final f in entities) {
          if (f.id == 'plinth_beam' || f.id.contains('plinth_concrete')) {
            if ((baseY - f.bounds.max.y).abs() <= _tol * 2) {
              anchored = true;
              break;
            }
          }
        }
      }

      if (anchored) continue;

      final support = _supportTopAt(entities, e, cx, cz);
      if (support == null) {
        warnings.add('${e.id}: no foundation support detected at column base');
      } else if (baseY > support + _tol) {
        errors.add('${e.id}: column floating above foundation');
      } else if (baseY < support - _tol * 2 && !_isDeckMountedColumn(e)) {
        errors.add('${e.id}: column below foundation contact');
      }
    }

    _validateAggregateConnections(entities, fp, errors, warnings);

    return ConstraintValidationResult(
      passed: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  static double _groundPlaneY(List<BimEntity> entities) {
    var ground = 0.0;
    for (final e in entities) {
      if (e.category == BimEntityCategory.terrain) {
        ground = math.max(ground, e.bounds.max.y);
      }
    }
    return ground;
  }

  static double _foundationContactY(List<BimEntity> entities, double groundY) {
    var contact = groundY;
    for (final e in entities) {
      if (_isGroundBearing(e)) {
        contact = math.max(contact, e.bounds.max.y);
      }
    }
    if (contact <= groundY + 0.01) {
      final wallBases = entities.where(_isWall).map((e) => e.bounds.min.y);
      if (wallBases.isNotEmpty) {
        contact = wallBases.reduce(math.min);
      }
    }
    return contact;
  }

  static double? _supportTopAt(
    List<BimEntity> entities,
    BimEntity column,
    double x,
    double z,
  ) {
    if (_isDeckMountedColumn(column)) {
      for (final e in entities) {
        if (e.id.contains('floating_deck') ||
            e.id.contains('elevated_slab') ||
            e.id.contains('platform_frame')) {
          return e.bounds.max.y;
        }
      }
    }

    double? best;
    for (final f in entities) {
      if (_isNonStructural(f)) continue;
      final isSupport = _isGroundBearing(f) ||
          f.id.contains('pedestal') ||
          f.id.contains('footing_concrete') ||
          f.id.contains('plinth_beam');
      if (!isSupport) continue;
      if (!_overlapsXZ(f, x, z, margin: 1.0)) continue;
      final top = f.bounds.max.y;
      best = best == null ? top : math.max(best, top);
    }
    return best;
  }

  static bool _overlapsXZ(BimEntity e, double x, double z, {double margin = 0.5}) {
    final b = e.bounds;
    return x >= b.min.x - margin &&
        x <= b.max.x + margin &&
        z >= b.min.z - margin &&
        z <= b.max.z + margin;
  }

  static double _beamLevel(List<BimEntity> entities, double contactY) {
    var beamY = contactY;
    for (final e in entities) {
      if (_isBeam(e)) beamY = math.max(beamY, e.bounds.min.y);
    }
    return beamY > contactY ? beamY : contactY + 2.8;
  }

  static double _wallTopLevel(List<BimEntity> entities, double contactY) {
    var wallTop = contactY;
    for (final e in entities) {
      if (_isWall(e)) wallTop = math.max(wallTop, e.bounds.max.y);
      if (_isColumn(e)) wallTop = math.max(wallTop, e.bounds.max.y);
    }
    return wallTop > contactY ? wallTop : contactY + 2.8;
  }

  static void _validateAggregateConnections(
    List<BimEntity> entities,
    BuildingFootprint fp,
    List<String> errors,
    List<String> warnings,
  ) {
    final foundations =
        entities.where((e) => _isGroundBearing(e) || _isElevatedBearing(e)).toList();
    final columns = entities.where(_isColumn).toList();
    final walls = entities.where(_isWall).toList();
    final beams = entities.where(_isBeam).toList();
    final roofs = entities.where(_isRoof).toList();

    if (foundations.isEmpty && columns.isNotEmpty) {
      warnings.add('Columns present without visible foundation');
    }

    if (walls.isNotEmpty) {
      final lowestWall = walls.map((w) => w.bounds.min.y).reduce(math.min);
      if (lowestWall > fp.foundationContactY + _tol * 3) {
        warnings.add('Lowest wall course may not start at foundation');
      }
    }

    if (columns.isNotEmpty && foundations.isNotEmpty) {
      final unanchored = columns.where((c) {
        if (_isDeckMountedColumn(c)) return false;
        return foundations.every((f) {
          final dx = (f.bounds.center.x - c.bounds.center.x).abs();
          final dz = (f.bounds.center.z - c.bounds.center.z).abs();
          return dx > 1.2 || dz > 1.2;
        });
      }).length;
      if (unanchored > 0) {
        warnings.add('$unanchored column(s) may not align with foundation grid');
      }
    }

    if (beams.isNotEmpty && columns.isNotEmpty) {
      final lowBeams = beams.where((b) => b.bounds.min.y < fp.wallTopY - _tol * 4).length;
      if (lowBeams > 0) {
        warnings.add('$lowBeams beam(s) may sit below wall top');
      }
    }

    if (roofs.isNotEmpty && walls.isNotEmpty) {
      final roofBottom = roofs.map((r) => r.bounds.min.y).reduce(math.min);
      if (roofBottom < fp.wallTopY - _tol * 5) {
        warnings.add('Roof may not bear on wall plate');
      }
    }
  }

  static bool _isNonStructural(BimEntity e) =>
      e.category == BimEntityCategory.terrain ||
      e.category == BimEntityCategory.excavation ||
      e.category == BimEntityCategory.grid ||
      e.category == BimEntityCategory.survey ||
      e.category == BimEntityCategory.annotation ||
      e.category == BimEntityCategory.finishing ||
      e.id.contains('ghost') ||
      e.id.contains('_hint');

  static bool _isDeckMountedColumn(BimEntity e) =>
      e.id.contains('guide_post') ||
      e.id.contains('frame_col') ||
      e.id.contains('platform_col');

  static bool _isElevatedBearing(BimEntity e) =>
      e.id.contains('elevated_slab') ||
      e.id.contains('floating_deck') ||
      e.id.contains('platform_frame');

  static bool _isGroundBearing(BimEntity e) =>
      (_isFoundation(e) || _isPlinth(e)) && !_isElevatedBearing(e);

  static bool _isFoundation(BimEntity e) =>
      e.id.contains('found') ||
      e.id.contains('footing') ||
      e.id.contains('pcc') ||
      (e.category == BimEntityCategory.concrete &&
          e.minStage <= 4 &&
          !e.id.contains('column') &&
          !e.id.contains('band'));

  static bool _isPlinth(BimEntity e) =>
      e.id.contains('plinth') || e.componentId == 'plinth_beam';

  static bool _isColumn(BimEntity e) {
    if (e.category == BimEntityCategory.rebar ||
        e.category == BimEntityCategory.formwork) {
      return false;
    }
    if (e.id.contains('formwork') ||
        e.id.contains('grout') ||
        e.id.contains('guide_post') ||
        e.id.contains('skin_') ||
        e.componentId == 'wall_panel') {
      return false;
    }
    if (e.id.startsWith('col_concrete') ||
        e.id.startsWith('rcc_column') ||
        e.id.contains('steel_column') ||
        e.id.contains('timber_column') ||
        e.id.startsWith('tie_col') ||
        e.id.startsWith('frame_col')) {
      return true;
    }
    if (e.id.contains('column') && !e.id.contains('formwork')) return true;
    if (e.category == BimEntityCategory.concrete &&
        e.mesh.vertices.length < 200 &&
        !e.id.contains('plinth') &&
        !e.id.contains('footing')) {
      final b = e.bounds;
      final hy = b.max.y - b.min.y;
      final hx = b.max.x - b.min.x;
      final hz = b.max.z - b.min.z;
      return hy > hx * 1.2 && hy > hz * 1.2 && hx > 0.12 && hz > 0.12;
    }
    if (e.category == BimEntityCategory.bamboo && e.id.contains('column')) {
      return true;
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
      (e.category == BimEntityCategory.concrete && e.id.contains('roof'));
}
