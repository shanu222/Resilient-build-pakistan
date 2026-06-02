import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'loh_kaat_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 10 Loh-Kaat Timber House.
class LohKaatSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
        _site(e);
    _settingOut(e);
    _excavation(e);
    _stoneFoundation(e);
    _timberTreatment(e);
    _timberBands(e);
    _masonryWalls(e);
    _openings(e);
    _cornerColumns(e);
    _roof(e);
    _finishing(e);
    _landscape(e);
    _comparisons(e);

    return e;
  }

  void _site(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'mountain_terrain',
        label: 'Mountain Terrain',
        mesh: BimMesh.box(
          width: LohKaatDimensions.plotWidth,
          height: 0.5,
          depth: LohKaatDimensions.plotDepth,
          center: BimVec3(LohKaatDimensions.plotWidth / 2, -0.15, LohKaatDimensions.plotDepth / 2),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.terrain,
        minStage: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'slope_pad',
        label: 'Building Platform',
        mesh: BimMesh.box(
          width: LohKaatDimensions.buildingWidth + 1.5,
          height: 0.2,
          depth: LohKaatDimensions.buildingDepth + 1.5,
          center: BimVec3(LohKaatDimensions.centerX, 0.1, LohKaatDimensions.centerZ),
        ),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.terrain,
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'drainage_path',
        label: 'Drainage Path',
        mesh: BimMesh.box(width: 0.08, height: 0.02, depth: 3),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.drainage,
        position: BimVec3(LohKaatDimensions.buildingWidth + 0.8, 0.12, LohKaatDimensions.centerZ),
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'slope_angle',
        label: 'Slope Angle',
        mesh: BimMesh.box(width: 0.04, height: 2, depth: 0.04),
        color: const Color(0xFF94A3B8),
        category: BimEntityCategory.annotation,
        position: BimVec3(0.3, 1.2, 0.3),
        minStage: 0,
        buildProgress: 0,
      ),
    );
  }

  void _settingOut(List<BimEntity> e) {
    for (var i = 0; i <= 5; i++) {
      e.add(
        BimEntity(
          id: 'grid_$i',
          label: 'Building Grid',
          mesh: BimMesh.box(width: 0.02, height: 0.01, depth: LohKaatDimensions.buildingDepth),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(i * (LohKaatDimensions.buildingWidth / 5), 0.14, 0),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    for (final c in _corners()) {
      e.add(
        BimEntity(
          id: 'corner_mark_${c.$1}_${c.$2}',
          label: 'Foundation Corner',
          mesh: BimMesh.cylinder(radius: 0.04, height: 0.6),
          color: const Color(0xFFF97316),
          category: BimEntityCategory.survey,
          position: BimVec3(c.$1, 0.12, c.$2),
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
          width: LohKaatDimensions.buildingWidth,
          height: 0.01,
          depth: 0.02,
          center: BimVec3(LohKaatDimensions.centerX, 0.15, 0),
        ),
        color: const Color(0xFF0F172A),
        category: BimEntityCategory.annotation,
        minStage: 1,
        opacity: 0.75,
        buildProgress: 0,
      ),
    );
  }

  void _excavation(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'excavation',
        label: 'Foundation Trench',
        mesh: BimMesh.box(
          width: LohKaatDimensions.buildingWidth + 0.8,
          height: LohKaatDimensions.trenchDepth,
          depth: LohKaatDimensions.buildingDepth + 0.8,
          center: BimVec3(LohKaatDimensions.centerX, -LohKaatDimensions.trenchDepth / 2 + 0.05, LohKaatDimensions.centerZ),
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
          width: LohKaatDimensions.buildingWidth + 1,
          height: 0.15,
          depth: LohKaatDimensions.buildingDepth + 1,
          center: BimVec3(LohKaatDimensions.centerX, -LohKaatDimensions.trenchDepth + 0.08, LohKaatDimensions.centerZ),
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
          width: LohKaatDimensions.buildingWidth + 0.5,
          height: LohKaatDimensions.pccThickness,
          depth: LohKaatDimensions.buildingDepth + 0.5,
          center: BimVec3(
            LohKaatDimensions.centerX,
            -LohKaatDimensions.trenchDepth + LohKaatDimensions.pccThickness / 2,
            LohKaatDimensions.centerZ,
          ),
        ),
        color: const Color(0xFFD1D5DB),
        category: BimEntityCategory.concrete,
        explodeGroup: 1,
        minStage: 3,
        buildProgress: 0,
      ),
    );
  }

  void _stoneFoundation(List<BimEntity> e) {
    final baseY = -LohKaatDimensions.trenchDepth + LohKaatDimensions.pccThickness;
    var idx = 0;
    for (var course = 0; course < LohKaatDimensions.stoneFoundationCourses; course++) {
      final y = baseY + course * LohKaatDimensions.stoneCourseHeight;
      for (final pos in _perimeter(0.15)) {
        e.add(
          BimEntity(
            id: 'stone_found_$idx',
            label: 'Stone Foundation',
            mesh: BimMesh.box(
              width: 0.55,
              height: LohKaatDimensions.stoneCourseHeight * 0.95,
              depth: 0.45,
            ),
            color: Color.lerp(
              const Color(0xFF78716C),
              const Color(0xFF57534E),
              course / LohKaatDimensions.stoneFoundationCourses,
            )!,
            category: BimEntityCategory.masonry,
            position: BimVec3(pos.$1, y, pos.$2),
            explodeGroup: 1,
            minStage: 3,
            pickable: idx == 0,
            componentId: 'stone_foundation',
            buildProgress: 0,
          ),
        );
        idx++;
      }
    }
  }

  void _timberTreatment(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'raw_timber',
        label: 'Raw Timber',
        mesh: BimMesh.box(width: 2, height: 0.12, depth: 0.12),
        color: const Color(0xFFB45309),
        category: BimEntityCategory.timber,
        position: BimVec3(-0.8, 0.3, LohKaatDimensions.centerZ),
        minStage: 4,
        opacity: 0.7,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'treated_timber',
        label: 'Treated Timber',
        mesh: BimMesh.box(width: 2, height: 0.12, depth: 0.12),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        position: BimVec3(-0.8, 0.5, LohKaatDimensions.centerZ),
        minStage: 4,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'moisture_coating',
        label: 'Moisture Protection',
        mesh: BimMesh.box(width: 0.02, height: 0.8, depth: 0.8),
        color: const Color(0xFF06B6D4),
        category: BimEntityCategory.finishing,
        position: BimVec3(-0.75, 0.35, LohKaatDimensions.centerZ),
        minStage: 4,
        opacity: 0.5,
        buildProgress: 0,
      ),
    );
  }

  void _timberBands(List<BimEntity> e) {
    _addBandRing(e, 'plinth_band', LohKaatDimensions.wallBaseY - LohKaatDimensions.bandHeight, 5);
    _addBandRing(e, 'mid_band', LohKaatDimensions.midBandY, 7);
    _addBandRing(e, 'lintel_band', LohKaatDimensions.lintelBandY, 9);
  }

  void _addBandRing(
    List<BimEntity> e,
    String prefix,
    double y,
    int minStage,
  ) {
    e.add(
      BimEntity(
        id: '${prefix}_front',
        label: 'Timber Band (Kaat)',
        mesh: BimMesh.box(
          width: LohKaatDimensions.buildingWidth + LohKaatDimensions.bandDepth,
          height: LohKaatDimensions.bandHeight,
          depth: LohKaatDimensions.bandDepth,
          center: BimVec3(LohKaatDimensions.centerX, y + LohKaatDimensions.bandHeight / 2, 0),
        ),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        explodeGroup: 2,
        minStage: minStage,
        pickable: prefix == 'plinth_band',
        componentId: 'timber_band',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: '${prefix}_rear',
        label: 'Timber Band (Kaat)',
        mesh: BimMesh.box(
          width: LohKaatDimensions.buildingWidth + LohKaatDimensions.bandDepth,
          height: LohKaatDimensions.bandHeight,
          depth: LohKaatDimensions.bandDepth,
          center: BimVec3(LohKaatDimensions.centerX, y + LohKaatDimensions.bandHeight / 2, LohKaatDimensions.buildingDepth),
        ),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        explodeGroup: 2,
        minStage: minStage,
        componentId: 'timber_band',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: '${prefix}_left',
        label: 'Timber Band (Kaat)',
        mesh: BimMesh.box(
          width: LohKaatDimensions.bandDepth,
          height: LohKaatDimensions.bandHeight,
          depth: LohKaatDimensions.buildingDepth + LohKaatDimensions.bandDepth,
          center: BimVec3(0, y + LohKaatDimensions.bandHeight / 2, LohKaatDimensions.centerZ),
        ),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        explodeGroup: 2,
        minStage: minStage,
        componentId: 'timber_band',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: '${prefix}_right',
        label: 'Timber Band (Kaat)',
        mesh: BimMesh.box(
          width: LohKaatDimensions.bandDepth,
          height: LohKaatDimensions.bandHeight,
          depth: LohKaatDimensions.buildingDepth + LohKaatDimensions.bandDepth,
          center: BimVec3(LohKaatDimensions.buildingWidth, y + LohKaatDimensions.bandHeight / 2, LohKaatDimensions.centerZ),
        ),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        explodeGroup: 2,
        minStage: minStage,
        componentId: 'timber_band',
        buildProgress: 0,
      ),
    );
    for (final c in _corners()) {
      e.add(
        BimEntity(
          id: '${prefix}_corner_${c.$1}_${c.$2}',
          label: 'Corner Interlock',
          mesh: BimMesh.box(
            width: LohKaatDimensions.bandDepth * 1.5,
            height: LohKaatDimensions.bandHeight,
            depth: LohKaatDimensions.bandDepth * 1.5,
          ),
          color: const Color(0xFF78350F),
          category: BimEntityCategory.timber,
          position: BimVec3(c.$1 - 0.02, y, c.$2 - 0.02),
          explodeGroup: 2,
          minStage: minStage,
          buildProgress: 0,
        ),
      );
    }
  }

  void _masonryWalls(List<BimEntity> e) {
    final baseY = LohKaatDimensions.wallBaseY;
    var idx = 0;
    for (var course = 0; course < LohKaatDimensions.masonryCourses; course++) {
      final y = baseY + course * LohKaatDimensions.masonryCourseHeight;
      for (final pos in _perimeter(0)) {
        e.add(
          BimEntity(
            id: 'masonry_$idx',
            label: 'Masonry Wall',
            mesh: BimMesh.box(
              width: 0.5,
              height: LohKaatDimensions.masonryCourseHeight * 0.92,
              depth: 0.42,
            ),
            color: Color.lerp(
              const Color(0xFFB45309),
              const Color(0xFF92400E),
              (course % 4) / 4,
            )!,
            category: BimEntityCategory.masonry,
            position: BimVec3(pos.$1, y, pos.$2),
            explodeGroup: 3,
            minStage: 6,
            pickable: idx == 0,
            componentId: 'masonry_wall',
            buildProgress: 0,
          ),
        );
        if (course % 3 == 0) {
          e.add(
            BimEntity(
              id: 'mud_mortar_$idx',
              label: 'Mud Mortar Joint',
              mesh: BimMesh.box(width: 0.52, height: 0.02, depth: 0.44),
              color: const Color(0xFFD6D3D1),
              category: BimEntityCategory.masonry,
              position: BimVec3(pos.$1, y - 0.01, pos.$2),
              explodeGroup: 3,
              minStage: 6,
              buildProgress: 0,
            ),
          );
        }
        idx++;
      }
    }
  }

  void _openings(List<BimEntity> e) {
    final y = LohKaatDimensions.wallBaseY + 0.8;
    e.add(
      BimEntity(
        id: 'door_frame',
        label: 'Door Frame',
        mesh: BimMesh.box(width: 0.9, height: 2.0, depth: 0.1),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.timber,
        position: BimVec3(LohKaatDimensions.centerX - 0.45, y, 0),
        minStage: 8,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'window_frame',
        label: 'Window Frame',
        mesh: BimMesh.box(width: 1.0, height: 1.0, depth: 0.08),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.timber,
        position: BimVec3(LohKaatDimensions.buildingWidth - 0.1, y + 0.4, LohKaatDimensions.centerZ),
        minStage: 8,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'opening_reinf',
        label: 'Timber Opening Reinforcement',
        mesh: BimMesh.box(width: 1.1, height: 0.1, depth: 0.1),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        position: BimVec3(LohKaatDimensions.centerX - 0.55, y + 2.1, 0),
        minStage: 8,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'stress_marker',
        label: 'Stress Concentration',
        mesh: BimMesh.box(width: 0.05, height: 0.6, depth: 0.05),
        color: const Color(0xFFF97316),
        category: BimEntityCategory.annotation,
        position: BimVec3(LohKaatDimensions.centerX + 0.5, y + 1, 0.05),
        minStage: 8,
        opacity: 0.8,
        buildProgress: 0,
      ),
    );
  }

  void _cornerColumns(List<BimEntity> e) {
    final baseY = LohKaatDimensions.wallBaseY;
    for (var i = 0; i < 4; i++) {
      final c = _corners()[i];
      e.add(
        BimEntity(
          id: 'timber_column_$i',
          label: 'Timber Column',
          mesh: BimMesh.box(
            width: 0.12,
            height: LohKaatDimensions.wallHeight,
            depth: 0.12,
          ),
          color: const Color(0xFF78350F),
          category: BimEntityCategory.timber,
          position: BimVec3(c.$1, baseY, c.$2),
          explodeGroup: 2,
          minStage: 10,
          pickable: i == 0,
          componentId: 'corner_reinforcement',
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'timber_beam_tie',
        label: 'Timber Beam',
        mesh: BimMesh.box(
          width: LohKaatDimensions.buildingWidth,
          height: 0.1,
          depth: 0.1,
          center: BimVec3(LohKaatDimensions.centerX, baseY + LohKaatDimensions.wallHeight - 0.05, LohKaatDimensions.centerZ),
        ),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        explodeGroup: 2,
        minStage: 10,
        buildProgress: 0,
      ),
    );
  }

  void _roof(List<BimEntity> e) {
    final y = LohKaatDimensions.roofBaseY;
    for (var i = 0; i < 6; i++) {
      e.add(
        BimEntity(
          id: 'rafter_$i',
          label: 'Rafter',
          mesh: BimMesh.box(width: 0.08, height: 0.08, depth: 2.2),
          color: const Color(0xFF92400E),
          category: BimEntityCategory.timber,
          position: BimVec3(0.4 + i * 0.85, y + 0.2, 0.5),
          explodeGroup: 4,
          minStage: 11,
          componentId: 'roof_frame',
          buildProgress: 0,
        ),
      );
    }
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'purlin_$i',
          label: 'Purlin',
          mesh: BimMesh.box(width: LohKaatDimensions.buildingWidth, height: 0.07, depth: 0.07),
          color: const Color(0xFF78350F),
          category: BimEntityCategory.timber,
          position: BimVec3(0, y + 0.35 + i * 0.08, 0.8 + i * 0.9),
          explodeGroup: 4,
          minStage: 11,
          pickable: i == 0,
          componentId: 'roof_frame',
          buildProgress: 0,
        ),
      );
    }
    for (var i = 0; i < 6; i++) {
      e.add(
        BimEntity(
          id: 'roof_sheet_$i',
          label: 'CGI Roof Sheet',
          mesh: BimMesh.box(width: 1.6, height: 0.02, depth: 2.0),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.finishing,
          position: BimVec3(0.3 + (i % 3) * 1.65, y + 0.45, 0.3 + (i ~/ 3) * 2),
          explodeGroup: 4,
          minStage: 12,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'heavy_roof_ghost',
        label: 'Heavy Roof (comparison)',
        mesh: BimMesh.box(width: 2, height: 0.12, depth: 2.5),
        color: const Color(0xFF57534E),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.7, y + 0.3, 1),
        minStage: 11,
        opacity: 0.4,
        buildProgress: 0,
      ),
    );
  }

  void _finishing(List<BimEntity> e) {
    final y = LohKaatDimensions.wallBaseY;
    e.add(
      BimEntity(
        id: 'wall_plaster',
        label: 'Wall Finish',
        mesh: BimMesh.box(
          width: 0.02,
          height: LohKaatDimensions.wallHeight,
          depth: LohKaatDimensions.buildingDepth,
          center: BimVec3(LohKaatDimensions.buildingWidth + 0.02, y + LohKaatDimensions.wallHeight / 2, LohKaatDimensions.centerZ),
        ),
        color: const Color(0xFFF5F5F4),
        category: BimEntityCategory.finishing,
        explodeGroup: 3,
        minStage: 13,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'floor_finish',
        label: 'Flooring',
        mesh: BimMesh.box(
          width: LohKaatDimensions.buildingWidth - 0.2,
          height: 0.03,
          depth: LohKaatDimensions.buildingDepth - 0.2,
          center: BimVec3(LohKaatDimensions.centerX, y - 0.02, LohKaatDimensions.centerZ),
        ),
        color: const Color(0xFFD6D3D1),
        category: BimEntityCategory.finishing,
        minStage: 13,
        buildProgress: 0,
      ),
    );
  }

  void _landscape(List<BimEntity> e) {
    for (var i = 0; i < 5; i++) {
      e.add(
        BimEntity(
          id: 'mountain_tree_$i',
          label: 'Mountain Landscape',
          mesh: BimMesh.cylinder(radius: 0.12, height: 1.0),
          color: const Color(0xFF166534),
          category: BimEntityCategory.terrain,
          position: BimVec3(9 + i * 0.7, 0.5 + i * 0.1, 1 + i * 1.5),
          minStage: 14,
          buildProgress: 0,
        ),
      );
    }
  }

  void _comparisons(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'no_band_wall_ghost',
        label: 'Without Timber Bands',
        mesh: BimMesh.box(
          width: 1.2,
          height: LohKaatDimensions.wallHeight,
          depth: 0.5,
          center: BimVec3(-0.7, LohKaatDimensions.wallBaseY + LohKaatDimensions.wallHeight / 2, LohKaatDimensions.centerZ),
        ),
        color: const Color(0xFFDC2626),
        category: BimEntityCategory.annotation,
        minStage: 0,
        opacity: 0.5,
        buildProgress: 1,
      ),
    );
    e.add(
      BimEntity(
        id: 'with_band_ghost',
        label: 'With Timber Bands',
        mesh: BimMesh.box(
          width: 0.08,
          height: LohKaatDimensions.wallHeight,
          depth: 0.08,
          center: BimVec3(-0.55, LohKaatDimensions.wallBaseY + LohKaatDimensions.wallHeight / 2, LohKaatDimensions.centerZ),
        ),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.annotation,
        minStage: 0,
        opacity: 0.6,
        buildProgress: 1,
      ),
    );
  }

  List<(double, double)> _corners() => [
    (0, 0),
    (LohKaatDimensions.buildingWidth, 0),
    (0, LohKaatDimensions.buildingDepth),
    (LohKaatDimensions.buildingWidth, LohKaatDimensions.buildingDepth),
  ];

  List<(double, double)> _perimeter(double inset) {
    final w = LohKaatDimensions.buildingWidth;
    final dep = LohKaatDimensions.buildingDepth;
    final out = <(double, double)>[];
    for (var x = inset; x < w - 0.45; x += 0.48) {
      out.add((x, inset));
      out.add((x, dep - 0.42));
    }
    for (var z = inset + 0.45; z < dep - 0.45; z += 0.45) {
      out.add((inset, z));
      out.add((w - 0.42, z));
    }
    return out;
  }
}
