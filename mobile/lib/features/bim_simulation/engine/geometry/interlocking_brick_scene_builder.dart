import 'dart:math' as math;
import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'house_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene for Model 01 — Interlocking Brick Masonry (single-storey).
class InterlockingBrickSceneBuilder {
  List<BimEntity> build() {
    final entities = <BimEntity>[];
        // --- Site & terrain ---
    entities.add(
      BimEntity(
        id: 'terrain',
        label: 'Terrain',
        mesh: BimMesh.box(
          width: HouseDimensions.plotWidth,
          height: 0.15,
          depth: HouseDimensions.plotDepth,
          center: BimVec3(HouseDimensions.plotWidth / 2, -0.075, HouseDimensions.plotDepth / 2),
        ),
        color: const Color(0xFF8B7355),
        category: BimEntityCategory.terrain,
        minStage: 0,
      ),
    );

    entities.add(
      BimEntity(
        id: 'boundary',
        label: 'Property Boundary',
        mesh: BimMesh.box(
          width: HouseDimensions.plotWidth,
          height: 0.02,
          depth: 0.05,
          center: BimVec3(HouseDimensions.plotWidth / 2, 0.02, 0.025),
        ),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.survey,
        minStage: 0,
      ),
    );

    // Footprint outline (4 edges)
    _addFootprintEdges(entities);

    // North arrow
    entities.add(
      BimEntity(
        id: 'north_arrow',
        label: 'North',
        mesh: BimMesh.box(width: 0.15, height: 0.02, depth: 1.2),
        color: const Color(0xFFEF4444),
        category: BimEntityCategory.annotation,
        position: BimVec3(HouseDimensions.plotWidth - 1.2, 0.05, HouseDimensions.plotDepth - 1.5),
        minStage: 0,
      ),
    );

    // Grid lines on ground
    for (var i = 0; i <= 6; i++) {
      final x = i * (HouseDimensions.buildingWidth / 6);
      entities.add(
        BimEntity(
          id: 'grid_x_$i',
          label: 'Grid',
          mesh: BimMesh.box(width: 0.02, height: 0.01, depth: HouseDimensions.buildingDepth + 1),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(x, 0.03, -0.5),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    for (var i = 0; i <= 4; i++) {
      final z = i * (HouseDimensions.buildingDepth / 4);
      entities.add(
        BimEntity(
          id: 'grid_z_$i',
          label: 'Grid',
          mesh: BimMesh.box(width: HouseDimensions.buildingWidth + 1, height: 0.01, depth: 0.02),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(-0.5, 0.03, z),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }

    // Survey stakes
    for (final corner in _buildingCorners()) {
      entities.add(
        BimEntity(
          id: 'stake_${corner.$1}_${corner.$2}',
          label: 'Survey Stake',
          mesh: BimMesh.cylinder(radius: 0.03, height: 1.2, segments: 8),
          color: const Color(0xFFF97316),
          category: BimEntityCategory.survey,
          position: BimVec3(corner.$1, 0, corner.$2),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }

    // Excavation trenches (4 sides)
    _addTrenches(entities);

    // Soil layer indicator (cross-section)
    entities.add(
      BimEntity(
        id: 'bearing_layer',
        label: 'Bearing Stratum',
        mesh: BimMesh.box(
          width: HouseDimensions.buildingWidth + 2,
          height: 0.25,
          depth: HouseDimensions.buildingDepth + 2,
          center: BimVec3(HouseDimensions.centerX, -HouseDimensions.trenchDepth + 0.12, HouseDimensions.centerZ),
        ),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.excavation,
        minStage: 2,
        opacity: 0.85,
      ),
    );

    // PCC strips in trench
    _addPccStrips(entities);

    // Strip footings
    _addStripFootings(entities);

    // Foundation masonry courses
    _addFoundationMasonry(entities);

    // Plinth beam — formwork, rebar cage, concrete
    _addPlinthBeamSystem(entities);

    // Vertical reinforcement at corners and openings
    _addVerticalRebars(entities);

    // Interlocking wall blocks
    _addInterlockingWalls(entities);

    // Lintel band
    entities.add(
      BimEntity(
        id: 'lintel_band',
        label: 'Lintel Band',
        mesh: BimMesh.box(
          width: HouseDimensions.buildingWidth + HouseDimensions.wallThickness,
          height: HouseDimensions.bandHeight,
          depth: HouseDimensions.buildingDepth + HouseDimensions.wallThickness,
          center: BimVec3(HouseDimensions.centerX, HouseDimensions.wallHeight + HouseDimensions.bandHeight / 2, HouseDimensions.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 2,
        minStage: 8,
        pickable: true,
        componentId: 'lintel_band',
        buildProgress: 0,
      ),
    );

    // Roof band
    entities.add(
      BimEntity(
        id: 'roof_band',
        label: 'Roof Band',
        mesh: BimMesh.box(
          width: HouseDimensions.buildingWidth + HouseDimensions.wallThickness * 1.2,
          height: HouseDimensions.bandHeight,
          depth: HouseDimensions.buildingDepth + HouseDimensions.wallThickness * 1.2,
          center: BimVec3(
            HouseDimensions.centerX,
            HouseDimensions.wallHeight + HouseDimensions.bandHeight * 1.8,
            HouseDimensions.centerZ,
          ),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 3,
        minStage: 9,
        pickable: true,
        componentId: 'roof_band',
        buildProgress: 0,
      ),
    );

    // Roof slab — shuttering, rebar, concrete
    _addRoofSlabSystem(entities);

    // Doors & windows (finishing)
    _addOpenings(entities);

    // Excavator (equipment) — simplified
    entities.add(
      BimEntity(
        id: 'excavator',
        label: 'Excavator',
        mesh: BimMesh.box(width: 1.8, height: 1.2, depth: 2.5),
        color: const Color(0xFFFBBF24),
        category: BimEntityCategory.equipment,
        position: BimVec3(-1.5, 0.1, HouseDimensions.buildingDepth + 1),
        minStage: 2,
        buildProgress: 0,
      ),
    );

    return entities;
  }

  void _addFootprintEdges(List<BimEntity> entities) {
    final y = 0.04;
    final h = 0.04;
    final edges = [
      (0.0, 0.0, HouseDimensions.buildingWidth, 0.0),
      (HouseDimensions.buildingWidth, 0.0, HouseDimensions.buildingWidth, HouseDimensions.buildingDepth),
      (HouseDimensions.buildingWidth, HouseDimensions.buildingDepth, 0.0, HouseDimensions.buildingDepth),
      (0.0, HouseDimensions.buildingDepth, 0.0, 0.0),
    ];
    var i = 0;
    for (final e in edges) {
      final len = _dist(e.$1, e.$2, e.$3, e.$4);
      entities.add(
        BimEntity(
          id: 'footprint_$i',
          label: 'Building Footprint',
          mesh: BimMesh.box(width: len, height: h, depth: 0.08),
          color: const Color(0xFF0F172A),
          category: BimEntityCategory.annotation,
          position: BimVec3(
            (e.$1 + e.$3) / 2 - len / 2,
            y,
            (e.$2 + e.$4) / 2,
          ),
          minStage: 0,
        ),
      );
      i++;
    }
  }

  void _addTrenches(List<BimEntity> entities) {
    final yBase = -HouseDimensions.trenchDepth / 2;
    final specs = [
      (HouseDimensions.centerX, yBase, 0.0, HouseDimensions.buildingWidth + HouseDimensions.trenchWidth * 2, HouseDimensions.trenchDepth, HouseDimensions.trenchWidth),
      (HouseDimensions.centerX, yBase, HouseDimensions.buildingDepth, HouseDimensions.buildingWidth + HouseDimensions.trenchWidth * 2, HouseDimensions.trenchDepth, HouseDimensions.trenchWidth),
      (0.0, yBase, HouseDimensions.centerZ, HouseDimensions.trenchWidth, HouseDimensions.trenchDepth, HouseDimensions.buildingDepth),
      (HouseDimensions.buildingWidth, yBase, HouseDimensions.centerZ, HouseDimensions.trenchWidth, HouseDimensions.trenchDepth, HouseDimensions.buildingDepth),
    ];
    for (var i = 0; i < specs.length; i++) {
      final s = specs[i];
      entities.add(
        BimEntity(
          id: 'trench_$i',
          label: 'Excavation Trench',
          mesh: BimMesh.box(width: s.$4, height: s.$5, depth: s.$6),
          color: const Color(0xFFA16207),
          category: BimEntityCategory.excavation,
          position: BimVec3(s.$1 - s.$4 / 2, s.$2, s.$3 - s.$6 / 2),
          explodeGroup: 1,
          minStage: 2,
          buildProgress: 0,
        ),
      );
    }
  }

  void _addPccStrips(List<BimEntity> entities) {
    final y = -HouseDimensions.trenchDepth + HouseDimensions.pccThickness / 2;
    for (var i = 0; i < 4; i++) {
      entities.add(
        BimEntity(
          id: 'pcc_$i',
          label: 'PCC Layer',
          mesh: BimMesh.box(
            width: i < 2 ? HouseDimensions.buildingWidth + 0.4 : HouseDimensions.trenchWidth,
            height: HouseDimensions.pccThickness,
            depth: i < 2 ? HouseDimensions.trenchWidth : HouseDimensions.buildingDepth + 0.2,
          ),
          color: const Color(0xFFD1D5DB),
          category: BimEntityCategory.concrete,
          position: BimVec3(HouseDimensions.centerX, y, HouseDimensions.centerZ),
          explodeGroup: 1,
          minStage: 3,
          pickable: true,
          componentId: 'foundation',
          buildProgress: 0,
        ),
      );
    }
  }

  void _addStripFootings(List<BimEntity> entities) {
    final y = -HouseDimensions.trenchDepth + HouseDimensions.pccThickness + HouseDimensions.footingDepth / 2;
    entities.add(
      BimEntity(
        id: 'footing_perimeter',
        label: 'Strip Footing',
        mesh: BimMesh.box(
          width: HouseDimensions.buildingWidth + HouseDimensions.footingWidth,
          height: HouseDimensions.footingDepth,
          depth: HouseDimensions.buildingDepth + HouseDimensions.footingWidth,
          center: BimVec3(HouseDimensions.centerX, y, HouseDimensions.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 4,
        pickable: true,
        componentId: 'foundation',
        buildProgress: 0,
      ),
    );
  }

  void _addFoundationMasonry(List<BimEntity> entities) {
    for (var course = 0; course < 3; course++) {
      entities.add(
        BimEntity(
          id: 'found_course_$course',
          label: 'Foundation Masonry',
          mesh: BimMesh.box(
            width: HouseDimensions.buildingWidth + HouseDimensions.wallThickness,
            height: HouseDimensions.blockHeight,
            depth: HouseDimensions.buildingDepth + HouseDimensions.wallThickness,
            center: BimVec3(
              HouseDimensions.centerX,
              -HouseDimensions.trenchDepth + HouseDimensions.pccThickness + HouseDimensions.footingDepth + HouseDimensions.blockHeight * (course + 0.5),
              HouseDimensions.centerZ,
            ),
          ),
          color: const Color(0xFFB45309),
          category: BimEntityCategory.masonry,
          explodeGroup: 1,
          minStage: 4,
          componentId: 'foundation',
          buildProgress: 0,
        ),
      );
    }
  }

  void _addPlinthBeamSystem(List<BimEntity> entities) {
    final baseY = -HouseDimensions.trenchDepth + HouseDimensions.pccThickness + HouseDimensions.footingDepth + HouseDimensions.blockHeight * 3;
    entities.add(
      BimEntity(
        id: 'plinth_formwork',
        label: 'Plinth Formwork',
        mesh: BimMesh.box(
          width: HouseDimensions.buildingWidth + 0.5,
          height: HouseDimensions.plinthBeam + 0.1,
          depth: HouseDimensions.buildingDepth + 0.5,
          center: BimVec3(HouseDimensions.centerX, baseY + HouseDimensions.plinthBeam / 2, HouseDimensions.centerZ),
        ),
        color: const Color(0xFFDEB887),
        category: BimEntityCategory.formwork,
        minStage: 5,
        buildProgress: 0,
      ),
    );
    // Stirrups + longitudinal bars (simplified cage)
    for (var i = 0; i < 12; i++) {
      final t = i / 11;
      entities.add(
        BimEntity(
          id: 'plinth_rebar_$i',
          label: 'Plinth Reinforcement',
          mesh: BimMesh.cylinder(radius: HouseDimensions.rebarRadius, height: HouseDimensions.plinthBeam * 0.8),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(
            0.3 + t * (HouseDimensions.buildingWidth - 0.6),
            baseY + HouseDimensions.plinthBeam * 0.1,
            0.15,
          ),
          explodeGroup: 2,
          minStage: 5,
          pickable: i == 0,
          componentId: 'plinth_beam',
          buildProgress: 0,
        ),
      );
    }
    entities.add(
      BimEntity(
        id: 'plinth_concrete',
        label: 'Plinth Beam Concrete',
        mesh: BimMesh.box(
          width: HouseDimensions.buildingWidth + HouseDimensions.wallThickness * 0.5,
          height: HouseDimensions.plinthBeam,
          depth: HouseDimensions.buildingDepth + HouseDimensions.wallThickness * 0.5,
          center: BimVec3(HouseDimensions.centerX, baseY + HouseDimensions.plinthBeam / 2, HouseDimensions.centerZ),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 2,
        minStage: 5,
        pickable: true,
        componentId: 'plinth_beam',
        buildProgress: 0,
      ),
    );
  }

  void _addVerticalRebars(List<BimEntity> entities) {
    final baseY = -HouseDimensions.trenchDepth +
        HouseDimensions.pccThickness +
        HouseDimensions.footingDepth +
        HouseDimensions.blockHeight * 3 +
        HouseDimensions.plinthBeam;
    final corners = _buildingCorners();
    var i = 0;
    for (final c in corners) {
      entities.add(
        BimEntity(
          id: 'vbar_$i',
          label: 'Vertical Bar 12mm',
          mesh: BimMesh.cylinder(radius: HouseDimensions.rebarRadius, height: HouseDimensions.wallHeight),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(c.$1, baseY, c.$2),
          explodeGroup: 2,
          minStage: 6,
          pickable: i == 0,
          componentId: 'vertical_reinforcement',
          buildProgress: 0,
        ),
      );
      i++;
    }
    // Mid-wall bars
    for (var j = 0; j < 4; j++) {
      entities.add(
        BimEntity(
          id: 'vbar_mid_$j',
          label: 'Vertical Bar',
          mesh: BimMesh.cylinder(radius: HouseDimensions.rebarRadius, height: HouseDimensions.wallHeight * 0.95),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(HouseDimensions.buildingWidth * (j + 1) / 5, baseY, HouseDimensions.buildingDepth / 2),
          minStage: 6,
          buildProgress: 0,
        ),
      );
    }
  }

  void _addInterlockingWalls(List<BimEntity> entities) {
    final courses = 12;
    final baseY = -HouseDimensions.trenchDepth +
        HouseDimensions.pccThickness +
        HouseDimensions.footingDepth +
        HouseDimensions.blockHeight * 3 +
        HouseDimensions.plinthBeam;

    var blockIndex = 0;
    for (var course = 0; course < courses; course++) {
      final y = baseY + course * HouseDimensions.blockHeight;
      // Front & back walls
      for (var bx = 0; bx < (HouseDimensions.buildingWidth / HouseDimensions.blockLength).ceil(); bx++) {
        final x = bx * HouseDimensions.blockLength + HouseDimensions.blockLength / 2;
        for (final z in [0.0, HouseDimensions.buildingDepth - HouseDimensions.blockWidth]) {
          entities.add(_interlockBlock(
            'blk_${blockIndex++}',
            x,
            y,
            z,
            course,
          ));
        }
      }
      // Side walls
      for (var bz = 1; bz < (HouseDimensions.buildingDepth / HouseDimensions.blockLength).ceil() - 1; bz++) {
        final z = bz * HouseDimensions.blockLength;
        for (final x in [0.0, HouseDimensions.buildingWidth - HouseDimensions.blockWidth]) {
          entities.add(_interlockBlock(
            'blk_${blockIndex++}',
            x,
            y,
            z,
            course,
          ));
        }
      }
    }
  }

  BimEntity _interlockBlock(String id, double x, double y, double z, int course) {
        // Interlock notch simulated with primary block + key nub
    return BimEntity(
      id: id,
      label: 'Interlocking Block',
      mesh: BimMesh.box(
        width: HouseDimensions.blockLength * 0.92,
        height: HouseDimensions.blockHeight,
        depth: HouseDimensions.blockWidth,
      ),
      color: Color.lerp(
        const Color(0xFFB45309),
        const Color(0xFF92400E),
        (course % 3) / 3,
      )!,
      category: BimEntityCategory.masonry,
      position: BimVec3(x, y, z),
      explodeGroup: 2,
      minStage: 7,
      pickable: id.endsWith('0'),
      componentId: 'interlocking_brick',
      buildProgress: 0,
    );
  }

  void _addRoofSlabSystem(List<BimEntity> entities) {
    final slabY = HouseDimensions.wallHeight + HouseDimensions.bandHeight * 2.5;
    entities.add(
      BimEntity(
        id: 'roof_shuttering',
        label: 'Roof Shuttering',
        mesh: BimMesh.box(
          width: HouseDimensions.buildingWidth + 0.3,
          height: 0.04,
          depth: HouseDimensions.buildingDepth + 0.3,
          center: BimVec3(HouseDimensions.centerX, slabY, HouseDimensions.centerZ),
        ),
        color: const Color(0xFFDEB887),
        category: BimEntityCategory.formwork,
        minStage: 10,
        buildProgress: 0,
      ),
    );
    // Bottom rebar grid
    for (var i = 0; i < 8; i++) {
      entities.add(
        BimEntity(
          id: 'slab_rebar_x_$i',
          label: 'Slab Reinforcement',
          mesh: BimMesh.cylinder(radius: HouseDimensions.rebarRadius, height: HouseDimensions.buildingWidth),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(0, slabY + 0.03, i * (HouseDimensions.buildingDepth / 7)),
          explodeGroup: 3,
          minStage: 10,
          pickable: i == 0,
          componentId: 'roof_slab',
          buildProgress: 0,
        ),
      );
    }
    entities.add(
      BimEntity(
        id: 'roof_concrete',
        label: 'RCC Roof Slab',
        mesh: BimMesh.box(
          width: HouseDimensions.buildingWidth + 0.3,
          height: HouseDimensions.slabThickness,
          depth: HouseDimensions.buildingDepth + 0.3,
          center: BimVec3(HouseDimensions.centerX, slabY + HouseDimensions.slabThickness / 2 + 0.04, HouseDimensions.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 3,
        minStage: 10,
        pickable: true,
        componentId: 'roof_slab',
        buildProgress: 0,
      ),
    );
  }

  void _addOpenings(List<BimEntity> entities) {
    entities.add(
      BimEntity(
        id: 'door',
        label: 'Door',
        mesh: BimMesh.box(width: 1.0, height: 2.1, depth: 0.08),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.finishing,
        position: BimVec3(HouseDimensions.centerX - 0.5, 0, 0),
        explodeGroup: 4,
        minStage: 11,
        buildProgress: 0,
      ),
    );
    entities.add(
      BimEntity(
        id: 'window_1',
        label: 'Window',
        mesh: BimMesh.box(width: 1.2, height: 1.0, depth: 0.06),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.finishing,
        position: BimVec3(HouseDimensions.buildingWidth - 0.1, 1.2, HouseDimensions.centerZ - 0.6),
        explodeGroup: 4,
        minStage: 11,
        buildProgress: 0,
      ),
    );
    // Landscape strip
    entities.add(
      BimEntity(
        id: 'landscape',
        label: 'Landscape',
        mesh: BimMesh.box(
          width: HouseDimensions.plotWidth,
          height: 0.08,
          depth: 1.5,
          center: BimVec3(HouseDimensions.plotWidth / 2, 0.04, HouseDimensions.plotDepth - 0.75),
        ),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.finishing,
        minStage: 11,
        buildProgress: 0,
      ),
    );
  }

  List<(double, double)> _buildingCorners() => [
        (0.12, 0.12),
        (HouseDimensions.buildingWidth - 0.12, 0.12),
        (HouseDimensions.buildingWidth - 0.12, HouseDimensions.buildingDepth - 0.12),
        (0.12, HouseDimensions.buildingDepth - 0.12),
      ];

  double _dist(double x1, double z1, double x2, double z2) {
    final dx = x2 - x1;
    final dz = z2 - z1;
    return math.sqrt(dx * dx + dz * dz);
  }
}
