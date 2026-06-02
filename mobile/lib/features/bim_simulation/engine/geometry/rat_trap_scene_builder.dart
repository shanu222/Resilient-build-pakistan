import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'rat_trap_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 13 Rat Trap Bond Masonry.
class RatTrapSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
        _site(e);
    _settingOut(e);
    _excavation(e);
    _footings(e);
    _foundationMasonry(e);
    _plinthBand(e);
    _ratTrapWalls(e);
    _seismicReinforcement(e);
    _openings(e);
    _lintelBand(e);
    _roofBand(e);
    _roofSlab(e);
    _dpcWaterproof(e);
    _comparisons(e);
    _landscape(e);

    return e;
  }

  void _site(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'terrain',
        label: 'Terrain',
        mesh: BimMesh.box(
          width: RatTrapDimensions.plotWidth,
          height: 0.15,
          depth: RatTrapDimensions.plotDepth,
          center: BimVec3(RatTrapDimensions.plotWidth / 2, -0.075, RatTrapDimensions.plotDepth / 2),
        ),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.terrain,
        minStage: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'site_boundary',
        label: 'Site Boundary',
        mesh: BimMesh.box(
          width: RatTrapDimensions.plotWidth,
          height: 0.02,
          depth: 0.05,
          center: BimVec3(RatTrapDimensions.plotWidth / 2, 0.02, 0.025),
        ),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.survey,
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'footprint',
        label: 'Building Footprint',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth,
          height: 0.03,
          depth: RatTrapDimensions.buildingDepth,
          center: BimVec3(RatTrapDimensions.centerX, 0.04, RatTrapDimensions.centerZ),
        ),
        color: const Color(0xFF0F172A),
        category: BimEntityCategory.annotation,
        minStage: 0,
        buildProgress: 0,
      ),
    );
    for (var i = 0; i <= 6; i++) {
      e.add(
        BimEntity(
          id: 'site_grid_$i',
          label: 'Site Grid',
          mesh: BimMesh.box(width: 0.02, height: 0.01, depth: RatTrapDimensions.buildingDepth),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(i * (RatTrapDimensions.buildingWidth / 6), 0.05, 0),
          minStage: 0,
          buildProgress: 0,
        ),
      );
    }
  }

  void _settingOut(List<BimEntity> e) {
    for (var i = 0; i <= 6; i++) {
      e.add(
        BimEntity(
          id: 'setout_grid_$i',
          label: 'Setting Out Grid',
          mesh: BimMesh.box(width: 0.015, height: 0.01, depth: RatTrapDimensions.buildingDepth),
          color: const Color(0xFF0F172A),
          category: BimEntityCategory.survey,
          position: BimVec3(i * (RatTrapDimensions.buildingWidth / 6), 0.06, 0),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'wall_centerline',
        label: 'Wall Centerline',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth,
          height: 0.008,
          depth: 0.02,
          center: BimVec3(RatTrapDimensions.centerX, 0.055, RatTrapDimensions.centerZ),
        ),
        color: const Color(0xFF2563EB),
        category: BimEntityCategory.annotation,
        minStage: 1,
        buildProgress: 0,
      ),
    );
    for (var i = 0; i < 4; i++) {
      final corners = [
        (0.0, 0.0),
        (RatTrapDimensions.buildingWidth - 0.15, 0.0),
        (0.0, RatTrapDimensions.buildingDepth - 0.15),
        (RatTrapDimensions.buildingWidth - 0.15, RatTrapDimensions.buildingDepth - 0.15),
      ];
      e.add(
        BimEntity(
          id: 'corner_$i',
          label: 'Corner Point',
          mesh: BimMesh.box(width: 0.15, height: 0.04, depth: 0.15),
          color: const Color(0xFFF97316),
          category: BimEntityCategory.survey,
          position: BimVec3(corners[i].$1, 0.06, corners[i].$2),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
  }

  void _excavation(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'excavation',
        label: 'Excavation',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth + 0.6,
          height: RatTrapDimensions.trenchDepth,
          depth: RatTrapDimensions.buildingDepth + 0.6,
          center: BimVec3(RatTrapDimensions.centerX, -RatTrapDimensions.trenchDepth / 2 + 0.05, RatTrapDimensions.centerZ),
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
        label: 'Bearing Strata',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth + 0.8,
          height: 0.12,
          depth: RatTrapDimensions.buildingDepth + 0.8,
          center: BimVec3(RatTrapDimensions.centerX, -RatTrapDimensions.trenchDepth + 0.06, RatTrapDimensions.centerZ),
        ),
        color: const Color(0xFF57534E),
        category: BimEntityCategory.excavation,
        explodeGroup: 1,
        minStage: 2,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'soil_profile',
        label: 'Soil Profile',
        mesh: BimMesh.box(width: 0.04, height: RatTrapDimensions.trenchDepth + 0.15, depth: 0.45),
        color: const Color(0xFFA16207),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.25, -RatTrapDimensions.trenchDepth / 2, RatTrapDimensions.centerZ),
        minStage: 2,
        buildProgress: 0,
      ),
    );
  }

  void _footings(List<BimEntity> e) {
    final baseY = -RatTrapDimensions.trenchDepth + RatTrapDimensions.pccThickness;
    e.add(
      BimEntity(
        id: 'pcc_layer',
        label: 'PCC Blinding',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth + 0.35,
          height: RatTrapDimensions.pccThickness,
          depth: RatTrapDimensions.buildingDepth + 0.35,
          center: BimVec3(RatTrapDimensions.centerX, -RatTrapDimensions.trenchDepth + RatTrapDimensions.pccThickness / 2, RatTrapDimensions.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 3,
        buildProgress: 0,
      ),
    );
    final positions = _footingPositions();
    for (var i = 0; i < positions.length; i++) {
      final p = positions[i];
      e.add(
        BimEntity(
          id: 'footing_rebar_$i',
          label: 'Footing Reinforcement',
          mesh: BimMesh.box(
            width: RatTrapDimensions.footingWidth - 0.06,
            height: RatTrapDimensions.footingDepth * 0.65,
            depth: RatTrapDimensions.footingWidth - 0.06,
          ),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(p.$1, baseY, p.$2),
          explodeGroup: 1,
          minStage: 3,
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: 'footing_concrete_$i',
          label: 'RCC Footing',
          mesh: BimMesh.box(
            width: RatTrapDimensions.footingWidth,
            height: RatTrapDimensions.footingDepth,
            depth: RatTrapDimensions.footingWidth,
            center: BimVec3(
              p.$1 + RatTrapDimensions.footingWidth / 2,
              baseY + RatTrapDimensions.footingDepth / 2,
              p.$2 + RatTrapDimensions.footingWidth / 2,
            ),
          ),
          color: const Color(0xFF64748B),
          category: BimEntityCategory.concrete,
          explodeGroup: 1,
          minStage: 3,
          buildProgress: 0,
        ),
      );
    }
  }

  void _foundationMasonry(List<BimEntity> e) {
    final baseY = -RatTrapDimensions.trenchDepth + RatTrapDimensions.pccThickness + RatTrapDimensions.footingDepth;
    var idx = 0;
    for (var c = 0; c < RatTrapDimensions.foundationCourses; c++) {
      final y = baseY + c * (RatTrapDimensions.courseHeight + RatTrapDimensions.mortarJoint);
      for (final p in _perimeterPositions(0.1)) {
        e.add(
          BimEntity(
            id: 'found_brick_$idx',
            label: 'Foundation Masonry',
            mesh: BimMesh.box(
              width: RatTrapDimensions.brickLength * 0.95,
              height: RatTrapDimensions.courseHeight,
              depth: RatTrapDimensions.brickWidth * 0.95,
            ),
            color: const Color(0xFF78716C),
            category: BimEntityCategory.masonry,
            position: BimVec3(p.$1, y, p.$2),
            explodeGroup: 2,
            minStage: 4,
            buildProgress: 0,
          ),
        );
        idx++;
      }
    }
  }

  void _plinthBand(List<BimEntity> e) {
    final y = -RatTrapDimensions.trenchDepth +
        RatTrapDimensions.pccThickness +
        RatTrapDimensions.footingDepth +
        RatTrapDimensions.foundationCourses * (RatTrapDimensions.courseHeight + RatTrapDimensions.mortarJoint);
    e.add(
      BimEntity(
        id: 'plinth_rebar',
        label: 'Plinth Band Reinforcement',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth,
          height: RatTrapDimensions.plinthBeamHeight * 0.6,
          depth: RatTrapDimensions.buildingDepth,
          center: BimVec3(RatTrapDimensions.centerX, y + RatTrapDimensions.plinthBeamHeight * 0.3, RatTrapDimensions.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 5,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'plinth_band',
        label: 'RCC Plinth Band',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth + 0.12,
          height: RatTrapDimensions.plinthBeamHeight,
          depth: RatTrapDimensions.buildingDepth + 0.12,
          center: BimVec3(RatTrapDimensions.centerX, y + RatTrapDimensions.plinthBeamHeight / 2, RatTrapDimensions.centerZ),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 2,
        minStage: 5,
        pickable: true,
        componentId: 'plinth_band',
        buildProgress: 0,
      ),
    );
  }

  void _ratTrapWalls(List<BimEntity> e) {
    final baseY = RatTrapDimensions.wallBaseY;
    var idx = 0;
    for (var course = 0; course < RatTrapDimensions.wallCourses; course++) {
      final y = baseY + course * (RatTrapDimensions.courseHeight + RatTrapDimensions.mortarJoint);
      final minStage = course == 0 ? 6 : 7;
      _rtbFace(
        e,
        face: 'front',
        course: course,
        y: y,
        minStage: minStage,
        idxStart: idx,
        detailed: true,
      );
      idx += RatTrapDimensions.baysAlongWidth * 2;
      _rtbFace(
        e,
        face: 'left',
        course: course,
        y: y,
        minStage: minStage,
        idxStart: idx,
        detailed: true,
      );
      idx += RatTrapDimensions.baysAlongDepth * 2;
      _rtbFace(
        e,
        face: 'rear',
        course: course,
        y: y,
        minStage: minStage,
        idxStart: idx,
        detailed: false,
      );
      idx += RatTrapDimensions.baysAlongWidth;
      _rtbFace(
        e,
        face: 'right',
        course: course,
        y: y,
        minStage: minStage,
        idxStart: idx,
        detailed: false,
      );
      idx += RatTrapDimensions.baysAlongDepth;
    }
  }

  void _rtbFace(
    List<BimEntity> e, {
    required String face,
    required int course,
    required double y,
    required int minStage,
    required int idxStart,
    required bool detailed,
  }) {
    final bays = face == 'front' || face == 'rear'
        ? RatTrapDimensions.baysAlongWidth
        : RatTrapDimensions.baysAlongDepth;
    for (var bay = 0; bay < bays; bay++) {
      final isCavity = detailed && (course + bay) % 2 == 1;
      final id = 'rtb_${face}_${course}_$bay';
      if (isCavity) {
        final (x, z) = _bayPosition(face, bay);
        e.add(
          BimEntity(
            id: '${id}_cavity',
            label: 'Air Cavity',
            mesh: BimMesh.box(
              width: RatTrapDimensions.cavityWidth,
              height: RatTrapDimensions.courseHeight * 0.92,
              depth: RatTrapDimensions.brickLength * 0.55,
              center: BimVec3(
                x + RatTrapDimensions.cavityWidth / 2,
                y + RatTrapDimensions.courseHeight / 2,
                z + RatTrapDimensions.brickLength * 0.28,
              ),
            ),
            color: const Color(0xFFBAE6FD),
            category: BimEntityCategory.annotation,
            explodeGroup: 3,
            minStage: minStage,
            pickable: bay == 0 && course == 0 && face == 'front',
            componentId: 'air_cavity',
            opacity: 0.75,
            buildProgress: 0,
          ),
        );
      } else {
        final (x, z) = _bayPosition(face, bay);
        e.add(
          BimEntity(
            id: '${id}_brick',
            label: 'Rat Trap Bond Brick',
            mesh: BimMesh.box(
              width: RatTrapDimensions.brickLength * 0.94,
              height: RatTrapDimensions.courseHeight,
              depth: RatTrapDimensions.brickWidth,
              center: BimVec3(
                x + RatTrapDimensions.brickLength / 2,
                y + RatTrapDimensions.courseHeight / 2,
                z + RatTrapDimensions.brickWidth / 2,
              ),
            ),
            color: Color.lerp(
              const Color(0xFFB91C1C),
              const Color(0xFFDC2626),
              (course % 4) / 4,
            )!,
            category: BimEntityCategory.masonry,
            explodeGroup: 3,
            minStage: minStage,
            pickable: bay == 1 && course == 0 && face == 'front',
            componentId: 'rat_trap_brick',
            buildProgress: 0,
          ),
        );
      }
    }
  }

  (double, double) _bayPosition(String face, int bay) {
    final offset = bay * RatTrapDimensions.baySpacing;
    return switch (face) {
      'front' => (offset + 0.05, 0.0),
      'rear' => (offset + 0.05, RatTrapDimensions.buildingDepth - RatTrapDimensions.brickWidth),
      'left' => (0.0, offset + 0.05),
      _ => (RatTrapDimensions.buildingWidth - RatTrapDimensions.brickWidth, offset + 0.05),
    };
  }

  void _seismicReinforcement(List<BimEntity> e) {
    final corners = [
      (0.12, 0.12),
      (RatTrapDimensions.buildingWidth - 0.2, 0.12),
      (0.12, RatTrapDimensions.buildingDepth - 0.2),
      (RatTrapDimensions.buildingWidth - 0.2, RatTrapDimensions.buildingDepth - 0.2),
    ];
    for (var i = 0; i < corners.length; i++) {
      e.add(
        BimEntity(
          id: 'seismic_bar_$i',
          label: 'Vertical Seismic Bar',
          mesh: BimMesh.cylinder(radius: 0.008, height: RatTrapDimensions.wallHeight * 0.85),
          color: const Color(0xFF1E293B),
          category: BimEntityCategory.rebar,
          position: BimVec3(corners[i].$1, RatTrapDimensions.wallBaseY + 0.1, corners[i].$2),
          explodeGroup: 3,
          minStage: 8,
          pickable: i == 0,
          componentId: 'seismic_reinforcement',
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: 'grout_fill_$i',
          label: 'Grout Fill',
          mesh: BimMesh.box(width: 0.06, height: RatTrapDimensions.wallHeight * 0.5, depth: 0.06),
          color: const Color(0xFF9CA3AF),
          category: BimEntityCategory.concrete,
          position: BimVec3(
            corners[i].$1,
            RatTrapDimensions.wallBaseY + RatTrapDimensions.wallHeight * 0.25,
            corners[i].$2,
          ),
          explodeGroup: 3,
          minStage: 8,
          buildProgress: 0,
        ),
      );
    }
  }

  void _openings(List<BimEntity> e) {
    final y = RatTrapDimensions.wallBaseY + 0.05;
    e.add(
      BimEntity(
        id: 'door_frame',
        label: 'Door Frame',
        mesh: BimMesh.box(width: 0.95, height: 2.05, depth: 0.1),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.finishing,
        position: BimVec3(RatTrapDimensions.centerX - 0.475, y, 0.02),
        explodeGroup: 4,
        minStage: 9,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'window_frame_0',
        label: 'Window Frame',
        mesh: BimMesh.box(width: 1.05, height: 0.95, depth: 0.08),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.finishing,
        position: BimVec3(0.55, y + 0.75, RatTrapDimensions.buildingDepth - 0.05),
        explodeGroup: 4,
        minStage: 9,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'opening_reinf',
        label: 'Opening Reinforcement',
        mesh: BimMesh.box(width: 1.2, height: 0.08, depth: 0.12),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        position: BimVec3(0.5, y + 1.75, RatTrapDimensions.buildingDepth - 0.06),
        explodeGroup: 4,
        minStage: 9,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'stress_flow',
        label: 'Stress Redistribution',
        mesh: BimMesh.box(width: 0.5, height: 0.03, depth: 0.5),
        color: const Color(0xFFF97316),
        category: BimEntityCategory.annotation,
        position: BimVec3(0.45, y + 1.65, RatTrapDimensions.buildingDepth + 0.15),
        minStage: 9,
        opacity: 0.85,
        buildProgress: 0,
      ),
    );
  }

  void _lintelBand(List<BimEntity> e) {
    final y = RatTrapDimensions.wallBaseY + RatTrapDimensions.wallHeight - RatTrapDimensions.bandHeight;
    e.add(
      BimEntity(
        id: 'lintel_rebar',
        label: 'Lintel Band Reinforcement',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth + 0.1,
          height: RatTrapDimensions.bandHeight * 0.55,
          depth: RatTrapDimensions.buildingDepth + 0.1,
          center: BimVec3(RatTrapDimensions.centerX, y + RatTrapDimensions.bandHeight * 0.28, RatTrapDimensions.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 10,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'lintel_band',
        label: 'RCC Lintel Band',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth + 0.14,
          height: RatTrapDimensions.bandHeight,
          depth: RatTrapDimensions.buildingDepth + 0.14,
          center: BimVec3(RatTrapDimensions.centerX, y + RatTrapDimensions.bandHeight / 2, RatTrapDimensions.centerZ),
        ),
        color: const Color(0xFF475569),
        category: BimEntityCategory.concrete,
        explodeGroup: 4,
        minStage: 10,
        pickable: true,
        componentId: 'lintel_band',
        buildProgress: 0,
      ),
    );
  }

  void _roofBand(List<BimEntity> e) {
    final y = RatTrapDimensions.wallBaseY + RatTrapDimensions.wallHeight;
    e.add(
      BimEntity(
        id: 'roof_band_rebar',
        label: 'Roof Band Reinforcement',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth + 0.1,
          height: RatTrapDimensions.bandHeight * 0.55,
          depth: RatTrapDimensions.buildingDepth + 0.1,
          center: BimVec3(RatTrapDimensions.centerX, y + RatTrapDimensions.bandHeight * 0.28, RatTrapDimensions.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 11,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'roof_band',
        label: 'RCC Roof Band',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth + 0.14,
          height: RatTrapDimensions.bandHeight,
          depth: RatTrapDimensions.buildingDepth + 0.14,
          center: BimVec3(RatTrapDimensions.centerX, y + RatTrapDimensions.bandHeight / 2, RatTrapDimensions.centerZ),
        ),
        color: const Color(0xFF475569),
        category: BimEntityCategory.concrete,
        explodeGroup: 5,
        minStage: 11,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'box_action_note',
        label: 'Box Action',
        mesh: BimMesh.box(width: 0.6, height: 0.03, depth: 0.6),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.annotation,
        position: BimVec3(RatTrapDimensions.centerX - 0.3, y + RatTrapDimensions.bandHeight + 0.05, RatTrapDimensions.centerZ),
        minStage: 11,
        opacity: 0.8,
        buildProgress: 0,
      ),
    );
  }

  void _roofSlab(List<BimEntity> e) {
    final y = RatTrapDimensions.wallBaseY + RatTrapDimensions.wallHeight + RatTrapDimensions.bandHeight;
    e.add(
      BimEntity(
        id: 'slab_formwork',
        label: 'Slab Formwork',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth + 0.2,
          height: 0.05,
          depth: RatTrapDimensions.buildingDepth + 0.2,
          center: BimVec3(RatTrapDimensions.centerX, y + 0.025, RatTrapDimensions.centerZ),
        ),
        color: const Color(0xFFD97706),
        category: BimEntityCategory.formwork,
        explodeGroup: 5,
        minStage: 12,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'slab_rebar_bottom',
        label: 'Bottom Reinforcement',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth - 0.2,
          height: 0.03,
          depth: RatTrapDimensions.buildingDepth - 0.2,
          center: BimVec3(RatTrapDimensions.centerX, y + 0.06, RatTrapDimensions.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        explodeGroup: 5,
        minStage: 12,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'slab_rebar_top',
        label: 'Top Reinforcement',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth - 0.35,
          height: 0.03,
          depth: RatTrapDimensions.buildingDepth - 0.35,
          center: BimVec3(
            RatTrapDimensions.centerX,
            y + RatTrapDimensions.slabThickness - 0.04,
            RatTrapDimensions.centerZ,
          ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        explodeGroup: 5,
        minStage: 12,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'roof_slab',
        label: 'RCC Roof Slab',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth,
          height: RatTrapDimensions.slabThickness,
          depth: RatTrapDimensions.buildingDepth,
          center: BimVec3(RatTrapDimensions.centerX, y + RatTrapDimensions.slabThickness / 2, RatTrapDimensions.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 5,
        minStage: 12,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'load_path_arrow',
        label: 'Load Path',
        mesh: BimMesh.box(width: 0.08, height: 0.5, depth: 0.08),
        color: const Color(0xFFEF4444),
        category: BimEntityCategory.annotation,
        position: BimVec3(RatTrapDimensions.centerX, y - 0.2, RatTrapDimensions.centerZ + 0.8),
        minStage: 12,
        opacity: 0.85,
        buildProgress: 0,
      ),
    );
  }

  void _dpcWaterproof(List<BimEntity> e) {
    final y = RatTrapDimensions.wallBaseY - 0.02;
    e.add(
      BimEntity(
        id: 'dpc_course',
        label: 'Damp Proof Course',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth + 0.15,
          height: RatTrapDimensions.dpcThickness,
          depth: RatTrapDimensions.buildingDepth + 0.15,
          center: BimVec3(RatTrapDimensions.centerX, y, RatTrapDimensions.centerZ),
        ),
        color: const Color(0xFF06B6D4),
        category: BimEntityCategory.finishing,
        explodeGroup: 2,
        minStage: 13,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'waterproof_membrane',
        label: 'Waterproof Membrane',
        mesh: BimMesh.box(
          width: RatTrapDimensions.buildingWidth + 0.08,
          height: RatTrapDimensions.wallHeight * 0.55,
          depth: 0.015,
          center: BimVec3(RatTrapDimensions.centerX, RatTrapDimensions.wallBaseY + RatTrapDimensions.wallHeight * 0.3, -0.008),
        ),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.finishing,
        explodeGroup: 6,
        minStage: 13,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'capillary_block',
        label: 'Capillary Break',
        mesh: BimMesh.box(width: 0.4, height: 0.03, depth: 0.4),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.35, y, RatTrapDimensions.centerZ),
        minStage: 13,
        opacity: 0.8,
        buildProgress: 0,
      ),
    );
  }

  void _comparisons(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'conventional_wall_ghost',
        label: 'Conventional Solid Wall (reference)',
        mesh: BimMesh.box(
          width: RatTrapDimensions.brickLength,
          height: RatTrapDimensions.wallHeight * 0.85,
          depth: RatTrapDimensions.brickLength,
          center: BimVec3(
            RatTrapDimensions.buildingWidth + 0.9,
            RatTrapDimensions.wallBaseY + RatTrapDimensions.wallHeight * 0.42,
            RatTrapDimensions.centerZ,
          ),
        ),
        color: const Color(0xFF94A3B8),
        category: BimEntityCategory.annotation,
        minStage: 7,
        opacity: 0.45,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'material_savings_note',
        label: 'Material Savings ~25%',
        mesh: BimMesh.box(width: 0.55, height: 0.03, depth: 0.55),
        color: const Color(0xFF16A34A),
        category: BimEntityCategory.annotation,
        position: BimVec3(RatTrapDimensions.buildingWidth + 0.65, RatTrapDimensions.wallBaseY + 1.2, RatTrapDimensions.centerZ),
        minStage: 14,
        opacity: 0.9,
        buildProgress: 0,
      ),
    );
  }

  void _landscape(List<BimEntity> e) {
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'landscape_$i',
          label: 'Landscape',
          mesh: BimMesh.box(width: 0.75, height: 0.22, depth: 0.75),
          color: const Color(0xFF16A34A),
          category: BimEntityCategory.terrain,
          position: BimVec3(
            i < 2 ? 0.5 + i * 2.2 : RatTrapDimensions.buildingWidth - 0.5,
            0.11,
            i % 2 == 0 ? 0.5 : RatTrapDimensions.plotDepth - 1.2,
          ),
          minStage: 14,
          buildProgress: 0,
        ),
      );
    }
  }

  List<(double, double)> _footingPositions() {
    return [
      (0.35, 0.35),
      (RatTrapDimensions.buildingWidth - 0.35 - RatTrapDimensions.footingWidth, 0.35),
      (0.35, RatTrapDimensions.buildingDepth - 0.35 - RatTrapDimensions.footingWidth),
      (RatTrapDimensions.buildingWidth - 0.35 - RatTrapDimensions.footingWidth, RatTrapDimensions.buildingDepth - 0.35 - RatTrapDimensions.footingWidth),
      (RatTrapDimensions.centerX - RatTrapDimensions.footingWidth / 2, 0.35),
      (RatTrapDimensions.centerX - RatTrapDimensions.footingWidth / 2, RatTrapDimensions.buildingDepth - 0.35 - RatTrapDimensions.footingWidth),
    ];
  }

  List<(double, double)> _perimeterPositions(double inset) {
    final w = RatTrapDimensions.buildingWidth;
    final dep = RatTrapDimensions.buildingDepth;
    final bl = RatTrapDimensions.brickLength;
    final bw = RatTrapDimensions.brickWidth;
    final out = <(double, double)>[];
    for (var x = inset; x < w - bl; x += bl * 0.98) {
      out.add((x, inset));
      out.add((x, dep - bw - inset));
    }
    for (var z = inset + bw; z < dep - bw * 2; z += bw * 0.98) {
      out.add((inset, z));
      out.add((w - bl - inset, z));
    }
    return out;
  }
}
