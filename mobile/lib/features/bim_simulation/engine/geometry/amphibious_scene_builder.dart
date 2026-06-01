import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'amphibious_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 06 Floating Amphibious Structure.
class AmphibiousSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
    final d = AmphibiousDimensions;

    _site(e, d);
    _settingOut(e, d);
    _foundationPads(e, d);
    _guidePosts(e, d);
    _platform(e, d);
    _buoyancyDrums(e, d);
    _frame(e, d);
    _floor(e, d);
    _walls(e, d);
    _openings(e, d);
    _roofStructure(e, d);
    _roofCover(e, d);
    _utilities(e, d);
    _anchorage(e, d);
    _landscape(e, d);
    _comparisons(e, d);

    return e;
  }

  void _site(List<BimEntity> e, AmphibiousDimensions d) {
    e.add(
      BimEntity(
        id: 'floodplain',
        label: 'Floodplain',
        mesh: BimMesh.box(
          width: d.plotWidth,
          height: 0.1,
          depth: d.plotDepth,
          center: BimVec3(d.plotWidth / 2, -0.05, d.plotDepth / 2),
        ),
        color: const Color(0xFF86EFAC),
        category: BimEntityCategory.terrain,
        explodeGroup: 0,
        minStage: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'river_channel',
        label: 'River',
        mesh: BimMesh.box(
          width: d.riverWidth,
          height: 0.07,
          depth: d.plotDepth,
          center: BimVec3(d.riverWidth / 2, -0.02, d.plotDepth / 2),
        ),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.drainage,
        explodeGroup: 0,
        minStage: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'footprint',
        label: 'Building Footprint',
        mesh: BimMesh.box(
          width: d.buildingWidth + 1.0,
          height: 0.02,
          depth: d.buildingDepth + 1.0,
          center: BimVec3(d.centerX, 0.03, d.centerZ),
        ),
        color: const Color(0xFF0F172A),
        category: BimEntityCategory.annotation,
        explodeGroup: 0,
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'flood_zone',
        label: 'Flood Zone',
        mesh: BimMesh.box(
          width: d.plotWidth - d.riverWidth,
          height: 0.012,
          depth: d.plotDepth,
          center: BimVec3(
            d.riverWidth + (d.plotWidth - d.riverWidth) / 2,
            0.025,
            d.plotDepth / 2,
          ),
        ),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.annotation,
        explodeGroup: 0,
        minStage: 0,
        opacity: 0.4,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'high_flood_mark',
        label: 'Historical Flood Level',
        mesh: BimMesh.box(width: 0.06, height: 0.03, depth: d.buildingDepth + 1.5),
        color: const Color(0xFFDC2626),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.centerX + 3.2, d.highFloodMark, -0.3),
        explodeGroup: 0,
        minStage: 0,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'anchorage_zone',
        label: 'Safe Anchorage Zone',
        mesh: BimMesh.box(
          width: d.buildingWidth + 2.5,
          height: 0.015,
          depth: d.buildingDepth + 2.5,
          center: BimVec3(d.centerX, 0.04, d.centerZ),
        ),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.annotation,
        explodeGroup: 0,
        minStage: 0,
        opacity: 0.35,
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
        explodeGroup: 0,
        minStage: 0,
        opacity: 0.42,
        buildProgress: 0,
      ),
    );
  }

  void _settingOut(List<BimEntity> e, AmphibiousDimensions d) {
    for (var i = 0; i <= 5; i++) {
      e.add(
        BimEntity(
          id: 'grid_$i',
          label: 'Survey Grid',
          mesh: BimMesh.box(width: 0.02, height: 0.01, depth: d.buildingDepth + 2),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(d.siteOffsetX + i * (d.buildingWidth / 5), 0.05, -0.5),
          explodeGroup: 0,
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    final pads = _padPositions(d);
    for (var i = 0; i < pads.length; i++) {
      final p = pads[i];
      e.add(
        BimEntity(
          id: 'pad_marker_$i',
          label: 'Foundation Pad Location',
          mesh: BimMesh.box(width: d.padSize, height: 0.03, depth: d.padSize),
          color: const Color(0xFFF97316),
          category: BimEntityCategory.survey,
          position: BimVec3(p.$1, 0.06, p.$2),
          explodeGroup: 0,
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    final guides = _guidePostPositions(d);
    for (var i = 0; i < guides.length; i++) {
      final p = guides[i];
      e.add(
        BimEntity(
          id: 'guide_marker_$i',
          label: 'Guide Post Location',
          mesh: BimMesh.cylinder(radius: 0.06, height: 0.05),
          color: const Color(0xFFDC2626),
          category: BimEntityCategory.survey,
          position: BimVec3(p.$1, 0.07, p.$2),
          explodeGroup: 0,
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
          width: d.buildingWidth + 0.5,
          height: 0.012,
          depth: d.buildingDepth + 0.5,
          center: BimVec3(d.centerX, d.deckY - 0.02, d.centerZ),
        ),
        color: const Color(0xFF0F172A),
        category: BimEntityCategory.annotation,
        explodeGroup: 0,
        minStage: 1,
        opacity: 0.75,
        buildProgress: 0,
      ),
    );
  }

  void _foundationPads(List<BimEntity> e, AmphibiousDimensions d) {
    final pads = _padPositions(d);
    for (var i = 0; i < pads.length; i++) {
      final p = pads[i];
      e.add(
        BimEntity(
          id: 'pad_excavation_$i',
          label: 'Pad Excavation',
          mesh: BimMesh.box(
            width: d.padSize + 0.2,
            height: d.trenchDepth,
            depth: d.padSize + 0.2,
            center: BimVec3(
              p.$1 + (d.padSize + 0.2) / 2,
              -d.trenchDepth / 2 + 0.02,
              p.$2 + (d.padSize + 0.2) / 2,
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
          id: 'pad_rebar_$i',
          label: 'Pad Rebar Cage',
          mesh: BimMesh.box(
            width: d.padSize * 0.9,
            height: d.padDepth * 0.7,
            depth: d.padSize * 0.9,
          ),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(p.$1, 0, p.$2),
          explodeGroup: 1,
          minStage: 2,
          pickable: i == 0,
          componentId: 'foundation',
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: 'foundation_pad_$i',
          label: 'RCC Foundation Pad',
          mesh: BimMesh.box(
            width: d.padSize,
            height: d.padDepth,
            depth: d.padSize,
            center: BimVec3(
              p.$1 + d.padSize / 2,
              d.padDepth / 2,
              p.$2 + d.padSize / 2,
            ),
          ),
          color: const Color(0xFF9CA3AF),
          category: BimEntityCategory.concrete,
          explodeGroup: 1,
          minStage: 2,
          componentId: 'foundation',
          buildProgress: 0,
        ),
      );
    }
  }

  void _guidePosts(List<BimEntity> e, AmphibiousDimensions d) {
    final guides = _guidePostPositions(d);
    for (var i = 0; i < guides.length; i++) {
      final p = guides[i];
      e.add(
        BimEntity(
          id: 'guide_post_$i',
          label: 'Guide Post',
          mesh: BimMesh.box(
            width: d.guidePostSize,
            height: d.guidePostHeight,
            depth: d.guidePostSize,
            center: BimVec3(
              p.$1 + d.guidePostSize / 2,
              d.guidePostHeight / 2,
              p.$2 + d.guidePostSize / 2,
            ),
          ),
          color: const Color(0xFF475569),
          category: BimEntityCategory.concrete,
          explodeGroup: 2,
          minStage: 3,
          pickable: i == 0,
          componentId: 'guide_post',
          buildProgress: 0,
        ),
      );
    }
  }

  void _platform(List<BimEntity> e, AmphibiousDimensions d) {
    e.add(
      BimEntity(
        id: 'platform_frame',
        label: 'Platform Frame',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.3,
          height: 0.12,
          depth: d.buildingDepth + 0.3,
          center: BimVec3(d.centerX, d.deckY - 0.06, d.centerZ),
        ),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        explodeGroup: 5,
        minStage: 4,
        componentId: 'floating_platform',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'floating_deck',
        label: 'Floating Deck',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.15,
          height: d.platformThickness,
          depth: d.buildingDepth + 0.15,
          center: BimVec3(
            d.centerX,
            d.deckY + d.platformThickness / 2,
            d.centerZ,
          ),
        ),
        color: const Color(0xFFD6D3D1),
        category: BimEntityCategory.timber,
        explodeGroup: 5,
        minStage: 4,
        pickable: true,
        componentId: 'floating_platform',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'pontoon_alt',
        label: 'Pontoon Option (alternative)',
        mesh: BimMesh.box(
          width: 1.8,
          height: 0.35,
          depth: 3.5,
          center: BimVec3(d.centerX - 3.5, 0.18, d.centerZ),
        ),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.annotation,
        explodeGroup: 0,
        minStage: 4,
        opacity: 0.4,
        buildProgress: 0,
      ),
    );
  }

  void _buoyancyDrums(List<BimEntity> e, AmphibiousDimensions d) {
    final positions = [
      (d.siteOffsetX + 0.6, 0.7),
      (d.siteOffsetX + 2.4, 0.7),
      (d.siteOffsetX + 4.2, 0.7),
      (d.siteOffsetX + 0.6, 3.2),
      (d.siteOffsetX + 2.4, 3.2),
      (d.siteOffsetX + 4.2, 3.2),
      (d.siteOffsetX + 1.5, 2.0),
      (d.siteOffsetX + 3.3, 2.0),
    ];
    for (var i = 0; i < positions.length; i++) {
      final p = positions[i];
      e.add(
        BimEntity(
          id: 'buoy_drum_$i',
          label: 'Sealed Buoyancy Drum',
          mesh: BimMesh.cylinder(radius: d.drumRadius, height: d.drumHeight),
          color: const Color(0xFF1D4ED8),
          category: BimEntityCategory.equipment,
          position: BimVec3(p.$1, 0.08, p.$2),
          explodeGroup: 5,
          minStage: 5,
          pickable: i == 0,
          componentId: 'buoyant_drum',
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: 'drum_strap_$i',
          label: 'Drum Connection',
          mesh: BimMesh.box(width: 0.04, height: 0.06, depth: 0.25),
          color: const Color(0xFF475569),
          category: BimEntityCategory.wire,
          position: BimVec3(p.$1, d.deckY - 0.02, p.$2),
          explodeGroup: 5,
          minStage: 5,
          buildProgress: 0,
        ),
      );
    }
  }

  void _frame(List<BimEntity> e, AmphibiousDimensions d) {
    final baseY = d.deckY + d.platformThickness;
    final cols = [
      (d.siteOffsetX + 0.2, 0.2),
      (d.siteOffsetX + d.buildingWidth - 0.35, 0.2),
      (d.siteOffsetX + 0.2, d.buildingDepth - 0.35),
      (d.siteOffsetX + d.buildingWidth - 0.35, d.buildingDepth - 0.35),
    ];
    for (var i = 0; i < cols.length; i++) {
      final p = cols[i];
      e.add(
        BimEntity(
          id: 'frame_col_$i',
          label: 'Frame Column',
          mesh: BimMesh.box(width: 0.1, height: d.frameColumnHeight, depth: 0.1),
          color: const Color(0xFF92400E),
          category: BimEntityCategory.timber,
          position: BimVec3(p.$1, baseY, p.$2),
          explodeGroup: 5,
          minStage: 6,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'bamboo_beam_front',
        label: 'Bamboo Beam',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: 0.09,
          depth: 0.09,
          center: BimVec3(d.centerX, baseY + d.frameColumnHeight - 0.05, 0.15),
        ),
        color: const Color(0xFF65A30D),
        category: BimEntityCategory.bamboo,
        explodeGroup: 5,
        minStage: 6,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'bamboo_beam_rear',
        label: 'Bamboo Beam',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: 0.09,
          depth: 0.09,
          center: BimVec3(
            d.centerX,
            baseY + d.frameColumnHeight - 0.05,
            d.buildingDepth - 0.15,
          ),
        ),
        color: const Color(0xFF65A30D),
        category: BimEntityCategory.bamboo,
        explodeGroup: 5,
        minStage: 6,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'steel_brace',
        label: 'Light Steel Brace',
        mesh: BimMesh.box(width: 0.05, height: 1.2, depth: 0.05),
        color: const Color(0xFF94A3B8),
        category: BimEntityCategory.rebar,
        position: BimVec3(d.centerX, baseY + 0.6, d.centerZ),
        explodeGroup: 5,
        minStage: 6,
        buildProgress: 0,
      ),
    );
  }

  void _floor(List<BimEntity> e, AmphibiousDimensions d) {
    final y = d.deckY + d.platformThickness + 0.02;
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'deck_panel_$i',
          label: 'Deck Panel',
          mesh: BimMesh.box(width: 2.3, height: 0.04, depth: 1.8),
          color: const Color(0xFFE7E5E4),
          category: BimEntityCategory.timber,
          position: BimVec3(d.siteOffsetX + 0.3 + (i % 2) * 2.3, y, 0.3 + (i ~/ 2) * 1.8),
          explodeGroup: 5,
          minStage: 7,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'moisture_floor',
        label: 'Moisture Resistant Flooring',
        mesh: BimMesh.box(
          width: d.buildingWidth - 0.1,
          height: 0.02,
          depth: d.buildingDepth - 0.1,
          center: BimVec3(d.centerX, y + 0.05, d.centerZ),
        ),
        color: const Color(0xFF06B6D4),
        category: BimEntityCategory.finishing,
        explodeGroup: 5,
        minStage: 7,
        opacity: 0.85,
        buildProgress: 0,
      ),
    );
  }

  void _walls(List<BimEntity> e, AmphibiousDimensions d) {
    final baseY = d.deckY + d.platformThickness + 0.08;
    var idx = 0;
    for (var c = 0; c < 6; c++) {
      final y = baseY + c * (d.wallThickness + 0.02);
      for (var s = 0; s < 4; s++) {
        final alongX = s < 2;
        final px = alongX
            ? d.siteOffsetX + (s * 2.4)
            : (s == 2 ? d.siteOffsetX : d.siteOffsetX + d.buildingWidth - d.wallThickness);
        final pz = alongX ? 0 : (s == 2 ? 0 : d.buildingDepth - d.wallThickness);
        final w = alongX ? 2.2 : d.wallThickness;
        final dep = alongX ? d.wallThickness : 1.8;
        e.add(
          BimEntity(
            id: 'wall_panel_$idx',
            label: 'Lightweight Wall Panel',
            mesh: BimMesh.box(
              width: w,
              height: d.wallThickness,
              depth: dep,
              center: BimVec3(px + w / 2, y + d.wallThickness / 2, pz + dep / 2),
            ),
            color: const Color(0xFFF5F5F4),
            category: BimEntityCategory.masonry,
            explodeGroup: 5,
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
          width: 1.0,
          height: d.wallHeight,
          depth: d.wallThickness,
          center: BimVec3(d.siteOffsetX - 0.7, baseY + d.wallHeight / 2, d.centerZ),
        ),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.annotation,
        explodeGroup: 0,
        minStage: 8,
        opacity: 0.35,
        buildProgress: 0,
      ),
    );
  }

  void _openings(List<BimEntity> e, AmphibiousDimensions d) {
    final y = d.deckY + d.platformThickness + 0.5;
    e.add(
      BimEntity(
        id: 'door_frame',
        label: 'Door Frame',
        mesh: BimMesh.box(width: 0.85, height: 1.95, depth: 0.05),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        position: BimVec3(d.siteOffsetX + 2.0, y, 0),
        explodeGroup: 5,
        minStage: 9,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'window_frame',
        label: 'Window Frame',
        mesh: BimMesh.box(width: 0.95, height: 0.95, depth: 0.05),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.timber,
        position: BimVec3(d.siteOffsetX + 0.35, y + 0.4, d.buildingDepth - 0.05),
        explodeGroup: 5,
        minStage: 9,
        buildProgress: 0,
      ),
    );
  }

  void _roofStructure(List<BimEntity> e, AmphibiousDimensions d) {
    final y = d.roofBaseY;
    final spans = [
      (d.siteOffsetX + 0.4, d.centerZ, d.siteOffsetX + 4.6, d.centerZ),
      (d.siteOffsetX + 0.4, 0.4, d.siteOffsetX + 2.5, d.centerZ + 0.8),
      (d.siteOffsetX + 4.6, 0.4, d.siteOffsetX + 2.5, d.centerZ + 0.8),
    ];
    for (var i = 0; i < spans.length; i++) {
      final s = spans[i];
      final len = ((s.$3 - s.$1) * (s.$3 - s.$1) + (s.$4 - s.$2) * (s.$4 - s.$2)).abs() + 0.01;
      e.add(
        BimEntity(
          id: 'roof_truss_$i',
          label: 'Roof Truss',
          mesh: BimMesh.box(width: len, height: 0.07, depth: 0.07),
          color: const Color(0xFF92400E),
          category: BimEntityCategory.timber,
          position: BimVec3(s.$1, y, s.$2),
          explodeGroup: 5,
          minStage: 10,
          componentId: 'roof_system',
          buildProgress: 0,
        ),
      );
    }
  }

  void _roofCover(List<BimEntity> e, AmphibiousDimensions d) {
    final y = d.roofBaseY + 0.2;
    for (var i = 0; i < 6; i++) {
      e.add(
        BimEntity(
          id: 'cgi_$i',
          label: 'CGI Sheet',
          mesh: BimMesh.box(width: 1.55, height: 0.02, depth: 2.0),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.finishing,
          position: BimVec3(
            d.siteOffsetX + 0.25 + (i % 3) * 1.55,
            y + (i ~/ 3) * 0.03,
            0.25 + (i ~/ 3) * 1.9,
          ),
          explodeGroup: 5,
          minStage: 11,
          componentId: 'roof_system',
          buildProgress: 0,
        ),
      );
    }
  }

  void _utilities(List<BimEntity> e, AmphibiousDimensions d) {
    e.add(
      BimEntity(
        id: 'flex_water',
        label: 'Flexible Water Connection',
        mesh: BimMesh.box(width: 0.08, height: 1.8, depth: 0.08),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.drainage,
        position: BimVec3(d.siteOffsetX - 0.5, 0.4, d.centerZ),
        explodeGroup: 5,
        minStage: 12,
        pickable: true,
        componentId: 'flexible_utilities',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'flex_electric',
        label: 'Flexible Electrical Conduit',
        mesh: BimMesh.box(width: 0.06, height: 1.6, depth: 0.06),
        color: const Color(0xFFFACC15),
        category: BimEntityCategory.wire,
        position: BimVec3(d.siteOffsetX + d.buildingWidth + 0.4, 0.5, 1.0),
        explodeGroup: 5,
        minStage: 12,
        componentId: 'flexible_utilities',
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'flex_drain',
        label: 'Flexible Drainage Line',
        mesh: BimMesh.box(width: 0.1, height: 1.4, depth: 0.1),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.drainage,
        position: BimVec3(d.centerX, 0.35, d.buildingDepth + 0.5),
        explodeGroup: 5,
        minStage: 12,
        componentId: 'flexible_utilities',
        buildProgress: 0,
      ),
    );
  }

  void _anchorage(List<BimEntity> e, AmphibiousDimensions d) {
    final guides = _guidePostPositions(d);
    for (var i = 0; i < guides.length; i++) {
      final p = guides[i];
      e.add(
        BimEntity(
          id: 'guide_collar_$i',
          label: 'Guide Collar',
          mesh: BimMesh.box(
            width: d.guidePostSize + 0.08,
            height: 0.12,
            depth: d.guidePostSize + 0.08,
          ),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.equipment,
          position: BimVec3(p.$1 - 0.04, d.deckY + 0.15, p.$2 - 0.04),
          explodeGroup: 5,
          minStage: 13,
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'movement_range',
        label: 'Vertical Movement Range',
        mesh: BimMesh.box(width: 0.04, height: d.maxFloatRise, depth: 0.04),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.centerX + 3.0, d.deckY, d.centerZ),
        explodeGroup: 0,
        minStage: 13,
        opacity: 0.85,
        buildProgress: 0,
      ),
    );
  }

  void _landscape(List<BimEntity> e, AmphibiousDimensions d) {
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'landscape_$i',
          label: 'Landscape',
          mesh: BimMesh.cylinder(radius: 0.1, height: 0.7),
          color: const Color(0xFF166534),
          category: BimEntityCategory.terrain,
          position: BimVec3(9 + i, 0.35, 2 + i * 1.5),
          explodeGroup: 0,
          minStage: 14,
          buildProgress: 0,
        ),
      );
    }
  }

  void _comparisons(List<BimEntity> e, AmphibiousDimensions d) {
    e.add(
      BimEntity(
        id: 'grounded_label',
        label: 'Normal Grounded Condition',
        mesh: BimMesh.box(width: 0.5, height: 0.02, depth: 0.5),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.centerX, d.deckY + 0.5, d.buildingDepth + 1.2),
        explodeGroup: 5,
        minStage: 14,
        buildProgress: 1,
      ),
    );
  }

  List<(double, double)> _padPositions(AmphibiousDimensions d) {
    final ox = d.siteOffsetX;
    return [
      (ox, 0),
      (ox + d.buildingWidth - d.padSize, 0),
      (ox, d.buildingDepth - d.padSize),
      (ox + d.buildingWidth - d.padSize, d.buildingDepth - d.padSize),
      (ox + d.buildingWidth / 2 - d.padSize / 2, d.buildingDepth / 2 - d.padSize / 2),
    ];
  }

  List<(double, double)> _guidePostPositions(AmphibiousDimensions d) {
    final ox = d.siteOffsetX - 0.35;
    final oz = -0.35;
    final bx = ox + d.buildingWidth + 0.35;
    final bz = oz + d.buildingDepth + 0.35;
    return [
      (ox, oz),
      (bx, oz),
      (ox, bz),
      (bx, bz),
    ];
  }
}
