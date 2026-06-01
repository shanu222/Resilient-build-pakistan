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
    final d = HouseDimensions;

    // --- Site & terrain ---
    entities.add(
      BimEntity(
        id: 'terrain',
        label: 'Terrain',
        mesh: BimMesh.box(
          width: d.plotWidth,
          height: 0.15,
          depth: d.plotDepth,
          center: BimVec3(d.plotWidth / 2, -0.075, d.plotDepth / 2),
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
          width: d.plotWidth,
          height: 0.02,
          depth: 0.05,
          center: BimVec3(d.plotWidth / 2, 0.02, 0.025),
        ),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.survey,
        minStage: 0,
      ),
    );

    // Footprint outline (4 edges)
    _addFootprintEdges(entities, d);

    // North arrow
    entities.add(
      BimEntity(
        id: 'north_arrow',
        label: 'North',
        mesh: BimMesh.box(width: 0.15, height: 0.02, depth: 1.2),
        color: const Color(0xFFEF4444),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.plotWidth - 1.2, 0.05, d.plotDepth - 1.5),
        minStage: 0,
      ),
    );

    // Grid lines on ground
    for (var i = 0; i <= 6; i++) {
      final x = i * (d.buildingWidth / 6);
      entities.add(
        BimEntity(
          id: 'grid_x_$i',
          label: 'Grid',
          mesh: BimMesh.box(width: 0.02, height: 0.01, depth: d.buildingDepth + 1),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(x, 0.03, -0.5),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    for (var i = 0; i <= 4; i++) {
      final z = i * (d.buildingDepth / 4);
      entities.add(
        BimEntity(
          id: 'grid_z_$i',
          label: 'Grid',
          mesh: BimMesh.box(width: d.buildingWidth + 1, height: 0.01, depth: 0.02),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(-0.5, 0.03, z),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }

    // Survey stakes
    for (final corner in _buildingCorners(d)) {
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
    _addTrenches(entities, d);

    // Soil layer indicator (cross-section)
    entities.add(
      BimEntity(
        id: 'bearing_layer',
        label: 'Bearing Stratum',
        mesh: BimMesh.box(
          width: d.buildingWidth + 2,
          height: 0.25,
          depth: d.buildingDepth + 2,
          center: BimVec3(d.centerX, -d.trenchDepth + 0.12, d.centerZ),
        ),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.excavation,
        minStage: 2,
        opacity: 0.85,
      ),
    );

    // PCC strips in trench
    _addPccStrips(entities, d);

    // Strip footings
    _addStripFootings(entities, d);

    // Foundation masonry courses
    _addFoundationMasonry(entities, d);

    // Plinth beam — formwork, rebar cage, concrete
    _addPlinthBeamSystem(entities, d);

    // Vertical reinforcement at corners and openings
    _addVerticalRebars(entities, d);

    // Interlocking wall blocks
    _addInterlockingWalls(entities, d);

    // Lintel band
    entities.add(
      BimEntity(
        id: 'lintel_band',
        label: 'Lintel Band',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.wallThickness,
          height: d.bandHeight,
          depth: d.buildingDepth + d.wallThickness,
          center: BimVec3(d.centerX, d.wallHeight + d.bandHeight / 2, d.centerZ),
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
          width: d.buildingWidth + d.wallThickness * 1.2,
          height: d.bandHeight,
          depth: d.buildingDepth + d.wallThickness * 1.2,
          center: BimVec3(
            d.centerX,
            d.wallHeight + d.bandHeight * 1.8,
            d.centerZ,
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
    _addRoofSlabSystem(entities, d);

    // Doors & windows (finishing)
    _addOpenings(entities, d);

    // Excavator (equipment) — simplified
    entities.add(
      BimEntity(
        id: 'excavator',
        label: 'Excavator',
        mesh: BimMesh.box(width: 1.8, height: 1.2, depth: 2.5),
        color: const Color(0xFFFBBF24),
        category: BimEntityCategory.equipment,
        position: BimVec3(-1.5, 0.1, d.buildingDepth + 1),
        minStage: 2,
        buildProgress: 0,
      ),
    );

    return entities;
  }

  void _addFootprintEdges(List<BimEntity> entities, HouseDimensions d) {
    final y = 0.04;
    final h = 0.04;
    final edges = [
      (0.0, 0.0, d.buildingWidth, 0.0),
      (d.buildingWidth, 0.0, d.buildingWidth, d.buildingDepth),
      (d.buildingWidth, d.buildingDepth, 0.0, d.buildingDepth),
      (0.0, d.buildingDepth, 0.0, 0.0),
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

  void _addTrenches(List<BimEntity> entities, HouseDimensions d) {
    final yBase = -d.trenchDepth / 2;
    final specs = [
      (d.centerX, yBase, 0.0, d.buildingWidth + d.trenchWidth * 2, d.trenchDepth, d.trenchWidth),
      (d.centerX, yBase, d.buildingDepth, d.buildingWidth + d.trenchWidth * 2, d.trenchDepth, d.trenchWidth),
      (0.0, yBase, d.centerZ, d.trenchWidth, d.trenchDepth, d.buildingDepth),
      (d.buildingWidth, yBase, d.centerZ, d.trenchWidth, d.trenchDepth, d.buildingDepth),
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

  void _addPccStrips(List<BimEntity> entities, HouseDimensions d) {
    final y = -d.trenchDepth + d.pccThickness / 2;
    for (var i = 0; i < 4; i++) {
      entities.add(
        BimEntity(
          id: 'pcc_$i',
          label: 'PCC Layer',
          mesh: BimMesh.box(
            width: i < 2 ? d.buildingWidth + 0.4 : d.trenchWidth,
            height: d.pccThickness,
            depth: i < 2 ? d.trenchWidth : d.buildingDepth + 0.2,
          ),
          color: const Color(0xFFD1D5DB),
          category: BimEntityCategory.concrete,
          position: BimVec3(d.centerX, y, d.centerZ),
          explodeGroup: 1,
          minStage: 3,
          pickable: true,
          componentId: 'foundation',
          buildProgress: 0,
        ),
      );
    }
  }

  void _addStripFootings(List<BimEntity> entities, HouseDimensions d) {
    final y = -d.trenchDepth + d.pccThickness + d.footingDepth / 2;
    entities.add(
      BimEntity(
        id: 'footing_perimeter',
        label: 'Strip Footing',
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
        pickable: true,
        componentId: 'foundation',
        buildProgress: 0,
      ),
    );
  }

  void _addFoundationMasonry(List<BimEntity> entities, HouseDimensions d) {
    for (var course = 0; course < 3; course++) {
      entities.add(
        BimEntity(
          id: 'found_course_$course',
          label: 'Foundation Masonry',
          mesh: BimMesh.box(
            width: d.buildingWidth + d.wallThickness,
            height: d.blockHeight,
            depth: d.buildingDepth + d.wallThickness,
            center: BimVec3(
              d.centerX,
              -d.trenchDepth + d.pccThickness + d.footingDepth + d.blockHeight * (course + 0.5),
              d.centerZ,
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

  void _addPlinthBeamSystem(List<BimEntity> entities, HouseDimensions d) {
    final baseY = -d.trenchDepth + d.pccThickness + d.footingDepth + d.blockHeight * 3;
    entities.add(
      BimEntity(
        id: 'plinth_formwork',
        label: 'Plinth Formwork',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.5,
          height: d.plinthBeam + 0.1,
          depth: d.buildingDepth + 0.5,
          center: BimVec3(d.centerX, baseY + d.plinthBeam / 2, d.centerZ),
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
          mesh: BimMesh.cylinder(radius: d.rebarRadius, height: d.plinthBeam * 0.8),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(
            0.3 + t * (d.buildingWidth - 0.6),
            baseY + d.plinthBeam * 0.1,
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
        componentId: 'plinth_beam',
        buildProgress: 0,
      ),
    );
  }

  void _addVerticalRebars(List<BimEntity> entities, HouseDimensions d) {
    final baseY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.blockHeight * 3 +
        d.plinthBeam;
    final corners = _buildingCorners(d);
    var i = 0;
    for (final c in corners) {
      entities.add(
        BimEntity(
          id: 'vbar_$i',
          label: 'Vertical Bar 12mm',
          mesh: BimMesh.cylinder(radius: d.rebarRadius, height: d.wallHeight),
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
          mesh: BimMesh.cylinder(radius: d.rebarRadius, height: d.wallHeight * 0.95),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(d.buildingWidth * (j + 1) / 5, baseY, d.buildingDepth / 2),
          minStage: 6,
          buildProgress: 0,
        ),
      );
    }
  }

  void _addInterlockingWalls(List<BimEntity> entities, HouseDimensions d) {
    final courses = 12;
    final baseY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.blockHeight * 3 +
        d.plinthBeam;

    var blockIndex = 0;
    for (var course = 0; course < courses; course++) {
      final y = baseY + course * d.blockHeight;
      // Front & back walls
      for (var bx = 0; bx < (d.buildingWidth / d.blockLength).ceil(); bx++) {
        final x = bx * d.blockLength + d.blockLength / 2;
        for (final z in [0.0, d.buildingDepth - d.blockWidth]) {
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
      for (var bz = 1; bz < (d.buildingDepth / d.blockLength).ceil() - 1; bz++) {
        final z = bz * d.blockLength;
        for (final x in [0.0, d.buildingWidth - d.blockWidth]) {
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
    final d = HouseDimensions;
    // Interlock notch simulated with primary block + key nub
    return BimEntity(
      id: id,
      label: 'Interlocking Block',
      mesh: BimMesh.box(
        width: d.blockLength * 0.92,
        height: d.blockHeight,
        depth: d.blockWidth,
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

  void _addRoofSlabSystem(List<BimEntity> entities, HouseDimensions d) {
    final slabY = d.wallHeight + d.bandHeight * 2.5;
    entities.add(
      BimEntity(
        id: 'roof_shuttering',
        label: 'Roof Shuttering',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.3,
          height: 0.04,
          depth: d.buildingDepth + 0.3,
          center: BimVec3(d.centerX, slabY, d.centerZ),
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
          mesh: BimMesh.cylinder(radius: d.rebarRadius, height: d.buildingWidth),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(0, slabY + 0.03, i * (d.buildingDepth / 7)),
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
          width: d.buildingWidth + 0.3,
          height: d.slabThickness,
          depth: d.buildingDepth + 0.3,
          center: BimVec3(d.centerX, slabY + d.slabThickness / 2 + 0.04, d.centerZ),
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

  void _addOpenings(List<BimEntity> entities, HouseDimensions d) {
    entities.add(
      BimEntity(
        id: 'door',
        label: 'Door',
        mesh: BimMesh.box(width: 1.0, height: 2.1, depth: 0.08),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.finishing,
        position: BimVec3(d.centerX - 0.5, 0, 0),
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
        position: BimVec3(d.buildingWidth - 0.1, 1.2, d.centerZ - 0.6),
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
          width: d.plotWidth,
          height: 0.08,
          depth: 1.5,
          center: BimVec3(d.plotWidth / 2, 0.04, d.plotDepth - 0.75),
        ),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.finishing,
        minStage: 11,
        buildProgress: 0,
      ),
    );
  }

  List<(double, double)> _buildingCorners(HouseDimensions d) => [
        (0.12, 0.12),
        (d.buildingWidth - 0.12, 0.12),
        (d.buildingWidth - 0.12, d.buildingDepth - 0.12),
        (0.12, d.buildingDepth - 0.12),
      ];

  double _dist(double x1, double z1, double x2, double z2) {
    final dx = x2 - x1;
    final dz = z2 - z1;
    return math.sqrt(dx * dx + dz * dz);
  }
}
