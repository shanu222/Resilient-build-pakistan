import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'adobe_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 14 Reinforced Adobe Brick Structure.
class AdobeSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
        _site(e);
    _soilSelection(e);
    _adobeProduction(e);
    _settingOut(e);
    _excavation(e);
    _footings(e);
    _plinthBand(e);
    _adobeWalls(e);
    _verticalReinforcement(e);
    _wireMesh(e);
    _openings(e);
    _lintelBand(e);
    _roofBand(e);
    _roofSystem(e);
    _plaster(e);
    _comparisons(e);
    _landscape(e);

    return e;
  }

  void _site(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'mountain_terrain',
        label: 'Mountain Terrain',
        mesh: BimMesh.box(
          width: AdobeDimensions.plotWidth,
          height: 0.45,
          depth: AdobeDimensions.plotDepth,
          center: BimVec3(AdobeDimensions.plotWidth / 2, -0.12, AdobeDimensions.plotDepth / 2),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.terrain,
        minStage: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'building_pad',
        label: 'Building Platform',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth + 1.2,
          height: 0.18,
          depth: AdobeDimensions.buildingDepth + 1.2,
          center: BimVec3(AdobeDimensions.centerX, 0.09, AdobeDimensions.centerZ),
        ),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.terrain,
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'footprint',
        label: 'Building Footprint',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth,
          height: 0.02,
          depth: AdobeDimensions.buildingDepth,
          center: BimVec3(AdobeDimensions.centerX, 0.12, AdobeDimensions.centerZ),
        ),
        color: const Color(0xFF0F172A),
        category: BimEntityCategory.annotation,
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'seismic_zone_marker',
        label: 'Seismic Zone',
        mesh: BimMesh.box(width: 0.5, height: 0.35, depth: 0.04),
        color: const Color(0xFFDC2626),
        category: BimEntityCategory.annotation,
        position: BimVec3(AdobeDimensions.buildingWidth + 0.6, 0.35, 0.2),
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'drainage_path',
        label: 'Drainage Path',
        mesh: BimMesh.box(width: 0.1, height: 0.02, depth: 2.5),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.drainage,
        position: BimVec3(AdobeDimensions.buildingWidth + 0.5, 0.11, AdobeDimensions.centerZ),
        minStage: 0,
        buildProgress: 0,
      ),
    );
  }

  void _soilSelection(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'soil_unsuitable',
        label: 'Unsuitable Soil',
        mesh: BimMesh.box(width: 0.6, height: 0.25, depth: 0.6),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.earthbag,
        position: BimVec3(-0.5, 0.2, 1),
        minStage: 1,
        opacity: 0.5,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'soil_suitable',
        label: 'Suitable Soil',
        mesh: BimMesh.box(width: 0.7, height: 0.3, depth: 0.7),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.earthbag,
        position: BimVec3(-0.45, 0.22, 2.2),
        minStage: 1,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'soil_test_note',
        label: 'Clay / Sand Test',
        mesh: BimMesh.box(width: 0.35, height: 0.03, depth: 0.35),
        color: const Color(0xFF2563EB),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.2, 0.45, 1.6),
        minStage: 1,
        buildProgress: 0,
      ),
    );
  }

  void _adobeProduction(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'adobe_mixer',
        label: 'Soil Mixer',
        mesh: BimMesh.box(width: 0.8, height: 0.45, depth: 0.6),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.equipment,
        position: BimVec3(-0.9, 0.25, AdobeDimensions.plotDepth - 1.2),
        minStage: 2,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'cement_stabilizer',
        label: 'Cement Stabilization',
        mesh: BimMesh.box(width: 0.35, height: 0.25, depth: 0.35),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.5, 0.2, AdobeDimensions.plotDepth - 0.6),
        minStage: 2,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'lime_stabilizer',
        label: 'Lime Stabilization',
        mesh: BimMesh.box(width: 0.35, height: 0.25, depth: 0.35),
        color: const Color(0xFFE2E8F0),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.15, 0.2, AdobeDimensions.plotDepth - 0.6),
        minStage: 2,
        buildProgress: 0,
      ),
    );
    for (var i = 0; i < 3; i++) {
      e.add(
        BimEntity(
          id: 'adobe_mold_$i',
          label: 'Adobe Mold',
          mesh: BimMesh.box(width: 0.35, height: 0.12, depth: 0.55),
          color: const Color(0xFFD97706),
          category: BimEntityCategory.formwork,
          position: BimVec3(-0.7 + i * 0.4, 0.14, AdobeDimensions.plotDepth - 1.8),
          minStage: 2,
          buildProgress: 0,
        ),
      );
    }
    for (var i = 0; i < 6; i++) {
      e.add(
        BimEntity(
          id: 'curing_brick_$i',
          label: 'Curing Adobe Brick',
          mesh: BimMesh.box(
            width: AdobeDimensions.brickLength * 0.95,
            height: AdobeDimensions.brickHeight,
            depth: AdobeDimensions.brickDepth * 0.95,
          ),
          color: const Color(0xFFD4A574),
          category: BimEntityCategory.masonry,
          position: BimVec3(-0.6 + (i % 3) * 0.35, 0.12, AdobeDimensions.plotDepth - 2.4 + (i ~/ 3) * 0.22),
          minStage: 2,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'traditional_adobe_sample',
        label: 'Traditional Adobe (unstabilized)',
        mesh: BimMesh.box(width: 0.28, height: 0.09, depth: 0.18),
        color: const Color(0xFFA8A29E),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.25, 0.35, AdobeDimensions.plotDepth - 0.35),
        minStage: 2,
        opacity: 0.7,
        buildProgress: 0,
      ),
    );
  }

  void _settingOut(List<BimEntity> e) {
    for (var i = 0; i <= 5; i++) {
      e.add(
        BimEntity(
          id: 'setout_grid_$i',
          label: 'Setting Out Grid',
          mesh: BimMesh.box(width: 0.015, height: 0.01, depth: AdobeDimensions.buildingDepth),
          color: const Color(0xFF0F172A),
          category: BimEntityCategory.survey,
          position: BimVec3(i * (AdobeDimensions.buildingWidth / 5), 0.14, 0),
          minStage: 3,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'wall_centerline',
        label: 'Wall Centerline',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth,
          height: 0.008,
          depth: 0.02,
          center: BimVec3(AdobeDimensions.centerX, 0.135, AdobeDimensions.centerZ),
        ),
        color: const Color(0xFF2563EB),
        category: BimEntityCategory.annotation,
        minStage: 3,
        buildProgress: 0,
      ),
    );
  }

  void _excavation(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'excavation',
        label: 'Excavation',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth + 0.5,
          height: AdobeDimensions.trenchDepth,
          depth: AdobeDimensions.buildingDepth + 0.5,
          center: BimVec3(AdobeDimensions.centerX, -AdobeDimensions.trenchDepth / 2 + 0.05, AdobeDimensions.centerZ),
        ),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.excavation,
        explodeGroup: 1,
        minStage: 4,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'bearing_soil',
        label: 'Bearing Strata',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth + 0.7,
          height: 0.12,
          depth: AdobeDimensions.buildingDepth + 0.7,
          center: BimVec3(AdobeDimensions.centerX, -AdobeDimensions.trenchDepth + 0.06, AdobeDimensions.centerZ),
        ),
        color: const Color(0xFF57534E),
        category: BimEntityCategory.excavation,
        explodeGroup: 1,
        minStage: 4,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'soil_profile',
        label: 'Soil Profile',
        mesh: BimMesh.box(width: 0.04, height: AdobeDimensions.trenchDepth + 0.12, depth: 0.4),
        color: const Color(0xFFA16207),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.2, -AdobeDimensions.trenchDepth / 2, AdobeDimensions.centerZ),
        minStage: 4,
        buildProgress: 0,
      ),
    );
  }

  void _footings(List<BimEntity> e) {
    final baseY = -AdobeDimensions.trenchDepth + AdobeDimensions.pccThickness;
    e.add(
      BimEntity(
        id: 'pcc_layer',
        label: 'PCC Blinding',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth + 0.35,
          height: AdobeDimensions.pccThickness,
          depth: AdobeDimensions.buildingDepth + 0.35,
          center: BimVec3(AdobeDimensions.centerX, -AdobeDimensions.trenchDepth + AdobeDimensions.pccThickness / 2, AdobeDimensions.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 5,
        buildProgress: 0,
      ),
    );
    for (var i = 0; i < 4; i++) {
      final p = _footingPos(i);
      e.add(
        BimEntity(
          id: 'footing_rebar_$i',
          label: 'Footing Reinforcement',
          mesh: BimMesh.box(
            width: AdobeDimensions.footingWidth - 0.06,
            height: AdobeDimensions.footingDepth * 0.65,
            depth: AdobeDimensions.footingWidth - 0.06,
          ),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(p.$1, baseY, p.$2),
          explodeGroup: 1,
          minStage: 5,
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: 'footing_concrete_$i',
          label: 'RCC Footing',
          mesh: BimMesh.box(
            width: AdobeDimensions.footingWidth,
            height: AdobeDimensions.footingDepth,
            depth: AdobeDimensions.footingWidth,
            center: BimVec3(
              p.$1 + AdobeDimensions.footingWidth / 2,
              baseY + AdobeDimensions.footingDepth / 2,
              p.$2 + AdobeDimensions.footingWidth / 2,
            ),
          ),
          color: const Color(0xFF64748B),
          category: BimEntityCategory.concrete,
          explodeGroup: 1,
          minStage: 5,
          buildProgress: 0,
        ),
      );
    }
    var fidx = 0;
    final fBase = -AdobeDimensions.trenchDepth + AdobeDimensions.pccThickness + AdobeDimensions.footingDepth;
    for (var c = 0; c < AdobeDimensions.foundationCourses; c++) {
      final y = fBase + c * (AdobeDimensions.brickHeight + AdobeDimensions.mortarJoint);
      for (final pos in _perimeter(0.08)) {
        e.add(
          BimEntity(
            id: 'found_brick_$fidx',
            label: 'Foundation Masonry',
            mesh: BimMesh.box(
              width: AdobeDimensions.brickLength * 0.94,
              height: AdobeDimensions.brickHeight,
              depth: AdobeDimensions.brickDepth * 0.94,
            ),
            color: const Color(0xFF78716C),
            category: BimEntityCategory.masonry,
            position: BimVec3(pos.$1, y, pos.$2),
            explodeGroup: 2,
            minStage: 5,
            buildProgress: 0,
          ),
        );
        fidx++;
      }
    }
  }

  void _plinthBand(List<BimEntity> e) {
    final y = -AdobeDimensions.trenchDepth +
        AdobeDimensions.pccThickness +
        AdobeDimensions.footingDepth +
        AdobeDimensions.foundationCourses * (AdobeDimensions.brickHeight + AdobeDimensions.mortarJoint);
    e.add(
      BimEntity(
        id: 'plinth_rebar',
        label: 'Plinth Band Reinforcement',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth,
          height: AdobeDimensions.plinthBeamHeight * 0.6,
          depth: AdobeDimensions.buildingDepth,
          center: BimVec3(AdobeDimensions.centerX, y + AdobeDimensions.plinthBeamHeight * 0.3, AdobeDimensions.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 6,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'plinth_band',
        label: 'RCC Plinth Band',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth + 0.12,
          height: AdobeDimensions.plinthBeamHeight,
          depth: AdobeDimensions.buildingDepth + 0.12,
          center: BimVec3(AdobeDimensions.centerX, y + AdobeDimensions.plinthBeamHeight / 2, AdobeDimensions.centerZ),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 2,
        minStage: 6,
        pickable: true,
        componentId: 'plinth_band',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'dpc_course',
        label: 'Damp Proof Course',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth + 0.14,
          height: AdobeDimensions.dpcThickness,
          depth: AdobeDimensions.buildingDepth + 0.14,
          center: BimVec3(
            AdobeDimensions.centerX,
            y + AdobeDimensions.plinthBeamHeight + AdobeDimensions.dpcThickness / 2,
            AdobeDimensions.centerZ,
          ),
        ),
        color: const Color(0xFF06B6D4),
        category: BimEntityCategory.finishing,
        explodeGroup: 2,
        minStage: 14,
        buildProgress: 0,
      ),
    );
  }

  void _adobeWalls(List<BimEntity> e) {
    var idx = 0;
    for (var c = 0; c < AdobeDimensions.wallCourses; c++) {
      final y = AdobeDimensions.wallBaseY + c * (AdobeDimensions.brickHeight + AdobeDimensions.mortarJoint);
      for (final pos in _perimeter(0)) {
        e.add(
          BimEntity(
            id: 'adobe_brick_$idx',
            label: 'Stabilized Adobe Brick',
            mesh: BimMesh.box(
              width: AdobeDimensions.brickLength * 0.94,
              height: AdobeDimensions.brickHeight,
              depth: AdobeDimensions.brickDepth * 0.94,
            ),
            color: Color.lerp(
              const Color(0xFFE8C49A),
              const Color(0xFFD4A574),
              (c % 5) / 5,
            )!,
            category: BimEntityCategory.masonry,
            position: BimVec3(pos.$1, y, pos.$2),
            explodeGroup: 3,
            minStage: 7,
            pickable: idx == 0,
            componentId: 'adobe_brick',
            buildProgress: 0,
          ),
        );
        idx++;
      }
    }
  }

  void _verticalReinforcement(List<BimEntity> e) {
    for (var i = 0; i < 4; i++) {
      final c = _corners()[i];
      e.add(
        BimEntity(
          id: 'vertical_bar_$i',
          label: 'Vertical Reinforcement',
          mesh: BimMesh.cylinder(radius: 0.009, height: AdobeDimensions.wallHeight * 0.9),
          color: const Color(0xFF1E293B),
          category: BimEntityCategory.rebar,
          position: BimVec3(c.$1, AdobeDimensions.wallBaseY + 0.05, c.$2),
          explodeGroup: 3,
          minStage: 8,
          pickable: i == 0,
          componentId: 'vertical_reinforcement',
          buildProgress: 0,
        ),
      );
    }
  }

  void _wireMesh(List<BimEntity> e) {
    for (var i = 0; i <= 4; i++) {
      final x = i * (AdobeDimensions.buildingWidth / 4);
      e.add(
        BimEntity(
          id: 'wire_mesh_front_$i',
          label: 'Wire Mesh',
          mesh: BimMesh.box(
            width: AdobeDimensions.buildingWidth / 4 + 0.05,
            height: AdobeDimensions.wallHeight * 0.85,
            depth: 0.012,
            center: BimVec3(
              x + AdobeDimensions.buildingWidth / 8,
              AdobeDimensions.wallBaseY + AdobeDimensions.wallHeight * 0.42,
              0.01,
            ),
          ),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.wire,
          explodeGroup: 4,
          minStage: 9,
          pickable: i == 0,
          componentId: 'wire_mesh',
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: 'wire_mesh_left_$i',
          label: 'Wire Mesh',
          mesh: BimMesh.box(
            width: 0.012,
            height: AdobeDimensions.wallHeight * 0.85,
            depth: AdobeDimensions.buildingDepth / 4 + 0.05,
            center: BimVec3(
              0.01,
              AdobeDimensions.wallBaseY + AdobeDimensions.wallHeight * 0.42,
              i * (AdobeDimensions.buildingDepth / 4) + AdobeDimensions.buildingDepth / 8,
            ),
          ),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.wire,
          explodeGroup: 4,
          minStage: 9,
          buildProgress: 0,
        ),
      );
    }
    for (var i = 0; i < 4; i++) {
      final c = _corners()[i];
      e.add(
        BimEntity(
          id: 'mesh_corner_$i',
          label: 'Corner Mesh Wrap',
          mesh: BimMesh.box(width: 0.18, height: 0.35, depth: 0.18),
          color: const Color(0xFF64748B),
          category: BimEntityCategory.wire,
          position: BimVec3(c.$1 - 0.02, AdobeDimensions.wallBaseY + 1.2, c.$2 - 0.02),
          explodeGroup: 4,
          minStage: 9,
          buildProgress: 0,
        ),
      );
    }
  }

  void _openings(List<BimEntity> e) {
    final y = AdobeDimensions.wallBaseY + 0.05;
    e.add(
      BimEntity(
        id: 'door_frame',
        label: 'Door Frame',
        mesh: BimMesh.box(width: 0.95, height: 2.05, depth: 0.1),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.finishing,
        position: BimVec3(AdobeDimensions.centerX - 0.475, y, 0.03),
        explodeGroup: 4,
        minStage: 10,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'window_frame',
        label: 'Window Frame',
        mesh: BimMesh.box(width: 1.05, height: 0.95, depth: 0.08),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.finishing,
        position: BimVec3(0.55, y + 0.75, AdobeDimensions.buildingDepth - 0.05),
        explodeGroup: 4,
        minStage: 10,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'opening_reinf',
        label: 'Opening Reinforcement',
        mesh: BimMesh.box(width: 1.15, height: 0.08, depth: 0.1),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.wire,
        position: BimVec3(0.5, y + 1.7, AdobeDimensions.buildingDepth - 0.06),
        explodeGroup: 4,
        minStage: 10,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'stress_flow',
        label: 'Stress Flow',
        mesh: BimMesh.box(width: 0.45, height: 0.03, depth: 0.45),
        color: const Color(0xFFF97316),
        category: BimEntityCategory.annotation,
        position: BimVec3(0.4, y + 1.55, AdobeDimensions.buildingDepth + 0.12),
        minStage: 10,
        opacity: 0.85,
        buildProgress: 0,
      ),
    );
  }

  void _lintelBand(List<BimEntity> e) {
    final y = AdobeDimensions.wallBaseY + AdobeDimensions.wallHeight - AdobeDimensions.bandHeight;
    e.add(
      BimEntity(
        id: 'lintel_rebar',
        label: 'Lintel Band Reinforcement',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth + 0.1,
          height: AdobeDimensions.bandHeight * 0.55,
          depth: AdobeDimensions.buildingDepth + 0.1,
          center: BimVec3(AdobeDimensions.centerX, y + AdobeDimensions.bandHeight * 0.28, AdobeDimensions.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 11,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'lintel_band',
        label: 'RCC Lintel Band',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth + 0.14,
          height: AdobeDimensions.bandHeight,
          depth: AdobeDimensions.buildingDepth + 0.14,
          center: BimVec3(AdobeDimensions.centerX, y + AdobeDimensions.bandHeight / 2, AdobeDimensions.centerZ),
        ),
        color: const Color(0xFF475569),
        category: BimEntityCategory.concrete,
        explodeGroup: 5,
        minStage: 11,
        pickable: true,
        componentId: 'lintel_band',
        buildProgress: 0,
      ),
    );
  }

  void _roofBand(List<BimEntity> e) {
    final y = AdobeDimensions.wallBaseY + AdobeDimensions.wallHeight;
    e.add(
      BimEntity(
        id: 'roof_band_rebar',
        label: 'Roof Band Reinforcement',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth + 0.1,
          height: AdobeDimensions.bandHeight * 0.55,
          depth: AdobeDimensions.buildingDepth + 0.1,
          center: BimVec3(AdobeDimensions.centerX, y + AdobeDimensions.bandHeight * 0.28, AdobeDimensions.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 12,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'roof_band',
        label: 'RCC Roof Band',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth + 0.14,
          height: AdobeDimensions.bandHeight,
          depth: AdobeDimensions.buildingDepth + 0.14,
          center: BimVec3(AdobeDimensions.centerX, y + AdobeDimensions.bandHeight / 2, AdobeDimensions.centerZ),
        ),
        color: const Color(0xFF475569),
        category: BimEntityCategory.concrete,
        explodeGroup: 5,
        minStage: 12,
        pickable: true,
        componentId: 'roof_band',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'box_action_note',
        label: 'Box Action',
        mesh: BimMesh.box(width: 0.55, height: 0.03, depth: 0.55),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.annotation,
        position: BimVec3(AdobeDimensions.centerX - 0.28, y + AdobeDimensions.bandHeight + 0.04, AdobeDimensions.centerZ),
        minStage: 12,
        opacity: 0.85,
        buildProgress: 0,
      ),
    );
  }

  void _roofSystem(List<BimEntity> e) {
    final y = AdobeDimensions.roofBaseY;
    e.add(
      BimEntity(
        id: 'roof_truss_0',
        label: 'Timber Truss',
        mesh: BimMesh.box(width: AdobeDimensions.buildingWidth - 0.2, height: 0.1, depth: 0.12),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        position: BimVec3(0.15, y + 0.35, AdobeDimensions.centerZ),
        explodeGroup: 6,
        minStage: 13,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'roof_truss_1',
        label: 'Timber Truss',
        mesh: BimMesh.box(width: AdobeDimensions.buildingWidth - 0.2, height: 0.1, depth: 0.12),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        position: BimVec3(0.15, y + 0.55, AdobeDimensions.centerZ),
        explodeGroup: 6,
        minStage: 13,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'ridge_beam',
        label: 'Ridge Beam',
        mesh: BimMesh.box(width: 0.12, height: 0.12, depth: AdobeDimensions.buildingDepth - 0.2),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.timber,
        position: BimVec3(AdobeDimensions.centerX, y + 0.65, 0.15),
        explodeGroup: 6,
        minStage: 13,
        buildProgress: 0,
      ),
    );
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'cgi_sheet_$i',
          label: 'CGI Roof Sheet',
          mesh: BimMesh.box(
            width: AdobeDimensions.buildingWidth / 2 - 0.05,
            height: 0.025,
            depth: AdobeDimensions.buildingDepth - 0.15,
            center: BimVec3(
              0.12 + (i % 2) * (AdobeDimensions.buildingWidth / 2),
              y + 0.72,
              AdobeDimensions.centerZ,
            ),
          ),
          color: const Color(0xFF64748B),
          category: BimEntityCategory.finishing,
          explodeGroup: 6,
          minStage: 13,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'heavy_roof_ghost',
        label: 'Heavy RCC Roof (reference)',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth,
          height: 0.2,
          depth: AdobeDimensions.buildingDepth,
          center: BimVec3(AdobeDimensions.centerX, y + 1.1, AdobeDimensions.centerZ + 1.5),
        ),
        color: const Color(0xFFEF4444),
        category: BimEntityCategory.annotation,
        minStage: 13,
        opacity: 0.35,
        buildProgress: 0,
      ),
    );
  }

  void _plaster(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'protective_plaster',
        label: 'Protective Plaster',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth + 0.06,
          height: AdobeDimensions.wallHeight * 0.9,
          depth: 0.025,
          center: BimVec3(
            AdobeDimensions.centerX,
            AdobeDimensions.wallBaseY + AdobeDimensions.wallHeight * 0.45,
            -0.012,
          ),
        ),
        color: const Color(0xFFF5F5F4),
        category: BimEntityCategory.finishing,
        explodeGroup: 6,
        minStage: 14,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'waterproof_coating',
        label: 'Waterproof Coating',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth + 0.1,
          height: 0.015,
          depth: AdobeDimensions.buildingDepth + 0.1,
          center: BimVec3(
            AdobeDimensions.centerX,
            AdobeDimensions.wallBaseY + AdobeDimensions.wallHeight * 0.15,
            AdobeDimensions.centerZ,
          ),
        ),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.finishing,
        explodeGroup: 6,
        minStage: 14,
        buildProgress: 0,
      ),
    );
  }

  void _comparisons(List<BimEntity> e) {
    final gx = AdobeDimensions.buildingWidth + 1.4;
    e.add(
      BimEntity(
        id: 'traditional_adobe_ghost',
        label: 'Traditional Adobe (no reinforcement)',
        mesh: BimMesh.box(
          width: AdobeDimensions.buildingWidth * 0.85,
          height: AdobeDimensions.wallHeight,
          depth: AdobeDimensions.buildingDepth * 0.85,
          center: BimVec3(
            gx + AdobeDimensions.buildingWidth * 0.425,
            AdobeDimensions.wallBaseY + AdobeDimensions.wallHeight / 2,
            AdobeDimensions.centerZ,
          ),
        ),
        color: const Color(0xFFA8A29E),
        category: BimEntityCategory.annotation,
        minStage: 7,
        opacity: 0.55,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'trad_crack_0',
        label: 'Crack',
        mesh: BimMesh.box(width: 0.04, height: 0.8, depth: 0.02),
        color: const Color(0xFFDC2626),
        category: BimEntityCategory.annotation,
        position: BimVec3(gx + 0.5, AdobeDimensions.wallBaseY + 1, AdobeDimensions.centerZ),
        minStage: 7,
        opacity: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'trad_crack_1',
        label: 'Crack',
        mesh: BimMesh.box(width: 0.6, height: 0.04, depth: 0.02),
        color: const Color(0xFFDC2626),
        category: BimEntityCategory.annotation,
        position: BimVec3(gx + 1.2, AdobeDimensions.wallBaseY + 1.8, AdobeDimensions.centerZ),
        minStage: 7,
        opacity: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'reinforced_label',
        label: 'Reinforced Adobe',
        mesh: BimMesh.box(width: 0.5, height: 0.03, depth: 0.5),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.annotation,
        position: BimVec3(AdobeDimensions.centerX - 0.25, AdobeDimensions.roofBaseY + 0.9, AdobeDimensions.centerZ),
        minStage: 15,
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
          mesh: BimMesh.box(width: 0.7, height: 0.2, depth: 0.7),
          color: const Color(0xFF16A34A),
          category: BimEntityCategory.terrain,
          position: BimVec3(
            i < 2 ? 0.4 + i * 2 : AdobeDimensions.plotWidth - 1.2,
            0.1,
            i % 2 == 0 ? 0.5 : AdobeDimensions.plotDepth - 1.1,
          ),
          minStage: 15,
          buildProgress: 0,
        ),
      );
    }
  }

  (double, double) _footingPos(int i) {
    final p = [
      (0.35, 0.35),
      (AdobeDimensions.buildingWidth - 0.35 - AdobeDimensions.footingWidth, 0.35),
      (0.35, AdobeDimensions.buildingDepth - 0.35 - AdobeDimensions.footingWidth),
      (AdobeDimensions.buildingWidth - 0.35 - AdobeDimensions.footingWidth, AdobeDimensions.buildingDepth - 0.35 - AdobeDimensions.footingWidth),
    ];
    return p[i];
  }

  List<(double, double)> _corners() => [
        (0.1, 0.1),
        (AdobeDimensions.buildingWidth - 0.15, 0.1),
        (0.1, AdobeDimensions.buildingDepth - 0.15),
        (AdobeDimensions.buildingWidth - 0.15, AdobeDimensions.buildingDepth - 0.15),
      ];

  List<(double, double)> _perimeter(double inset) {
    final w = AdobeDimensions.buildingWidth;
    final dep = AdobeDimensions.buildingDepth;
    final bl = AdobeDimensions.brickLength;
    final bd = AdobeDimensions.brickDepth;
    final out = <(double, double)>[];
    for (var x = inset; x < w - bl; x += bl * 0.98) {
      out.add((x, inset));
      out.add((x, dep - bd - inset));
    }
    for (var z = inset + bd; z < dep - bd * 2; z += bd * 0.98) {
      out.add((inset, z));
      out.add((w - bl - inset, z));
    }
    return out;
  }
}
