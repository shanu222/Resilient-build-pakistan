import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'timber_frame_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 15 Timber Frame with Lath and Plaster.
class TimberFrameSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
    final d = TimberFrameDimensions;

    _site(e, d);
    _settingOut(e, d);
    _excavation(e, d);
    _foundation(e, d);
    _timberTreatment(e, d);
    _columns(e, d);
    _beams(e, d);
    _bracing(e, d);
    _wallFrame(e, d);
    _laths(e, d);
    _wireMesh(e, d);
    _plaster(e, d);
    _roofFrame(e, d);
    _roofCovering(e, d);
    _openingsFinishing(e, d);
    _comparisons(e, d);
    _landscape(e, d);

    return e;
  }

  void _site(List<BimEntity> e, TimberFrameDimensions d) {
    e.add(
      BimEntity(
        id: 'mountain_terrain',
        label: 'Mountain Terrain',
        mesh: BimMesh.box(
          width: d.plotWidth,
          height: 0.42,
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
        id: 'footprint',
        label: 'Building Footprint',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: 0.02,
          depth: d.buildingDepth,
          center: BimVec3(d.centerX, 0.12, d.centerZ),
        ),
        color: const Color(0xFF0F172A),
        category: BimEntityCategory.annotation,
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'drainage_path',
        label: 'Drainage Path',
        mesh: BimMesh.box(width: 0.1, height: 0.02, depth: 2.2),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.drainage,
        position: BimVec3(d.buildingWidth + 0.5, 0.11, d.centerZ),
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'slope_marker',
        label: 'Slope Angle',
        mesh: BimMesh.box(width: 0.04, height: 1.8, depth: 0.04),
        color: const Color(0xFF94A3B8),
        category: BimEntityCategory.annotation,
        position: BimVec3(0.25, 1.0, 0.3),
        minStage: 0,
        buildProgress: 0,
      ),
    );
  }

  void _settingOut(List<BimEntity> e, TimberFrameDimensions d) {
    for (var i = 0; i <= 5; i++) {
      e.add(
        BimEntity(
          id: 'survey_grid_$i',
          label: 'Survey Grid',
          mesh: BimMesh.box(width: 0.02, height: 0.01, depth: d.buildingDepth),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(i * (d.buildingWidth / 5), 0.14, 0),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    for (var i = 0; i < _columnPositions(d).length; i++) {
      final p = _columnPositions(d)[i];
      e.add(
        BimEntity(
          id: 'col_marker_$i',
          label: 'Column Location',
          mesh: BimMesh.box(
            width: d.columnSize,
            height: 0.04,
            depth: d.columnSize,
          ),
          color: const Color(0xFFF97316),
          category: BimEntityCategory.survey,
          position: BimVec3(p.$1 - d.columnSize / 2, 0.15, p.$2 - d.columnSize / 2),
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
          width: d.buildingWidth,
          height: 0.008,
          depth: 0.02,
          center: BimVec3(d.centerX, 0.135, d.centerZ),
        ),
        color: const Color(0xFF2563EB),
        category: BimEntityCategory.annotation,
        minStage: 1,
        buildProgress: 0,
      ),
    );
  }

  void _excavation(List<BimEntity> e, TimberFrameDimensions d) {
    e.add(
      BimEntity(
        id: 'excavation',
        label: 'Excavation',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.5,
          height: d.trenchDepth,
          depth: d.buildingDepth + 0.5,
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
        label: 'Bearing Strata',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.7,
          height: 0.12,
          depth: d.buildingDepth + 0.7,
          center: BimVec3(d.centerX, -d.trenchDepth + 0.06, d.centerZ),
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
        mesh: BimMesh.box(width: 0.04, height: d.trenchDepth + 0.12, depth: 0.4),
        color: const Color(0xFFA16207),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.2, -d.trenchDepth / 2, d.centerZ),
        minStage: 2,
        buildProgress: 0,
      ),
    );
  }

  void _foundation(List<BimEntity> e, TimberFrameDimensions d) {
    final baseY = -d.trenchDepth + d.pccThickness;
    e.add(
      BimEntity(
        id: 'pcc_layer',
        label: 'PCC Blinding',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.35,
          height: d.pccThickness,
          depth: d.buildingDepth + 0.35,
          center: BimVec3(d.centerX, -d.trenchDepth + d.pccThickness / 2, d.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 3,
        buildProgress: 0,
      ),
    );
    var sidx = 0;
    for (var c = 0; c < d.stoneFoundationCourses; c++) {
      final y = baseY + c * d.stoneCourseHeight;
      for (final p in _perimeter(d, 0.08)) {
        e.add(
          BimEntity(
            id: 'stone_found_$sidx',
            label: 'Stone Foundation',
            mesh: BimMesh.box(width: 0.5, height: d.stoneCourseHeight * 0.95, depth: 0.4),
            color: const Color(0xFF78716C),
            category: BimEntityCategory.masonry,
            position: BimVec3(p.$1, y, p.$2),
            explodeGroup: 1,
            minStage: 3,
            buildProgress: 0,
          ),
        );
        sidx++;
      }
    }
    final plinthY = baseY + d.stoneFoundationCourses * d.stoneCourseHeight;
    e.add(
      BimEntity(
        id: 'plinth_beam',
        label: 'RCC Plinth Beam',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.1,
          height: d.plinthBeamHeight,
          depth: d.buildingDepth + 0.1,
          center: BimVec3(d.centerX, plinthY + d.plinthBeamHeight / 2, d.centerZ),
        ),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.concrete,
        explodeGroup: 2,
        minStage: 3,
        buildProgress: 0,
      ),
    );
  }

  void _timberTreatment(List<BimEntity> e, TimberFrameDimensions d) {
    e.add(
      BimEntity(
        id: 'raw_timber',
        label: 'Raw Timber',
        mesh: BimMesh.box(width: 1.8, height: 0.1, depth: 0.1),
        color: const Color(0xFFD97706),
        category: BimEntityCategory.timber,
        position: BimVec3(-0.7, 0.25, d.centerZ),
        minStage: 4,
        opacity: 0.65,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'treated_timber',
        label: 'Treated Timber',
        mesh: BimMesh.box(width: 1.8, height: 0.1, depth: 0.1),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        position: BimVec3(-0.7, 0.42, d.centerZ),
        minStage: 4,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'termite_coating',
        label: 'Termite Protection',
        mesh: BimMesh.box(width: 0.02, height: 0.7, depth: 0.7),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.finishing,
        position: BimVec3(-0.65, 0.3, d.centerZ),
        minStage: 4,
        opacity: 0.55,
        buildProgress: 0,
      ),
    );
  }

  void _columns(List<BimEntity> e, TimberFrameDimensions d) {
    for (var i = 0; i < _columnPositions(d).length; i++) {
      final p = _columnPositions(d)[i];
      e.add(
        BimEntity(
          id: 'timber_column_$i',
          label: 'Timber Column',
          mesh: BimMesh.box(
            width: d.columnSize,
            height: d.wallHeight,
            depth: d.columnSize,
            center: BimVec3(
              p.$1,
              d.wallBaseY + d.wallHeight / 2,
              p.$2,
            ),
          ),
          color: const Color(0xFF92400E),
          category: BimEntityCategory.timber,
          explodeGroup: 2,
          minStage: 5,
          pickable: i == 0,
          componentId: 'timber_column',
          buildProgress: 0,
        ),
      );
    }
  }

  void _beams(List<BimEntity> e, TimberFrameDimensions d) {
    final y = d.wallPlateY - d.beamDepth / 2;
    e.add(
      BimEntity(
        id: 'beam_front',
        label: 'Timber Beam',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: d.beamDepth,
          depth: d.beamWidth,
          center: BimVec3(d.centerX, y, 0),
        ),
        color: const Color(0xFFB45309),
        category: BimEntityCategory.timber,
        explodeGroup: 3,
        minStage: 6,
        pickable: true,
        componentId: 'timber_beam',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'beam_rear',
        label: 'Timber Beam',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: d.beamDepth,
          depth: d.beamWidth,
          center: BimVec3(d.centerX, y, d.buildingDepth),
        ),
        color: const Color(0xFFB45309),
        category: BimEntityCategory.timber,
        explodeGroup: 3,
        minStage: 6,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'beam_left',
        label: 'Timber Beam',
        mesh: BimMesh.box(
          width: d.beamWidth,
          height: d.beamDepth,
          depth: d.buildingDepth,
          center: BimVec3(0, y, d.centerZ),
        ),
        color: const Color(0xFFB45309),
        category: BimEntityCategory.timber,
        explodeGroup: 3,
        minStage: 6,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'beam_right',
        label: 'Timber Beam',
        mesh: BimMesh.box(
          width: d.beamWidth,
          height: d.beamDepth,
          depth: d.buildingDepth,
          center: BimVec3(d.buildingWidth, y, d.centerZ),
        ),
        color: const Color(0xFFB45309),
        category: BimEntityCategory.timber,
        explodeGroup: 3,
        minStage: 6,
        buildProgress: 0,
      ),
    );
  }

  void _bracing(List<BimEntity> e, TimberFrameDimensions d) {
    e.add(
      BimEntity(
        id: 'brace_front_diag',
        label: 'Timber Brace',
        mesh: BimMesh.box(
          width: d.buildingWidth * 0.85,
          height: d.braceSize,
          depth: d.braceSize,
          center: BimVec3(d.centerX, d.wallBaseY + d.wallHeight * 0.45, 0.04),
        ),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.timber,
        explodeGroup: 3,
        minStage: 7,
        pickable: true,
        componentId: 'timber_brace',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'brace_left_diag',
        label: 'Timber Brace',
        mesh: BimMesh.box(
          width: d.braceSize,
          height: d.braceSize,
          depth: d.buildingDepth * 0.85,
          center: BimVec3(0.04, d.wallBaseY + d.wallHeight * 0.5, d.centerZ),
        ),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.timber,
        explodeGroup: 3,
        minStage: 7,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'unbraced_frame_ghost',
        label: 'Frame Without Bracing (reference)',
        mesh: BimMesh.box(
          width: d.buildingWidth * 0.7,
          height: d.wallHeight * 0.8,
          depth: d.buildingDepth * 0.7,
          center: BimVec3(
            d.buildingWidth + 1.0,
            d.wallBaseY + d.wallHeight * 0.4,
            d.centerZ,
          ),
        ),
        color: const Color(0xFFEF4444),
        category: BimEntityCategory.annotation,
        minStage: 7,
        opacity: 0.4,
        buildProgress: 0,
      ),
    );
  }

  void _wallFrame(List<BimEntity> e, TimberFrameDimensions d) {
    final studSpacing = 0.6;
    var idx = 0;
    for (var x = studSpacing; x < d.buildingWidth; x += studSpacing) {
      e.add(
        BimEntity(
          id: 'wall_stud_$idx',
          label: 'Wall Stud',
          mesh: BimMesh.box(
            width: 0.06,
            height: d.wallHeight * 0.92,
            depth: 0.06,
            center: BimVec3(x, d.wallBaseY + d.wallHeight / 2, 0.03),
          ),
          color: const Color(0xFFA16207),
          category: BimEntityCategory.timber,
          explodeGroup: 4,
          minStage: 8,
          buildProgress: 0,
        ),
      );
      idx++;
    }
    e.add(
      BimEntity(
        id: 'wall_top_plate',
        label: 'Top Plate',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: 0.06,
          depth: 0.08,
          center: BimVec3(d.centerX, d.wallPlateY - 0.03, 0.04),
        ),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        explodeGroup: 4,
        minStage: 8,
        buildProgress: 0,
      ),
    );
  }

  void _laths(List<BimEntity> e, TimberFrameDimensions d) {
    final count = (d.wallHeight / d.lathSpacing).floor();
    var idx = 0;
    for (var i = 0; i < count; i++) {
      final y = d.wallBaseY + i * d.lathSpacing + d.lathThickness / 2;
      e.add(
        BimEntity(
          id: 'timber_lath_$idx',
          label: 'Timber Lath',
          mesh: BimMesh.box(
            width: d.buildingWidth - 0.15,
            height: d.lathThickness,
            depth: 0.02,
            center: BimVec3(d.centerX, y, 0.015),
          ),
          color: const Color(0xFFD97706),
          category: BimEntityCategory.timber,
          explodeGroup: 5,
          minStage: 9,
          pickable: i == 2,
          componentId: 'timber_lath',
          buildProgress: 0,
        ),
      );
      idx++;
    }
  }

  void _wireMesh(List<BimEntity> e, TimberFrameDimensions d) {
    for (var i = 0; i <= 3; i++) {
      e.add(
        BimEntity(
          id: 'wire_mesh_$i',
          label: 'Wire Mesh',
          mesh: BimMesh.box(
            width: d.buildingWidth / 3 + 0.05,
            height: d.wallHeight * 0.88,
            depth: 0.01,
            center: BimVec3(
              i * (d.buildingWidth / 3) + d.buildingWidth / 6,
              d.wallBaseY + d.wallHeight * 0.44,
              0.008,
            ),
          ),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.wire,
          explodeGroup: 5,
          minStage: 10,
          pickable: i == 0,
          componentId: 'wire_mesh',
          buildProgress: 0,
        ),
      );
    }
  }

  void _plaster(List<BimEntity> e, TimberFrameDimensions d) {
    e.add(
      BimEntity(
        id: 'plaster_base',
        label: 'Base Plaster Coat',
        mesh: BimMesh.box(
          width: d.buildingWidth - 0.08,
          height: d.wallHeight * 0.9,
          depth: d.plasterThickness,
          center: BimVec3(
            d.centerX,
            d.wallBaseY + d.wallHeight * 0.45,
            -d.plasterThickness / 2,
          ),
        ),
        color: const Color(0xFFD6D3D1),
        category: BimEntityCategory.finishing,
        explodeGroup: 5,
        minStage: 11,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'plaster_finish',
        label: 'Finish Plaster Coat',
        mesh: BimMesh.box(
          width: d.buildingWidth - 0.06,
          height: d.wallHeight * 0.88,
          depth: d.plasterThickness * 0.8,
          center: BimVec3(
            d.centerX,
            d.wallBaseY + d.wallHeight * 0.45,
            -d.plasterThickness * 0.9,
          ),
        ),
        color: const Color(0xFFF5F5F4),
        category: BimEntityCategory.finishing,
        explodeGroup: 5,
        minStage: 11,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'plaster_crack_hint',
        label: 'Minor Crack (EQ)',
        mesh: BimMesh.box(width: 0.03, height: 0.4, depth: 0.01),
        color: const Color(0xFFDC2626),
        category: BimEntityCategory.annotation,
        position: BimVec3(1.2, d.wallBaseY + 1.5, -0.02),
        minStage: 11,
        opacity: 0,
        buildProgress: 0,
      ),
    );
  }

  void _roofFrame(List<BimEntity> e, TimberFrameDimensions d) {
    final y = d.wallPlateY;
    e.add(
      BimEntity(
        id: 'roof_truss_0',
        label: 'Roof Truss',
        mesh: BimMesh.box(width: d.buildingWidth - 0.2, height: 0.08, depth: 0.1),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        position: BimVec3(0.12, y + 0.35, d.centerZ),
        explodeGroup: 6,
        minStage: 12,
        pickable: true,
        componentId: 'roof_truss',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'roof_truss_1',
        label: 'Roof Truss',
        mesh: BimMesh.box(width: d.buildingWidth - 0.2, height: 0.08, depth: 0.1),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        position: BimVec3(0.12, y + 0.55, d.centerZ),
        explodeGroup: 6,
        minStage: 12,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'ridge_beam',
        label: 'Ridge Beam',
        mesh: BimMesh.box(width: 0.1, height: 0.1, depth: d.buildingDepth - 0.2),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.timber,
        position: BimVec3(d.centerX, d.ridgeY - 0.05, 0.12),
        explodeGroup: 6,
        minStage: 12,
        buildProgress: 0,
      ),
    );
    for (var i = 0; i < 5; i++) {
      e.add(
        BimEntity(
          id: 'rafter_$i',
          label: 'Rafter',
          mesh: BimMesh.box(width: 0.06, height: 0.06, depth: d.buildingDepth - 0.15),
          color: const Color(0xFFB45309),
          category: BimEntityCategory.timber,
          position: BimVec3(0.5 + i * 1.0, y + 0.45, 0.15),
          explodeGroup: 6,
          minStage: 12,
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: 'purlin_$i',
          label: 'Purlin',
          mesh: BimMesh.box(width: d.buildingWidth - 0.2, height: 0.05, depth: 0.05),
          color: const Color(0xFFA16207),
          category: BimEntityCategory.timber,
          position: BimVec3(0.12, y + 0.65 + i * 0.08, d.centerZ),
          explodeGroup: 6,
          minStage: 12,
          buildProgress: 0,
        ),
      );
    }
  }

  void _roofCovering(List<BimEntity> e, TimberFrameDimensions d) {
    final y = d.ridgeY - 0.02;
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'cgi_sheet_$i',
          label: 'CGI Roofing',
          mesh: BimMesh.box(
            width: d.buildingWidth / 2 - 0.05,
            height: 0.022,
            depth: d.buildingDepth - 0.15,
            center: BimVec3(
              0.1 + (i % 2) * (d.buildingWidth / 2),
              y,
              d.centerZ,
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
    for (var i = 0; i < 6; i++) {
      e.add(
        BimEntity(
          id: 'roof_fastener_$i',
          label: 'Roof Fastener',
          mesh: BimMesh.cylinder(radius: 0.006, height: 0.04),
          color: const Color(0xFF475569),
          category: BimEntityCategory.equipment,
          position: BimVec3(0.8 + i * 0.75, y + 0.02, 0.5 + (i % 2) * 1.5),
          explodeGroup: 6,
          minStage: 13,
          buildProgress: 0,
        ),
      );
    }
  }

  void _openingsFinishing(List<BimEntity> e, TimberFrameDimensions d) {
    final y = d.wallBaseY + 0.05;
    e.add(
      BimEntity(
        id: 'door_frame',
        label: 'Door Frame',
        mesh: BimMesh.box(width: 0.95, height: 2.05, depth: 0.1),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.finishing,
        position: BimVec3(d.centerX - 0.475, y, 0.03),
        explodeGroup: 5,
        minStage: 14,
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
        position: BimVec3(0.55, y + 0.75, d.buildingDepth - 0.05),
        explodeGroup: 5,
        minStage: 14,
        buildProgress: 0,
      ),
    );
  }

  void _comparisons(List<BimEntity> e, TimberFrameDimensions d) {
    e.add(
      BimEntity(
        id: 'heavy_masonry_roof_ghost',
        label: 'Heavy Masonry Roof (reference)',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: 0.25,
          depth: d.buildingDepth,
          center: BimVec3(d.centerX, d.ridgeY + 0.8, d.centerZ + 1.2),
        ),
        color: const Color(0xFFEF4444),
        category: BimEntityCategory.annotation,
        minStage: 12,
        opacity: 0.3,
        buildProgress: 0,
      ),
    );
  }

  void _landscape(List<BimEntity> e, TimberFrameDimensions d) {
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'landscape_$i',
          label: 'Mountain Landscape',
          mesh: BimMesh.box(width: 0.75, height: 0.22, depth: 0.75),
          color: const Color(0xFF16A34A),
          category: BimEntityCategory.terrain,
          position: BimVec3(
            i < 2 ? 0.4 + i * 2.2 : d.plotWidth - 1.1,
            0.11,
            i % 2 == 0 ? 0.5 : d.plotDepth - 1.1,
          ),
          minStage: 15,
          buildProgress: 0,
        ),
      );
    }
  }

  List<(double, double)> _columnPositions(TimberFrameDimensions d) => [
        (0.08, 0.08),
        (d.buildingWidth - 0.08, 0.08),
        (0.08, d.buildingDepth - 0.08),
        (d.buildingWidth - 0.08, d.buildingDepth - 0.08),
        (d.centerX, 0.08),
        (d.centerX, d.buildingDepth - 0.08),
      ];

  List<(double, double)> _perimeter(TimberFrameDimensions d, double inset) {
    final w = d.buildingWidth;
    final dep = d.buildingDepth;
    final step = 0.45;
    final out = <(double, double)>[];
    for (var x = inset; x < w - step; x += step) {
      out.add((x, inset));
      out.add((x, dep - step - inset));
    }
    for (var z = inset + step; z < dep - step * 2; z += step) {
      out.add((inset, z));
      out.add((w - step - inset, z));
    }
    return out;
  }
}
