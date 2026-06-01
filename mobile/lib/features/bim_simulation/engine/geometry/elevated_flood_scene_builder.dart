import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'elevated_flood_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 05 Elevated Flood Resilient House.
class ElevatedFloodSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
    final d = ElevatedFloodDimensions;

    _siteAndRiver(e, d);
    _settingOut(e, d);
    _excavation(e, d);
    _footings(e, d);
    _scourProtection(e, d);
    _columns(e, d);
    _platformBeams(e, d);
    _elevatedSlab(e, d);
    _walls(e, d);
    _openings(e, d);
    _roofStructure(e, d);
    _roofCovering(e, d);
    _stairs(e, d);
    _waterproofing(e, d);
    _drainage(e, d);
    _finishing(e, d);
    _landscape(e, d);
    _comparisons(e, d);

    return e;
  }

  void _siteAndRiver(List<BimEntity> e, ElevatedFloodDimensions d) {
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
          width: d.buildingWidth + 1.2,
          height: 0.02,
          depth: d.buildingDepth + 1.2,
          center: BimVec3(d.centerX + 1.5, 0.04, d.centerZ),
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
        label: 'High Flood Mark',
        mesh: BimMesh.box(width: 0.08, height: 0.04, depth: d.buildingDepth + 2),
        color: const Color(0xFFDC2626),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.buildingWidth + 2.2, d.highFloodMark, -0.5),
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'safe_level_mark',
        label: 'Safe Occupancy Level',
        mesh: BimMesh.box(width: 0.08, height: 0.04, depth: d.buildingDepth + 2),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.buildingWidth + 2.5, d.platformElevation, -0.5),
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'flood_water',
        label: 'Flood Water',
        mesh: BimMesh.box(
          width: d.plotWidth - d.riverWidth + 0.5,
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

  void _settingOut(List<BimEntity> e, ElevatedFloodDimensions d) {
    for (var i = 0; i <= 5; i++) {
      e.add(
        BimEntity(
          id: 'grid_x_$i',
          label: 'Survey Grid',
          mesh: BimMesh.box(width: 0.02, height: 0.01, depth: d.buildingDepth + 1.5),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(1.2 + i * (d.buildingWidth / 5), 0.06, 0),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    final cols = _columnPositions(d);
    for (var i = 0; i < cols.length; i++) {
      final p = cols[i];
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
          position: BimVec3(p.$1 + 1.2, 0.08, p.$2),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'platform_boundary',
        label: 'Platform Boundary',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.4,
          height: 0.015,
          depth: d.buildingDepth + 0.4,
          center: BimVec3(d.centerX + 1.2, 0.07, d.centerZ),
        ),
        color: const Color(0xFF0F172A),
        category: BimEntityCategory.annotation,
        minStage: 1,
        opacity: 0.7,
        buildProgress: 0,
      ),
    );
  }

  void _excavation(List<BimEntity> e, ElevatedFloodDimensions d) {
    final ox = 1.2;
    e.add(
      BimEntity(
        id: 'excavation',
        label: 'Footing Excavation',
        mesh: BimMesh.box(
          width: d.buildingWidth + 1.0,
          height: d.trenchDepth,
          depth: d.buildingDepth + 1.0,
          center: BimVec3(
            d.centerX + ox,
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
        label: 'Bearing Layer',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.8,
          height: 0.15,
          depth: d.buildingDepth + 0.8,
          center: BimVec3(d.centerX + ox, -d.trenchDepth + 0.08, d.centerZ),
        ),
        color: const Color(0xFF57534E),
        category: BimEntityCategory.excavation,
        minStage: 2,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'scour_zone',
        label: 'Potential Scour Zone',
        mesh: BimMesh.box(
          width: d.buildingWidth + 1.4,
          height: 0.25,
          depth: 0.6,
          center: BimVec3(d.centerX + ox, 0.02, -0.35),
        ),
        color: const Color(0xFFF59E0B),
        category: BimEntityCategory.annotation,
        minStage: 2,
        opacity: 0.5,
        buildProgress: 0,
      ),
    );
  }

  void _footings(List<BimEntity> e, ElevatedFloodDimensions d) {
    final ox = 1.2;
    final baseY = -d.trenchDepth + 0.05;
    final cols = _columnPositions(d);
    for (var i = 0; i < cols.length; i++) {
      final p = cols[i];
      final wx = p.$1 + ox;
      final wz = p.$2;
      e.add(
        BimEntity(
          id: 'footing_rebar_$i',
          label: 'Footing Rebar Cage',
          mesh: BimMesh.box(
            width: d.footingWidth,
            height: d.footingDepth * 0.75,
            depth: d.footingWidth,
          ),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(wx, baseY, wz),
          explodeGroup: 1,
          minStage: 3,
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
              wx + d.footingWidth / 2,
              baseY + d.footingDepth / 2,
              wz + d.footingWidth / 2,
            ),
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
          id: 'pedestal_$i',
          label: 'RCC Pedestal',
          mesh: BimMesh.box(
            width: d.columnSize + 0.05,
            height: d.pedestalHeight,
            depth: d.columnSize + 0.05,
            center: BimVec3(
              wx + d.footingWidth / 2,
              baseY + d.footingDepth + d.pedestalHeight / 2,
              wz + d.footingWidth / 2,
            ),
          ),
          color: const Color(0xFF6B7280),
          category: BimEntityCategory.concrete,
          explodeGroup: 1,
          minStage: 3,
          buildProgress: 0,
        ),
      );
    }
  }

  void _scourProtection(List<BimEntity> e, ElevatedFloodDimensions d) {
    final ox = 1.2;
    final baseY = -d.trenchDepth + 0.05;
    for (var i = 0; i < 14; i++) {
      e.add(
        BimEntity(
          id: 'riprap_$i',
          label: 'Riprap / Stone Pitching',
          mesh: BimMesh.box(
            width: 0.22 + (i % 3) * 0.06,
            height: 0.14 + (i % 2) * 0.04,
            depth: 0.2,
          ),
          color: const Color(0xFF64748B),
          category: BimEntityCategory.masonry,
          position: BimVec3(
            ox + 0.3 + (i % 7) * 0.75,
            baseY + (i ~/ 7) * 0.06,
            -0.15 + (i % 4) * 1.1,
          ),
          explodeGroup: 1,
          minStage: 4,
          pickable: i == 0,
          componentId: 'scour_protection',
          buildProgress: 0,
        ),
      );
    }
  }

  void _columns(List<BimEntity> e, ElevatedFloodDimensions d) {
    final ox = 1.2;
    final baseY = -d.trenchDepth + d.footingDepth + d.pedestalHeight + 0.05;
    final cols = _columnPositions(d);
    for (var i = 0; i < cols.length; i++) {
      final p = cols[i];
      e.add(
        BimEntity(
          id: 'col_cage_$i',
          label: 'Column Rebar Cage',
          mesh: BimMesh.box(
            width: d.columnSize * 0.8,
            height: d.columnHeight,
            depth: d.columnSize * 0.8,
          ),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(p.$1 + ox, baseY, p.$2),
          explodeGroup: 2,
          minStage: 5,
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: 'col_formwork_$i',
          label: 'Column Formwork',
          mesh: BimMesh.box(
            width: d.columnSize + 0.06,
            height: d.columnHeight + 0.04,
            depth: d.columnSize + 0.06,
          ),
          color: const Color(0xFFDEB887),
          category: BimEntityCategory.formwork,
          position: BimVec3(p.$1 + ox - 0.03, baseY, p.$2 - 0.03),
          minStage: 5,
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: 'col_concrete_$i',
          label: 'RCC Column',
          mesh: BimMesh.box(
            width: d.columnSize,
            height: d.columnHeight,
            depth: d.columnSize,
            center: BimVec3(
              p.$1 + ox + d.columnSize / 2,
              baseY + d.columnHeight / 2,
              p.$2 + d.columnSize / 2,
            ),
          ),
          color: const Color(0xFF6B7280),
          category: BimEntityCategory.concrete,
          explodeGroup: 2,
          minStage: 5,
          pickable: i == 0,
          componentId: 'rcc_column',
          buildProgress: 0,
        ),
      );
    }
  }

  void _platformBeams(List<BimEntity> e, ElevatedFloodDimensions d) {
    final ox = 1.2;
    final y = -d.trenchDepth + d.footingDepth + d.pedestalHeight + d.columnHeight;
    e.add(
      BimEntity(
        id: 'beam_rebar_x',
        label: 'Platform Beam Rebar',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: d.platformBeamHeight * 0.65,
          depth: d.platformBeamWidth,
          center: BimVec3(d.centerX + ox, y + d.platformBeamHeight * 0.32, 0),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 6,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'beam_rebar_z',
        label: 'Platform Beam Rebar',
        mesh: BimMesh.box(
          width: d.platformBeamWidth,
          height: d.platformBeamHeight * 0.65,
          depth: d.buildingDepth,
          center: BimVec3(0, y + d.platformBeamHeight * 0.32, d.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 6,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'platform_beam_x',
        label: 'Platform Beam',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.columnSize,
          height: d.platformBeamHeight,
          depth: d.platformBeamWidth,
          center: BimVec3(d.centerX + ox, y + d.platformBeamHeight / 2, 0),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 3,
        minStage: 6,
        pickable: true,
        componentId: 'platform_beam',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'platform_beam_z',
        label: 'Platform Beam',
        mesh: BimMesh.box(
          width: d.platformBeamWidth,
          height: d.platformBeamHeight,
          depth: d.buildingDepth + d.columnSize,
          center: BimVec3(ox, y + d.platformBeamHeight / 2, d.centerZ),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 3,
        minStage: 6,
        componentId: 'platform_beam',
        buildProgress: 0,
      ),
    );
  }

  void _elevatedSlab(List<BimEntity> e, ElevatedFloodDimensions d) {
    final ox = 1.2;
    final y = d.platformElevation;
    e.add(
      BimEntity(
        id: 'slab_formwork',
        label: 'Slab Formwork',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.3,
          height: 0.08,
          depth: d.buildingDepth + 0.3,
          center: BimVec3(d.centerX + ox, y - 0.04, d.centerZ),
        ),
        color: const Color(0xFFDEB887),
        category: BimEntityCategory.formwork,
        minStage: 7,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'slab_rebar_bottom',
        label: 'Slab Reinforcement',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: 0.02,
          depth: d.buildingDepth,
          center: BimVec3(d.centerX + ox, y + 0.02, d.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 7,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'elevated_slab',
        label: 'Elevated Floor Slab',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.2,
          height: d.slabThickness,
          depth: d.buildingDepth + 0.2,
          center: BimVec3(
            d.centerX + ox,
            y + d.slabThickness / 2,
            d.centerZ,
          ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 3,
        minStage: 7,
        pickable: true,
        componentId: 'elevated_slab',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'flood_level_ref',
        label: 'Design Flood Level',
        mesh: BimMesh.box(
          width: d.buildingWidth + 2,
          height: 0.03,
          depth: 0.05,
          center: BimVec3(d.centerX + ox, d.designFloodLevel, d.buildingDepth + 0.8),
        ),
        color: const Color(0xFF0284C7),
        category: BimEntityCategory.annotation,
        minStage: 7,
        opacity: 0.7,
        buildProgress: 0,
      ),
    );
  }

  void _walls(List<BimEntity> e, ElevatedFloodDimensions d) {
    final ox = 1.2;
    final baseY = d.platformTopY;
    var idx = 0;
    for (var course = 0; course < 8; course++) {
      final y = baseY + course * (d.wallPanelThickness + 0.02);
      for (var seg = 0; seg < 6; seg++) {
        final alongX = seg < 3;
        final t = seg % 3;
        final px = alongX ? ox + t * 1.6 : (seg == 3 ? ox : ox + d.buildingWidth - d.wallPanelThickness);
        final pz = alongX ? (seg == 0 ? 0 : d.buildingDepth - d.wallPanelThickness) : t * 1.3;
        final w = alongX ? 1.55 : d.wallPanelThickness;
        final dep = alongX ? d.wallPanelThickness : 1.2;
        e.add(
          BimEntity(
            id: 'wall_panel_$idx',
            label: 'Lightweight Wall Panel',
            mesh: BimMesh.box(
              width: w,
              height: d.wallPanelThickness,
              depth: dep,
              center: BimVec3(px + w / 2, y + d.wallPanelThickness / 2, pz + dep / 2),
            ),
            color: const Color(0xFFE7E5E4),
            category: BimEntityCategory.masonry,
            explodeGroup: 4,
            minStage: 8,
            buildProgress: 0,
          ),
        );
        idx++;
      }
    }
    e.add(
      BimEntity(
        id: 'heavy_wall_ghost',
        label: 'Heavy Masonry (comparison)',
        mesh: BimMesh.box(
          width: 1.2,
          height: d.wallHeight,
          depth: d.wallPanelThickness,
          center: BimVec3(ox - 0.8, baseY + d.wallHeight / 2, d.centerZ),
        ),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.annotation,
        minStage: 8,
        opacity: 0.35,
        buildProgress: 0,
      ),
    );
  }

  void _openings(List<BimEntity> e, ElevatedFloodDimensions d) {
    final ox = 1.2;
    final y = d.platformTopY + 0.9;
    e.add(
      BimEntity(
        id: 'door_frame',
        label: 'Door Frame',
        mesh: BimMesh.box(width: 0.9, height: 2.0, depth: 0.06),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        position: BimVec3(ox + 2.0, y, 0),
        minStage: 9,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'window_frame_0',
        label: 'Window Frame',
        mesh: BimMesh.box(width: 1.0, height: 1.0, depth: 0.05),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.timber,
        position: BimVec3(ox + 0.4, y + 0.5, d.buildingDepth - 0.05),
        minStage: 9,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'window_frame_1',
        label: 'Window Frame',
        mesh: BimMesh.box(width: 1.0, height: 1.0, depth: 0.05),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.timber,
        position: BimVec3(ox + d.buildingWidth - 1.4, y + 0.5, d.buildingDepth - 0.05),
        minStage: 9,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'flood_elev_ref',
        label: 'Flood Elevation Reference',
        mesh: BimMesh.box(width: 0.05, height: 1.2, depth: 0.05),
        color: const Color(0xFF0284C7),
        category: BimEntityCategory.annotation,
        position: BimVec3(ox - 0.3, d.designFloodLevel, d.centerZ),
        minStage: 9,
        opacity: 0.8,
        buildProgress: 0,
      ),
    );
  }

  void _roofStructure(List<BimEntity> e, ElevatedFloodDimensions d) {
    final ox = 1.2;
    final y = d.roofBaseY;
    final trussSpans = [
      (ox + 0.5, d.centerZ, ox + 4.5, d.centerZ),
      (ox + 0.5, d.centerZ, ox + 2.5, d.centerZ + 1.2),
      (ox + 4.5, d.centerZ, ox + 2.5, d.centerZ + 1.2),
      (ox + 1.0, 0.3, ox + 4.0, 0.3),
      (ox + 1.0, d.buildingDepth - 0.3, ox + 4.0, d.buildingDepth - 0.3),
    ];
    for (var i = 0; i < trussSpans.length; i++) {
      final s = trussSpans[i];
      final dx = s.$3 - s.$1;
      final dz = s.$4 - s.$2;
      final len = (dx * dx + dz * dz).abs() + 0.01;
      e.add(
        BimEntity(
          id: 'truss_$i',
          label: 'Roof Truss Member',
          mesh: BimMesh.box(width: len, height: 0.08, depth: 0.08),
          color: const Color(0xFF92400E),
          category: BimEntityCategory.timber,
          position: BimVec3(s.$1, y, s.$2),
          minStage: 10,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'ridge_beam',
        label: 'Ridge Beam',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: 0.1,
          depth: 0.12,
          center: BimVec3(d.centerX + ox, y + 0.35, d.centerZ),
        ),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.timber,
        minStage: 10,
        buildProgress: 0,
      ),
    );
  }

  void _roofCovering(List<BimEntity> e, ElevatedFloodDimensions d) {
    final ox = 1.2;
    final y = d.roofBaseY + 0.25;
    for (var i = 0; i < 6; i++) {
      e.add(
        BimEntity(
          id: 'cgi_sheet_$i',
          label: 'CGI Sheet',
          mesh: BimMesh.box(width: 1.6, height: 0.02, depth: 2.2),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.finishing,
          position: BimVec3(ox + 0.2 + (i % 3) * 1.55, y + (i ~/ 3) * 0.04, 0.2 + (i ~/ 3) * 1.8),
          explodeGroup: 5,
          minStage: 11,
          buildProgress: 0,
        ),
      );
    }
    for (var i = 0; i < 8; i++) {
      e.add(
        BimEntity(
          id: 'roof_fastener_$i',
          label: 'Roof Fastener',
          mesh: BimMesh.cylinder(radius: 0.015, height: 0.04),
          color: const Color(0xFF475569),
          category: BimEntityCategory.annotation,
          position: BimVec3(ox + 0.5 + (i % 4) * 1.2, y + 0.03, 0.5 + (i ~/ 4) * 2.0),
          minStage: 11,
          buildProgress: 0,
        ),
      );
    }
  }

  void _stairs(List<BimEntity> e, ElevatedFloodDimensions d) {
    final ox = 0.4;
    final rise = d.platformElevation / 12;
    for (var i = 0; i < 12; i++) {
      e.add(
        BimEntity(
          id: 'stair_tread_$i',
          label: 'Stair Tread',
          mesh: BimMesh.box(width: 1.0, height: 0.06, depth: 0.28),
          color: const Color(0xFF64748B),
          category: BimEntityCategory.concrete,
          position: BimVec3(ox, i * rise, i * 0.28),
          minStage: 12,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'stair_handrail',
        label: 'Handrail',
        mesh: BimMesh.box(width: 0.04, height: d.platformElevation + 0.5, depth: 0.04),
        color: const Color(0xFF0F172A),
        category: BimEntityCategory.timber,
        position: BimVec3(ox + 0.95, 0, 3.2),
        minStage: 12,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'stair_landing',
        label: 'Landing at Platform',
        mesh: BimMesh.box(
          width: 1.2,
          height: d.slabThickness,
          depth: 0.8,
          center: BimVec3(ox + 0.6, d.platformTopY, 3.5),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        minStage: 12,
        buildProgress: 0,
      ),
    );
  }

  void _waterproofing(List<BimEntity> e, ElevatedFloodDimensions d) {
    final ox = 1.2;
    final y = d.platformTopY;
    e.add(
      BimEntity(
        id: 'moisture_barrier',
        label: 'Moisture Barrier',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.1,
          height: 0.01,
          depth: d.buildingDepth + 0.1,
          center: BimVec3(d.centerX + ox, y - 0.02, d.centerZ),
        ),
        color: const Color(0xFF22D3EE),
        category: BimEntityCategory.finishing,
        explodeGroup: 4,
        minStage: 13,
        pickable: true,
        componentId: 'waterproofing',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'protective_coating',
        label: 'Protective Coating',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: d.wallHeight,
          depth: 0.02,
          center: BimVec3(ox - 0.02, y + d.wallHeight / 2, d.centerZ),
        ),
        color: const Color(0xFF06B6D4),
        category: BimEntityCategory.finishing,
        minStage: 13,
        opacity: 0.4,
        componentId: 'waterproofing',
        buildProgress: 0,
      ),
    );
  }

  void _drainage(List<BimEntity> e, ElevatedFloodDimensions d) {
    final ox = 1.2;
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'surface_drain_$i',
          label: 'Surface Drain',
          mesh: BimMesh.box(width: 0.25, height: 0.08, depth: 1.8),
          color: const Color(0xFF475569),
          category: BimEntityCategory.drainage,
          position: BimVec3(ox + 1.0 + i * 1.1, d.platformTopY + 0.02, -0.35),
          minStage: 14,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'drain_channel',
        label: 'Drainage Channel',
        mesh: BimMesh.box(
          width: d.plotWidth - d.riverWidth - 1,
          height: 0.1,
          depth: 0.35,
          center: BimVec3(d.riverWidth + 4, 0.05, d.plotDepth - 0.5),
        ),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.drainage,
        minStage: 14,
        buildProgress: 0,
      ),
    );
  }

  void _finishing(List<BimEntity> e, ElevatedFloodDimensions d) {
    final ox = 1.2;
    final y = d.platformTopY;
    e.add(
      BimEntity(
        id: 'floor_finish',
        label: 'Floor Finish',
        mesh: BimMesh.box(
          width: d.buildingWidth - 0.2,
          height: 0.02,
          depth: d.buildingDepth - 0.2,
          center: BimVec3(d.centerX + ox, y + d.slabThickness + 0.01, d.centerZ),
        ),
        color: const Color(0xFFD6D3D1),
        category: BimEntityCategory.finishing,
        minStage: 14,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'exterior_paint',
        label: 'Exterior Paint',
        mesh: BimMesh.box(
          width: 0.02,
          height: d.wallHeight * 0.9,
          depth: d.buildingDepth,
          center: BimVec3(ox + d.buildingWidth + 0.02, y + d.wallHeight / 2, d.centerZ),
        ),
        color: const Color(0xFFF97316),
        category: BimEntityCategory.finishing,
        minStage: 14,
        opacity: 0.85,
        buildProgress: 0,
      ),
    );
  }

  void _landscape(List<BimEntity> e, ElevatedFloodDimensions d) {
    for (var i = 0; i < 5; i++) {
      e.add(
        BimEntity(
          id: 'landscape_tree_$i',
          label: 'Landscape',
          mesh: BimMesh.cylinder(radius: 0.12, height: 0.8),
          color: const Color(0xFF166534),
          category: BimEntityCategory.terrain,
          position: BimVec3(8 + i * 1.1, 0.4, 1 + i * 1.8),
          minStage: 15,
          buildProgress: 0,
        ),
      );
    }
  }

  void _comparisons(List<BimEntity> e, ElevatedFloodDimensions d) {
    e.add(
      BimEntity(
        id: 'ground_storey_open',
        label: 'Open Ground Storey (flood flow)',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: 0.02,
          depth: d.buildingDepth,
          center: BimVec3(d.centerX + 1.2, 0.08, d.centerZ),
        ),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.annotation,
        minStage: 0,
        opacity: 0.25,
        buildProgress: 1,
      ),
    );
  }

  List<(double, double)> _columnPositions(ElevatedFloodDimensions d) {
    return [
      (0, 0),
      (d.buildingWidth - d.columnSize, 0),
      (0, d.buildingDepth - d.columnSize),
      (d.buildingWidth - d.columnSize, d.buildingDepth - d.columnSize),
      (d.buildingWidth / 2 - d.columnSize / 2, 0),
      (d.buildingWidth / 2 - d.columnSize / 2, d.buildingDepth - d.columnSize),
    ];
  }
}
