import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'prefab_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 11 Pre-Fabricated House.
class PrefabSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
        _site(e);
    _foundation(e);
    _anchors(e);
    _floorPanels(e);
    _wallPanels(e);
    _cornerConnectors(e);
    _openings(e);
    _roofPanels(e);
    _insulationSystem(e);
    _connectionsInspection(e);
    _services(e);
    _finishes(e);
    _equipment(e);
    _landscape(e);

    return e;
  }

  void _site(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'terrain',
        label: 'Terrain',
        mesh: BimMesh.box(
          width: PrefabDimensions.plotWidth,
          height: 0.15,
          depth: PrefabDimensions.plotDepth,
          center: BimVec3(PrefabDimensions.plotWidth / 2, -0.075, PrefabDimensions.plotDepth / 2),
        ),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.terrain,
        minStage: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'footprint',
        label: 'Building Footprint',
        mesh: BimMesh.box(
          width: PrefabDimensions.buildingWidth,
          height: 0.02,
          depth: PrefabDimensions.buildingDepth,
          center: BimVec3(PrefabDimensions.centerX, 0.04, PrefabDimensions.centerZ),
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
          id: 'survey_grid_$i',
          label: 'Survey Grid',
          mesh: BimMesh.box(width: 0.02, height: 0.01, depth: PrefabDimensions.buildingDepth),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(i * (PrefabDimensions.buildingWidth / 6), 0.05, 0),
          minStage: 0,
          buildProgress: 0,
        ),
      );
    }
    for (var i = 0; i <= 4; i++) {
      e.add(
        BimEntity(
          id: 'setout_line_$i',
          label: 'Setting Out Line',
          mesh: BimMesh.box(width: 0.015, height: 0.01, depth: PrefabDimensions.buildingDepth),
          color: const Color(0xFF0F172A),
          category: BimEntityCategory.survey,
          position: BimVec3(i * (PrefabDimensions.buildingWidth / 4), 0.06, 0),
          minStage: 1,
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: 'panel_layout_$i',
          label: 'Panel Layout Mark',
          mesh: BimMesh.box(width: PrefabDimensions.buildingWidth / 4 - 0.1, height: 0.008, depth: 0.02),
          color: const Color(0xFF2563EB),
          category: BimEntityCategory.annotation,
          position: BimVec3(
            i * (PrefabDimensions.buildingWidth / 4) + PrefabDimensions.buildingWidth / 8,
            0.055,
            PrefabDimensions.centerZ,
          ),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
  }

  void _foundation(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'excavation',
        label: 'Foundation Excavation',
        mesh: BimMesh.box(
          width: PrefabDimensions.buildingWidth + 0.6,
          height: PrefabDimensions.trenchDepth,
          depth: PrefabDimensions.buildingDepth + 0.6,
          center: BimVec3(PrefabDimensions.centerX, -PrefabDimensions.trenchDepth / 2 + 0.05, PrefabDimensions.centerZ),
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
          width: PrefabDimensions.buildingWidth + 0.8,
          height: 0.12,
          depth: PrefabDimensions.buildingDepth + 0.8,
          center: BimVec3(PrefabDimensions.centerX, -PrefabDimensions.trenchDepth + 0.06, PrefabDimensions.centerZ),
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
        mesh: BimMesh.box(width: 0.04, height: PrefabDimensions.trenchDepth + 0.2, depth: 0.5),
        color: const Color(0xFFA16207),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.35, -PrefabDimensions.trenchDepth / 2, PrefabDimensions.centerZ),
        minStage: 2,
        buildProgress: 0,
      ),
    );
    final baseY = -PrefabDimensions.trenchDepth + PrefabDimensions.pccThickness;
    e.add(
      BimEntity(
        id: 'pcc_layer',
        label: 'PCC Blinding',
        mesh: BimMesh.box(
          width: PrefabDimensions.buildingWidth + 0.4,
          height: PrefabDimensions.pccThickness,
          depth: PrefabDimensions.buildingDepth + 0.4,
          center: BimVec3(PrefabDimensions.centerX, -PrefabDimensions.trenchDepth + PrefabDimensions.pccThickness / 2, PrefabDimensions.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 3,
        buildProgress: 0,
      ),
    );
    final footY = -PrefabDimensions.trenchDepth + PrefabDimensions.pccThickness + PrefabDimensions.footingDepth / 2;
    final footPositions = [
      (0.4, 0.4),
      (PrefabDimensions.buildingWidth - 0.4, 0.4),
      (0.4, PrefabDimensions.buildingDepth - 0.4),
      (PrefabDimensions.buildingWidth - 0.4, PrefabDimensions.buildingDepth - 0.4),
    ];
    for (var i = 0; i < footPositions.length; i++) {
      final p = footPositions[i];
      e.add(
        BimEntity(
          id: 'footing_$i',
          label: 'RCC Footing',
          mesh: BimMesh.box(width: 0.55, height: PrefabDimensions.footingDepth, depth: 0.55),
          color: const Color(0xFF64748B),
          category: BimEntityCategory.concrete,
          position: BimVec3(p.$1 - 0.275, footY - PrefabDimensions.footingDepth / 2, p.$2 - 0.275),
          explodeGroup: 1,
          minStage: 3,
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: 'footing_rebar_$i',
          label: 'Footing Reinforcement',
          mesh: BimMesh.box(width: 0.45, height: 0.04, depth: 0.45),
          color: const Color(0xFF1E293B),
          category: BimEntityCategory.rebar,
          position: BimVec3(p.$1 - 0.225, footY - 0.02, p.$2 - 0.225),
          explodeGroup: 1,
          minStage: 3,
          buildProgress: 0,
        ),
      );
    }
    final beamY = -PrefabDimensions.trenchDepth + PrefabDimensions.pccThickness + PrefabDimensions.footingDepth;
    e.add(
      BimEntity(
        id: 'foundation_beam',
        label: 'Foundation Beam',
        mesh: BimMesh.box(
          width: PrefabDimensions.buildingWidth,
          height: PrefabDimensions.beamHeight,
          depth: 0.22,
          center: BimVec3(PrefabDimensions.centerX, beamY + PrefabDimensions.beamHeight / 2, 0.11),
        ),
        color: const Color(0xFF475569),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 3,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'foundation_beam_rear',
        label: 'Foundation Beam',
        mesh: BimMesh.box(
          width: PrefabDimensions.buildingWidth,
          height: PrefabDimensions.beamHeight,
          depth: 0.22,
          center: BimVec3(PrefabDimensions.centerX, beamY + PrefabDimensions.beamHeight / 2, PrefabDimensions.buildingDepth - 0.11),
        ),
        color: const Color(0xFF475569),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 3,
        buildProgress: 0,
      ),
    );
  }

  void _anchors(List<BimEntity> e) {
    final baseY = -PrefabDimensions.trenchDepth + PrefabDimensions.pccThickness + PrefabDimensions.footingDepth + PrefabDimensions.beamHeight;
    final pts = [
      (0.35, 0.35),
      (PrefabDimensions.buildingWidth - 0.35, 0.35),
      (0.35, PrefabDimensions.buildingDepth - 0.35),
      (PrefabDimensions.buildingWidth - 0.35, PrefabDimensions.buildingDepth - 0.35),
      (PrefabDimensions.centerX, 0.35),
      (PrefabDimensions.centerX, PrefabDimensions.buildingDepth - 0.35),
      (0.35, PrefabDimensions.centerZ),
      (PrefabDimensions.buildingWidth - 0.35, PrefabDimensions.centerZ),
    ];
    for (var i = 0; i < pts.length; i++) {
      e.add(
        BimEntity(
          id: 'anchor_bolt_$i',
          label: 'Anchor Bolt',
          mesh: BimMesh.cylinder(radius: 0.014, height: 0.16),
          color: const Color(0xFF334155),
          category: BimEntityCategory.equipment,
          position: BimVec3(pts[i].$1, baseY, pts[i].$2),
          explodeGroup: 2,
          minStage: 4,
          buildProgress: 0,
        ),
      );
    }
  }

  void _floorPanels(List<BimEntity> e) {
    final y = PrefabDimensions.floorTopY - PrefabDimensions.floorPanelThickness;
    final halfW = PrefabDimensions.buildingWidth / 2;
    for (var i = 0; i < 2; i++) {
      e.add(
        BimEntity(
          id: 'floor_panel_$i',
          label: 'Precast Floor Panel',
          mesh: BimMesh.box(
            width: halfW - 0.05,
            height: PrefabDimensions.floorPanelThickness,
            depth: PrefabDimensions.buildingDepth - 0.1,
            center: BimVec3(
              i * halfW + halfW / 2,
              y + PrefabDimensions.floorPanelThickness / 2,
              PrefabDimensions.centerZ,
            ),
          ),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.concrete,
          explodeGroup: 2,
          minStage: 5,
          pickable: i == 0,
          componentId: 'floor_panel',
          buildProgress: 0,
        ),
      );
    }
  }

  void _wallPanels(List<BimEntity> e) {
    final y = PrefabDimensions.floorTopY;
    final h = PrefabDimensions.wallHeight;
    final t = PrefabDimensions.panelThickness;
    final ins = PrefabDimensions.insulationThickness;

    void sandwichWall(
      String id,
      String label,
      double cx,
      double cz,
      double w,
      double depth,
      int idx,
    ) {
      e.add(
        BimEntity(
          id: '${id}_skin_ext',
          label: label,
          mesh: BimMesh.box(
            width: w,
            height: h,
            depth: 0.02,
            center: BimVec3(cx, y + h / 2, cz),
          ),
          color: const Color(0xFFCBD5E1),
          category: BimEntityCategory.concrete,
          explodeGroup: 3,
          minStage: 6,
          pickable: idx == 0,
          componentId: 'wall_panel',
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: '${id}_insulation',
          label: 'Insulation Core',
          mesh: BimMesh.box(
            width: w * 0.92,
            height: h * 0.95,
            depth: ins,
            center: BimVec3(cx, y + h / 2, cz),
          ),
          color: const Color(0xFFFDE68A),
          category: BimEntityCategory.finishing,
          explodeGroup: 3,
          minStage: 10,
          pickable: idx == 0,
          componentId: 'insulation_core',
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: '${id}_skin_int',
          label: label,
          mesh: BimMesh.box(
            width: w * 0.92,
            height: h * 0.95,
            depth: 0.02,
            center: BimVec3(cx, y + h / 2, cz + (depth > t ? ins : -ins)),
          ),
          color: const Color(0xFFE2E8F0),
          category: BimEntityCategory.concrete,
          explodeGroup: 3,
          minStage: 6,
          buildProgress: 0,
        ),
      );
    }

    sandwichWall(
      'wall_front',
      'Front Wall Panel',
      PrefabDimensions.centerX,
      t / 2,
      PrefabDimensions.buildingWidth - 0.2,
      t,
      0,
    );
    sandwichWall(
      'wall_rear',
      'Rear Wall Panel',
      PrefabDimensions.centerX,
      PrefabDimensions.buildingDepth - t / 2,
      PrefabDimensions.buildingWidth - 0.2,
      t,
      1,
    );
    sandwichWall(
      'wall_left',
      'Left Wall Panel',
      t / 2,
      PrefabDimensions.centerZ,
      t,
      PrefabDimensions.buildingDepth - 0.2,
      2,
    );
    sandwichWall(
      'wall_right',
      'Right Wall Panel',
      PrefabDimensions.buildingWidth - t / 2,
      PrefabDimensions.centerZ,
      t,
      PrefabDimensions.buildingDepth - 0.2,
      3,
    );
  }

  void _cornerConnectors(List<BimEntity> e) {
    final y = PrefabDimensions.floorTopY + PrefabDimensions.wallHeight * 0.5;
    final corners = [
      (0.08, 0.08),
      (PrefabDimensions.buildingWidth - 0.08, 0.08),
      (0.08, PrefabDimensions.buildingDepth - 0.08),
      (PrefabDimensions.buildingWidth - 0.08, PrefabDimensions.buildingDepth - 0.08),
    ];
    for (var i = 0; i < corners.length; i++) {
      e.add(
        BimEntity(
          id: 'steel_connector_$i',
          label: 'Steel Corner Connector',
          mesh: BimMesh.box(width: 0.08, height: 0.35, depth: 0.08),
          color: const Color(0xFF1E40AF),
          category: BimEntityCategory.equipment,
          position: BimVec3(corners[i].$1 - 0.04, y - 0.175, corners[i].$2 - 0.04),
          explodeGroup: 3,
          minStage: 7,
          pickable: i == 0,
          componentId: 'steel_connector',
          buildProgress: 0,
        ),
      );
    }
  }

  void _openings(List<BimEntity> e) {
    final y = PrefabDimensions.floorTopY + 0.05;
    e.add(
      BimEntity(
        id: 'door_module',
        label: 'Door Module',
        mesh: BimMesh.box(width: 0.95, height: 2.1, depth: 0.08),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.finishing,
        position: BimVec3(PrefabDimensions.centerX - 0.475, y, 0.02),
        explodeGroup: 3,
        minStage: 8,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'window_module_0',
        label: 'Window Module',
        mesh: BimMesh.box(width: 1.1, height: 1.0, depth: 0.06),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.finishing,
        position: BimVec3(0.5, y + 0.8, PrefabDimensions.buildingDepth - 0.04),
        explodeGroup: 3,
        minStage: 8,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'window_module_1',
        label: 'Window Module',
        mesh: BimMesh.box(width: 1.1, height: 1.0, depth: 0.06),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.finishing,
        position: BimVec3(PrefabDimensions.buildingWidth - 1.6, y + 0.8, PrefabDimensions.buildingDepth - 0.04),
        explodeGroup: 3,
        minStage: 8,
        buildProgress: 0,
      ),
    );
  }

  void _roofPanels(List<BimEntity> e) {
    final y = PrefabDimensions.floorTopY + PrefabDimensions.wallHeight;
    final halfW = PrefabDimensions.buildingWidth / 2;
    for (var i = 0; i < 2; i++) {
      e.add(
        BimEntity(
          id: 'roof_panel_$i',
          label: 'Insulated Roof Panel',
          mesh: BimMesh.box(
            width: halfW - 0.05,
            height: PrefabDimensions.roofPanelThickness,
            depth: PrefabDimensions.buildingDepth - 0.12,
            center: BimVec3(
              i * halfW + halfW / 2,
              y + PrefabDimensions.roofPanelThickness / 2,
              PrefabDimensions.centerZ,
            ),
          ),
          color: const Color(0xFF64748B),
          category: BimEntityCategory.concrete,
          explodeGroup: 4,
          minStage: 9,
          pickable: i == 0,
          componentId: 'roof_panel',
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'heavy_roof_ghost',
        label: 'Conventional Heavy Roof (reference)',
        mesh: BimMesh.box(
          width: PrefabDimensions.buildingWidth,
          height: 0.45,
          depth: PrefabDimensions.buildingDepth,
          center: BimVec3(PrefabDimensions.centerX, y + 0.55, PrefabDimensions.centerZ + 1.8),
        ),
        color: const Color(0xFFEF4444),
        category: BimEntityCategory.annotation,
        minStage: 9,
        opacity: 0.35,
        buildProgress: 0,
      ),
    );
  }

  void _insulationSystem(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'thermal_barrier',
        label: 'Thermal Barrier Layer',
        mesh: BimMesh.box(
          width: PrefabDimensions.buildingWidth - 0.3,
          height: PrefabDimensions.wallHeight - 0.2,
          depth: 0.015,
          center: BimVec3(
            PrefabDimensions.centerX,
            PrefabDimensions.floorTopY + PrefabDimensions.wallHeight / 2,
            PrefabDimensions.buildingDepth / 2,
          ),
        ),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.finishing,
        explodeGroup: 5,
        minStage: 10,
        buildProgress: 0,
      ),
    );
  }

  void _connectionsInspection(List<BimEntity> e) {
    final y = PrefabDimensions.floorTopY + 1.2;
    for (var i = 0; i < 6; i++) {
      e.add(
        BimEntity(
          id: 'panel_lock_$i',
          label: 'Panel Locking Mechanism',
          mesh: BimMesh.box(width: 0.06, height: 0.06, depth: 0.04),
          color: const Color(0xFFF59E0B),
          category: BimEntityCategory.equipment,
          position: BimVec3(0.5 + i * 0.9, y, 0.05),
          explodeGroup: 5,
          minStage: 11,
          buildProgress: 0,
        ),
      );
    }
  }

  void _services(List<BimEntity> e) {
    final y = PrefabDimensions.floorTopY + 0.3;
    e.add(
      BimEntity(
        id: 'electrical_conduit',
        label: 'Electrical Conduit',
        mesh: BimMesh.cylinder(radius: 0.02, height: PrefabDimensions.buildingWidth - 0.5),
        color: const Color(0xFFEAB308),
        category: BimEntityCategory.equipment,
        position: BimVec3(0.25, y, PrefabDimensions.centerZ),
        explodeGroup: 5,
        minStage: 12,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'water_line',
        label: 'Water Supply Line',
        mesh: BimMesh.cylinder(radius: 0.018, height: PrefabDimensions.buildingDepth - 0.4),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.equipment,
        position: BimVec3(PrefabDimensions.buildingWidth - 0.2, y - 0.15, 0.3),
        explodeGroup: 5,
        minStage: 12,
        buildProgress: 0,
      ),
    );
  }

  void _finishes(List<BimEntity> e) {
    final y = PrefabDimensions.floorTopY;
    e.add(
      BimEntity(
        id: 'exterior_finish',
        label: 'Exterior Finish',
        mesh: BimMesh.box(
          width: PrefabDimensions.buildingWidth + 0.04,
          height: PrefabDimensions.wallHeight,
          depth: 0.03,
          center: BimVec3(PrefabDimensions.centerX, y + PrefabDimensions.wallHeight / 2, -0.015),
        ),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.finishing,
        explodeGroup: 5,
        minStage: 13,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'interior_finish',
        label: 'Interior Finish',
        mesh: BimMesh.box(
          width: PrefabDimensions.buildingWidth - 0.25,
          height: PrefabDimensions.wallHeight - 0.15,
          depth: PrefabDimensions.buildingDepth - 0.25,
          center: BimVec3(PrefabDimensions.centerX, y + PrefabDimensions.wallHeight / 2, PrefabDimensions.centerZ),
        ),
        color: const Color(0xFFF5F5F4),
        category: BimEntityCategory.finishing,
        explodeGroup: 5,
        minStage: 13,
        buildProgress: 0,
      ),
    );
  }

  void _equipment(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'mobile_crane',
        label: 'Mobile Crane',
        mesh: BimMesh.box(width: 0.35, height: 2.8, depth: 0.35),
        color: const Color(0xFFFACC15),
        category: BimEntityCategory.equipment,
        position: BimVec3(-1.2, 0, PrefabDimensions.centerZ),
        explodeGroup: 0,
        minStage: 5,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'crane_boom',
        label: 'Crane Boom',
        mesh: BimMesh.box(width: 3.2, height: 0.12, depth: 0.12),
        color: const Color(0xFFEAB308),
        category: BimEntityCategory.equipment,
        position: BimVec3(0.4, 2.4, PrefabDimensions.centerZ),
        explodeGroup: 0,
        minStage: 5,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'factory_module_note',
        label: 'Factory-Built Module',
        mesh: BimMesh.box(width: 0.6, height: 0.03, depth: 0.6),
        color: const Color(0xFF2563EB),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.8, 1.2, PrefabDimensions.buildingDepth + 0.5),
        minStage: 14,
        opacity: 0.85,
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
          mesh: BimMesh.box(width: 0.8, height: 0.25, depth: 0.8),
          color: const Color(0xFF16A34A),
          category: BimEntityCategory.terrain,
          position: BimVec3(
            i < 2 ? 0.5 + i * 2 : PrefabDimensions.buildingWidth - 1.5,
            0.125,
            i % 2 == 0 ? 0.5 : PrefabDimensions.buildingDepth - 1.3,
          ),
          minStage: 14,
          buildProgress: 0,
        ),
      );
    }
  }
}
