import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'raised_plinth_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 12 Raised Plinth Flood Resilient House.
class RaisedPlinthSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
    final d = RaisedPlinthDimensions;

    _siteAndFlood(e, d);
    _settingOut(e, d);
    _excavation(e, d);
    _footings(e, d);
    _foundationMasonry(e, d);
    _earthFill(e, d);
    _retainingEdge(e, d);
    _plinthBeam(e, d);
    _dpc(e, d);
    _walls(e, d);
    _openings(e, d);
    _roof(e, d);
    _drainage(e, d);
    _waterproofing(e, d);
    _landscape(e, d);

    return e;
  }

  void _siteAndFlood(List<BimEntity> e, RaisedPlinthDimensions d) {
    e.add(
      BimEntity(
        id: 'floodplain',
        label: 'Floodplain',
        mesh: BimMesh.box(
          width: d.plotWidth,
          height: 0.12,
          depth: d.plotDepth,
          center: BimVec3(d.plotWidth / 2, -0.06, d.plotDepth / 2),
        ),
        color: const Color(0xFF86EFAC),
        category: BimEntityCategory.terrain,
        minStage: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'river_channel',
        label: 'River',
        mesh: BimMesh.box(
          width: d.riverWidth,
          height: 0.08,
          depth: d.plotDepth,
          center: BimVec3(d.riverWidth / 2, -0.02, d.plotDepth / 2),
        ),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.drainage,
        minStage: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'footprint',
        label: 'Building Footprint',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.8,
          height: 0.02,
          depth: d.buildingDepth + 0.8,
          center: BimVec3(d.centerX + 0.4, 0.04, d.centerZ),
        ),
        color: const Color(0xFF0F172A),
        category: BimEntityCategory.annotation,
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'flood_zone_marker',
        label: 'Flood Zone',
        mesh: BimMesh.box(
          width: d.plotWidth - d.riverWidth,
          height: 0.015,
          depth: d.plotDepth,
          center: BimVec3(
            d.riverWidth + (d.plotWidth - d.riverWidth) / 2,
            0.03,
            d.plotDepth / 2,
          ),
        ),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.annotation,
        minStage: 0,
        opacity: 0.35,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'high_flood_mark',
        label: 'Historical Flood Level',
        mesh: BimMesh.box(width: 0.08, height: 0.04, depth: d.buildingDepth + 1.5),
        color: const Color(0xFFDC2626),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.buildingWidth + 1.2, d.highFloodMark, -0.3),
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'safe_level_mark',
        label: 'Safe Occupancy Level',
        mesh: BimMesh.box(width: 0.08, height: 0.04, depth: d.buildingDepth + 1.5),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.buildingWidth + 1.5, d.floorLevelY, -0.3),
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'flood_water',
        label: 'Flood Water',
        mesh: BimMesh.box(
          width: d.plotWidth - d.riverWidth + 0.4,
          height: d.designFloodLevel,
          depth: d.plotDepth,
          center: BimVec3(
            d.riverWidth + (d.plotWidth - d.riverWidth) / 2,
            d.designFloodLevel / 2,
            d.plotDepth / 2,
          ),
        ),
        color: const Color(0xFF0284C7),
        category: BimEntityCategory.drainage,
        minStage: 0,
        opacity: 0.45,
        buildProgress: 0,
      ),
    );
  }

  void _settingOut(List<BimEntity> e, RaisedPlinthDimensions d) {
    for (var i = 0; i <= 5; i++) {
      e.add(
        BimEntity(
          id: 'grid_x_$i',
          label: 'Survey Grid',
          mesh: BimMesh.box(width: 0.02, height: 0.01, depth: d.buildingDepth + 1),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(0.4 + i * (d.buildingWidth / 5), 0.06, 0),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'plinth_boundary',
        label: 'Plinth Boundary',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.6,
          height: 0.015,
          depth: d.buildingDepth + 0.6,
          center: BimVec3(d.centerX + 0.4, 0.07, d.centerZ),
        ),
        color: const Color(0xFF2563EB),
        category: BimEntityCategory.annotation,
        minStage: 1,
        opacity: 0.75,
        buildProgress: 0,
      ),
    );
  }

  void _excavation(List<BimEntity> e, RaisedPlinthDimensions d) {
    e.add(
      BimEntity(
        id: 'excavation',
        label: 'Foundation Excavation',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.5,
          height: d.trenchDepth,
          depth: d.buildingDepth + 0.5,
          center: BimVec3(
            d.centerX + 0.4,
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
        label: 'Bearing Strata',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.7,
          height: 0.12,
          depth: d.buildingDepth + 0.7,
          center: BimVec3(d.centerX + 0.4, -d.trenchDepth + 0.06, d.centerZ),
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
        mesh: BimMesh.box(width: 0.04, height: d.trenchDepth + 0.15, depth: 0.45),
        color: const Color(0xFFA16207),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.1, -d.trenchDepth / 2, d.centerZ),
        minStage: 2,
        buildProgress: 0,
      ),
    );
  }

  void _footings(List<BimEntity> e, RaisedPlinthDimensions d) {
    final pccY = -d.trenchDepth + d.pccThickness / 2;
    e.add(
      BimEntity(
        id: 'pcc_layer',
        label: 'PCC Blinding',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.35,
          height: d.pccThickness,
          depth: d.buildingDepth + 0.35,
          center: BimVec3(d.centerX + 0.4, pccY, d.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 3,
        buildProgress: 0,
      ),
    );
    final footY = -d.trenchDepth + d.pccThickness + d.footingDepth / 2;
    final positions = [
      (0.5, 0.5),
      (d.buildingWidth - 0.1, 0.5),
      (0.5, d.buildingDepth - 0.1),
      (d.buildingWidth - 0.1, d.buildingDepth - 0.1),
      (d.centerX, 0.5),
      (d.centerX, d.buildingDepth - 0.1),
    ];
    for (var i = 0; i < positions.length; i++) {
      final p = positions[i];
      e.add(
        BimEntity(
          id: 'footing_rebar_$i',
          label: 'Footing Reinforcement',
          mesh: BimMesh.box(
            width: d.footingWidth - 0.08,
            height: 0.05,
            depth: d.footingWidth - 0.08,
          ),
          color: const Color(0xFF1E293B),
          category: BimEntityCategory.rebar,
          position: BimVec3(
            p.$1 + 0.4 - (d.footingWidth - 0.08) / 2,
            footY - 0.02,
            p.$2 - (d.footingWidth - 0.08) / 2,
          ),
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
            width: d.footingWidth,
            height: d.footingDepth,
            depth: d.footingWidth,
          ),
          color: const Color(0xFF64748B),
          category: BimEntityCategory.concrete,
          position: BimVec3(
            p.$1 + 0.4 - d.footingWidth / 2,
            footY - d.footingDepth / 2,
            p.$2 - d.footingWidth / 2,
          ),
          explodeGroup: 1,
          minStage: 3,
          pickable: i == 0,
          componentId: 'footing',
          buildProgress: 0,
        ),
      );
    }
  }

  void _foundationMasonry(List<BimEntity> e, RaisedPlinthDimensions d) {
    final baseY = -d.trenchDepth + d.pccThickness + d.footingDepth;
    final courses = (d.foundationMasonryHeight / d.courseHeight).ceil();
    for (var c = 0; c < courses; c++) {
      e.add(
        BimEntity(
          id: 'found_wall_course_$c',
          label: 'Foundation Masonry',
          mesh: BimMesh.box(
            width: d.buildingWidth,
            height: d.courseHeight - 0.01,
            depth: d.wallThickness,
            center: BimVec3(
              d.centerX + 0.4,
              baseY + c * d.courseHeight + d.courseHeight / 2,
              d.wallThickness / 2,
            ),
          ),
          color: const Color(0xFF78716C),
          category: BimEntityCategory.masonry,
          explodeGroup: 2,
          minStage: 4,
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: 'found_wall_rear_$c',
          label: 'Foundation Masonry',
          mesh: BimMesh.box(
            width: d.buildingWidth,
            height: d.courseHeight - 0.01,
            depth: d.wallThickness,
            center: BimVec3(
              d.centerX + 0.4,
              baseY + c * d.courseHeight + d.courseHeight / 2,
              d.buildingDepth - d.wallThickness / 2,
            ),
          ),
          color: const Color(0xFF78716C),
          category: BimEntityCategory.masonry,
          explodeGroup: 2,
          minStage: 4,
          buildProgress: 0,
        ),
      );
    }
  }

  void _earthFill(List<BimEntity> e, RaisedPlinthDimensions d) {
    final baseY = d.foundationTopY;
    final layerH = d.plinthFillHeight / 4;
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'earth_fill_$i',
          label: 'Compacted Fill Layer',
          mesh: BimMesh.box(
            width: d.buildingWidth + 0.2,
            height: layerH - 0.02,
            depth: d.buildingDepth + 0.2,
            center: BimVec3(
              d.centerX + 0.4,
              baseY + i * layerH + layerH / 2,
              d.centerZ,
            ),
          ),
          color: Color.lerp(
            const Color(0xFF92400E),
            const Color(0xFFA16207),
            i / 3,
          )!,
          category: BimEntityCategory.earthbag,
          explodeGroup: 3,
          minStage: 5,
          pickable: i == 0,
          componentId: 'raised_plinth',
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'compaction_roller',
        label: 'Compaction Roller',
        mesh: BimMesh.box(width: 0.5, height: 0.35, depth: 0.7),
        color: const Color(0xFFFACC15),
        category: BimEntityCategory.equipment,
        position: BimVec3(d.centerX - 0.5, baseY + d.plinthFillHeight * 0.5, d.centerZ + 1.2),
        explodeGroup: 3,
        minStage: 5,
        buildProgress: 0,
      ),
    );
  }

  void _retainingEdge(List<BimEntity> e, RaisedPlinthDimensions d) {
    final h = d.plinthFillHeight + 0.1;
    final cy = d.foundationTopY + h / 2;
    final cx = d.centerX + 0.4;
    final specs = <(String, BimMesh)>[
      (
        'retaining_edge_0',
        BimMesh.box(
          width: d.buildingWidth + 0.25,
          height: h,
          depth: 0.14,
          center: BimVec3(cx, cy, 0.07),
        ),
      ),
      (
        'retaining_edge_1',
        BimMesh.box(
          width: d.buildingWidth + 0.25,
          height: h,
          depth: 0.14,
          center: BimVec3(cx, cy, d.buildingDepth - 0.07),
        ),
      ),
      (
        'retaining_edge_2',
        BimMesh.box(
          width: 0.14,
          height: h,
          depth: d.buildingDepth + 0.2,
          center: BimVec3(0.47, cy, d.centerZ),
        ),
      ),
      (
        'retaining_edge_3',
        BimMesh.box(
          width: 0.14,
          height: h,
          depth: d.buildingDepth + 0.2,
          center: BimVec3(d.buildingWidth + 0.33, cy, d.centerZ),
        ),
      ),
    ];
    for (final spec in specs) {
      e.add(
        BimEntity(
          id: spec.$1,
          label: 'Plinth Retaining Edge',
          mesh: spec.$2,
          color: const Color(0xFF57534E),
          category: BimEntityCategory.concrete,
          explodeGroup: 3,
          minStage: 6,
          buildProgress: 0,
        ),
      );
    }
  }

  void _plinthBeam(List<BimEntity> e, RaisedPlinthDimensions d) {
    final y = d.foundationTopY + d.plinthFillHeight;
    e.add(
      BimEntity(
        id: 'plinth_beam_rebar',
        label: 'Plinth Beam Reinforcement',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.15,
          height: 0.06,
          depth: d.plinthBeamWidth,
          center: BimVec3(
            d.centerX + 0.4,
            y + d.plinthBeamHeight / 2,
            d.plinthBeamWidth / 2,
          ),
        ),
        color: const Color(0xFF1E293B),
        category: BimEntityCategory.rebar,
        explodeGroup: 4,
        minStage: 7,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'plinth_beam_rebar_rear',
        label: 'Plinth Beam Reinforcement',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.15,
          height: 0.06,
          depth: d.plinthBeamWidth,
          center: BimVec3(
            d.centerX + 0.4,
            y + d.plinthBeamHeight / 2,
            d.buildingDepth - d.plinthBeamWidth / 2,
          ),
        ),
        color: const Color(0xFF1E293B),
        category: BimEntityCategory.rebar,
        explodeGroup: 4,
        minStage: 7,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'plinth_beam_formwork',
        label: 'Beam Formwork',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.25,
          height: d.plinthBeamHeight + 0.08,
          depth: d.buildingDepth + 0.25,
          center: BimVec3(
            d.centerX + 0.4,
            y + d.plinthBeamHeight / 2,
            d.centerZ,
          ),
        ),
        color: const Color(0xFFD97706),
        category: BimEntityCategory.formwork,
        explodeGroup: 4,
        minStage: 7,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'plinth_beam',
        label: 'RCC Plinth Beam',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.1,
          height: d.plinthBeamHeight,
          depth: d.plinthBeamWidth,
          center: BimVec3(
            d.centerX + 0.4,
            y + d.plinthBeamHeight / 2,
            d.plinthBeamWidth / 2,
          ),
        ),
        color: const Color(0xFF475569),
        category: BimEntityCategory.concrete,
        explodeGroup: 4,
        minStage: 7,
        pickable: true,
        componentId: 'plinth_beam',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'plinth_beam_rear',
        label: 'RCC Plinth Beam',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.1,
          height: d.plinthBeamHeight,
          depth: d.plinthBeamWidth,
          center: BimVec3(
            d.centerX + 0.4,
            y + d.plinthBeamHeight / 2,
            d.buildingDepth - d.plinthBeamWidth / 2,
          ),
        ),
        color: const Color(0xFF475569),
        category: BimEntityCategory.concrete,
        explodeGroup: 4,
        minStage: 7,
        buildProgress: 0,
      ),
    );
  }

  void _dpc(List<BimEntity> e, RaisedPlinthDimensions d) {
    e.add(
      BimEntity(
        id: 'dpc_layer',
        label: 'Damp Proof Course',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.05,
          height: d.dpcThickness,
          depth: d.buildingDepth + 0.05,
          center: BimVec3(
            d.centerX + 0.4,
            d.plinthTopY + d.dpcThickness / 2,
            d.centerZ,
          ),
        ),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.finishing,
        explodeGroup: 4,
        minStage: 8,
        pickable: true,
        componentId: 'damp_proof_course',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'waterproof_membrane',
        label: 'Waterproof Membrane',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.15,
          height: 0.012,
          depth: d.buildingDepth + 0.15,
          center: BimVec3(
            d.centerX + 0.4,
            d.plinthTopY - 0.01,
            d.centerZ,
          ),
        ),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.finishing,
        explodeGroup: 4,
        minStage: 8,
        buildProgress: 0,
      ),
    );
  }

  void _walls(List<BimEntity> e, RaisedPlinthDimensions d) {
    final courses = (d.wallHeight / d.courseHeight).ceil();
    final baseY = d.floorLevelY;
    for (var c = 0; c < courses; c++) {
      final cy = baseY + c * d.courseHeight + d.courseHeight / 2;
      for (var side = 0; side < 4; side++) {
        final id = 'wall_${side}_course_$c';
        BimMesh mesh;
        if (side == 0) {
          mesh = BimMesh.box(
            width: d.buildingWidth - 0.1,
            height: d.courseHeight - 0.01,
            depth: d.wallThickness,
            center: BimVec3(d.centerX + 0.4, cy, d.wallThickness / 2),
          );
        } else if (side == 1) {
          mesh = BimMesh.box(
            width: d.buildingWidth - 0.1,
            height: d.courseHeight - 0.01,
            depth: d.wallThickness,
            center: BimVec3(
              d.centerX + 0.4,
              cy,
              d.buildingDepth - d.wallThickness / 2,
            ),
          );
        } else if (side == 2) {
          mesh = BimMesh.box(
            width: d.wallThickness,
            height: d.courseHeight - 0.01,
            depth: d.buildingDepth - 0.15,
            center: BimVec3(0.4 + d.wallThickness / 2, cy, d.centerZ),
          );
        } else {
          mesh = BimMesh.box(
            width: d.wallThickness,
            height: d.courseHeight - 0.01,
            depth: d.buildingDepth - 0.15,
            center: BimVec3(
              d.buildingWidth + 0.4 - d.wallThickness / 2,
              cy,
              d.centerZ,
            ),
          );
        }
        e.add(
          BimEntity(
            id: id,
            label: 'Masonry Wall',
            mesh: mesh,
            color: const Color(0xFFB45309),
            category: BimEntityCategory.masonry,
            explodeGroup: 5,
            minStage: 9,
            buildProgress: 0,
          ),
        );
      }
    }
  }

  void _openings(List<BimEntity> e, RaisedPlinthDimensions d) {
    final y = d.floorLevelY + 0.05;
    e.add(
      BimEntity(
        id: 'door_frame',
        label: 'Door Frame',
        mesh: BimMesh.box(width: 0.95, height: 2.05, depth: 0.08),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.finishing,
        position: BimVec3(d.centerX - 0.075, y, 0.04),
        explodeGroup: 5,
        minStage: 10,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'window_frame_0',
        label: 'Window Frame',
        mesh: BimMesh.box(width: 1.05, height: 0.95, depth: 0.06),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.finishing,
        position: BimVec3(0.55, y + 0.75, d.buildingDepth - 0.04),
        explodeGroup: 5,
        minStage: 10,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'window_frame_1',
        label: 'Window Frame',
        mesh: BimMesh.box(width: 1.05, height: 0.95, depth: 0.06),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.finishing,
        position: BimVec3(d.buildingWidth - 0.15, y + 0.75, d.buildingDepth - 0.04),
        explodeGroup: 5,
        minStage: 10,
        buildProgress: 0,
      ),
    );
  }

  void _roof(List<BimEntity> e, RaisedPlinthDimensions d) {
    final y = d.roofBaseY;
    e.add(
      BimEntity(
        id: 'roof_truss_0',
        label: 'Roof Truss',
        mesh: BimMesh.box(width: d.buildingWidth - 0.2, height: 0.1, depth: 0.12),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        position: BimVec3(0.5, y + 0.35, d.centerZ),
        explodeGroup: 6,
        minStage: 11,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'roof_truss_1',
        label: 'Roof Truss',
        mesh: BimMesh.box(width: d.buildingWidth - 0.2, height: 0.1, depth: 0.12),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        position: BimVec3(0.5, y + 0.55, d.centerZ),
        explodeGroup: 6,
        minStage: 11,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'ridge_beam',
        label: 'Ridge Beam',
        mesh: BimMesh.box(width: 0.12, height: 0.12, depth: d.buildingDepth - 0.2),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.timber,
        position: BimVec3(d.centerX + 0.4, y + 0.65, 0.15),
        explodeGroup: 6,
        minStage: 11,
        buildProgress: 0,
      ),
    );
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'cgi_sheet_$i',
          label: 'CGI Roofing',
          mesh: BimMesh.box(
            width: d.buildingWidth / 2 - 0.05,
            height: 0.025,
            depth: d.buildingDepth - 0.15,
            center: BimVec3(
              0.45 + i % 2 * (d.buildingWidth / 2),
              y + 0.72,
              d.centerZ,
            ),
          ),
          color: const Color(0xFF64748B),
          category: BimEntityCategory.finishing,
          explodeGroup: 6,
          minStage: 11,
          buildProgress: 0,
        ),
      );
    }
  }

  void _drainage(List<BimEntity> e, RaisedPlinthDimensions d) {
    e.add(
      BimEntity(
        id: 'drain_channel_front',
        label: 'Drainage Channel',
        mesh: BimMesh.box(width: d.buildingWidth + 1.5, height: 0.08, depth: 0.25),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.drainage,
        position: BimVec3(d.centerX - 0.35, 0.04, -0.35),
        explodeGroup: 7,
        minStage: 12,
        pickable: true,
        componentId: 'drainage_channel',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'drain_channel_side',
        label: 'Surface Drain',
        mesh: BimMesh.box(width: 0.25, height: 0.08, depth: d.plotDepth - 1),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.drainage,
        position: BimVec3(d.buildingWidth + 1.0, 0.04, d.plotDepth / 2),
        explodeGroup: 7,
        minStage: 12,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'runoff_arrow_note',
        label: 'Runoff Control',
        mesh: BimMesh.box(width: 0.4, height: 0.02, depth: 0.4),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.buildingWidth + 0.6, 0.1, 0.5),
        minStage: 12,
        opacity: 0.8,
        buildProgress: 0,
      ),
    );
  }

  void _waterproofing(List<BimEntity> e, RaisedPlinthDimensions d) {
    final y = d.floorLevelY + d.wallHeight * 0.4;
    e.add(
      BimEntity(
        id: 'ext_waterproofing',
        label: 'External Waterproofing',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.08,
          height: d.wallHeight * 0.6,
          depth: 0.02,
          center: BimVec3(d.centerX + 0.4, y, -0.01),
        ),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.finishing,
        explodeGroup: 7,
        minStage: 13,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'plinth_toe_coating',
        label: 'Plinth Toe Protection',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.3,
          height: 0.15,
          depth: 0.08,
          center: BimVec3(
            d.centerX + 0.4,
            d.foundationTopY + d.plinthFillHeight * 0.15,
            0.02,
          ),
        ),
        color: const Color(0xFF16A34A),
        category: BimEntityCategory.finishing,
        explodeGroup: 7,
        minStage: 13,
        buildProgress: 0,
      ),
    );
  }

  void _landscape(List<BimEntity> e, RaisedPlinthDimensions d) {
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'landscape_$i',
          label: 'Landscape',
          mesh: BimMesh.box(width: 0.7, height: 0.22, depth: 0.7),
          color: const Color(0xFF16A34A),
          category: BimEntityCategory.terrain,
          position: BimVec3(
            i < 2 ? 0.6 + i * 2.5 : d.buildingWidth + 0.8,
            0.11,
            i % 2 == 0 ? 0.6 : d.plotDepth - 1.2,
          ),
          minStage: 14,
          buildProgress: 0,
        ),
      );
    }
  }
}
