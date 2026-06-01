import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'cement_bamboo_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 03 Cement Bamboo Frame (single-storey seismic).
class CementBambooSceneBuilder {
  List<BimEntity> build() {
    final list = <BimEntity>[];
    final d = CementBambooDimensions;

    list.add(
      BimEntity(
        id: 'terrain',
        label: 'Terrain',
        mesh: BimMesh.box(
          width: d.plotWidth,
          height: 0.2,
          depth: d.plotDepth,
          center: BimVec3(d.plotWidth / 2, -0.1, d.plotDepth / 2),
        ),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.terrain,
        minStage: 0,
      ),
    );
    list.add(
      BimEntity(
        id: 'footprint',
        label: 'Building Footprint',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: 0.02,
          depth: d.buildingDepth,
          center: BimVec3(d.centerX, 0.04, d.centerZ),
        ),
        color: const Color(0xFF0F172A),
        category: BimEntityCategory.annotation,
        minStage: 0,
        buildProgress: 0,
      ),
    );
    list.add(
      BimEntity(
        id: 'drainage_arrow',
        label: 'Drainage Direction',
        mesh: BimMesh.box(width: 0.08, height: 0.02, depth: 1.8),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.buildingWidth + 0.3, 0.1, d.centerZ),
        minStage: 0,
        buildProgress: 0,
      ),
    );

    _settingOut(list, d);
    _excavation(list, d);
    _foundation(list, d);
    _treatment(list, d);
    _columns(list, d);
    _beams(list, d);
    _bracing(list, d);
    _wallFrame(list, d);
    _wireMesh(list, d);
    _plaster(list, d);
    _roofTruss(list, d);
    _roofSheets(list, d);
    _anchors(list, d);
    _finishing(list, d);
    _landscape(list, d);

    return list;
  }

  void _settingOut(List<BimEntity> e, CementBambooDimensions d) {
    for (var ix = 0; ix <= 3; ix++) {
      for (var iz = 0; iz <= 2; iz++) {
        e.add(
          BimEntity(
            id: 'grid_${ix}_$iz',
            label: 'Grid',
            mesh: BimMesh.cylinder(radius: 0.015, height: 0.02, segments: 6),
            color: const Color(0xFF94A3B8),
            category: BimEntityCategory.grid,
            position: BimVec3(ix * d.gridSpacingX, 0.06, iz * d.gridSpacingZ),
            minStage: 1,
            buildProgress: 0,
          ),
        );
      }
    }
    for (var i = 0; i < 6; i++) {
      final x = (i % 3) * d.gridSpacingX;
      final z = (i ~/ 3) * d.gridSpacingZ;
      e.add(
        BimEntity(
          id: 'col_marker_$i',
          label: 'Column Position',
          mesh: BimMesh.box(width: 0.2, height: 0.04, depth: 0.2),
          color: const Color(0xFFF97316),
          category: BimEntityCategory.survey,
          position: BimVec3(x, 0.08, z),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
  }

  void _excavation(List<BimEntity> e, CementBambooDimensions d) {
    e.add(
      BimEntity(
        id: 'excavation_trench',
        label: 'Excavation',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.6,
          height: d.trenchDepth,
          depth: d.buildingDepth + 0.6,
          center: BimVec3(d.centerX, -d.trenchDepth / 2 + 0.05, d.centerZ),
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
          width: d.buildingWidth + 0.8,
          height: 0.15,
          depth: d.buildingDepth + 0.8,
          center: BimVec3(d.centerX, -d.trenchDepth + 0.08, d.centerZ),
        ),
        color: const Color(0xFF57534E),
        category: BimEntityCategory.excavation,
        minStage: 2,
        buildProgress: 0,
      ),
    );
  }

  void _foundation(List<BimEntity> e, CementBambooDimensions d) {
    final baseY = -d.trenchDepth + d.pccThickness;
    e.add(
      BimEntity(
        id: 'pcc_layer',
        label: 'PCC Layer',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.5,
          height: d.pccThickness,
          depth: d.buildingDepth + 0.5,
          center: BimVec3(d.centerX, -d.trenchDepth + d.pccThickness / 2, d.centerZ),
        ),
        color: const Color(0xFFD1D5DB),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 3,
        pickable: true,
        componentId: 'foundation',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'strip_footing',
        label: 'Strip Footing',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.4,
          height: d.footingDepth,
          depth: d.buildingDepth + 0.4,
          center: BimVec3(d.centerX, baseY + d.footingDepth / 2, d.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 3,
        componentId: 'foundation',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'foundation_beam',
        label: 'Foundation Beam',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.2,
          height: d.foundationBeamHeight,
          depth: d.buildingDepth + 0.2,
          center: BimVec3(
            d.centerX,
            baseY + d.footingDepth + d.foundationBeamHeight / 2,
            d.centerZ,
          ),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 3,
        componentId: 'foundation',
        buildProgress: 0,
      ),
    );
  }

  void _treatment(List<BimEntity> e, CementBambooDimensions d) {
    e.add(
      BimEntity(
        id: 'treatment_tank',
        label: 'Treatment Tank',
        mesh: BimMesh.box(width: 2.0, height: 0.8, depth: 1.2),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.equipment,
        position: BimVec3(-1.2, 0, d.buildingDepth + 1),
        minStage: 4,
        buildProgress: 0,
      ),
    );
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'bamboo_raw_$i',
          label: 'Raw Bamboo',
          mesh: BimMesh.cylinder(
            radius: d.columnSize / 2,
            height: 3.0,
            segments: 10,
          ),
          color: const Color(0xFFD97706),
          category: BimEntityCategory.bamboo,
          position: BimVec3(-0.8 + i * 0.4, 0.1, d.buildingDepth + 1.5),
          minStage: 4,
          buildProgress: 0,
        ),
      );
    }
  }

  void _columns(List<BimEntity> e, CementBambooDimensions d) {
    final baseY = -d.trenchDepth + d.pccThickness + d.footingDepth + d.foundationBeamHeight;
    var i = 0;
    for (var ix = 0; ix <= 2; ix++) {
      for (var iz = 0; iz <= 2; iz++) {
        if (ix == 0 && iz == 0) continue; // skip one for door zone visual
        e.add(
          BimEntity(
            id: 'column_$i',
            label: 'Bamboo Column',
            mesh: BimMesh.cylinder(
              radius: d.columnSize / 2,
              height: d.columnHeight,
              segments: 12,
            ),
            color: const Color(0xFF65A30D),
            category: BimEntityCategory.bamboo,
            position: BimVec3(ix * d.gridSpacingX, baseY, iz * d.gridSpacingZ),
            explodeGroup: 2,
            minStage: 5,
            pickable: i == 0,
            componentId: 'bamboo_column',
            buildProgress: 0,
          ),
        );
        e.add(
          BimEntity(
            id: 'col_base_$i',
            label: 'Column Base Connection',
            mesh: BimMesh.box(width: 0.18, height: 0.08, depth: 0.18),
            color: const Color(0xFF475569),
            category: BimEntityCategory.rebar,
            position: BimVec3(ix * d.gridSpacingX, baseY, iz * d.gridSpacingZ),
            minStage: 5,
            buildProgress: 0,
          ),
        );
        i++;
      }
    }
  }

  void _beams(List<BimEntity> e, CementBambooDimensions d) {
    final beamY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.foundationBeamHeight +
        d.columnHeight;
    // Perimeter beams X direction
    for (var z = 0; z <= 2; z++) {
      e.add(
        BimEntity(
          id: 'beam_x_$z',
          label: 'Bamboo Beam',
          mesh: BimMesh.box(
            width: d.buildingWidth,
            height: d.beamDepth,
            depth: d.beamWidth,
            center: BimVec3(d.centerX, beamY + d.beamDepth / 2, z * d.gridSpacingZ),
          ),
          color: const Color(0xFF84CC16),
          category: BimEntityCategory.bamboo,
          explodeGroup: 2,
          minStage: 6,
          pickable: z == 0,
          componentId: 'bamboo_beam',
          buildProgress: 0,
        ),
      );
    }
    for (var x = 0; x <= 2; x++) {
      e.add(
        BimEntity(
          id: 'beam_z_$x',
          label: 'Bamboo Beam',
          mesh: BimMesh.box(
            width: d.beamWidth,
            height: d.beamDepth,
            depth: d.buildingDepth,
            center: BimVec3(x * d.gridSpacingX, beamY + d.beamDepth / 2, d.centerZ),
          ),
          color: const Color(0xFF84CC16),
          category: BimEntityCategory.bamboo,
          explodeGroup: 2,
          minStage: 6,
          buildProgress: 0,
        ),
      );
    }
  }

  void _bracing(List<BimEntity> e, CementBambooDimensions d) {
    final baseY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.foundationBeamHeight;
    final pairs = [
      (0.0, 0.0, d.gridSpacingX, d.gridSpacingZ),
      (d.gridSpacingX * 2, 0.0, d.gridSpacingX, d.gridSpacingZ * 2),
      (0.0, d.gridSpacingZ * 2, d.gridSpacingX * 2, d.gridSpacingZ),
    ];
    for (var i = 0; i < pairs.length; i++) {
      final p = pairs[i];
      final len = _len(p.$1, p.$2, p.$3, p.$4);
      e.add(
        BimEntity(
          id: 'brace_$i',
          label: 'Diagonal Brace',
          mesh: BimMesh.box(width: len, height: d.columnSize * 0.8, depth: d.columnSize * 0.6),
          color: const Color(0xFF4D7C0F),
          category: BimEntityCategory.bamboo,
          position: BimVec3(p.$1, baseY + d.columnHeight * 0.5, p.$2),
          explodeGroup: 2,
          minStage: 7,
          pickable: i == 0,
          componentId: 'cross_bracing',
          buildProgress: 0,
        ),
      );
    }
    // Ghost frame without bracing (shown dim in structural compare - separate entity)
    e.add(
      BimEntity(
        id: 'frame_no_brace_ghost',
        label: 'Frame Without Bracing',
        mesh: BimMesh.box(width: 0.05, height: d.columnHeight, depth: 0.05),
        color: const Color(0xFFEF4444),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.buildingWidth + 0.5, baseY, 0),
        minStage: 7,
        opacity: 0.4,
        buildProgress: 0,
      ),
    );
  }

  void _wallFrame(List<BimEntity> e, CementBambooDimensions d) {
    final baseY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.foundationBeamHeight;
    for (var i = 0; i < 8; i++) {
      final t = i / 7;
      e.add(
        BimEntity(
          id: 'wall_nog_$i',
          label: 'Wall Frame Member',
          mesh: BimMesh.cylinder(radius: 0.035, height: d.columnHeight * 0.9, segments: 8),
          color: const Color(0xFFA3E635),
          category: BimEntityCategory.bamboo,
          position: BimVec3(t * d.buildingWidth, baseY + d.columnHeight * 0.05, 0.05),
          explodeGroup: 3,
          minStage: 8,
          buildProgress: 0,
        ),
      );
    }
  }

  void _wireMesh(List<BimEntity> e, CementBambooDimensions d) {
    final baseY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.foundationBeamHeight;
    e.add(
      BimEntity(
        id: 'wire_mesh_walls',
        label: 'Wire Mesh',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.meshOffset * 2,
          height: d.columnHeight,
          depth: d.buildingDepth + d.meshOffset * 2,
          center: BimVec3(
            d.centerX,
            baseY + d.columnHeight / 2,
            d.centerZ,
          ),
        ),
        color: const Color(0xFFD4D4D8),
        category: BimEntityCategory.wire,
        explodeGroup: 3,
        minStage: 9,
        pickable: true,
        componentId: 'wire_mesh',
        buildProgress: 0,
        opacity: 0.55,
      ),
    );
  }

  void _plaster(List<BimEntity> e, CementBambooDimensions d) {
    final baseY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.foundationBeamHeight;
    e.add(
      BimEntity(
        id: 'cement_plaster',
        label: 'Cement Plaster',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.08,
          height: d.columnHeight,
          depth: d.buildingDepth + 0.08,
          center: BimVec3(d.centerX, baseY + d.columnHeight / 2, d.centerZ),
        ),
        color: const Color(0xFFE7E5E4),
        category: BimEntityCategory.masonry,
        explodeGroup: 3,
        minStage: 10,
        buildProgress: 0,
      ),
    );
  }

  void _roofTruss(List<BimEntity> e, CementBambooDimensions d) {
    final trussY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.foundationBeamHeight +
        d.columnHeight +
        d.beamDepth;
    for (var t = 0; t < 3; t++) {
      e.add(
        BimEntity(
          id: 'truss_chord_top_$t',
          label: 'Truss Top Chord',
          mesh: BimMesh.box(width: 0.08, height: 0.08, depth: d.buildingDepth + 0.4),
          color: const Color(0xFF65A30D),
          category: BimEntityCategory.bamboo,
          position: BimVec3(1.0 + t * 2.0, trussY + 1.2, -0.2),
          explodeGroup: 4,
          minStage: 11,
          pickable: t == 0,
          componentId: 'roof_truss',
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: 'truss_web_$t',
          label: 'Truss Web',
          mesh: BimMesh.box(width: 0.06, height: 1.0, depth: 0.06),
          color: const Color(0xFF84CC16),
          category: BimEntityCategory.bamboo,
          position: BimVec3(1.0 + t * 2.0, trussY + 0.6, d.centerZ),
          explodeGroup: 4,
          minStage: 11,
          buildProgress: 0,
        ),
      );
    }
    for (var p = 0; p < 5; p++) {
      e.add(
        BimEntity(
          id: 'purlin_$p',
          label: 'Bamboo Purlin',
          mesh: BimMesh.cylinder(radius: 0.04, height: d.buildingWidth + 0.3, segments: 8),
          color: const Color(0xFF65A30D),
          category: BimEntityCategory.bamboo,
          position: BimVec3(-0.15, trussY + 1.25, p * (d.buildingDepth / 4)),
          explodeGroup: 4,
          minStage: 11,
          buildProgress: 0,
        ),
      );
    }
  }

  void _roofSheets(List<BimEntity> e, CementBambooDimensions d) {
    final roofY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.foundationBeamHeight +
        d.columnHeight +
        d.beamDepth +
        1.35;
    e.add(
      BimEntity(
        id: 'cgi_roof',
        label: 'CGI Roofing',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.5,
          height: 0.02,
          depth: d.buildingDepth + 0.8,
          center: BimVec3(d.centerX, roofY, d.centerZ),
        ),
        color: const Color(0xFF94A3B8),
        category: BimEntityCategory.finishing,
        explodeGroup: 4,
        minStage: 12,
        buildProgress: 0,
      ),
    );
    // Heavy roof comparison ghost
    e.add(
      BimEntity(
        id: 'heavy_roof_ghost',
        label: 'Heavy Roof (comparison)',
        mesh: BimMesh.box(width: 2, height: 0.25, depth: 2),
        color: const Color(0xFFEF4444),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.buildingWidth + 1, roofY, 1),
        minStage: 12,
        opacity: 0.5,
        buildProgress: 0,
      ),
    );
  }

  void _anchors(List<BimEntity> e, CementBambooDimensions d) {
    final roofY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.foundationBeamHeight +
        d.columnHeight +
        1.3;
    for (var i = 0; i < 8; i++) {
      e.add(
        BimEntity(
          id: 'roof_anchor_$i',
          label: 'Roof Anchor',
          mesh: BimMesh.cylinder(radius: 0.01, height: 0.2, segments: 6),
          color: const Color(0xFF475569),
          category: BimEntityCategory.rebar,
          position: BimVec3(
            0.3 + (i % 4) * 1.5,
            roofY,
            i < 4 ? 0.2 : d.buildingDepth - 0.2,
          ),
          explodeGroup: 4,
          minStage: 13,
          pickable: i == 0,
          componentId: 'roof_anchorage',
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'tie_down_strap',
        label: 'Tie-Down Strap',
        mesh: BimMesh.box(width: 0.04, height: 0.5, depth: 0.04),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.wire,
        position: BimVec3(0, roofY - 0.25, 0),
        minStage: 13,
        buildProgress: 0,
      ),
    );
  }

  void _finishing(List<BimEntity> e, CementBambooDimensions d) {
    final baseY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.foundationBeamHeight;
    e.add(
      BimEntity(
        id: 'door',
        label: 'Door',
        mesh: BimMesh.box(width: 0.9, height: 2.0, depth: 0.08),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.finishing,
        position: BimVec3(d.centerX - 0.45, baseY, 0),
        minStage: 14,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'window',
        label: 'Window',
        mesh: BimMesh.box(width: 1.0, height: 0.9, depth: 0.06),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.finishing,
        position: BimVec3(d.buildingWidth - 0.1, baseY + 1.0, d.centerZ),
        minStage: 14,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'floor_finish',
        label: 'Floor Finish',
        mesh: BimMesh.box(
          width: d.buildingWidth - 0.2,
          height: 0.05,
          depth: d.buildingDepth - 0.2,
          center: BimVec3(d.centerX, baseY + 0.025, d.centerZ),
        ),
        color: const Color(0xFFD6D3D1),
        category: BimEntityCategory.finishing,
        minStage: 14,
        buildProgress: 0,
      ),
    );
  }

  void _landscape(List<BimEntity> e, CementBambooDimensions d) {
    for (var i = 0; i < 3; i++) {
      e.add(
        BimEntity(
          id: 'landscape_$i',
          label: 'Landscaping',
          mesh: BimMesh.cylinder(radius: 0.25, height: 0.15, segments: 8),
          color: const Color(0xFF22C55E),
          category: BimEntityCategory.finishing,
          position: BimVec3(d.plotWidth - 1.5, 0.08, 2 + i * 2),
          minStage: 15,
          buildProgress: 0,
        ),
      );
    }
  }

  double _len(double x1, double z1, double x2, double z2) {
    final dx = x2 - x1;
    final dz = z2 - z1;
    return (dx * dx + dz * dz).sqrtLike();
  }
}

extension on double {
  double sqrtLike() {
    if (this <= 0) return 0;
    var r = this;
    for (var i = 0; i < 10; i++) {
      r = (r + this / r) / 2;
    }
    return r;
  }
}
