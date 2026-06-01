import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'light_gauge_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 09 Light Gauge Steel House.
class LightGaugeSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
        _site(e);
    _excavationFootings(e);
    _anchorsAndTracks(e);
    _studsAndColumns(e);
    _beams(e);
    _bracing(e);
    _roof(e);
    _sheathingInsulation(e);
    _finishes(e);
    _landscape(e);

    return e;
  }

  void _site(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'terrain',
        label: 'Terrain',
        mesh: BimMesh.box(
          width: LightGaugeDimensions.plotWidth,
          height: 0.15,
          depth: LightGaugeDimensions.plotDepth,
          center: BimVec3(LightGaugeDimensions.plotWidth / 2, -0.075, LightGaugeDimensions.plotDepth / 2),
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
          width: LightGaugeDimensions.buildingWidth,
          height: 0.02,
          depth: LightGaugeDimensions.buildingDepth,
          center: BimVec3(LightGaugeDimensions.centerX, 0.04, LightGaugeDimensions.centerZ),
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
          label: 'Survey Grid',
          mesh: BimMesh.box(width: 0.02, height: 0.01, depth: LightGaugeDimensions.buildingDepth),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(i * (LightGaugeDimensions.buildingWidth / 6), 0.05, 0),
          minStage: 0,
          buildProgress: 0,
        ),
      );
    }
  }

  void _excavationFootings(List<BimEntity> e) {
    for (var i = 0; i <= 6; i++) {
      e.add(
        BimEntity(
          id: 'setout_line_$i',
          label: 'Building Line',
          mesh: BimMesh.box(width: 0.015, height: 0.01, depth: LightGaugeDimensions.buildingDepth),
          color: const Color(0xFF0F172A),
          category: BimEntityCategory.survey,
          position: BimVec3(i * (LightGaugeDimensions.buildingWidth / 6), 0.06, 0),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'excavation',
        label: 'Excavation',
        mesh: BimMesh.box(
          width: LightGaugeDimensions.buildingWidth + 0.8,
          height: LightGaugeDimensions.trenchDepth,
          depth: LightGaugeDimensions.buildingDepth + 0.8,
          center: BimVec3(LightGaugeDimensions.centerX, -LightGaugeDimensions.trenchDepth / 2 + 0.05, LightGaugeDimensions.centerZ),
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
          width: LightGaugeDimensions.buildingWidth + 1,
          height: 0.15,
          depth: LightGaugeDimensions.buildingDepth + 1,
          center: BimVec3(LightGaugeDimensions.centerX, -LightGaugeDimensions.trenchDepth + 0.08, LightGaugeDimensions.centerZ),
        ),
        color: const Color(0xFF57534E),
        category: BimEntityCategory.excavation,
        minStage: 2,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'pcc_layer',
        label: 'PCC Layer',
        mesh: BimMesh.box(
          width: LightGaugeDimensions.buildingWidth + 0.5,
          height: LightGaugeDimensions.pccThickness,
          depth: LightGaugeDimensions.buildingDepth + 0.5,
          center: BimVec3(
            LightGaugeDimensions.centerX,
            -LightGaugeDimensions.trenchDepth + LightGaugeDimensions.pccThickness / 2,
            LightGaugeDimensions.centerZ,
          ),
        ),
        color: const Color(0xFFD1D5DB),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 3,
        buildProgress: 0,
      ),
    );
    final footPos = _columnGrid();
    for (var i = 0; i < footPos.length; i++) {
      final p = footPos[i];
      e.add(
        BimEntity(
          id: 'footing_rebar_$i',
          label: 'Footing Rebar',
          mesh: BimMesh.box(
            width: LightGaugeDimensions.footingWidth,
            height: LightGaugeDimensions.footingDepth * 0.7,
            depth: LightGaugeDimensions.footingWidth,
          ),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(p.$1, -LightGaugeDimensions.trenchDepth + LightGaugeDimensions.pccThickness, p.$2),
          minStage: 3,
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: 'footing_$i',
          label: 'RCC Footing',
          mesh: BimMesh.box(
            width: LightGaugeDimensions.footingWidth,
            height: LightGaugeDimensions.footingDepth,
            depth: LightGaugeDimensions.footingWidth,
            center: BimVec3(
              p.$1 + LightGaugeDimensions.footingWidth / 2,
              -LightGaugeDimensions.trenchDepth + LightGaugeDimensions.pccThickness + LightGaugeDimensions.footingDepth / 2,
              p.$2 + LightGaugeDimensions.footingWidth / 2,
            ),
          ),
          color: const Color(0xFF9CA3AF),
          category: BimEntityCategory.concrete,
          explodeGroup: 1,
          minStage: 3,
          buildProgress: 0,
        ),
      );
    }
  }

  void _anchorsAndTracks(List<BimEntity> e) {
    final baseY = -LightGaugeDimensions.trenchDepth + LightGaugeDimensions.pccThickness + LightGaugeDimensions.footingDepth;
    final grid = _columnGrid();
    for (var i = 0; i < grid.length; i++) {
      final p = grid[i];
      e.add(
        BimEntity(
          id: 'anchor_bolt_$i',
          label: 'Anchor Bolt',
          mesh: BimMesh.cylinder(radius: 0.012, height: 0.18),
          color: const Color(0xFF475569),
          category: BimEntityCategory.equipment,
          position: BimVec3(p.$1 + 0.05, baseY, p.$2 + 0.05),
          explodeGroup: 2,
          minStage: 4,
          pickable: i == 0,
          componentId: 'anchor_bolt',
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'base_track_front',
        label: 'Base Track',
        mesh: BimMesh.box(
          width: LightGaugeDimensions.buildingWidth,
          height: LightGaugeDimensions.trackHeight,
          depth: LightGaugeDimensions.studFlange,
          center: BimVec3(LightGaugeDimensions.centerX, baseY + LightGaugeDimensions.trackHeight / 2, 0),
        ),
        color: const Color(0xFFB0BEC5),
        category: BimEntityCategory.rebar,
        explodeGroup: 2,
        minStage: 5,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'base_track_rear',
        label: 'Base Track',
        mesh: BimMesh.box(
          width: LightGaugeDimensions.buildingWidth,
          height: LightGaugeDimensions.trackHeight,
          depth: LightGaugeDimensions.studFlange,
          center: BimVec3(LightGaugeDimensions.centerX, baseY + LightGaugeDimensions.trackHeight / 2, LightGaugeDimensions.buildingDepth),
        ),
        color: const Color(0xFFB0BEC5),
        category: BimEntityCategory.rebar,
        explodeGroup: 2,
        minStage: 5,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'base_track_side',
        label: 'Base Track',
        mesh: BimMesh.box(
          width: LightGaugeDimensions.studFlange,
          height: LightGaugeDimensions.trackHeight,
          depth: LightGaugeDimensions.buildingDepth,
          center: BimVec3(0, baseY + LightGaugeDimensions.trackHeight / 2, LightGaugeDimensions.centerZ),
        ),
        color: const Color(0xFFB0BEC5),
        category: BimEntityCategory.rebar,
        explodeGroup: 2,
        minStage: 5,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'galvanization_note',
        label: 'Galvanization Coating',
        mesh: BimMesh.box(width: 0.5, height: 0.02, depth: 0.5),
        color: const Color(0xFF94A3B8),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.4, baseY + 0.1, LightGaugeDimensions.centerZ),
        minStage: 5,
        opacity: 0.7,
        buildProgress: 0,
      ),
    );
  }

  void _studsAndColumns(List<BimEntity> e) {
    final baseY = LightGaugeDimensions.frameBaseY;
    var idx = 0;
    for (var x = 0.0; x <= LightGaugeDimensions.buildingWidth; x += LightGaugeDimensions.studSpacing) {
      for (final z in [0.0, LightGaugeDimensions.buildingDepth]) {
        e.add(
          BimEntity(
            id: 'stud_$idx',
            label: 'Steel Wall Stud',
            mesh: BimMesh.box(
              width: LightGaugeDimensions.studWeb,
              height: LightGaugeDimensions.wallHeight,
              depth: LightGaugeDimensions.studFlange,
            ),
            color: const Color(0xFF90A4AE),
            category: BimEntityCategory.rebar,
            position: BimVec3(x, baseY, z),
            explodeGroup: 3,
            minStage: 6,
            pickable: idx == 0,
            componentId: 'steel_stud',
            buildProgress: 0,
          ),
        );
        idx++;
      }
    }
    for (var z = LightGaugeDimensions.studSpacing; z < LightGaugeDimensions.buildingDepth; z += LightGaugeDimensions.studSpacing) {
      for (final x in [0.0, LightGaugeDimensions.buildingWidth]) {
        e.add(
          BimEntity(
            id: 'stud_$idx',
            label: 'Steel Wall Stud',
            mesh: BimMesh.box(
              width: LightGaugeDimensions.studFlange,
              height: LightGaugeDimensions.wallHeight,
              depth: LightGaugeDimensions.studWeb,
            ),
            color: const Color(0xFF90A4AE),
            category: BimEntityCategory.rebar,
            position: BimVec3(x, baseY, z),
            explodeGroup: 3,
            minStage: 6,
            componentId: 'steel_stud',
            buildProgress: 0,
          ),
        );
        idx++;
      }
    }
    final cols = _columnGrid();
    for (var i = 0; i < cols.length; i++) {
      final p = cols[i];
      e.add(
        BimEntity(
          id: 'steel_column_$i',
          label: 'Steel Column',
          mesh: BimMesh.box(
            width: LightGaugeDimensions.studWeb * 1.2,
            height: LightGaugeDimensions.wallHeight,
            depth: LightGaugeDimensions.studWeb * 1.2,
          ),
          color: const Color(0xFF78909C),
          category: BimEntityCategory.rebar,
          position: BimVec3(p.$1, baseY, p.$2),
          explodeGroup: 3,
          minStage: 6,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'top_track',
        label: 'Top Track',
        mesh: BimMesh.box(
          width: LightGaugeDimensions.buildingWidth,
          height: LightGaugeDimensions.trackHeight,
          depth: LightGaugeDimensions.studFlange,
          center: BimVec3(LightGaugeDimensions.centerX, baseY + LightGaugeDimensions.wallHeight, 0),
        ),
        color: const Color(0xFFB0BEC5),
        category: BimEntityCategory.rebar,
        explodeGroup: 3,
        minStage: 6,
        buildProgress: 0,
      ),
    );
  }

  void _beams(List<BimEntity> e) {
    final y = LightGaugeDimensions.frameBaseY + LightGaugeDimensions.wallHeight - LightGaugeDimensions.trackHeight;
    e.add(
      BimEntity(
        id: 'beam_front',
        label: 'Steel Beam',
        mesh: BimMesh.box(
          width: LightGaugeDimensions.buildingWidth,
          height: LightGaugeDimensions.studWeb,
          depth: LightGaugeDimensions.studFlange * 1.5,
          center: BimVec3(LightGaugeDimensions.centerX, y, 0.05),
        ),
        color: const Color(0xFF607D8B),
        category: BimEntityCategory.rebar,
        explodeGroup: 4,
        minStage: 7,
        pickable: true,
        componentId: 'steel_beam',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'beam_rear',
        label: 'Steel Beam',
        mesh: BimMesh.box(
          width: LightGaugeDimensions.buildingWidth,
          height: LightGaugeDimensions.studWeb,
          depth: LightGaugeDimensions.studFlange * 1.5,
          center: BimVec3(LightGaugeDimensions.centerX, y, LightGaugeDimensions.buildingDepth - 0.05),
        ),
        color: const Color(0xFF607D8B),
        category: BimEntityCategory.rebar,
        explodeGroup: 4,
        minStage: 7,
        componentId: 'steel_beam',
        buildProgress: 0,
      ),
    );
    for (var i = 0; i < 6; i++) {
      e.add(
        BimEntity(
          id: 'screw_$i',
          label: 'Self-Drilling Screw',
          mesh: BimMesh.cylinder(radius: 0.006, height: 0.04),
          color: const Color(0xFF1F2937),
          category: BimEntityCategory.equipment,
          position: BimVec3(0.5 + i, y, LightGaugeDimensions.centerZ),
          explodeGroup: 4,
          minStage: 7,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'gusset_0',
        label: 'Gusset Plate',
        mesh: BimMesh.box(width: 0.15, height: 0.12, depth: 0.02),
        color: const Color(0xFF546E7A),
        category: BimEntityCategory.equipment,
        position: BimVec3(0, y - 0.05, 0),
        explodeGroup: 4,
        minStage: 7,
        buildProgress: 0,
      ),
    );
  }

  void _bracing(List<BimEntity> e) {
    final baseY = LightGaugeDimensions.frameBaseY;
    final braces = [
      (0.1, 0.1, LightGaugeDimensions.buildingWidth - 0.2, LightGaugeDimensions.buildingDepth - 0.2),
      (LightGaugeDimensions.buildingWidth - 0.2, 0.1, 0.1, LightGaugeDimensions.buildingDepth - 0.2),
      (0.1, 0.1, LightGaugeDimensions.buildingWidth * 0.5, LightGaugeDimensions.buildingDepth * 0.5),
    ];
    for (var i = 0; i < braces.length; i++) {
      final b = braces[i];
      final dx = b.$3 - b.$1;
      final dz = b.$4 - b.$2;
      final len = (dx * dx + dz * dz).abs() + 0.01;
      e.add(
        BimEntity(
          id: 'brace_$i',
          label: 'Diagonal Bracing',
          mesh: BimMesh.box(width: len, height: 0.04, depth: 0.04),
          color: const Color(0xFF455A64),
          category: BimEntityCategory.wire,
          position: BimVec3(b.$1, baseY + 0.5, b.$2),
          explodeGroup: 5,
          minStage: 8,
          pickable: i == 0,
          componentId: 'steel_bracing',
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'unbraced_ghost',
        label: 'Without Bracing (unstable)',
        mesh: BimMesh.box(
          width: 1.5,
          height: LightGaugeDimensions.wallHeight,
          depth: 0.08,
          center: BimVec3(-0.6, baseY + LightGaugeDimensions.wallHeight / 2, LightGaugeDimensions.centerZ),
        ),
        color: const Color(0xFFDC2626),
        category: BimEntityCategory.annotation,
        minStage: 8,
        opacity: 0.45,
        buildProgress: 0,
      ),
    );
  }

  void _roof(List<BimEntity> e) {
    final y = LightGaugeDimensions.roofEaveY;
    final ridge = y + LightGaugeDimensions.buildingDepth * LightGaugeDimensions.roofPitch * 0.5;
    e.add(
      BimEntity(
        id: 'truss_lower',
        label: 'Truss Bottom Chord',
        mesh: BimMesh.box(
          width: LightGaugeDimensions.buildingWidth,
          height: 0.05,
          depth: 0.06,
          center: BimVec3(LightGaugeDimensions.centerX, y + 0.05, LightGaugeDimensions.centerZ),
        ),
        color: const Color(0xFF78909C),
        category: BimEntityCategory.rebar,
        explodeGroup: 6,
        minStage: 9,
        componentId: 'roof_truss',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'truss_web_0',
        label: 'Truss Web',
        mesh: BimMesh.box(width: 0.05, height: 0.5, depth: 0.05),
        color: const Color(0xFF90A4AE),
        category: BimEntityCategory.rebar,
        position: BimVec3(1.5, y + 0.1, LightGaugeDimensions.centerZ - 0.5),
        explodeGroup: 6,
        minStage: 9,
        componentId: 'roof_truss',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'truss_web_1',
        label: 'Truss Web',
        mesh: BimMesh.box(width: 0.05, height: 0.5, depth: 0.05),
        color: const Color(0xFF90A4AE),
        category: BimEntityCategory.rebar,
        position: BimVec3(4.5, y + 0.1, LightGaugeDimensions.centerZ + 0.5),
        explodeGroup: 6,
        minStage: 9,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'truss_ridge',
        label: 'Ridge Member',
        mesh: BimMesh.box(
          width: LightGaugeDimensions.buildingWidth,
          height: 0.05,
          depth: 0.06,
          center: BimVec3(LightGaugeDimensions.centerX, ridge, LightGaugeDimensions.centerZ),
        ),
        color: const Color(0xFF607D8B),
        category: BimEntityCategory.rebar,
        explodeGroup: 6,
        minStage: 9,
        pickable: true,
        componentId: 'roof_truss',
        buildProgress: 0,
      ),
    );
    for (var i = 0; i < 5; i++) {
      e.add(
        BimEntity(
          id: 'purlin_$i',
          label: 'Purlin',
          mesh: BimMesh.box(width: LightGaugeDimensions.buildingWidth, height: 0.04, depth: 0.06),
          color: const Color(0xFF90A4AE),
          category: BimEntityCategory.rebar,
          position: BimVec3(0, ridge - 0.05, 0.5 + i * 0.85),
          explodeGroup: 6,
          minStage: 10,
          buildProgress: 0,
        ),
      );
    }
    for (var i = 0; i < 6; i++) {
      e.add(
        BimEntity(
          id: 'roof_sheet_$i',
          label: 'Lightweight Roof Sheet',
          mesh: BimMesh.box(width: 1.8, height: 0.015, depth: 2.0),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.finishing,
          position: BimVec3(0.3 + (i % 3) * 1.85, ridge + 0.02, 0.3 + (i ~/ 3) * 2.0),
          explodeGroup: 6,
          minStage: 10,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'heavy_roof_ghost',
        label: 'Heavy Roof (comparison)',
        mesh: BimMesh.box(width: 2, height: 0.15, depth: 2.5),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.8, ridge, 1),
        minStage: 10,
        opacity: 0.4,
        buildProgress: 0,
      ),
    );
  }

  void _sheathingInsulation(List<BimEntity> e) {
    final baseY = LightGaugeDimensions.frameBaseY;
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'ext_sheath_$i',
          label: 'Exterior Sheathing',
          mesh: BimMesh.box(width: 2.8, height: LightGaugeDimensions.wallHeight * 0.9, depth: 0.012),
          color: const Color(0xFFD6D3D1),
          category: BimEntityCategory.masonry,
          position: BimVec3(0.1 + (i % 2) * 2.9, baseY, (i ~/ 2) * 2.2),
          explodeGroup: 7,
          minStage: 11,
          pickable: i == 0,
          componentId: 'sheathing_panel',
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'insulation_fill',
        label: 'Insulation Layer',
        mesh: BimMesh.box(
          width: LightGaugeDimensions.buildingWidth - 0.3,
          height: LightGaugeDimensions.wallHeight - 0.2,
          depth: LightGaugeDimensions.buildingDepth - 0.3,
          center: BimVec3(LightGaugeDimensions.centerX, baseY + LightGaugeDimensions.wallHeight / 2, LightGaugeDimensions.centerZ),
        ),
        color: const Color(0xFFFDE68A),
        category: BimEntityCategory.finishing,
        explodeGroup: 7,
        minStage: 12,
        opacity: 0.55,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'int_sheath',
        label: 'Interior Sheathing',
        mesh: BimMesh.box(
          width: 0.012,
          height: LightGaugeDimensions.wallHeight * 0.9,
          depth: LightGaugeDimensions.buildingDepth,
          center: BimVec3(LightGaugeDimensions.buildingWidth - 0.15, baseY + LightGaugeDimensions.wallHeight / 2, LightGaugeDimensions.centerZ),
        ),
        color: const Color(0xFFF5F5F4),
        category: BimEntityCategory.masonry,
        explodeGroup: 7,
        minStage: 13,
        buildProgress: 0,
      ),
    );
  }

  void _finishes(List<BimEntity> e) {
    final y = LightGaugeDimensions.frameBaseY + 0.9;
    e.add(
      BimEntity(
        id: 'door_frame',
        label: 'Door',
        mesh: BimMesh.box(width: 0.9, height: 2.0, depth: 0.08),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.finishing,
        position: BimVec3(LightGaugeDimensions.centerX - 0.45, y, 0),
        minStage: 13,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'window_frame',
        label: 'Window',
        mesh: BimMesh.box(width: 1.0, height: 1.0, depth: 0.06),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.finishing,
        position: BimVec3(LightGaugeDimensions.buildingWidth - 0.1, y + 0.4, LightGaugeDimensions.centerZ),
        minStage: 13,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'moisture_barrier',
        label: 'Moisture Protection',
        mesh: BimMesh.box(width: 0.01, height: LightGaugeDimensions.wallHeight, depth: LightGaugeDimensions.buildingDepth),
        color: const Color(0xFF06B6D4),
        category: BimEntityCategory.finishing,
        position: BimVec3(-0.02, LightGaugeDimensions.frameBaseY, 0),
        minStage: 13,
        opacity: 0.5,
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
          mesh: BimMesh.cylinder(radius: 0.1, height: 0.7),
          color: const Color(0xFF166534),
          category: BimEntityCategory.terrain,
          position: BimVec3(8.0 + i, 0.35, 2 + i * 1.8),
          minStage: 14,
          buildProgress: 0,
        ),
      );
    }
  }

  List<(double, double)> _columnGrid() => [
    (0, 0),
    (LightGaugeDimensions.buildingWidth, 0),
    (0, LightGaugeDimensions.buildingDepth),
    (LightGaugeDimensions.buildingWidth, LightGaugeDimensions.buildingDepth),
    (LightGaugeDimensions.centerX, LightGaugeDimensions.centerZ),
  ];
}
