import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'fly_ash_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 07 Fly Ash Masonry.
class FlyAshSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
    final d = FlyAshDimensions;

    _site(e, d);
    _settingOut(e, d);
    _excavation(e, d);
    _pcc(e, d);
    _footings(e, d);
    _foundationMasonry(e, d);
    _plinthBand(e, d);
    _flyAshWalls(e, d);
    _junctionReinf(e, d);
    _openings(e, d);
    _lintelBand(e, d);
    _roofBand(e, d);
    _roofSlab(e, d);
    _dpcAndWaterproof(e, d);
    _plaster(e, d);
    _landscape(e, d);

    return e;
  }

  void _site(List<BimEntity> e, FlyAshDimensions d) {
    e.add(
      BimEntity(
        id: 'terrain',
        label: 'Terrain',
        mesh: BimMesh.box(
          width: d.plotWidth,
          height: 0.15,
          depth: d.plotDepth,
          center: BimVec3(d.plotWidth / 2, -0.075, d.plotDepth / 2),
        ),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.terrain,
        minStage: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'boundary',
        label: 'Property Boundary',
        mesh: BimMesh.box(
          width: d.plotWidth,
          height: 0.02,
          depth: 0.05,
          center: BimVec3(d.plotWidth / 2, 0.02, 0.025),
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
          width: d.buildingWidth,
          height: 0.03,
          depth: d.buildingDepth,
          center: BimVec3(d.centerX, 0.04, d.centerZ),
        ),
        color: const Color(0xFF0F172A),
        category: BimEntityCategory.annotation,
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'load_zone',
        label: 'Load Zone',
        mesh: BimMesh.box(width: 1.4, height: 0.02, depth: 1.4),
        color: const Color(0xFFF97316),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.centerX - 0.7, 0.05, d.centerZ - 0.7),
        minStage: 0,
        opacity: 0.55,
        buildProgress: 0,
      ),
    );
  }

  void _settingOut(List<BimEntity> e, FlyAshDimensions d) {
    for (var i = 0; i <= 6; i++) {
      e.add(
        BimEntity(
          id: 'grid_x_$i',
          label: 'Survey Grid',
          mesh: BimMesh.box(width: 0.02, height: 0.01, depth: d.buildingDepth + 0.5),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(i * (d.buildingWidth / 6), 0.06, -0.25),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    for (var c in _corners(d)) {
      e.add(
        BimEntity(
          id: 'corner_marker_${c.$1}_${c.$2}',
          label: 'Corner Marker',
          mesh: BimMesh.cylinder(radius: 0.035, height: 0.9),
          color: const Color(0xFFF97316),
          category: BimEntityCategory.survey,
          position: BimVec3(c.$1, 0, c.$2),
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
          height: 0.01,
          depth: 0.02,
          center: BimVec3(d.centerX, 0.07, 0),
        ),
        color: const Color(0xFF0F172A),
        category: BimEntityCategory.annotation,
        minStage: 1,
        opacity: 0.7,
        buildProgress: 0,
      ),
    );
  }

  void _excavation(List<BimEntity> e, FlyAshDimensions d) {
    e.add(
      BimEntity(
        id: 'excavation',
        label: 'Foundation Excavation',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.8,
          height: d.trenchDepth,
          depth: d.buildingDepth + 0.8,
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
        label: 'Bearing Stratum',
        mesh: BimMesh.box(
          width: d.buildingWidth + 1,
          height: 0.18,
          depth: d.buildingDepth + 1,
          center: BimVec3(d.centerX, -d.trenchDepth + 0.1, d.centerZ),
        ),
        color: const Color(0xFF57534E),
        category: BimEntityCategory.excavation,
        minStage: 2,
        buildProgress: 0,
      ),
    );
  }

  void _pcc(List<BimEntity> e, FlyAshDimensions d) {
    e.add(
      BimEntity(
        id: 'pcc_layer',
        label: 'PCC Layer',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.6,
          height: d.pccThickness,
          depth: d.buildingDepth + 0.6,
          center: BimVec3(
            d.centerX,
            -d.trenchDepth + d.pccThickness / 2,
            d.centerZ,
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

  void _footings(List<BimEntity> e, FlyAshDimensions d) {
    final baseY = -d.trenchDepth + d.pccThickness;
    final positions = _footingPositions(d);
    for (var i = 0; i < positions.length; i++) {
      final p = positions[i];
      e.add(
        BimEntity(
          id: 'footing_rebar_$i',
          label: 'Footing Rebar Cage',
          mesh: BimMesh.box(
            width: d.footingWidth,
            height: d.footingDepth * 0.7,
            depth: d.footingWidth,
          ),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(p.$1, baseY, p.$2),
          explodeGroup: 1,
          minStage: 4,
          pickable: i == 0,
          componentId: 'foundation',
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
            center: BimVec3(
              p.$1 + d.footingWidth / 2,
              baseY + d.footingDepth / 2,
              p.$2 + d.footingWidth / 2,
            ),
          ),
          color: const Color(0xFF9CA3AF),
          category: BimEntityCategory.concrete,
          explodeGroup: 1,
          minStage: 4,
          buildProgress: 0,
        ),
      );
    }
  }

  void _foundationMasonry(List<BimEntity> e, FlyAshDimensions d) {
    final baseY = -d.trenchDepth + d.pccThickness + d.footingDepth;
    var idx = 0;
    for (var course = 0; course < d.foundationCourses; course++) {
      final y = baseY + course * (d.brickHeight + d.mortarJoint);
      for (final pos in _perimeterPositions(d, 0.12)) {
        e.add(
          BimEntity(
            id: 'found_brick_$idx',
            label: 'Foundation Masonry',
            mesh: BimMesh.box(
              width: d.brickLength * 0.96,
              height: d.brickHeight,
              depth: d.brickDepth * 0.96,
            ),
            color: const Color(0xFF64748B),
            category: BimEntityCategory.masonry,
            position: BimVec3(pos.$1, y, pos.$2),
            explodeGroup: 2,
            minStage: 5,
            buildProgress: 0,
          ),
        );
        idx++;
      }
    }
  }

  void _plinthBand(List<BimEntity> e, FlyAshDimensions d) {
    final y = -d.trenchDepth + d.pccThickness + d.footingDepth +
        d.foundationCourses * (d.brickHeight + d.mortarJoint);
    e.add(
      BimEntity(
        id: 'plinth_rebar',
        label: 'Plinth Band Rebar',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: d.plinthBeamHeight * 0.65,
          depth: d.buildingDepth,
          center: BimVec3(d.centerX, y + d.plinthBeamHeight * 0.32, d.centerZ),
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
        label: 'Plinth Band',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.15,
          height: d.plinthBeamHeight,
          depth: d.buildingDepth + 0.15,
          center: BimVec3(d.centerX, y + d.plinthBeamHeight / 2, d.centerZ),
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
          width: d.buildingWidth + 0.2,
          height: d.dpcThickness,
          depth: d.buildingDepth + 0.2,
          center: BimVec3(
            d.centerX,
            y + d.plinthBeamHeight + d.dpcThickness / 2,
            d.centerZ,
          ),
        ),
        color: const Color(0xFF06B6D4),
        category: BimEntityCategory.finishing,
        explodeGroup: 2,
        minStage: 12,
        pickable: true,
        componentId: 'damp_proof_course',
        buildProgress: 0,
      ),
    );
  }

  void _flyAshWalls(List<BimEntity> e, FlyAshDimensions d) {
    final baseY = d.wallBaseY;
    var idx = 0;
    for (var course = 0; course < d.wallCourses; course++) {
      final y = baseY + course * (d.brickHeight + d.mortarJoint);
      final isCornerCourse = course % 4 == 0;
      for (final pos in _perimeterPositions(d, 0)) {
        e.add(
          BimEntity(
            id: 'fa_brick_$idx',
            label: 'Fly Ash Brick',
            mesh: BimMesh.box(
              width: d.brickLength * 0.96,
              height: d.brickHeight,
              depth: d.brickDepth * 0.96,
            ),
            color: Color.lerp(
              const Color(0xFFB8C5D6),
              const Color(0xFF94A3B8),
              (course % 5) / 5,
            )!,
            category: BimEntityCategory.masonry,
            position: BimVec3(pos.$1, y, pos.$2),
            explodeGroup: 3,
            minStage: 7,
            pickable: idx == 0,
            componentId: 'fly_ash_brick',
            buildProgress: 0,
          ),
        );
        if (isCornerCourse && idx % 7 == 0) {
          e.add(
            BimEntity(
              id: 'mortar_joint_$idx',
              label: 'Cement Mortar Joint',
              mesh: BimMesh.box(
                width: d.brickLength,
                height: d.mortarJoint,
                depth: d.brickDepth,
              ),
              color: const Color(0xFFD6D3D1),
              category: BimEntityCategory.masonry,
              position: BimVec3(pos.$1, y - d.mortarJoint, pos.$2),
              explodeGroup: 3,
              minStage: 7,
              buildProgress: 0,
            ),
          );
        }
        idx++;
      }
    }
    e.add(
      BimEntity(
        id: 'clay_brick_ghost',
        label: 'Conventional Clay Brick (comparison)',
        mesh: BimMesh.box(
          width: 0.9,
          height: 1.2,
          depth: 0.23,
          center: BimVec3(-0.6, baseY + 0.6, d.centerZ),
        ),
        color: const Color(0xFFB45309),
        category: BimEntityCategory.annotation,
        minStage: 7,
        opacity: 0.4,
        buildProgress: 0,
      ),
    );
  }

  void _junctionReinf(List<BimEntity> e, FlyAshDimensions d) {
    final baseY = d.wallBaseY;
    for (var i = 0; i < 4; i++) {
      final c = _corners(d)[i];
      e.add(
        BimEntity(
          id: 'junction_rebar_$i',
          label: 'Reinforced Masonry Junction',
          mesh: BimMesh.box(width: 0.08, height: d.wallHeight * 0.85, depth: 0.08),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(c.$1, baseY, c.$2),
          explodeGroup: 3,
          minStage: 7,
          buildProgress: 0,
        ),
      );
    }
  }

  void _openings(List<BimEntity> e, FlyAshDimensions d) {
    final y = d.wallBaseY;
    e.add(
      BimEntity(
        id: 'door_frame',
        label: 'Door Frame',
        mesh: BimMesh.box(width: 1.0, height: 2.1, depth: 0.1),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.finishing,
        position: BimVec3(d.centerX - 0.5, y, 0),
        minStage: 8,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'window_frame',
        label: 'Window Frame',
        mesh: BimMesh.box(width: 1.1, height: 1.0, depth: 0.08),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.finishing,
        position: BimVec3(d.buildingWidth - 0.12, y + 1.0, d.centerZ),
        minStage: 8,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'opening_reinf',
        label: 'Opening Reinforcement',
        mesh: BimMesh.box(width: 1.2, height: 0.08, depth: 0.08),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        position: BimVec3(d.centerX - 0.6, y + 2.15, 0),
        minStage: 8,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'stress_flow',
        label: 'Stress Flow',
        mesh: BimMesh.box(width: 0.04, height: 0.8, depth: 0.04),
        color: const Color(0xFFF97316),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.centerX + 0.55, y + 1.0, 0.05),
        minStage: 8,
        opacity: 0.75,
        buildProgress: 0,
      ),
    );
  }

  void _lintelBand(List<BimEntity> e, FlyAshDimensions d) {
    final y = d.wallBaseY + d.wallHeight - d.bandHeight;
    e.add(
      BimEntity(
        id: 'lintel_rebar',
        label: 'Lintel Band Rebar',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.1,
          height: d.bandHeight * 0.6,
          depth: d.buildingDepth + 0.1,
          center: BimVec3(d.centerX, y + d.bandHeight * 0.3, d.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 9,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'lintel_band',
        label: 'Lintel Band',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.2,
          height: d.bandHeight,
          depth: d.buildingDepth + 0.2,
          center: BimVec3(d.centerX, y + d.bandHeight / 2, d.centerZ),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 4,
        minStage: 9,
        pickable: true,
        componentId: 'lintel_band',
        buildProgress: 0,
      ),
    );
  }

  void _roofBand(List<BimEntity> e, FlyAshDimensions d) {
    final y = d.wallBaseY + d.wallHeight;
    e.add(
      BimEntity(
        id: 'roof_band_rebar',
        label: 'Roof Band Rebar',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.15,
          height: d.bandHeight * 0.55,
          depth: d.buildingDepth + 0.15,
          center: BimVec3(d.centerX, y + d.bandHeight * 0.28, d.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 10,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'roof_band',
        label: 'Roof Band',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.25,
          height: d.bandHeight,
          depth: d.buildingDepth + 0.25,
          center: BimVec3(d.centerX, y + d.bandHeight / 2, d.centerZ),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 4,
        minStage: 10,
        pickable: true,
        componentId: 'roof_band',
        buildProgress: 0,
      ),
    );
  }

  void _roofSlab(List<BimEntity> e, FlyAshDimensions d) {
    final y = d.wallBaseY + d.wallHeight + d.bandHeight;
    e.add(
      BimEntity(
        id: 'slab_formwork',
        label: 'Slab Formwork',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.35,
          height: 0.08,
          depth: d.buildingDepth + 0.35,
          center: BimVec3(d.centerX, y - 0.04, d.centerZ),
        ),
        color: const Color(0xFFDEB887),
        category: BimEntityCategory.formwork,
        minStage: 11,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'slab_rebar_bottom',
        label: 'Bottom Reinforcement',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: 0.02,
          depth: d.buildingDepth,
          center: BimVec3(d.centerX, y + 0.02, d.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 11,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'slab_rebar_top',
        label: 'Top Reinforcement',
        mesh: BimMesh.box(
          width: d.buildingWidth * 0.85,
          height: 0.02,
          depth: d.buildingDepth * 0.85,
          center: BimVec3(d.centerX, y + d.slabThickness - 0.03, d.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 11,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'roof_slab',
        label: 'RCC Roof Slab',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.2,
          height: d.slabThickness,
          depth: d.buildingDepth + 0.2,
          center: BimVec3(
            d.centerX,
            y + d.slabThickness / 2,
            d.centerZ,
          ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 5,
        minStage: 11,
        pickable: true,
        componentId: 'roof_slab',
        buildProgress: 0,
      ),
    );
  }

  void _dpcAndWaterproof(List<BimEntity> e, FlyAshDimensions d) {
    final y = d.wallBaseY - d.dpcThickness;
    e.add(
      BimEntity(
        id: 'waterproof_membrane',
        label: 'Waterproofing Layer',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.25,
          height: 0.015,
          depth: d.buildingDepth + 0.25,
          center: BimVec3(d.centerX, y, d.centerZ),
        ),
        color: const Color(0xFF22D3EE),
        category: BimEntityCategory.finishing,
        explodeGroup: 2,
        minStage: 12,
        opacity: 0.85,
        componentId: 'damp_proof_course',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'capillary_block',
        label: 'Capillary Rise Prevention',
        mesh: BimMesh.box(width: 0.05, height: 0.6, depth: 0.05),
        color: const Color(0xFFEF4444),
        category: BimEntityCategory.annotation,
        position: BimVec3(-0.35, y + 0.3, d.centerZ),
        minStage: 12,
        opacity: 0.7,
        buildProgress: 0,
      ),
    );
  }

  void _plaster(List<BimEntity> e, FlyAshDimensions d) {
    final y = d.wallBaseY;
    e.add(
      BimEntity(
        id: 'plaster_internal',
        label: 'Internal Plaster',
        mesh: BimMesh.box(
          width: d.buildingWidth - 0.2,
          height: d.wallHeight,
          depth: 0.02,
          center: BimVec3(d.centerX, y + d.wallHeight / 2, d.centerZ),
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
        id: 'plaster_external',
        label: 'External Plaster',
        mesh: BimMesh.box(
          width: 0.02,
          height: d.wallHeight,
          depth: d.buildingDepth,
          center: BimVec3(d.buildingWidth + 0.02, y + d.wallHeight / 2, d.centerZ),
        ),
        color: const Color(0xFFE7E5E4),
        category: BimEntityCategory.finishing,
        explodeGroup: 3,
        minStage: 13,
        buildProgress: 0,
      ),
    );
  }

  void _landscape(List<BimEntity> e, FlyAshDimensions d) {
    for (var i = 0; i < 5; i++) {
      e.add(
        BimEntity(
          id: 'landscape_$i',
          label: 'Landscape',
          mesh: BimMesh.cylinder(radius: 0.1, height: 0.75),
          color: const Color(0xFF166534),
          category: BimEntityCategory.terrain,
          position: BimVec3(8 + i * 0.9, 0.38, 2 + i * 1.6),
          minStage: 14,
          buildProgress: 0,
        ),
      );
    }
  }

  List<(double, double)> _corners(FlyAshDimensions d) => [
    (0, 0),
    (d.buildingWidth, 0),
    (0, d.buildingDepth),
    (d.buildingWidth, d.buildingDepth),
  ];

  List<(double, double)> _footingPositions(FlyAshDimensions d) => [
    (0, 0),
    (d.buildingWidth - d.footingWidth, 0),
    (0, d.buildingDepth - d.footingWidth),
    (d.buildingWidth - d.footingWidth, d.buildingDepth - d.footingWidth),
    (d.centerX - d.footingWidth / 2, d.centerZ - d.footingWidth / 2),
  ];

  /// Perimeter brick positions for one course.
  List<(double, double)> _perimeterPositions(FlyAshDimensions d, double inset) {
    final w = d.buildingWidth;
    final dep = d.buildingDepth;
    final bl = d.brickLength;
    final bd = d.brickDepth;
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
