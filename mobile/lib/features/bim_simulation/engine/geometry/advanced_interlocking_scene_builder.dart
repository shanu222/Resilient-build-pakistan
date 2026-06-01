import 'dart:math' as math;
import 'dart:ui';

import '../bim_entity.dart';
import 'advanced_interlocking_dimensions.dart';
import 'bim_mesh.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 16 Advanced Interlocking Brick Masonry.
class AdvancedInterlockingSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
    final d = AdvancedInterlockingDimensions;
    _site(e, d);
    _settingOut(e, d);
    _excavation(e, d);
    _pcc(e, d);
    _footings(e, d);
    _plinth(e, d);
    _wallsAndBlocks(e, d);
    _verticalBars(e, d);
    _groutCells(e, d);
    _bands(e, d);
    _roof(e, d);
    _openingsAndFinish(e, d);
    _comparisons(e, d);
    return e;
  }

  void _site(List<BimEntity> e, AdvancedInterlockingDimensions d) {
    e.add(
      BimEntity(
        id: 'terrain',
        label: 'Terrain',
        mesh: BimMesh.box(
          width: d.plotWidth,
          height: 0.15,
          depth: d.plotDepth,
          center: BimVec3(d.centerX, -0.075, d.centerZ + 1),
        ),
        color: const Color(0xFF8B7355),
        category: BimEntityCategory.terrain,
        minStage: 0,
      ),
    );
    _footprint(e, d);
    e.add(
      BimEntity(
        id: 'drainage_arrow',
        label: 'Drainage',
        mesh: BimMesh.box(width: 2.5, height: 0.02, depth: 0.12),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.drainage,
        position: BimVec3(1.5, 0.05, d.plotDepth - 1.2),
        minStage: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'load_zone_marker',
        label: 'Load Zone',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.4,
          height: 0.02,
          depth: d.buildingDepth + 0.4,
          center: BimVec3(d.centerX, 0.04, d.centerZ),
        ),
        color: const Color(0xFFEF4444).withValues(alpha: 0.35),
        category: BimEntityCategory.annotation,
        minStage: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'north_arrow',
        label: 'North',
        mesh: BimMesh.box(width: 0.12, height: 0.02, depth: 1.0),
        color: const Color(0xFFEF4444),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.plotWidth - 1.2, 0.05, d.plotDepth - 1.5),
        minStage: 0,
      ),
    );
  }

  void _footprint(List<BimEntity> e, AdvancedInterlockingDimensions d) {
    final y = 0.04;
    final edges = [
      (0.0, 0.0, d.buildingWidth, 0.0),
      (d.buildingWidth, 0.0, d.buildingWidth, d.buildingDepth),
      (d.buildingWidth, d.buildingDepth, 0.0, d.buildingDepth),
      (0.0, d.buildingDepth, 0.0, 0.0),
    ];
    for (var i = 0; i < edges.length; i++) {
      final ed = edges[i];
      final len = math.sqrt(
        math.pow(ed.$3 - ed.$1, 2) + math.pow(ed.$4 - ed.$2, 2),
      );
      e.add(
        BimEntity(
          id: 'footprint_$i',
          label: 'Footprint',
          mesh: BimMesh.box(width: len, height: 0.04, depth: 0.08),
          color: const Color(0xFF0F172A),
          category: BimEntityCategory.annotation,
          position: BimVec3((ed.$1 + ed.$3) / 2 - len / 2, y, (ed.$2 + ed.$4) / 2),
          minStage: 0,
        ),
      );
    }
  }

  void _settingOut(List<BimEntity> e, AdvancedInterlockingDimensions d) {
    for (var i = 0; i <= 6; i++) {
      e.add(
        BimEntity(
          id: 'grid_x_$i',
          label: 'Grid',
          mesh: BimMesh.box(
            width: 0.02,
            height: 0.01,
            depth: d.buildingDepth + 1,
          ),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(i * (d.buildingWidth / 6), 0.03, -0.5),
          minStage: 1,
        ),
      );
    }
    for (final c in _corners(d)) {
      e.add(
        BimEntity(
          id: 'stake_${c.$1}_${c.$2}',
          label: 'Stake',
          mesh: BimMesh.cylinder(radius: 0.03, height: 1.2, segments: 8),
          color: const Color(0xFFF97316),
          category: BimEntityCategory.survey,
          position: BimVec3(c.$1, 0, c.$2),
          minStage: 1,
        ),
      );
    }
  }

  void _excavation(List<BimEntity> e, AdvancedInterlockingDimensions d) {
    final yBase = -d.trenchDepth / 2;
    final specs = [
      (d.centerX, yBase, 0.0, d.buildingWidth + 0.5, d.trenchDepth, d.trenchWidth),
      (d.centerX, yBase, d.buildingDepth, d.buildingWidth + 0.5, d.trenchDepth, d.trenchWidth),
      (0.0, yBase, d.centerZ, d.trenchWidth, d.trenchDepth, d.buildingDepth),
      (d.buildingWidth, yBase, d.centerZ, d.trenchWidth, d.trenchDepth, d.buildingDepth),
    ];
    for (var i = 0; i < specs.length; i++) {
      final s = specs[i];
      e.add(
        BimEntity(
          id: 'trench_$i',
          label: 'Trench',
          mesh: BimMesh.box(width: s.$4, height: s.$5, depth: s.$6),
          color: const Color(0xFFA16207),
          category: BimEntityCategory.excavation,
          position: BimVec3(s.$1 - s.$4 / 2, s.$2, s.$3 - s.$6 / 2),
          explodeGroup: 1,
          minStage: 2,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'soil_profile',
        label: 'Soil Profile',
        mesh: BimMesh.box(width: 0.08, height: d.trenchDepth + 0.3, depth: 0.5),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.excavation,
        position: BimVec3(-0.8, -d.trenchDepth / 2, d.centerZ),
        minStage: 2,
      ),
    );
    e.add(
      BimEntity(
        id: 'bearing_layer',
        label: 'Bearing Stratum',
        mesh: BimMesh.box(
          width: d.buildingWidth + 1.5,
          height: 0.2,
          depth: d.buildingDepth + 1.5,
          center: BimVec3(d.centerX, -d.trenchDepth + 0.1, d.centerZ),
        ),
        color: const Color(0xFF57534E),
        category: BimEntityCategory.excavation,
        minStage: 2,
        opacity: 0.85,
      ),
    );
    e.add(
      BimEntity(
        id: 'excavator',
        label: 'Excavator',
        mesh: BimMesh.box(width: 1.8, height: 1.2, depth: 2.5),
        color: const Color(0xFFFBBF24),
        category: BimEntityCategory.equipment,
        position: BimVec3(-1.5, 0.1, d.buildingDepth + 1),
        minStage: 2,
      ),
    );
  }

  void _pcc(List<BimEntity> e, AdvancedInterlockingDimensions d) {
    final y = -d.trenchDepth + d.pccThickness / 2;
    e.add(
      BimEntity(
        id: 'pcc_strip',
        label: 'PCC Layer',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.5,
          height: d.pccThickness,
          depth: d.buildingDepth + 0.5,
          center: BimVec3(d.centerX, y, d.centerZ),
        ),
        color: const Color(0xFFD1D5DB),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 3,
      ),
    );
  }

  void _footings(List<BimEntity> e, AdvancedInterlockingDimensions d) {
    final y = -d.trenchDepth + d.pccThickness + d.footingDepth / 2;
    e.add(
      BimEntity(
        id: 'footing_rebar_cage',
        label: 'Footing Rebar',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.footingWidth - 0.1,
          height: d.footingDepth * 0.7,
          depth: d.buildingDepth + d.footingWidth - 0.1,
          center: BimVec3(d.centerX, y, d.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        explodeGroup: 1,
        minStage: 4,
        opacity: 0.9,
      ),
    );
    e.add(
      BimEntity(
        id: 'footing_concrete',
        label: 'RCC Footing',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.footingWidth,
          height: d.footingDepth,
          depth: d.buildingDepth + d.footingWidth,
          center: BimVec3(d.centerX, y, d.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 4,
      ),
    );
    for (var i = 0; i < 3; i++) {
      e.add(
        BimEntity(
          id: 'found_masonry_$i',
          label: 'Foundation Masonry',
          mesh: BimMesh.box(
            width: d.buildingWidth + 0.2,
            height: d.blockHeight,
            depth: d.buildingDepth + 0.2,
            center: BimVec3(
              d.centerX,
              y + d.footingDepth / 2 + d.blockHeight * (i + 0.5),
              d.centerZ,
            ),
          ),
          color: const Color(0xFFB45309),
          category: BimEntityCategory.masonry,
          explodeGroup: 1,
          minStage: 4,
        ),
      );
    }
  }

  void _plinth(List<BimEntity> e, AdvancedInterlockingDimensions d) {
    final baseY = -d.trenchDepth + d.pccThickness + d.footingDepth + d.blockHeight * 2;
    e.add(
      BimEntity(
        id: 'plinth_formwork',
        label: 'Plinth Formwork',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.35,
          height: d.plinthBeam + 0.06,
          depth: d.buildingDepth + 0.35,
          center: BimVec3(d.centerX, baseY + d.plinthBeam / 2, d.centerZ),
        ),
        color: const Color(0xFFDEB887),
        category: BimEntityCategory.formwork,
        minStage: 5,
      ),
    );
    e.add(
      BimEntity(
        id: 'plinth_rebar',
        label: 'Plinth Rebar',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.15,
          height: d.plinthBeam * 0.5,
          depth: d.buildingDepth + 0.15,
          center: BimVec3(d.centerX, baseY + d.plinthBeam * 0.55, d.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        explodeGroup: 2,
        minStage: 5,
      ),
    );
    e.add(
      BimEntity(
        id: 'plinth_concrete',
        label: 'Plinth Band',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.wallThickness * 0.5,
          height: d.plinthBeam,
          depth: d.buildingDepth + d.wallThickness * 0.5,
          center: BimVec3(d.centerX, baseY + d.plinthBeam / 2, d.centerZ),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 2,
        minStage: 5,
        pickable: true,
        componentId: 'plinth_band',
      ),
    );
    e.add(
      BimEntity(
        id: 'dpc_layer',
        label: 'DPC',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.4,
          height: d.dpcThickness,
          depth: d.buildingDepth + 0.4,
          center: BimVec3(d.centerX, baseY + d.plinthBeam + d.dpcThickness / 2, d.centerZ),
        ),
        color: const Color(0xFF1E293B),
        category: BimEntityCategory.finishing,
        minStage: 5,
      ),
    );
  }

  void _wallsAndBlocks(List<BimEntity> e, AdvancedInterlockingDimensions d) {
    final courses = 12;
    final baseY = d.wallBaseY;
    var idx = 0;
    for (var course = 0; course < courses; course++) {
      final y = baseY + course * d.blockHeight;
      final minStage = course == 0 ? 6 : 8;
      for (var bx = 0; bx < (d.buildingWidth / d.blockLength).ceil(); bx++) {
        final x = bx * d.blockLength + d.blockLength / 2;
        for (final z in [0.0, d.buildingDepth - d.blockWidth]) {
          e.add(_block('blk_$idx', x, y, z, course, minStage));
          idx++;
        }
      }
      for (var bz = 1; bz < (d.buildingDepth / d.blockLength).ceil() - 1; bz++) {
        final z = bz * d.blockLength;
        for (final x in [0.0, d.buildingWidth - d.blockWidth]) {
          e.add(_block('blk_$idx', x, y, z, course, minStage));
          idx++;
        }
      }
    }
    e.add(
      BimEntity(
        id: 'block_lock_demo',
        label: 'Interlock Detail',
        mesh: BimMesh.box(width: d.blockLength * 0.25, height: d.blockHeight * 0.35, depth: d.blockWidth * 0.4),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.masonry,
        position: BimVec3(d.buildingWidth + 0.6, baseY + d.blockHeight / 2, 0.5),
        explodeGroup: 2,
        minStage: 6,
      ),
    );
  }

  BimEntity _block(
    String id,
    double x,
    double y,
    double z,
    int course,
    int minStage,
  ) {
    final d = AdvancedInterlockingDimensions;
    return BimEntity(
      id: id,
      label: 'Interlocking Block',
      mesh: BimMesh.box(
        width: d.blockLength * 0.92,
        height: d.blockHeight,
        depth: d.blockWidth,
      ),
      color: Color.lerp(
        const Color(0xFFD97706),
        const Color(0xFF92400E),
        (course % 4) / 4,
      )!,
      category: BimEntityCategory.masonry,
      position: BimVec3(x, y, z),
      explodeGroup: 2,
      minStage: minStage,
      pickable: id == 'blk_0',
      componentId: 'interlocking_block',
    );
  }

  void _verticalBars(List<BimEntity> e, AdvancedInterlockingDimensions d) {
    final baseY = d.wallBaseY;
    var i = 0;
    for (final c in _corners(d)) {
      e.add(
        BimEntity(
          id: 'vbar_$i',
          label: 'Vertical Bar',
          mesh: BimMesh.cylinder(radius: d.rebarRadius, height: d.wallHeight),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(c.$1, baseY, c.$2),
          explodeGroup: 2,
          minStage: 7,
          pickable: i == 0,
          componentId: 'vertical_reinforcement',
        ),
      );
      i++;
    }
    for (var j = 0; j < 3; j++) {
      e.add(
        BimEntity(
          id: 'vbar_mid_$j',
          label: 'Vertical Bar',
          mesh: BimMesh.cylinder(radius: d.rebarRadius, height: d.wallHeight * 0.95),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(d.buildingWidth * (j + 1) / 4, baseY, d.buildingDepth / 2),
          minStage: 7,
        ),
      );
    }
  }

  void _groutCells(List<BimEntity> e, AdvancedInterlockingDimensions d) {
    final baseY = d.wallBaseY;
    for (var i = 0; i < 4; i++) {
      final c = _corners(d)[i];
      e.add(
        BimEntity(
          id: 'grout_cell_$i',
          label: 'Grouted Core',
          mesh: BimMesh.cylinder(
            radius: d.coreDiameter / 2,
            height: d.wallHeight * 0.92,
            segments: 10,
          ),
          color: const Color(0xFF9CA3AF),
          category: BimEntityCategory.concrete,
          position: BimVec3(c.$1, baseY + d.wallHeight * 0.46, c.$2),
          explodeGroup: 2,
          minStage: 9,
          pickable: i == 0,
          componentId: 'grouted_core',
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'grout_pour_hint',
        label: 'Grout Pour',
        mesh: BimMesh.box(width: 0.15, height: d.wallHeight, depth: 0.15),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.concrete,
        position: BimVec3(d.centerX, baseY + d.wallHeight / 2, 0.1),
        minStage: 9,
        opacity: 0.7,
      ),
    );
  }

  void _bands(List<BimEntity> e, AdvancedInterlockingDimensions d) {
    final lintelY = d.wallBaseY + d.wallHeight - d.bandHeight / 2;
    e.add(
      BimEntity(
        id: 'lintel_rebar',
        label: 'Lintel Rebar',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.2,
          height: d.bandHeight * 0.6,
          depth: d.buildingDepth + 0.2,
          center: BimVec3(d.centerX, lintelY, d.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 11,
        opacity: 0.85,
      ),
    );
    e.add(
      BimEntity(
        id: 'lintel_band',
        label: 'Lintel Band',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.wallThickness,
          height: d.bandHeight,
          depth: d.buildingDepth + d.wallThickness,
          center: BimVec3(d.centerX, lintelY, d.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 3,
        minStage: 11,
        pickable: true,
        componentId: 'lintel_band',
      ),
    );
    final roofBandY = d.wallBaseY + d.wallHeight + d.bandHeight * 0.5;
    e.add(
      BimEntity(
        id: 'roof_band',
        label: 'Roof Band',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.wallThickness * 1.2,
          height: d.bandHeight,
          depth: d.buildingDepth + d.wallThickness * 1.2,
          center: BimVec3(d.centerX, roofBandY, d.centerZ),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 3,
        minStage: 12,
        pickable: true,
        componentId: 'roof_band',
      ),
    );
  }

  void _roof(List<BimEntity> e, AdvancedInterlockingDimensions d) {
    final slabY = d.wallBaseY + d.wallHeight + d.bandHeight * 1.2;
    e.add(
      BimEntity(
        id: 'roof_shuttering',
        label: 'Roof Formwork',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.3,
          height: 0.04,
          depth: d.buildingDepth + 0.3,
          center: BimVec3(d.centerX, slabY, d.centerZ),
        ),
        color: const Color(0xFFDEB887),
        category: BimEntityCategory.formwork,
        minStage: 13,
      ),
    );
    for (var i = 0; i < 6; i++) {
      e.add(
        BimEntity(
          id: 'slab_rebar_$i',
          label: 'Slab Rebar',
          mesh: BimMesh.cylinder(radius: d.rebarRadius, height: d.buildingWidth),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(0, slabY + 0.03, i * (d.buildingDepth / 5)),
          explodeGroup: 3,
          minStage: 13,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'roof_concrete',
        label: 'RCC Roof Slab',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.3,
          height: d.slabThickness,
          depth: d.buildingDepth + 0.3,
          center: BimVec3(d.centerX, slabY + d.slabThickness / 2 + 0.04, d.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 3,
        minStage: 13,
      ),
    );
  }

  void _openingsAndFinish(List<BimEntity> e, AdvancedInterlockingDimensions d) {
    e.add(
      BimEntity(
        id: 'door_frame',
        label: 'Door Frame',
        mesh: BimMesh.box(width: 1.0, height: 2.1, depth: 0.08),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.finishing,
        position: BimVec3(d.centerX - 0.5, d.wallBaseY, 0),
        explodeGroup: 4,
        minStage: 10,
      ),
    );
    e.add(
      BimEntity(
        id: 'window_frame',
        label: 'Window Frame',
        mesh: BimMesh.box(width: 1.2, height: 1.0, depth: 0.06),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.finishing,
        position: BimVec3(d.buildingWidth - 0.1, d.wallBaseY + 1.2, d.centerZ - 0.6),
        explodeGroup: 4,
        minStage: 10,
      ),
    );
    e.add(
      BimEntity(
        id: 'waterproofing',
        label: 'Waterproofing',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.5,
          height: 0.015,
          depth: d.buildingDepth + 0.5,
          center: BimVec3(
            d.centerX,
            d.wallBaseY + d.wallHeight + d.bandHeight * 1.2 + d.slabThickness + 0.02,
            d.centerZ,
          ),
        ),
        color: const Color(0xFF0F172A),
        category: BimEntityCategory.finishing,
        minStage: 14,
      ),
    );
    e.add(
      BimEntity(
        id: 'landscape',
        label: 'Landscape',
        mesh: BimMesh.box(
          width: d.plotWidth,
          height: 0.08,
          depth: 1.5,
          center: BimVec3(d.centerX, 0.04, d.plotDepth - 0.75),
        ),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.finishing,
        minStage: 15,
      ),
    );
  }

  void _comparisons(List<BimEntity> e, AdvancedInterlockingDimensions d) {
    e.add(
      BimEntity(
        id: 'conventional_masonry_ghost',
        label: 'Conventional Masonry (fails)',
        mesh: BimMesh.box(
          width: d.buildingWidth * 0.85,
          height: d.wallHeight,
          depth: d.wallThickness,
          center: BimVec3(d.buildingWidth + 1.8, d.wallBaseY + d.wallHeight / 2, d.centerZ),
        ),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.masonry,
        minStage: 15,
        opacity: 0.35,
      ),
    );
    e.add(
      BimEntity(
        id: 'wall_separation_hint',
        label: 'Wall Separation',
        mesh: BimMesh.box(width: 0.06, height: d.wallHeight * 0.6, depth: 0.06),
        color: const Color(0xFFEF4444),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.buildingWidth + 1.4, d.wallBaseY + d.wallHeight * 0.5, d.centerZ),
        minStage: 15,
        opacity: 0.5,
      ),
    );
  }

  List<(double, double)> _corners(AdvancedInterlockingDimensions d) => [
        (0.12, 0.12),
        (d.buildingWidth - 0.12, 0.12),
        (d.buildingWidth - 0.12, d.buildingDepth - 0.12),
        (0.12, d.buildingDepth - 0.12),
      ];
}
