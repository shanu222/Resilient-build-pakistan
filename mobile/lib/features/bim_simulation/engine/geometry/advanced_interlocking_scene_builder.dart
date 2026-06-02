import 'dart:math' as math;
import 'dart:ui';

import '../bim_entity.dart';
import 'advanced_interlocking_dimensions.dart';
import 'bim_mesh.dart';
import '../math/bim_vec3.dart';

/// Engineering-grade procedural BIM — Advanced Interlocking Hollow Block House (8×6 m).
class AdvancedInterlockingSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
    _site(e);
    _excavation(e);
    _foundationRebar(e);
    _footings(e);
    _foundationWall(e);
    _plinthBeam(e);
    _dpc(e);
    _interlockingWalls(e);
    _verticalRebar(e);
    _groutCells(e);
    _lintelBand(e);
    _roofBand(e);
    _steelRoof(e);
    _openings(e);
    _inspectionMarkers(e);
    _comparisons(e);
    return e;
  }

  void _site(List<BimEntity> e) {
    e.add(BimEntity(
      id: 'terrain',
      label: 'Terrain',
      mesh: BimMesh.box(width: AdvancedInterlockingDimensions.plotWidth, height: 0.12, depth: AdvancedInterlockingDimensions.plotDepth,
          center: BimVec3(AdvancedInterlockingDimensions.plotWidth / 2, -0.06, AdvancedInterlockingDimensions.plotDepth / 2)),
      color: const Color(0xFF8B7355),
      category: BimEntityCategory.terrain,
      minStage: 0,
    ));
    _footprint(e);
    for (var i = 0; i <= (AdvancedInterlockingDimensions.buildingWidth / AdvancedInterlockingDimensions.gridModule).ceil(); i++) {
      e.add(BimEntity(
        id: 'grid_x_$i',
        label: 'Grid X$i',
        mesh: BimMesh.box(width: 0.012, height: 0.008, depth: AdvancedInterlockingDimensions.buildingDepth + 1.2),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.grid,
        position: BimVec3(i * AdvancedInterlockingDimensions.gridModule, 0.025, -0.6),
        minStage: 0,
        buildProgress: 0,
      ));
    }
    for (var i = 0; i <= (AdvancedInterlockingDimensions.buildingDepth / AdvancedInterlockingDimensions.gridModule).ceil(); i++) {
      e.add(BimEntity(
        id: 'grid_z_$i',
        label: 'Grid Z$i',
        mesh: BimMesh.box(width: AdvancedInterlockingDimensions.buildingWidth + 1.2, height: 0.008, depth: 0.012),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.grid,
        position: BimVec3(-0.6, 0.025, i * AdvancedInterlockingDimensions.gridModule),
        minStage: 0,
        buildProgress: 0,
      ));
    }
    e.add(BimEntity(
      id: 'dim_label',
      label: '8m × 6m',
      mesh: BimMesh.box(width: 1.2, height: 0.02, depth: 0.3),
      color: const Color(0xFF0F172A),
      category: BimEntityCategory.annotation,
      position: BimVec3(AdvancedInterlockingDimensions.centerX - 0.6, 0.05, -0.4),
      minStage: 0,
    ));
  }

  void _footprint(List<BimEntity> e) {
    final edges = [
      (0.0, 0.0, AdvancedInterlockingDimensions.buildingWidth, 0.0),
      (AdvancedInterlockingDimensions.buildingWidth, 0.0, AdvancedInterlockingDimensions.buildingWidth, AdvancedInterlockingDimensions.buildingDepth),
      (AdvancedInterlockingDimensions.buildingWidth, AdvancedInterlockingDimensions.buildingDepth, 0.0, AdvancedInterlockingDimensions.buildingDepth),
      (0.0, AdvancedInterlockingDimensions.buildingDepth, 0.0, 0.0),
    ];
    for (var i = 0; i < edges.length; i++) {
      final ed = edges[i];
      final len = math.sqrt(
        math.pow(ed.$4 - ed.$2, 2) + math.pow(ed.$3 - ed.$1, 2),
      );
      e.add(BimEntity(
        id: 'footprint_$i',
        label: 'Footprint',
        mesh: BimMesh.box(width: len, height: 0.04, depth: 0.08),
        color: const Color(0xFF0F172A),
        category: BimEntityCategory.annotation,
        position: BimVec3((ed.$1 + ed.$3) / 2 - len / 2, 0.04, (ed.$2 + ed.$4) / 2),
        minStage: 0,
      ));
    }
  }

  void _excavation(List<BimEntity> e) {
    final yBase = AdvancedInterlockingDimensions.trenchBottomY + AdvancedInterlockingDimensions.trenchDepth / 2;
    final specs = [
      (AdvancedInterlockingDimensions.centerX, yBase, 0.0, AdvancedInterlockingDimensions.buildingWidth + AdvancedInterlockingDimensions.trenchWidth * 2, AdvancedInterlockingDimensions.trenchDepth, AdvancedInterlockingDimensions.trenchWidth),
      (AdvancedInterlockingDimensions.centerX, yBase, AdvancedInterlockingDimensions.buildingDepth, AdvancedInterlockingDimensions.buildingWidth + AdvancedInterlockingDimensions.trenchWidth * 2, AdvancedInterlockingDimensions.trenchDepth, AdvancedInterlockingDimensions.trenchWidth),
      (0.0, yBase, AdvancedInterlockingDimensions.centerZ, AdvancedInterlockingDimensions.trenchWidth, AdvancedInterlockingDimensions.trenchDepth, AdvancedInterlockingDimensions.buildingDepth),
      (AdvancedInterlockingDimensions.buildingWidth, yBase, AdvancedInterlockingDimensions.centerZ, AdvancedInterlockingDimensions.trenchWidth, AdvancedInterlockingDimensions.trenchDepth, AdvancedInterlockingDimensions.buildingDepth),
    ];
    for (var i = 0; i < specs.length; i++) {
      final s = specs[i];
      e.add(BimEntity(
        id: 'trench_$i',
        label: 'Excavation Trench',
        mesh: BimMesh.box(width: s.$4, height: s.$5, depth: s.$6),
        color: const Color(0xFFA16207),
        category: BimEntityCategory.excavation,
        position: BimVec3(s.$1 - s.$4 / 2, s.$2, s.$3 - s.$6 / 2),
        explodeGroup: 1,
        minStage: 1,
        pickable: i == 0,
        componentId: 'footing',
        buildProgress: 0,
      ));
    }
    e.add(BimEntity(
      id: 'bearing_layer',
      label: 'Bearing Stratum',
      mesh: BimMesh.box(
        width: AdvancedInterlockingDimensions.buildingWidth + 1.5, height: 0.18, depth: AdvancedInterlockingDimensions.buildingDepth + 1.5,
        center: BimVec3(AdvancedInterlockingDimensions.centerX, AdvancedInterlockingDimensions.trenchBottomY + 0.09, AdvancedInterlockingDimensions.centerZ)),
      color: const Color(0xFF57534E),
      category: BimEntityCategory.excavation,
      minStage: 1,
      opacity: 0.85,
    ));
    e.add(BimEntity(
      id: 'pcc_strip',
      label: 'PCC Blinding',
      mesh: BimMesh.box(
        width: AdvancedInterlockingDimensions.buildingWidth + 0.5, height: AdvancedInterlockingDimensions.pccThickness, depth: AdvancedInterlockingDimensions.buildingDepth + 0.5,
        center: BimVec3(AdvancedInterlockingDimensions.centerX, AdvancedInterlockingDimensions.trenchBottomY + AdvancedInterlockingDimensions.pccThickness / 2, AdvancedInterlockingDimensions.centerZ)),
      color: const Color(0xFFD1D5DB),
      category: BimEntityCategory.concrete,
      explodeGroup: 1,
      minStage: 1,
      componentId: 'footing',
      buildProgress: 0,
    ));
  }

  void _foundationRebar(List<BimEntity> e) {
    final y = AdvancedInterlockingDimensions.pccTopY + AdvancedInterlockingDimensions.footingDepth * 0.35;
    for (var i = 0; i < 12; i++) {
      final t = i / 11;
      e.add(BimEntity(
        id: 'found_rebar_$i',
        label: 'Foundation Rebar',
        mesh: BimMesh.cylinder(radius: AdvancedInterlockingDimensions.rebarRadius, height: AdvancedInterlockingDimensions.footingDepth * 0.6),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        position: BimVec3(0.2 + t * (AdvancedInterlockingDimensions.buildingWidth - 0.4), y, 0.15),
        explodeGroup: 1,
        minStage: 2,
        pickable: i == 0,
        componentId: 'vertical_reinforcement',
        buildProgress: 0,
      ));
    }
    for (final c in _corners(inset: 0.2)) {
      e.add(BimEntity(
        id: 'cover_block_${c.$1}_${c.$2}',
        label: 'Cover Block',
        mesh: BimMesh.box(width: 0.04, height: 0.04, depth: 0.04),
        color: const Color(0xFF94A3B8),
        category: BimEntityCategory.concrete,
        position: BimVec3(c.$1, y - 0.02, c.$2),
        minStage: 2,
        buildProgress: 0,
      ));
    }
  }

  void _footings(List<BimEntity> e) {
    final y = AdvancedInterlockingDimensions.pccTopY + AdvancedInterlockingDimensions.footingDepth / 2;
    final fw = AdvancedInterlockingDimensions.footingWidth;
    final specs = [
      (AdvancedInterlockingDimensions.centerX, y, 0.0, AdvancedInterlockingDimensions.buildingWidth + fw, AdvancedInterlockingDimensions.footingDepth, fw),
      (AdvancedInterlockingDimensions.centerX, y, AdvancedInterlockingDimensions.buildingDepth, AdvancedInterlockingDimensions.buildingWidth + fw, AdvancedInterlockingDimensions.footingDepth, fw),
      (0.0, y, AdvancedInterlockingDimensions.centerZ, fw, AdvancedInterlockingDimensions.footingDepth, AdvancedInterlockingDimensions.buildingDepth + fw * 0.5),
      (AdvancedInterlockingDimensions.buildingWidth, y, AdvancedInterlockingDimensions.centerZ, fw, AdvancedInterlockingDimensions.footingDepth, AdvancedInterlockingDimensions.buildingDepth + fw * 0.5),
    ];
    for (var i = 0; i < specs.length; i++) {
      final s = specs[i];
      e.add(BimEntity(
        id: 'footing_$i',
        label: 'Strip Footing',
        mesh: BimMesh.box(width: s.$4, height: s.$5, depth: s.$6),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        position: BimVec3(s.$1 - s.$4 / 2, s.$2, s.$3 - s.$6 / 2),
        explodeGroup: 1,
        minStage: 3,
        pickable: i == 0,
        componentId: 'footing',
        buildProgress: 0,
      ));
    }
  }

  void _foundationWall(List<BimEntity> e) {
    for (var course = 0; course < AdvancedInterlockingDimensions.foundationCourses; course++) {
      final y = AdvancedInterlockingDimensions.footingTopY + course * AdvancedInterlockingDimensions.blockHeight + AdvancedInterlockingDimensions.blockHeight / 2;
      e.add(BimEntity(
        id: 'found_wall_$course',
        label: 'Foundation Wall Course ${course + 1}',
        mesh: BimMesh.box(
          width: AdvancedInterlockingDimensions.buildingWidth + AdvancedInterlockingDimensions.wallThickness, height: AdvancedInterlockingDimensions.blockHeight,
          depth: AdvancedInterlockingDimensions.buildingDepth + AdvancedInterlockingDimensions.wallThickness,
          center: BimVec3(AdvancedInterlockingDimensions.centerX, y, AdvancedInterlockingDimensions.centerZ)),
        color: const Color(0xFFB45309),
        category: BimEntityCategory.masonry,
        explodeGroup: 1,
        minStage: 4,
        componentId: 'foundation_wall',
        buildProgress: 0,
      ));
    }
  }

  void _plinthBeam(List<BimEntity> e) {
    final baseY = AdvancedInterlockingDimensions.foundationWallTopY;
    e.add(BimEntity(
      id: 'plinth_formwork',
      label: 'Plinth Formwork',
      mesh: BimMesh.box(
        width: AdvancedInterlockingDimensions.buildingWidth + 0.35, height: AdvancedInterlockingDimensions.plinthBeam + 0.06, depth: AdvancedInterlockingDimensions.buildingDepth + 0.35,
        center: BimVec3(AdvancedInterlockingDimensions.centerX, baseY + AdvancedInterlockingDimensions.plinthBeam / 2, AdvancedInterlockingDimensions.centerZ)),
      color: const Color(0xFFDEB887),
      category: BimEntityCategory.formwork,
      minStage: 5,
      buildProgress: 0,
    ));
    for (var i = 0; i < 10; i++) {
      e.add(BimEntity(
        id: 'plinth_rebar_$i',
        label: 'Plinth Rebar',
        mesh: BimMesh.cylinder(radius: AdvancedInterlockingDimensions.rebarRadius, height: AdvancedInterlockingDimensions.plinthBeam * 0.7),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        position: BimVec3(0.2 + i * (AdvancedInterlockingDimensions.buildingWidth - 0.4) / 9, baseY + AdvancedInterlockingDimensions.plinthBeam * 0.3, 0.12),
        minStage: 5,
        pickable: i == 0,
        componentId: 'plinth_beam',
        buildProgress: 0,
      ));
    }
    e.add(BimEntity(
      id: 'plinth_concrete',
      label: 'Plinth Beam',
      mesh: BimMesh.box(
        width: AdvancedInterlockingDimensions.buildingWidth + AdvancedInterlockingDimensions.wallThickness * 0.5, height: AdvancedInterlockingDimensions.plinthBeam,
        depth: AdvancedInterlockingDimensions.buildingDepth + AdvancedInterlockingDimensions.wallThickness * 0.5,
        center: BimVec3(AdvancedInterlockingDimensions.centerX, baseY + AdvancedInterlockingDimensions.plinthBeam / 2, AdvancedInterlockingDimensions.centerZ)),
      color: const Color(0xFF6B7280),
      category: BimEntityCategory.concrete,
      explodeGroup: 2,
      minStage: 5,
      pickable: true,
      componentId: 'plinth_beam',
      buildProgress: 0,
    ));
  }

  void _dpc(List<BimEntity> e) {
    e.add(BimEntity(
      id: 'dpc_layer',
      label: 'DPC Membrane',
      mesh: BimMesh.box(
        width: AdvancedInterlockingDimensions.buildingWidth + AdvancedInterlockingDimensions.wallThickness, height: AdvancedInterlockingDimensions.dpcThickness,
        depth: AdvancedInterlockingDimensions.buildingDepth + AdvancedInterlockingDimensions.wallThickness,
        center: BimVec3(AdvancedInterlockingDimensions.centerX, AdvancedInterlockingDimensions.wallBaseY - AdvancedInterlockingDimensions.dpcThickness / 2, AdvancedInterlockingDimensions.centerZ)),
      color: const Color(0xFF1E293B),
      category: BimEntityCategory.finishing,
      minStage: 6,
      pickable: true,
      componentId: 'dpc',
      buildProgress: 0,
    ));
  }

  void _interlockingWalls(List<BimEntity> e) {
    final courses = (AdvancedInterlockingDimensions.wallHeight / AdvancedInterlockingDimensions.blockHeight).ceil();
    var idx = 0;
    for (var course = 0; course < courses; course++) {
      final y = AdvancedInterlockingDimensions.wallBaseY + course * AdvancedInterlockingDimensions.blockHeight;
      final stagger = (course % 2) * AdvancedInterlockingDimensions.blockLength / 2;
      idx = _wallRun(e, idx, course, y, stagger, wall: _WallDir.front);
      idx = _wallRun(e, idx, course, y, stagger, wall: _WallDir.back);
      idx = _wallRun(e, idx, course, y, stagger, wall: _WallDir.left);
      idx = _wallRun(e, idx, course, y, stagger, wall: _WallDir.right);
      for (final c in _corners(inset: 0)) {
        e.add(_hollowBlock('blk_corner_$idx', c.$1, y, c.$2, AdvancedInterlockingDimensions.wallThickness, AdvancedInterlockingDimensions.wallThickness, course, corner: true));
        idx++;
      }
    }
  }

  int _wallRun(List<BimEntity> e, int idx, int course, double y, double stagger,
      {required _WallDir wall}) {
    final wt = AdvancedInterlockingDimensions.wallThickness;
    final bl = AdvancedInterlockingDimensions.blockLength;
    final alongX = wall == _WallDir.front || wall == _WallDir.back;
    final run = (alongX ? AdvancedInterlockingDimensions.buildingWidth : AdvancedInterlockingDimensions.buildingDepth) - wt * 2;
    final count = (run / bl).floor();
    for (var b = 0; b < count; b++) {
      final coord = wt + stagger + b * bl;
      late double x, z, bw, bd;
      switch (wall) {
        case _WallDir.front:
          x = coord; z = 0; bw = bl; bd = wt;
        case _WallDir.back:
          x = coord; z = AdvancedInterlockingDimensions.buildingDepth - wt; bw = bl; bd = wt;
        case _WallDir.left:
          x = 0; z = coord; bw = wt; bd = bl;
        case _WallDir.right:
          x = AdvancedInterlockingDimensions.buildingWidth - wt; z = coord; bw = wt; bd = bl;
      }
      e.add(_hollowBlock('blk_$idx', x, y, z, bw, bd, course));
      idx++;
    }
    return idx;
  }

  BimEntity _hollowBlock(String id, double x, double y, double z,
      double w, double depth, int course, {bool corner = false}) {
    return BimEntity(
      id: id,
      label: corner ? 'Corner Hollow Block' : 'Interlocking Hollow Block',
      mesh: BimMesh.box(width: w * 0.94, height: AdvancedInterlockingDimensions.blockHeight, depth: depth * 0.94),
      color: Color.lerp(const Color(0xFFD97706), const Color(0xFF92400E), (course % 4) / 4)!,
      category: BimEntityCategory.masonry,
      position: BimVec3(x, y, z),
      explodeGroup: 2,
      minStage: 7,
      pickable: id.endsWith('0') || corner,
      componentId: 'interlocking_block',
      buildProgress: 0,
    );
  }

  void _verticalRebar(List<BimEntity> e) {
    final barH = AdvancedInterlockingDimensions.wallHeight + AdvancedInterlockingDimensions.bandHeight * 2;
    var i = 0;
    for (final c in _corners(inset: AdvancedInterlockingDimensions.wallThickness / 2)) {
      e.add(BimEntity(
        id: 'vbar_$i',
        label: 'Vertical Bar Ø12',
        mesh: BimMesh.cylinder(radius: AdvancedInterlockingDimensions.rebarRadius, height: barH),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        position: BimVec3(c.$1, AdvancedInterlockingDimensions.wallBaseY, c.$2),
        explodeGroup: 2,
        minStage: 8,
        pickable: i == 0,
        componentId: 'vertical_reinforcement',
        buildProgress: 0,
      ));
      e.add(BimEntity(
        id: 'core_void_$i',
        label: 'Hollow Core',
        mesh: BimMesh.cylinder(radius: AdvancedInterlockingDimensions.coreDiameter / 2, height: AdvancedInterlockingDimensions.blockHeight * 0.9, segments: 8),
        color: const Color(0xFF451A03),
        category: BimEntityCategory.masonry,
        position: BimVec3(c.$1, AdvancedInterlockingDimensions.wallBaseY + AdvancedInterlockingDimensions.blockHeight / 2, c.$2),
        minStage: 8,
        opacity: 0.4,
        buildProgress: 0,
      ));
      i++;
    }
    for (var j = 0; j < 4; j++) {
      final positions = [
        (AdvancedInterlockingDimensions.centerX, 0.12),
        (AdvancedInterlockingDimensions.centerX, AdvancedInterlockingDimensions.buildingDepth - 0.12),
        (0.12, AdvancedInterlockingDimensions.centerZ),
        (AdvancedInterlockingDimensions.buildingWidth - 0.12, AdvancedInterlockingDimensions.centerZ),
      ];
      final p = positions[j];
      e.add(BimEntity(
        id: 'vbar_mid_$j',
        label: 'Wall Bar',
        mesh: BimMesh.cylinder(radius: AdvancedInterlockingDimensions.rebarRadius, height: barH * 0.98),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        position: BimVec3(p.$1, AdvancedInterlockingDimensions.wallBaseY, p.$2),
        minStage: 8,
        componentId: 'vertical_reinforcement',
        buildProgress: 0,
      ));
    }
  }

  void _groutCells(List<BimEntity> e) {
    for (var i = 0; i < 4; i++) {
      final c = _corners(inset: AdvancedInterlockingDimensions.wallThickness / 2)[i];
      e.add(BimEntity(
        id: 'grout_cell_$i',
        label: 'Grouted Core',
        mesh: BimMesh.cylinder(radius: AdvancedInterlockingDimensions.coreDiameter / 2, height: AdvancedInterlockingDimensions.wallHeight * 0.92, segments: 10),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        position: BimVec3(c.$1, AdvancedInterlockingDimensions.wallBaseY + AdvancedInterlockingDimensions.wallHeight * 0.46, c.$2),
        explodeGroup: 2,
        minStage: 8,
        componentId: 'grouted_core',
        buildProgress: 0,
      ));
    }
  }

  void _lintelBand(List<BimEntity> e) {
    final y = AdvancedInterlockingDimensions.lintelBandY + AdvancedInterlockingDimensions.bandHeight / 2;
    e.add(BimEntity(
      id: 'lintel_formwork',
      label: 'Lintel Formwork',
      mesh: BimMesh.box(
        width: AdvancedInterlockingDimensions.buildingWidth + 0.3, height: AdvancedInterlockingDimensions.bandHeight + 0.05, depth: AdvancedInterlockingDimensions.buildingDepth + 0.3,
        center: BimVec3(AdvancedInterlockingDimensions.centerX, y, AdvancedInterlockingDimensions.centerZ)),
      color: const Color(0xFFDEB887),
      category: BimEntityCategory.formwork,
      minStage: 9,
      buildProgress: 0,
    ));
    for (var i = 0; i < 14; i++) {
      e.add(BimEntity(
        id: 'lintel_rebar_$i',
        label: 'Lintel Rebar',
        mesh: BimMesh.cylinder(radius: AdvancedInterlockingDimensions.rebarRadius, height: AdvancedInterlockingDimensions.bandHeight * 0.7),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        position: BimVec3(0.15 + i * (AdvancedInterlockingDimensions.buildingWidth - 0.3) / 13, AdvancedInterlockingDimensions.lintelBandY + AdvancedInterlockingDimensions.bandHeight * 0.3, 0.12),
        minStage: 9,
        pickable: i == 0,
        componentId: 'lintel_band',
        buildProgress: 0,
      ));
    }
    e.add(BimEntity(
      id: 'lintel_band',
      label: 'Lintel Band',
      mesh: BimMesh.box(
        width: AdvancedInterlockingDimensions.buildingWidth + AdvancedInterlockingDimensions.wallThickness, height: AdvancedInterlockingDimensions.bandHeight,
        depth: AdvancedInterlockingDimensions.buildingDepth + AdvancedInterlockingDimensions.wallThickness,
        center: BimVec3(AdvancedInterlockingDimensions.centerX, y, AdvancedInterlockingDimensions.centerZ)),
      color: const Color(0xFF9CA3AF),
      category: BimEntityCategory.concrete,
      explodeGroup: 3,
      minStage: 9,
      pickable: true,
      componentId: 'lintel_band',
      buildProgress: 0,
    ));
  }

  void _roofBand(List<BimEntity> e) {
    final y = AdvancedInterlockingDimensions.roofBandY + AdvancedInterlockingDimensions.bandHeight / 2;
    for (var i = 0; i < 16; i++) {
      e.add(BimEntity(
        id: 'roof_band_rebar_$i',
        label: 'Roof Band Rebar',
        mesh: BimMesh.cylinder(radius: AdvancedInterlockingDimensions.rebarRadius, height: AdvancedInterlockingDimensions.bandHeight * 0.75),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        position: BimVec3(0.12 + i * (AdvancedInterlockingDimensions.buildingWidth - 0.24) / 15, AdvancedInterlockingDimensions.roofBandY + AdvancedInterlockingDimensions.bandHeight * 0.28, 0.1),
        minStage: 10,
        componentId: 'roof_band',
        buildProgress: 0,
      ));
    }
    e.add(BimEntity(
      id: 'roof_band',
      label: 'Roof Band',
      mesh: BimMesh.box(
        width: AdvancedInterlockingDimensions.buildingWidth + AdvancedInterlockingDimensions.wallThickness * 1.1, height: AdvancedInterlockingDimensions.bandHeight,
        depth: AdvancedInterlockingDimensions.buildingDepth + AdvancedInterlockingDimensions.wallThickness * 1.1,
        center: BimVec3(AdvancedInterlockingDimensions.centerX, y, AdvancedInterlockingDimensions.centerZ)),
      color: const Color(0xFF6B7280),
      category: BimEntityCategory.concrete,
      explodeGroup: 3,
      minStage: 10,
      pickable: true,
      componentId: 'roof_band',
      buildProgress: 0,
    ));
  }

  void _steelRoof(List<BimEntity> e) {
    e.add(BimEntity(
      id: 'wall_plate',
      label: 'Wall Plate',
      mesh: BimMesh.box(
        width: AdvancedInterlockingDimensions.buildingWidth + 0.1, height: 0.08, depth: AdvancedInterlockingDimensions.buildingDepth + 0.1,
        center: BimVec3(AdvancedInterlockingDimensions.centerX, AdvancedInterlockingDimensions.eaveY + 0.04, AdvancedInterlockingDimensions.centerZ)),
      color: const Color(0xFF64748B),
      category: BimEntityCategory.timber,
      minStage: 11,
      componentId: 'roof_truss',
      buildProgress: 0,
    ));
    final trussCount = (AdvancedInterlockingDimensions.buildingWidth / AdvancedInterlockingDimensions.trussSpacing).ceil() + 1;
    for (var t = 0; t < trussCount; t++) {
      final x = t * AdvancedInterlockingDimensions.trussSpacing;
      if (x > AdvancedInterlockingDimensions.buildingWidth) break;
      final rafterLen = (AdvancedInterlockingDimensions.buildingDepth / 2 + 0.1) / math.cos(AdvancedInterlockingDimensions.roofSlopeRadians);
      e.add(BimEntity(
        id: 'truss_${t}_bottom',
        label: 'Truss Bottom Chord',
        mesh: BimMesh.box(width: 0.08, height: 0.06, depth: AdvancedInterlockingDimensions.buildingDepth + 0.15),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.timber,
        position: BimVec3(x, AdvancedInterlockingDimensions.eaveY + 0.08, -0.05),
        minStage: 11,
        pickable: t == 0,
        componentId: 'roof_truss',
        buildProgress: 0,
      ));
      e.add(BimEntity(
        id: 'truss_${t}_rafter_l',
        label: 'Steel Rafter',
        mesh: BimMesh.box(width: 0.06, height: rafterLen, depth: 0.06),
        color: const Color(0xFF475569),
        category: BimEntityCategory.timber,
        position: BimVec3(x, AdvancedInterlockingDimensions.eaveY + (AdvancedInterlockingDimensions.ridgeY - AdvancedInterlockingDimensions.eaveY) / 2, AdvancedInterlockingDimensions.buildingDepth / 4),
        minStage: 11,
        componentId: 'roof_truss',
        buildProgress: 0,
      ));
      e.add(BimEntity(
        id: 'truss_${t}_rafter_r',
        label: 'Steel Rafter',
        mesh: BimMesh.box(width: 0.06, height: rafterLen, depth: 0.06),
        color: const Color(0xFF475569),
        category: BimEntityCategory.timber,
        position: BimVec3(x, AdvancedInterlockingDimensions.eaveY + (AdvancedInterlockingDimensions.ridgeY - AdvancedInterlockingDimensions.eaveY) / 2, AdvancedInterlockingDimensions.buildingDepth * 3 / 4),
        minStage: 11,
        componentId: 'roof_truss',
        buildProgress: 0,
      ));
      e.add(BimEntity(
        id: 'truss_connector_$t',
        label: 'Truss Connection',
        mesh: BimMesh.box(width: 0.1, height: 0.04, depth: 0.1),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.concrete,
        position: BimVec3(x, AdvancedInterlockingDimensions.eaveY, 0.05),
        minStage: 11,
        componentId: 'roof_truss',
        buildProgress: 0,
      ));
    }
    e.add(BimEntity(
      id: 'ridge_beam',
      label: 'Ridge Beam',
      mesh: BimMesh.box(width: AdvancedInterlockingDimensions.buildingWidth + 0.12, height: 0.08, depth: 0.08),
      color: const Color(0xFF64748B),
      category: BimEntityCategory.timber,
      position: BimVec3(0, AdvancedInterlockingDimensions.ridgeY, AdvancedInterlockingDimensions.centerZ),
      minStage: 11,
      componentId: 'roof_truss',
      buildProgress: 0,
    ));
    for (var p = 0; p <= (AdvancedInterlockingDimensions.buildingDepth / AdvancedInterlockingDimensions.purlinSpacing).ceil(); p++) {
      final z = p * AdvancedInterlockingDimensions.purlinSpacing;
      if (z > AdvancedInterlockingDimensions.buildingDepth) break;
      final py = AdvancedInterlockingDimensions.eaveY + (z / AdvancedInterlockingDimensions.buildingDepth) * (AdvancedInterlockingDimensions.ridgeY - AdvancedInterlockingDimensions.eaveY) * 2 * math.min(z / AdvancedInterlockingDimensions.buildingDepth, 1 - z / AdvancedInterlockingDimensions.buildingDepth) * 2;
      e.add(BimEntity(
        id: 'purlin_$p',
        label: 'Purlin',
        mesh: BimMesh.box(width: AdvancedInterlockingDimensions.buildingWidth + 0.15, height: 0.05, depth: 0.07),
        color: const Color(0xFF475569),
        category: BimEntityCategory.timber,
        position: BimVec3(-0.08, py + 0.03, z),
        minStage: 11,
        componentId: 'roof_truss',
        buildProgress: 0,
      ));
    }
    e.add(BimEntity(
      id: 'roof_bracing',
      label: 'Roof Bracing',
      mesh: BimMesh.box(width: 0.04, height: 0.04, depth: AdvancedInterlockingDimensions.buildingDepth * 0.7),
      color: const Color(0xFF64748B),
      category: BimEntityCategory.wire,
      position: BimVec3(AdvancedInterlockingDimensions.centerX, AdvancedInterlockingDimensions.ridgeY - 0.12, AdvancedInterlockingDimensions.centerZ),
      minStage: 11,
      componentId: 'roof_truss',
      buildProgress: 0,
    ));
    final rows = (AdvancedInterlockingDimensions.buildingDepth / AdvancedInterlockingDimensions.purlinSpacing).ceil();
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < 4; col++) {
        final z = row * AdvancedInterlockingDimensions.purlinSpacing;
        final x = col * (AdvancedInterlockingDimensions.buildingWidth / 4);
        final sy = AdvancedInterlockingDimensions.eaveY + (z / AdvancedInterlockingDimensions.buildingDepth) * (AdvancedInterlockingDimensions.ridgeY - AdvancedInterlockingDimensions.eaveY);
        e.add(BimEntity(
          id: 'roof_sheet_${row}_$col',
          label: 'Roof Sheet',
          mesh: BimMesh.box(width: AdvancedInterlockingDimensions.buildingWidth / 4 + 0.04, height: 0.001, depth: AdvancedInterlockingDimensions.purlinSpacing + 0.04),
          color: const Color(0xFF334155),
          category: BimEntityCategory.finishing,
          position: BimVec3(x, sy + 0.04, z),
          explodeGroup: 4,
          minStage: 12,
          pickable: row == 0 && col == 0,
          componentId: 'roof_cover',
          buildProgress: 0,
        ));
      }
    }
  }

  void _openings(List<BimEntity> e) {
    e.add(BimEntity(
      id: 'door_frame',
      label: 'Door Frame',
      mesh: BimMesh.box(width: 1.0, height: 2.1, depth: 0.06),
      color: const Color(0xFF78350F),
      category: BimEntityCategory.finishing,
      position: BimVec3(AdvancedInterlockingDimensions.centerX - 0.5, AdvancedInterlockingDimensions.wallBaseY, 0),
      minStage: 12,
      buildProgress: 0,
    ));
    e.add(BimEntity(
      id: 'window_frame',
      label: 'Window Frame',
      mesh: BimMesh.box(width: 1.2, height: 1.0, depth: 0.05),
      color: const Color(0xFF38BDF8),
      category: BimEntityCategory.finishing,
      position: BimVec3(AdvancedInterlockingDimensions.buildingWidth - 0.08, AdvancedInterlockingDimensions.wallBaseY + 1.2, AdvancedInterlockingDimensions.centerZ - 0.6),
      minStage: 12,
      buildProgress: 0,
    ));
  }

  void _inspectionMarkers(List<BimEntity> e) {
    e.add(BimEntity(
      id: 'load_path_marker',
      label: 'Load Path',
      mesh: BimMesh.box(width: 0.1, height: 0.1, depth: 0.1),
      color: const Color(0xFFEF4444),
      category: BimEntityCategory.annotation,
      position: BimVec3(AdvancedInterlockingDimensions.centerX, AdvancedInterlockingDimensions.ridgeY, AdvancedInterlockingDimensions.centerZ),
      minStage: 13,
      opacity: 0.85,
      buildProgress: 0,
    ));
  }

  void _comparisons(List<BimEntity> e) {
    e.add(BimEntity(
      id: 'conventional_masonry_ghost',
      label: 'Conventional Masonry (fails)',
      mesh: BimMesh.box(
        width: AdvancedInterlockingDimensions.buildingWidth * 0.4, height: AdvancedInterlockingDimensions.wallHeight, depth: AdvancedInterlockingDimensions.wallThickness,
        center: BimVec3(AdvancedInterlockingDimensions.buildingWidth + 2.5, AdvancedInterlockingDimensions.wallBaseY + AdvancedInterlockingDimensions.wallHeight / 2, AdvancedInterlockingDimensions.centerZ)),
      color: const Color(0xFF78716C),
      category: BimEntityCategory.masonry,
      minStage: 14,
      opacity: 0.25,
    ));
    e.add(BimEntity(
      id: 'landscape',
      label: 'Completed House',
      mesh: BimMesh.box(
        width: AdvancedInterlockingDimensions.plotWidth, height: 0.06, depth: 1.2,
        center: BimVec3(AdvancedInterlockingDimensions.plotWidth / 2, 0.03, AdvancedInterlockingDimensions.plotDepth - 0.6)),
      color: const Color(0xFF22C55E),
      category: BimEntityCategory.finishing,
      minStage: 14,
      buildProgress: 0,
    ));
  }

  List<(double, double)> _corners({double inset = 0.12}) {
    return [
      (inset, inset),
      (AdvancedInterlockingDimensions.buildingWidth - inset, inset),
      (AdvancedInterlockingDimensions.buildingWidth - inset, AdvancedInterlockingDimensions.buildingDepth - inset),
      (inset, AdvancedInterlockingDimensions.buildingDepth - inset),
    ];
  }
}

enum _WallDir { front, back, left, right }
