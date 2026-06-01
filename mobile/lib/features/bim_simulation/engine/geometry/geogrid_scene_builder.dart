import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'geogrid_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 08 Geogrid Reinforced Retaining Wall.
class GeogridSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
    final d = GeogridDimensions;

    _site(e, d);
    _investigation(e, d);
    _excavation(e, d);
    _foundation(e, d);
    _facingAndGeogrids(e, d);
    _backfillLayers(e, d);
    _drainage(e, d);
    _erosion(e, d);
    _landslideTeaching(e, d);

    return e;
  }

  void _site(List<BimEntity> e, GeogridDimensions d) {
    e.add(
      BimEntity(
        id: 'mountain_slope',
        label: 'Natural Slope',
        mesh: BimMesh.box(
          width: d.benchDepth + 4,
          height: 5.5,
          depth: d.plotDepth,
          center: BimVec3(4, 3.2, d.centerZ),
        ),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.terrain,
        explodeGroup: 0,
        minStage: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'road_alignment',
        label: 'Road Corridor',
        mesh: BimMesh.box(
          width: d.roadWidth,
          height: 0.12,
          depth: d.plotDepth - 1,
          center: BimVec3(12, d.roadY, d.centerZ),
        ),
        color: const Color(0xFF374151),
        category: BimEntityCategory.annotation,
        explodeGroup: 0,
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'failure_surface',
        label: 'Potential Failure Surface',
        mesh: BimMesh.box(width: 0.06, height: 0.04, depth: 8),
        color: const Color(0xFFDC2626),
        category: BimEntityCategory.annotation,
        position: BimVec3(3, 4.5, 1),
        explodeGroup: 0,
        minStage: 0,
        opacity: 0.75,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'landslide_zone',
        label: 'Historical Landslide Zone',
        mesh: BimMesh.box(width: 3, height: 0.02, depth: 4),
        color: const Color(0xFFF97316),
        category: BimEntityCategory.annotation,
        position: BimVec3(2.5, 5.8, 3),
        explodeGroup: 0,
        minStage: 0,
        opacity: 0.5,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'slope_angle_marker',
        label: 'Slope Angle',
        mesh: BimMesh.box(width: 0.04, height: 2.5, depth: 0.04),
        color: const Color(0xFF94A3B8),
        category: BimEntityCategory.annotation,
        position: BimVec3(1.5, 2.5, 0.5),
        explodeGroup: 0,
        minStage: 0,
        buildProgress: 0,
      ),
    );
  }

  void _investigation(List<BimEntity> e, GeogridDimensions d) {
    for (var i = 0; i < 3; i++) {
      e.add(
        BimEntity(
          id: 'borehole_$i',
          label: 'Borehole',
          mesh: BimMesh.cylinder(radius: 0.05, height: 4.5),
          color: const Color(0xFF64748B),
          category: BimEntityCategory.excavation,
          position: BimVec3(3 + i * 2.2, 0, 2 + i * 2),
          explodeGroup: 0,
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'soil_layer_fill',
        label: 'Fill Layer',
        mesh: BimMesh.box(width: 5, height: 1.2, depth: 6, center: BimVec3(4, 0.6, 4)),
        color: const Color(0xFFB45309),
        category: BimEntityCategory.excavation,
        explodeGroup: 0,
        minStage: 1,
        opacity: 0.7,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'soil_layer_native',
        label: 'Native Soil',
        mesh: BimMesh.box(width: 5, height: 1.5, depth: 6, center: BimVec3(4, -0.5, 4)),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.excavation,
        minStage: 1,
        opacity: 0.85,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'groundwater_table',
        label: 'Groundwater Table',
        mesh: BimMesh.box(width: 6, height: 0.03, depth: 7),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.drainage,
        position: BimVec3(2.5, 1.1, 1.5),
        explodeGroup: 0,
        minStage: 1,
        opacity: 0.6,
        buildProgress: 0,
      ),
    );
  }

  void _excavation(List<BimEntity> e, GeogridDimensions d) {
    e.add(
      BimEntity(
        id: 'slope_cut',
        label: 'Slope Cutting',
        mesh: BimMesh.box(
          width: d.benchDepth,
          height: 3.5,
          depth: d.plotDepth,
          center: BimVec3(d.benchDepth / 2 + 1, 1.8, d.centerZ),
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
        id: 'bench_1',
        label: 'Construction Bench',
        mesh: BimMesh.box(width: 3, height: 0.25, depth: d.plotDepth),
        color: const Color(0xFF57534E),
        category: BimEntityCategory.excavation,
        position: BimVec3(5, 0.12, 0),
        explodeGroup: 1,
        minStage: 2,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'foundation_trench',
        label: 'Foundation Trench',
        mesh: BimMesh.box(
          width: d.blockThickness + 1.5,
          height: 0.45,
          depth: d.plotDepth - 1,
          center: BimVec3(d.wallFaceX - 0.5, 0.22, d.centerZ),
        ),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.excavation,
        explodeGroup: 1,
        minStage: 2,
        buildProgress: 0,
      ),
    );
  }

  void _foundation(List<BimEntity> e, GeogridDimensions d) {
    e.add(
      BimEntity(
        id: 'leveling_pad',
        label: 'Leveling Pad',
        mesh: BimMesh.box(
          width: d.blockThickness + 0.4,
          height: 0.08,
          depth: d.plotDepth - 1.5,
          center: BimVec3(d.wallFaceX - 0.2, 0.04, d.centerZ),
        ),
        color: const Color(0xFFD1D5DB),
        category: BimEntityCategory.concrete,
        explodeGroup: 2,
        minStage: 3,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'granular_foundation',
        label: 'Granular Foundation Layer',
        mesh: BimMesh.box(
          width: d.geogridLength + 1,
          height: 0.25,
          depth: d.plotDepth - 1.5,
          center: BimVec3(d.wallFaceX - d.geogridLength / 2, 0.18, d.centerZ),
        ),
        color: const Color(0xFF94A3B8),
        category: BimEntityCategory.masonry,
        explodeGroup: 2,
        minStage: 3,
        pickable: true,
        componentId: 'reinforced_soil_zone',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'compaction_roller_0',
        label: 'Compaction Roller',
        mesh: BimMesh.cylinder(radius: 0.35, height: 0.5),
        color: const Color(0xFFF97316),
        category: BimEntityCategory.equipment,
        position: BimVec3(7, 0.35, 4),
        explodeGroup: 2,
        minStage: 3,
        buildProgress: 0,
      ),
    );
  }

  void _facingAndGeogrids(List<BimEntity> e, GeogridDimensions d) {
    for (var course = 0; course < d.courseCount; course++) {
      final y = 0.35 + course * d.courseHeight;
      final gridStage = course == 0 ? 5 : 8;
      final blockStage = course == 0 ? 4 : 8;

      e.add(
        BimEntity(
          id: 'facing_block_$course',
          label: 'Segmental Facing Block',
          mesh: BimMesh.box(
            width: d.blockThickness,
            height: d.courseHeight * 0.92,
            depth: d.blockDepth,
            center: BimVec3(
              d.wallFaceX - d.blockThickness / 2,
              y + d.courseHeight * 0.46,
              d.centerZ,
            ),
          ),
          color: Color.lerp(
            const Color(0xFF9CA3AF),
            const Color(0xFF6B7280),
            course / d.courseCount,
          )!,
          category: BimEntityCategory.masonry,
          explodeGroup: 3,
          minStage: blockStage,
          pickable: course == 0,
          componentId: 'facing_block',
          buildProgress: 0,
        ),
      );

      e.add(
        BimEntity(
          id: 'geogrid_$course',
          label: 'Geogrid Layer',
          mesh: BimMesh.box(
            width: d.geogridLength,
            height: d.geogridThickness,
            depth: d.plotDepth - 2,
          ),
          color: const Color(0xFF1D4ED8),
          category: BimEntityCategory.wire,
          position: BimVec3(
            d.wallFaceX - d.geogridLength - d.blockThickness,
            y + d.courseHeight * 0.5,
            1,
          ),
          explodeGroup: 4,
          minStage: gridStage,
          pickable: course == 0,
          componentId: 'geogrid',
          buildProgress: 0,
        ),
      );

      e.add(
        BimEntity(
          id: 'grid_connection_$course',
          label: 'Mechanical Connection',
          mesh: BimMesh.box(width: 0.12, height: 0.08, depth: 0.3),
          color: const Color(0xFF475569),
          category: BimEntityCategory.equipment,
          position: BimVec3(d.wallFaceX - d.blockThickness - 0.05, y + 0.1, d.centerZ),
          explodeGroup: 4,
          minStage: gridStage,
          buildProgress: 0,
        ),
      );
    }

    e.add(
      BimEntity(
        id: 'top_coping',
        label: 'Top Coping',
        mesh: BimMesh.box(
          width: d.blockThickness + 0.1,
          height: 0.15,
          depth: d.blockDepth + 0.2,
          center: BimVec3(
            d.wallFaceX - d.blockThickness / 2,
            0.35 + d.courseCount * d.courseHeight + 0.08,
            d.centerZ,
          ),
        ),
        color: const Color(0xFF4B5563),
        category: BimEntityCategory.masonry,
        explodeGroup: 3,
        minStage: 11,
        buildProgress: 0,
      ),
    );
  }

  void _backfillLayers(List<BimEntity> e, GeogridDimensions d) {
    for (var layer = 0; layer < d.courseCount; layer++) {
      final y = 0.5 + layer * d.backfillLift;
      e.add(
        BimEntity(
          id: 'backfill_$layer',
          label: 'Granular Backfill',
          mesh: BimMesh.box(
            width: d.geogridLength - 0.3,
            height: d.backfillLift * 0.9,
            depth: d.plotDepth - 2.5,
          ),
          color: Color.lerp(
            const Color(0xFFD6D3D1),
            const Color(0xFFA8A29E),
            layer / d.courseCount,
          )!,
          category: BimEntityCategory.earthbag,
          position: BimVec3(
            d.wallFaceX - d.geogridLength - d.blockThickness + 0.15,
            y,
            1.2,
          ),
          explodeGroup: 5,
          minStage: layer == 0 ? 6 : 8,
          pickable: layer == 0,
          componentId: 'backfill',
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'reinforced_zone_outline',
        label: 'Reinforced Soil Mass',
        mesh: BimMesh.box(
          width: d.geogridLength,
          height: d.wallHeight,
          depth: d.plotDepth - 2,
          center: BimVec3(
            d.wallFaceX - d.geogridLength / 2 - d.blockThickness,
            d.wallHeight / 2 + 0.3,
            d.centerZ,
          ),
        ),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.annotation,
        explodeGroup: 5,
        minStage: 8,
        opacity: 0.2,
        componentId: 'reinforced_soil_zone',
        buildProgress: 0,
      ),
    );
    for (var i = 0; i < 3; i++) {
      e.add(
        BimEntity(
          id: 'compaction_roller_${i + 1}',
          label: 'Compaction Roller',
          mesh: BimMesh.cylinder(radius: 0.32, height: 0.45),
          color: const Color(0xFFF97316),
          category: BimEntityCategory.equipment,
          position: BimVec3(6.5, 0.8 + i * 1.8, 3 + i),
          explodeGroup: 5,
          minStage: 7,
          buildProgress: 0,
        ),
      );
    }
  }

  void _drainage(List<BimEntity> e, GeogridDimensions d) {
    e.add(
      BimEntity(
        id: 'drainage_pipe',
        label: 'Perforated Drainage Pipe',
        mesh: BimMesh.cylinder(radius: 0.08, height: d.plotDepth - 2),
        color: const Color(0xFF475569),
        category: BimEntityCategory.drainage,
        position: BimVec3(d.wallFaceX - 1.2, 0.45, 1),
        explodeGroup: 6,
        minStage: 9,
        pickable: true,
        componentId: 'drainage_pipe',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'drainage_blanket',
        label: 'Drainage Blanket',
        mesh: BimMesh.box(
          width: d.geogridLength,
          height: 0.12,
          depth: d.plotDepth - 2,
          center: BimVec3(
            d.wallFaceX - d.geogridLength / 2,
            0.35,
            d.centerZ,
          ),
        ),
        color: const Color(0xFF94A3B8),
        category: BimEntityCategory.drainage,
        explodeGroup: 6,
        minStage: 9,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'filter_layer',
        label: 'Filter Layer',
        mesh: BimMesh.box(
          width: 0.25,
          height: d.wallHeight,
          depth: d.plotDepth - 2,
          center: BimVec3(d.wallFaceX - 0.55, d.wallHeight / 2, d.centerZ),
        ),
        color: const Color(0xFFE7E5E4),
        category: BimEntityCategory.drainage,
        explodeGroup: 6,
        minStage: 9,
        opacity: 0.85,
        buildProgress: 0,
      ),
    );
    for (var i = 0; i < 5; i++) {
      e.add(
        BimEntity(
          id: 'weep_hole_$i',
          label: 'Weep Hole',
          mesh: BimMesh.cylinder(radius: 0.03, height: 0.15),
          color: const Color(0xFF0EA5E9),
          category: BimEntityCategory.drainage,
          position: BimVec3(
            d.wallFaceX + 0.02,
            0.8 + i * 1.1,
            2 + i * 1.2,
          ),
          explodeGroup: 6,
          minStage: 10,
          buildProgress: 0,
        ),
      );
    }
  }

  void _erosion(List<BimEntity> e, GeogridDimensions d) {
    e.add(
      BimEntity(
        id: 'surface_protection',
        label: 'Surface Protection',
        mesh: BimMesh.box(
          width: 5,
          height: 0.04,
          depth: 4,
          center: BimVec3(3, d.roadY - 0.1, 5),
        ),
        color: const Color(0xFF86EFAC),
        category: BimEntityCategory.terrain,
        explodeGroup: 7,
        minStage: 12,
        buildProgress: 0,
      ),
    );
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'vegetation_$i',
          label: 'Vegetation',
          mesh: BimMesh.cylinder(radius: 0.08, height: 0.5),
          color: const Color(0xFF166534),
          category: BimEntityCategory.terrain,
          position: BimVec3(2 + i * 1.1, d.roadY, 3 + i),
          explodeGroup: 7,
          minStage: 12,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'completed_road',
        label: 'Protected Road',
        mesh: BimMesh.box(
          width: d.roadWidth,
          height: 0.15,
          depth: d.plotDepth - 0.5,
          center: BimVec3(12, d.roadY + 0.05, d.centerZ),
        ),
        color: const Color(0xFF1F2937),
        category: BimEntityCategory.annotation,
        explodeGroup: 0,
        minStage: 13,
        buildProgress: 0,
      ),
    );
  }

  void _landslideTeaching(List<BimEntity> e, GeogridDimensions d) {
    e.add(
      BimEntity(
        id: 'unreinforced_slope_mass',
        label: 'Unreinforced Slope (fails)',
        mesh: BimMesh.box(
          width: 4.5,
          height: 2.8,
          depth: 5,
          center: BimVec3(3.2, 4.8, 3.5),
        ),
        color: const Color(0xFFB45309),
        category: BimEntityCategory.terrain,
        explodeGroup: 0,
        minStage: 0,
        opacity: 0.55,
        buildProgress: 1,
      ),
    );
    e.add(
      BimEntity(
        id: 'reinforced_stable_zone',
        label: 'Reinforced Stable Block',
        mesh: BimMesh.box(
          width: d.geogridLength + 0.5,
          height: d.wallHeight + 0.5,
          depth: 3,
          center: BimVec3(
            d.wallFaceX - d.geogridLength / 2,
            d.wallHeight / 2 + 0.5,
            d.centerZ + 2,
          ),
        ),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.annotation,
        explodeGroup: 5,
        minStage: 0,
        opacity: 0.25,
        buildProgress: 1,
      ),
    );
  }
}
