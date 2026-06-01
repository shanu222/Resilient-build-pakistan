import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'earthbag_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 02 Earthbag Masonry (mountain / seismic context).
class EarthbagSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
    final d = EarthbagDimensions;

    // Mountain terrain (sloped pad)
    e.add(
      BimEntity(
        id: 'mountain_terrain',
        label: 'Mountain Terrain',
        mesh: BimMesh.box(
          width: d.plotWidth,
          height: 0.4,
          depth: d.plotDepth,
          center: BimVec3(d.plotWidth / 2, -0.1, d.plotDepth / 2),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.terrain,
        minStage: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'building_platform',
        label: 'Safe Building Platform',
        mesh: BimMesh.box(
          width: d.buildingWidth + 1.2,
          height: 0.25,
          depth: d.buildingDepth + 1.2,
          center: BimVec3(d.centerX, 0.12, d.centerZ),
        ),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.terrain,
        minStage: 0,
        buildProgress: 0,
      ),
    );

    // Drainage flow annotations (viewport draws arrows in drainage mode)
    e.add(
      BimEntity(
        id: 'slope_indicator',
        label: 'Slope Direction',
        mesh: BimMesh.box(width: 0.1, height: 0.02, depth: 2.0),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.buildingWidth + 0.5, 0.2, d.centerZ),
        minStage: 0,
      ),
    );

    _footprint(e, d);
    _gridAndStakes(e, d);

    // Excavation trench
    e.add(
      BimEntity(
        id: 'excavation_trench',
        label: 'Foundation Trench',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.trenchWidth,
          height: d.trenchDepth,
          depth: d.buildingDepth + d.trenchWidth,
          center: BimVec3(
            d.centerX,
            -d.trenchDepth / 2 + 0.05,
            d.centerZ,
          ),
        ),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.excavation,
        explodeGroup: 1,
        minStage: 2,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'bearing_soil',
        label: 'Bearing Soil',
        mesh: BimMesh.box(
          width: d.buildingWidth + 1,
          height: 0.2,
          depth: d.buildingDepth + 1,
          center: BimVec3(d.centerX, -d.trenchDepth + 0.1, d.centerZ),
        ),
        color: const Color(0xFF57534E),
        category: BimEntityCategory.excavation,
        minStage: 2,
        opacity: 0.9,
        buildProgress: 0,
      ),
    );

    // Rubble trench + gravel + drainage
    for (var i = 0; i < 8; i++) {
      e.add(
        BimEntity(
          id: 'rubble_$i',
          label: 'Rubble Stone',
          mesh: BimMesh.box(
            width: 0.25 + (i % 3) * 0.08,
            height: 0.18,
            depth: 0.22,
          ),
          color: const Color(0xFF64748B),
          category: BimEntityCategory.masonry,
          position: BimVec3(
            0.5 + (i % 4) * 1.3,
            -d.trenchDepth + 0.1 + (i ~/ 4) * 0.08,
            0.3 + (i ~/ 2) * 0.9,
          ),
          explodeGroup: 1,
          minStage: 3,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'gravel_base',
        label: 'Compacted Gravel',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.4,
          height: d.gravelThickness,
          depth: d.buildingDepth + 0.4,
          center: BimVec3(
            d.centerX,
            -d.trenchDepth + d.rubbleDepth + d.gravelThickness / 2,
            d.centerZ,
          ),
        ),
        color: const Color(0xFFA8A29E),
        category: BimEntityCategory.masonry,
        explodeGroup: 1,
        minStage: 3,
        pickable: true,
        componentId: 'foundation',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'drainage_pipe',
        label: 'Drainage Layer',
        mesh: BimMesh.cylinder(radius: 0.05, height: d.buildingWidth),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.drainage,
        position: BimVec3(0.2, -d.trenchDepth + 0.15, d.centerZ),
        minStage: 3,
        buildProgress: 0,
      ),
    );

  final baseY = -d.trenchDepth + d.rubbleDepth + d.gravelThickness;

    // First course in trench
    _addBagCourse(e, d, course: 0, baseY: baseY, minStage: 4, idPrefix: 'first');

    // Barbed wire layers (between courses)
    for (var c = 1; c <= d.courses; c++) {
      final wireY = baseY + c * d.bagHeight;
      e.add(
        BimEntity(
          id: 'barbed_wire_$c',
          label: 'Barbed Wire Reinforcement',
          mesh: BimMesh.box(
            width: d.buildingWidth + d.wallThickness,
            height: 0.008,
            depth: d.buildingDepth + d.wallThickness,
            center: BimVec3(d.centerX, wireY, d.centerZ),
          ),
          color: const Color(0xFF525252),
          category: BimEntityCategory.wire,
          explodeGroup: 2,
          minStage: c == 1 ? 5 : 6,
          pickable: c == 1,
          componentId: 'barbed_wire',
          buildProgress: 0,
        ),
      );
    }

    // Wall courses 1..courses-1 (course 0 already first)
    for (var course = 1; course < d.courses; course++) {
      _addBagCourse(
        e,
        d,
        course: course,
        baseY: baseY,
        minStage: 6,
        idPrefix: 'wall',
      );
    }

    // Buttress
    e.add(
      BimEntity(
        id: 'buttress',
        label: 'Buttress Wall',
        mesh: BimMesh.box(
          width: d.buttressWidth,
          height: d.wallHeight * 0.85,
          depth: d.wallThickness,
        ),
        color: const Color(0xFFA16207),
        category: BimEntityCategory.earthbag,
        position: BimVec3(-0.15, baseY, d.buildingDepth - 0.1),
        explodeGroup: 2,
        minStage: 6,
        buildProgress: 0,
      ),
    );

    // Vertical reinforcement
    final wallTop = baseY + d.courses * d.bagHeight;
    for (var i = 0; i < 6; i++) {
      e.add(
        BimEntity(
          id: 'vbar_$i',
          label: 'Vertical Reinforcement',
          mesh: BimMesh.cylinder(radius: d.rebarRadius, height: d.wallHeight),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(
            0.4 + i * (d.buildingWidth - 0.8) / 5,
            baseY,
            i.isEven ? 0.15 : d.buildingDepth - 0.15,
          ),
          explodeGroup: 2,
          minStage: 7,
          pickable: i == 0,
          componentId: 'vertical_reinforcement',
          buildProgress: 0,
        ),
      );
    }

    // Door & window frames
    e.add(
      BimEntity(
        id: 'door_frame',
        label: 'Door Frame',
        mesh: BimMesh.box(width: 1.0, height: 2.1, depth: 0.12),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.timber,
        position: BimVec3(d.centerX - 0.5, baseY, 0),
        minStage: 8,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'window_frame',
        label: 'Window Frame',
        mesh: BimMesh.box(width: 1.1, height: 1.0, depth: 0.1),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.timber,
        position: BimVec3(d.buildingWidth - 0.15, baseY + 1.0, d.centerZ),
        minStage: 8,
        buildProgress: 0,
      ),
    );

    // Plinth band
    e.add(
      BimEntity(
        id: 'plinth_band',
        label: 'RC Plinth Band',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.wallThickness,
          height: d.plinthBandHeight,
          depth: d.buildingDepth + d.wallThickness,
          center: BimVec3(d.centerX, baseY + d.plinthBandHeight / 2, d.centerZ),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 2,
        minStage: 4,
        opacity: 0.95,
        buildProgress: 0,
      ),
    );

    // Lintel band
    e.add(
      BimEntity(
        id: 'lintel_band',
        label: 'RC Lintel Band',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.wallThickness * 1.1,
          height: d.bandHeight,
          depth: d.buildingDepth + d.wallThickness * 1.1,
          center: BimVec3(d.centerX, wallTop + d.bandHeight / 2, d.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 3,
        minStage: 9,
        pickable: true,
        componentId: 'lintel_band',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'lintel_rebar',
        label: 'Lintel Rebar Cage',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: d.bandHeight * 0.6,
          depth: d.buildingDepth,
          center: BimVec3(d.centerX, wallTop + d.bandHeight * 0.3, d.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 9,
        buildProgress: 0,
      ),
    );

    // Roof anchorage bolts
    for (var i = 0; i < 8; i++) {
      e.add(
        BimEntity(
          id: 'anchor_$i',
          label: 'Roof Anchor',
          mesh: BimMesh.cylinder(radius: 0.012, height: 0.25),
          color: const Color(0xFF475569),
          category: BimEntityCategory.rebar,
          position: BimVec3(
            0.5 + (i % 4) * 1.5,
            wallTop + d.bandHeight,
            i < 4 ? 0.3 : d.buildingDepth - 0.3,
          ),
          minStage: 10,
          pickable: i == 0,
          componentId: 'roof_anchorage',
          buildProgress: 0,
        ),
      );
    }

    // Timber roof trusses
    final roofY = wallTop + d.bandHeight + 0.1;
    for (var t = 0; t < 3; t++) {
      e.add(
        BimEntity(
          id: 'truss_$t',
          label: 'Timber Truss',
          mesh: BimMesh.box(width: 0.12, height: 1.4, depth: d.buildingDepth + 0.4),
          color: const Color(0xFF92400E),
          category: BimEntityCategory.timber,
          position: BimVec3(1.0 + t * 1.8, roofY + 0.7, -0.2),
          explodeGroup: 4,
          minStage: 11,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'roof_sheeting',
        label: 'Roof Sheeting',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.6,
          height: 0.04,
          depth: d.buildingDepth + 0.8,
          center: BimVec3(d.centerX, roofY + 1.45, d.centerZ),
        ),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.timber,
        explodeGroup: 4,
        minStage: 11,
        buildProgress: 0,
      ),
    );

    // Plaster / mesh / waterproof
    e.add(
      BimEntity(
        id: 'wire_mesh',
        label: 'Wire Mesh',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.wallThickness * 2,
          height: d.wallHeight,
          depth: d.buildingDepth + d.wallThickness * 2,
          center: BimVec3(d.centerX, baseY + d.wallHeight / 2, d.centerZ),
        ),
        color: const Color(0xFFD4D4D8),
        category: BimEntityCategory.finishing,
        minStage: 12,
        opacity: 0.45,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'exterior_plaster',
        label: 'Exterior Plaster',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.wallThickness * 2 + 0.04,
          height: d.wallHeight + 0.1,
          depth: d.buildingDepth + d.wallThickness * 2 + 0.04,
          center: BimVec3(d.centerX, baseY + d.wallHeight / 2, d.centerZ),
        ),
        color: const Color(0xFFE7E5E4),
        category: BimEntityCategory.finishing,
        explodeGroup: 5,
        minStage: 12,
        buildProgress: 0,
      ),
    );

    // Drainage apron
    e.add(
      BimEntity(
        id: 'drainage_apron',
        label: 'Drainage Apron',
        mesh: BimMesh.box(
          width: d.buildingWidth + 3,
          height: 0.08,
          depth: d.buildingDepth + 3,
          center: BimVec3(d.centerX, 0.04, d.centerZ),
        ),
        color: const Color(0xFF94A3B8),
        category: BimEntityCategory.drainage,
        minStage: 13,
        buildProgress: 0,
      ),
    );

    // Landscape / mountain backdrop trees
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'tree_$i',
          label: 'Landscape',
          mesh: BimMesh.cylinder(radius: 0.2, height: 1.5, segments: 8),
          color: const Color(0xFF166534),
          category: BimEntityCategory.finishing,
          position: BimVec3(
            i < 2 ? -0.5 : d.plotWidth - 1,
            0,
            2 + i * 2.5,
          ),
          minStage: 14,
          buildProgress: 0,
        ),
      );
    }

    return e;
  }

  void _footprint(List<BimEntity> e, EarthbagDimensions d) {
    e.add(
      BimEntity(
        id: 'footprint',
        label: 'Building Footprint',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: 0.03,
          depth: d.buildingDepth,
          center: BimVec3(d.centerX, 0.05, d.centerZ),
        ),
        color: const Color(0xFF0F172A),
        category: BimEntityCategory.annotation,
        minStage: 0,
        buildProgress: 0,
      ),
    );
  }

  void _gridAndStakes(List<BimEntity> e, EarthbagDimensions d) {
    for (var i = 0; i <= 5; i++) {
      e.add(
        BimEntity(
          id: 'grid_x_$i',
          label: 'Survey Grid',
          mesh: BimMesh.box(width: 0.015, height: 0.01, depth: d.buildingDepth + 0.5),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(i * (d.buildingWidth / 5), 0.08, -0.25),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    for (final (x, z) in [
      (0.0, 0.0),
      (d.buildingWidth, 0.0),
      (d.buildingWidth, d.buildingDepth),
      (0.0, d.buildingDepth),
    ]) {
      e.add(
        BimEntity(
          id: 'stake_${x}_$z',
          label: 'Survey Stake',
          mesh: BimMesh.cylinder(radius: 0.025, height: 1.0, segments: 6),
          color: const Color(0xFFF97316),
          category: BimEntityCategory.survey,
          position: BimVec3(x, 0, z),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    // Opening markers
    e.add(
      BimEntity(
        id: 'opening_marker_door',
        label: 'Door Opening',
        mesh: BimMesh.box(width: 1.0, height: 0.02, depth: 0.2),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.centerX - 0.5, 0.09, 0),
        minStage: 1,
        buildProgress: 0,
      ),
    );
  }

  void _addBagCourse(
    List<BimEntity> e,
    EarthbagDimensions d, {
    required int course,
    required double baseY,
    required int minStage,
    required String idPrefix,
  }) {
    final y = baseY + course * d.bagHeight;
    var idx = 0;
    // Perimeter bags
    for (var bx = 0; bx < (d.buildingWidth / d.bagLength).ceil(); bx++) {
      final x = bx * d.bagLength * 0.95;
      for (final z in [0.0, d.buildingDepth - d.bagDepth]) {
        e.add(_bag(
          '${idPrefix}_bag_${course}_$idx',
          x,
          y,
          z,
          minStage,
          course,
        ));
        idx++;
      }
    }
    for (var bz = 1; bz < (d.buildingDepth / d.bagLength).ceil() - 1; bz++) {
      final z = bz * d.bagLength * 0.95;
      for (final x in [0.0, d.buildingWidth - d.bagDepth]) {
        e.add(_bag(
          '${idPrefix}_bag_${course}_$idx',
          x,
          y,
          z,
          minStage,
          course,
        ));
        idx++;
      }
    }
  }

  BimEntity _bag(
    String id,
    double x,
    double y,
    double z,
    int minStage,
    int course,
  ) {
    final d = EarthbagDimensions;
    return BimEntity(
      id: id,
      label: 'Earthbag',
      mesh: BimMesh.box(
        width: d.bagLength,
        height: d.bagHeight,
        depth: d.bagDepth,
      ),
      color: Color.lerp(
        const Color(0xFFD97706),
        const Color(0xFFB45309),
        (course % 4) / 4,
      )!,
      category: BimEntityCategory.earthbag,
      position: BimVec3(x, y, z),
      explodeGroup: 2,
      minStage: minStage,
      pickable: id.endsWith('_0'),
      componentId: 'earthbag',
      buildProgress: 0,
    );
  }
}
