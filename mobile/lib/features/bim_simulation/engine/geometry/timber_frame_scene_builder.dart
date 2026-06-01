import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'timber_frame_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 15 Timber Frame with Lath and Plaster.
class TimberFrameSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
        _site(e);
    _settingOut(e);
    _excavation(e);
    _foundation(e);
    _timberTreatment(e);
    _columns(e);
    _beams(e);
    _bracing(e);
    _wallFrame(e);
    _laths(e);
    _wireMesh(e);
    _plaster(e);
    _roofFrame(e);
    _roofCovering(e);
    _openingsFinishing(e);
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
          width: TimberFrameDimensions.plotWidth,
          height: 0.42,
          depth: TimberFrameDimensions.plotDepth,
          center: BimVec3(TimberFrameDimensions.plotWidth / 2, -0.1, TimberFrameDimensions.plotDepth / 2),
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
          width: TimberFrameDimensions.buildingWidth,
          height: 0.02,
          depth: TimberFrameDimensions.buildingDepth,
          center: BimVec3(TimberFrameDimensions.centerX, 0.12, TimberFrameDimensions.centerZ),
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
        position: BimVec3(TimberFrameDimensions.buildingWidth + 0.5, 0.11, TimberFrameDimensions.centerZ),
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

  void _settingOut(List<BimEntity> e) {
    for (var i = 0; i <= 5; i++) {
      e.add(
        BimEntity(
          id: 'survey_grid_$i',
          label: 'Survey Grid',
          mesh: BimMesh.box(width: 0.02, height: 0.01, depth: TimberFrameDimensions.buildingDepth),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(i * (TimberFrameDimensions.buildingWidth / 5), 0.14, 0),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    for (var i = 0; i < _columnPositions().length; i++) {
      final p = _columnPositions()[i];
      e.add(
        BimEntity(
          id: 'col_marker_$i',
          label: 'Column Location',
          mesh: BimMesh.box(
            width: TimberFrameDimensions.columnSize,
            height: 0.04,
            depth: TimberFrameDimensions.columnSize,
          ),
          color: const Color(0xFFF97316),
          category: BimEntityCategory.survey,
          position: BimVec3(p.$1 - TimberFrameDimensions.columnSize / 2, 0.15, p.$2 - TimberFrameDimensions.columnSize / 2),
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
          width: TimberFrameDimensions.buildingWidth,
          height: 0.008,
          depth: 0.02,
          center: BimVec3(TimberFrameDimensions.centerX, 0.135, TimberFrameDimensions.centerZ),
        ),
        color: const Color(0xFF2563EB),
        category: BimEntityCategory.annotation,
        minStage: 1,
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
          width: TimberFrameDimensions.buildingWidth + 0.5,
          height: TimberFrameDimensions.trenchDepth,
          depth: TimberFrameDimensions.buildingDepth + 0.5,
          center: BimVec3(TimberFrameDimensions.centerX, -TimberFrameDimensions.trenchDepth / 2 + 0.05, TimberFrameDimensions.centerZ),
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
          width: TimberFrameDimensions.buildingWidth + 0.7,
          height: 0.12,
          depth: TimberFrameDimensions.buildingDepth + 0.7,
          center: BimVec3(TimberFrameDimensions.centerX, -TimberFrameDimensions.trenchDepth + 0.06, TimberFrameDimensions.centerZ),
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
        mesh: BimMesh.box(width: 0.04, height: TimberFrameDimensions.trenchDepth + 0.12, depth: 0.4),
        color: const Color(0xFFA16207),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.2, -TimberFrameDimensions.trenchDepth / 2, TimberFrameDimensions.centerZ),
        minStage: 2,
        buildProgress: 0,
      ),
    );
  }

  void _foundation(List<BimEntity> e) {
    final baseY = -TimberFrameDimensions.trenchDepth + TimberFrameDimensions.pccThickness;
    e.add(
      BimEntity(
        id: 'pcc_layer',
        label: 'PCC Blinding',
        mesh: BimMesh.box(
          width: TimberFrameDimensions.buildingWidth + 0.35,
          height: TimberFrameDimensions.pccThickness,
          depth: TimberFrameDimensions.buildingDepth + 0.35,
          center: BimVec3(TimberFrameDimensions.centerX, -TimberFrameDimensions.trenchDepth + TimberFrameDimensions.pccThickness / 2, TimberFrameDimensions.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 3,
        buildProgress: 0,
      ),
    );
    var sidx = 0;
    for (var c = 0; c < TimberFrameDimensions.stoneFoundationCourses; c++) {
      final y = baseY + c * TimberFrameDimensions.stoneCourseHeight;
      for (final p in _perimeter(0.08)) {
        e.add(
          BimEntity(
            id: 'stone_found_$sidx',
            label: 'Stone Foundation',
            mesh: BimMesh.box(width: 0.5, height: TimberFrameDimensions.stoneCourseHeight * 0.95, depth: 0.4),
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
    final plinthY = baseY + TimberFrameDimensions.stoneFoundationCourses * TimberFrameDimensions.stoneCourseHeight;
    e.add(
      BimEntity(
        id: 'plinth_beam',
        label: 'RCC Plinth Beam',
        mesh: BimMesh.box(
          width: TimberFrameDimensions.buildingWidth + 0.1,
          height: TimberFrameDimensions.plinthBeamHeight,
          depth: TimberFrameDimensions.buildingDepth + 0.1,
          center: BimVec3(TimberFrameDimensions.centerX, plinthY + TimberFrameDimensions.plinthBeamHeight / 2, TimberFrameDimensions.centerZ),
        ),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.concrete,
        explodeGroup: 2,
        minStage: 3,
        buildProgress: 0,
      ),
    );
  }

  void _timberTreatment(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'raw_timber',
        label: 'Raw Timber',
        mesh: BimMesh.box(width: 1.8, height: 0.1, depth: 0.1),
        color: const Color(0xFFD97706),
        category: BimEntityCategory.timber,
        position: BimVec3(-0.7, 0.25, TimberFrameDimensions.centerZ),
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
        position: BimVec3(-0.7, 0.42, TimberFrameDimensions.centerZ),
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
        position: BimVec3(-0.65, 0.3, TimberFrameDimensions.centerZ),
        minStage: 4,
        opacity: 0.55,
        buildProgress: 0,
      ),
    );
  }

  void _columns(List<BimEntity> e) {
    for (var i = 0; i < _columnPositions().length; i++) {
      final p = _columnPositions()[i];
      e.add(
        BimEntity(
          id: 'timber_column_$i',
          label: 'Timber Column',
          mesh: BimMesh.box(
            width: TimberFrameDimensions.columnSize,
            height: TimberFrameDimensions.wallHeight,
            depth: TimberFrameDimensions.columnSize,
            center: BimVec3(
              p.$1,
              TimberFrameDimensions.wallBaseY + TimberFrameDimensions.wallHeight / 2,
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

  void _beams(List<BimEntity> e) {
    final y = TimberFrameDimensions.wallPlateY - TimberFrameDimensions.beamDepth / 2;
    e.add(
      BimEntity(
        id: 'beam_front',
        label: 'Timber Beam',
        mesh: BimMesh.box(
          width: TimberFrameDimensions.buildingWidth,
          height: TimberFrameDimensions.beamDepth,
          depth: TimberFrameDimensions.beamWidth,
          center: BimVec3(TimberFrameDimensions.centerX, y, 0),
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
          width: TimberFrameDimensions.buildingWidth,
          height: TimberFrameDimensions.beamDepth,
          depth: TimberFrameDimensions.beamWidth,
          center: BimVec3(TimberFrameDimensions.centerX, y, TimberFrameDimensions.buildingDepth),
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
          width: TimberFrameDimensions.beamWidth,
          height: TimberFrameDimensions.beamDepth,
          depth: TimberFrameDimensions.buildingDepth,
          center: BimVec3(0, y, TimberFrameDimensions.centerZ),
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
          width: TimberFrameDimensions.beamWidth,
          height: TimberFrameDimensions.beamDepth,
          depth: TimberFrameDimensions.buildingDepth,
          center: BimVec3(TimberFrameDimensions.buildingWidth, y, TimberFrameDimensions.centerZ),
        ),
        color: const Color(0xFFB45309),
        category: BimEntityCategory.timber,
        explodeGroup: 3,
        minStage: 6,
        buildProgress: 0,
      ),
    );
  }

  void _bracing(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'brace_front_diag',
        label: 'Timber Brace',
        mesh: BimMesh.box(
          width: TimberFrameDimensions.buildingWidth * 0.85,
          height: TimberFrameDimensions.braceSize,
          depth: TimberFrameDimensions.braceSize,
          center: BimVec3(TimberFrameDimensions.centerX, TimberFrameDimensions.wallBaseY + TimberFrameDimensions.wallHeight * 0.45, 0.04),
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
          width: TimberFrameDimensions.braceSize,
          height: TimberFrameDimensions.braceSize,
          depth: TimberFrameDimensions.buildingDepth * 0.85,
          center: BimVec3(0.04, TimberFrameDimensions.wallBaseY + TimberFrameDimensions.wallHeight * 0.5, TimberFrameDimensions.centerZ),
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
          width: TimberFrameDimensions.buildingWidth * 0.7,
          height: TimberFrameDimensions.wallHeight * 0.8,
          depth: TimberFrameDimensions.buildingDepth * 0.7,
          center: BimVec3(
            TimberFrameDimensions.buildingWidth + 1.0,
            TimberFrameDimensions.wallBaseY + TimberFrameDimensions.wallHeight * 0.4,
            TimberFrameDimensions.centerZ,
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

  void _wallFrame(List<BimEntity> e) {
    final studSpacing = 0.6;
    var idx = 0;
    for (var x = studSpacing; x < TimberFrameDimensions.buildingWidth; x += studSpacing) {
      e.add(
        BimEntity(
          id: 'wall_stud_$idx',
          label: 'Wall Stud',
          mesh: BimMesh.box(
            width: 0.06,
            height: TimberFrameDimensions.wallHeight * 0.92,
            depth: 0.06,
            center: BimVec3(x, TimberFrameDimensions.wallBaseY + TimberFrameDimensions.wallHeight / 2, 0.03),
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
          width: TimberFrameDimensions.buildingWidth,
          height: 0.06,
          depth: 0.08,
          center: BimVec3(TimberFrameDimensions.centerX, TimberFrameDimensions.wallPlateY - 0.03, 0.04),
        ),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        explodeGroup: 4,
        minStage: 8,
        buildProgress: 0,
      ),
    );
  }

  void _laths(List<BimEntity> e) {
    final count = (TimberFrameDimensions.wallHeight / TimberFrameDimensions.lathSpacing).floor();
    var idx = 0;
    for (var i = 0; i < count; i++) {
      final y = TimberFrameDimensions.wallBaseY + i * TimberFrameDimensions.lathSpacing + TimberFrameDimensions.lathThickness / 2;
      e.add(
        BimEntity(
          id: 'timber_lath_$idx',
          label: 'Timber Lath',
          mesh: BimMesh.box(
            width: TimberFrameDimensions.buildingWidth - 0.15,
            height: TimberFrameDimensions.lathThickness,
            depth: 0.02,
            center: BimVec3(TimberFrameDimensions.centerX, y, 0.015),
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

  void _wireMesh(List<BimEntity> e) {
    for (var i = 0; i <= 3; i++) {
      e.add(
        BimEntity(
          id: 'wire_mesh_$i',
          label: 'Wire Mesh',
          mesh: BimMesh.box(
            width: TimberFrameDimensions.buildingWidth / 3 + 0.05,
            height: TimberFrameDimensions.wallHeight * 0.88,
            depth: 0.01,
            center: BimVec3(
              i * (TimberFrameDimensions.buildingWidth / 3) + TimberFrameDimensions.buildingWidth / 6,
              TimberFrameDimensions.wallBaseY + TimberFrameDimensions.wallHeight * 0.44,
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

  void _plaster(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'plaster_base',
        label: 'Base Plaster Coat',
        mesh: BimMesh.box(
          width: TimberFrameDimensions.buildingWidth - 0.08,
          height: TimberFrameDimensions.wallHeight * 0.9,
          depth: TimberFrameDimensions.plasterThickness,
          center: BimVec3(
            TimberFrameDimensions.centerX,
            TimberFrameDimensions.wallBaseY + TimberFrameDimensions.wallHeight * 0.45,
            -TimberFrameDimensions.plasterThickness / 2,
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
          width: TimberFrameDimensions.buildingWidth - 0.06,
          height: TimberFrameDimensions.wallHeight * 0.88,
          depth: TimberFrameDimensions.plasterThickness * 0.8,
          center: BimVec3(
            TimberFrameDimensions.centerX,
            TimberFrameDimensions.wallBaseY + TimberFrameDimensions.wallHeight * 0.45,
            -TimberFrameDimensions.plasterThickness * 0.9,
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
        position: BimVec3(1.2, TimberFrameDimensions.wallBaseY + 1.5, -0.02),
        minStage: 11,
        opacity: 0,
        buildProgress: 0,
      ),
    );
  }

  void _roofFrame(List<BimEntity> e) {
    final y = TimberFrameDimensions.wallPlateY;
    e.add(
      BimEntity(
        id: 'roof_truss_0',
        label: 'Roof Truss',
        mesh: BimMesh.box(width: TimberFrameDimensions.buildingWidth - 0.2, height: 0.08, depth: 0.1),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        position: BimVec3(0.12, y + 0.35, TimberFrameDimensions.centerZ),
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
        mesh: BimMesh.box(width: TimberFrameDimensions.buildingWidth - 0.2, height: 0.08, depth: 0.1),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        position: BimVec3(0.12, y + 0.55, TimberFrameDimensions.centerZ),
        explodeGroup: 6,
        minStage: 12,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'ridge_beam',
        label: 'Ridge Beam',
        mesh: BimMesh.box(width: 0.1, height: 0.1, depth: TimberFrameDimensions.buildingDepth - 0.2),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.timber,
        position: BimVec3(TimberFrameDimensions.centerX, TimberFrameDimensions.ridgeY - 0.05, 0.12),
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
          mesh: BimMesh.box(width: 0.06, height: 0.06, depth: TimberFrameDimensions.buildingDepth - 0.15),
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
          mesh: BimMesh.box(width: TimberFrameDimensions.buildingWidth - 0.2, height: 0.05, depth: 0.05),
          color: const Color(0xFFA16207),
          category: BimEntityCategory.timber,
          position: BimVec3(0.12, y + 0.65 + i * 0.08, TimberFrameDimensions.centerZ),
          explodeGroup: 6,
          minStage: 12,
          buildProgress: 0,
        ),
      );
    }
  }

  void _roofCovering(List<BimEntity> e) {
    final y = TimberFrameDimensions.ridgeY - 0.02;
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'cgi_sheet_$i',
          label: 'CGI Roofing',
          mesh: BimMesh.box(
            width: TimberFrameDimensions.buildingWidth / 2 - 0.05,
            height: 0.022,
            depth: TimberFrameDimensions.buildingDepth - 0.15,
            center: BimVec3(
              0.1 + (i % 2) * (TimberFrameDimensions.buildingWidth / 2),
              y,
              TimberFrameDimensions.centerZ,
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

  void _openingsFinishing(List<BimEntity> e) {
    final y = TimberFrameDimensions.wallBaseY + 0.05;
    e.add(
      BimEntity(
        id: 'door_frame',
        label: 'Door Frame',
        mesh: BimMesh.box(width: 0.95, height: 2.05, depth: 0.1),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.finishing,
        position: BimVec3(TimberFrameDimensions.centerX - 0.475, y, 0.03),
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
        position: BimVec3(0.55, y + 0.75, TimberFrameDimensions.buildingDepth - 0.05),
        explodeGroup: 5,
        minStage: 14,
        buildProgress: 0,
      ),
    );
  }

  void _comparisons(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'heavy_masonry_roof_ghost',
        label: 'Heavy Masonry Roof (reference)',
        mesh: BimMesh.box(
          width: TimberFrameDimensions.buildingWidth,
          height: 0.25,
          depth: TimberFrameDimensions.buildingDepth,
          center: BimVec3(TimberFrameDimensions.centerX, TimberFrameDimensions.ridgeY + 0.8, TimberFrameDimensions.centerZ + 1.2),
        ),
        color: const Color(0xFFEF4444),
        category: BimEntityCategory.annotation,
        minStage: 12,
        opacity: 0.3,
        buildProgress: 0,
      ),
    );
  }

  void _landscape(List<BimEntity> e) {
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'landscape_$i',
          label: 'Mountain Landscape',
          mesh: BimMesh.box(width: 0.75, height: 0.22, depth: 0.75),
          color: const Color(0xFF16A34A),
          category: BimEntityCategory.terrain,
          position: BimVec3(
            i < 2 ? 0.4 + i * 2.2 : TimberFrameDimensions.plotWidth - 1.1,
            0.11,
            i % 2 == 0 ? 0.5 : TimberFrameDimensions.plotDepth - 1.1,
          ),
          minStage: 15,
          buildProgress: 0,
        ),
      );
    }
  }

  List<(double, double)> _columnPositions() => [
        (0.08, 0.08),
        (TimberFrameDimensions.buildingWidth - 0.08, 0.08),
        (0.08, TimberFrameDimensions.buildingDepth - 0.08),
        (TimberFrameDimensions.buildingWidth - 0.08, TimberFrameDimensions.buildingDepth - 0.08),
        (TimberFrameDimensions.centerX, 0.08),
        (TimberFrameDimensions.centerX, TimberFrameDimensions.buildingDepth - 0.08),
      ];

  List<(double, double)> _perimeter(double inset) {
    final w = TimberFrameDimensions.buildingWidth;
    final dep = TimberFrameDimensions.buildingDepth;
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
