import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'amphibious_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 06 Floating Amphibious Structure.
class AmphibiousSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
        _site(e);
    _settingOut(e);
    _foundationPads(e);
    _guidePosts(e);
    _platform(e);
    _buoyancyDrums(e);
    _frame(e);
    _floor(e);
    _walls(e);
    _openings(e);
    _roofStructure(e);
    _roofCover(e);
    _utilities(e);
    _anchorage(e);
    _landscape(e);
    _comparisons(e);

    return e;
  }

  void _site(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'floodplain',
        label: 'Floodplain',
        mesh: BimMesh.box(
          width: AmphibiousDimensions.plotWidth,
          height: 0.1,
          depth: AmphibiousDimensions.plotDepth,
          center: BimVec3(AmphibiousDimensions.plotWidth / 2, -0.05, AmphibiousDimensions.plotDepth / 2),
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
          width: AmphibiousDimensions.riverWidth,
          height: 0.07,
          depth: AmphibiousDimensions.plotDepth,
          center: BimVec3(AmphibiousDimensions.riverWidth / 2, -0.02, AmphibiousDimensions.plotDepth / 2),
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
          width: AmphibiousDimensions.buildingWidth + 1.0,
          height: 0.02,
          depth: AmphibiousDimensions.buildingDepth + 1.0,
          center: BimVec3(AmphibiousDimensions.centerX, 0.03, AmphibiousDimensions.centerZ),
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
          width: AmphibiousDimensions.plotWidth - AmphibiousDimensions.riverWidth,
          height: 0.012,
          depth: AmphibiousDimensions.plotDepth,
          center: BimVec3(
            AmphibiousDimensions.riverWidth + (AmphibiousDimensions.plotWidth - AmphibiousDimensions.riverWidth) / 2,
            0.025,
            AmphibiousDimensions.plotDepth / 2,
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
        mesh: BimMesh.box(width: 0.06, height: 0.03, depth: AmphibiousDimensions.buildingDepth + 1.5),
        color: const Color(0xFFDC2626),
        category: BimEntityCategory.annotation,
        position: BimVec3(AmphibiousDimensions.centerX + 3.2, AmphibiousDimensions.highFloodMark, -0.3),
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
          width: AmphibiousDimensions.buildingWidth + 2.5,
          height: 0.015,
          depth: AmphibiousDimensions.buildingDepth + 2.5,
          center: BimVec3(AmphibiousDimensions.centerX, 0.04, AmphibiousDimensions.centerZ),
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
          width: AmphibiousDimensions.plotWidth - AmphibiousDimensions.riverWidth + 0.4,
          height: AmphibiousDimensions.designFloodLevel,
          depth: AmphibiousDimensions.plotDepth,
          center: BimVec3(
            AmphibiousDimensions.riverWidth + (AmphibiousDimensions.plotWidth - AmphibiousDimensions.riverWidth) / 2,
            AmphibiousDimensions.designFloodLevel / 2,
            AmphibiousDimensions.plotDepth / 2,
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

  void _settingOut(List<BimEntity> e) {
    for (var i = 0; i <= 5; i++) {
      e.add(
        BimEntity(
          id: 'grid_$i',
          label: 'Survey Grid',
          mesh: BimMesh.box(width: 0.02, height: 0.01, depth: AmphibiousDimensions.buildingDepth + 2),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(AmphibiousDimensions.siteOffsetX + i * (AmphibiousDimensions.buildingWidth / 5), 0.05, -0.5),
          explodeGroup: 0,
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    final pads = _padPositions();
    for (var i = 0; i < pads.length; i++) {
      final p = pads[i];
      e.add(
        BimEntity(
          id: 'pad_marker_$i',
          label: 'Foundation Pad Location',
          mesh: BimMesh.box(width: AmphibiousDimensions.padSize, height: 0.03, depth: AmphibiousDimensions.padSize),
          color: const Color(0xFFF97316),
          category: BimEntityCategory.survey,
          position: BimVec3(p.$1, 0.06, p.$2),
          explodeGroup: 0,
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    final guides = _guidePostPositions();
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
          width: AmphibiousDimensions.buildingWidth + 0.5,
          height: 0.012,
          depth: AmphibiousDimensions.buildingDepth + 0.5,
          center: BimVec3(AmphibiousDimensions.centerX, AmphibiousDimensions.deckY - 0.02, AmphibiousDimensions.centerZ),
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

  void _foundationPads(List<BimEntity> e) {
    final pads = _padPositions();
    for (var i = 0; i < pads.length; i++) {
      final p = pads[i];
      e.add(
        BimEntity(
          id: 'pad_excavation_$i',
          label: 'Pad Excavation',
          mesh: BimMesh.box(
            width: AmphibiousDimensions.padSize + 0.2,
            height: AmphibiousDimensions.trenchDepth,
            depth: AmphibiousDimensions.padSize + 0.2,
            center: BimVec3(
              p.$1 + (AmphibiousDimensions.padSize + 0.2) / 2,
              -AmphibiousDimensions.trenchDepth / 2 + 0.02,
              p.$2 + (AmphibiousDimensions.padSize + 0.2) / 2,
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
            width: AmphibiousDimensions.padSize * 0.9,
            height: AmphibiousDimensions.padDepth * 0.7,
            depth: AmphibiousDimensions.padSize * 0.9,
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
            width: AmphibiousDimensions.padSize,
            height: AmphibiousDimensions.padDepth,
            depth: AmphibiousDimensions.padSize,
            center: BimVec3(
              p.$1 + AmphibiousDimensions.padSize / 2,
              AmphibiousDimensions.padDepth / 2,
              p.$2 + AmphibiousDimensions.padSize / 2,
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

  void _guidePosts(List<BimEntity> e) {
    final guides = _guidePostPositions();
    for (var i = 0; i < guides.length; i++) {
      final p = guides[i];
      e.add(
        BimEntity(
          id: 'guide_post_$i',
          label: 'Guide Post',
          mesh: BimMesh.box(
            width: AmphibiousDimensions.guidePostSize,
            height: AmphibiousDimensions.guidePostHeight,
            depth: AmphibiousDimensions.guidePostSize,
            center: BimVec3(
              p.$1 + AmphibiousDimensions.guidePostSize / 2,
              AmphibiousDimensions.guidePostHeight / 2,
              p.$2 + AmphibiousDimensions.guidePostSize / 2,
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

  void _platform(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'platform_frame',
        label: 'Platform Frame',
        mesh: BimMesh.box(
          width: AmphibiousDimensions.buildingWidth + 0.3,
          height: 0.12,
          depth: AmphibiousDimensions.buildingDepth + 0.3,
          center: BimVec3(AmphibiousDimensions.centerX, AmphibiousDimensions.deckY - 0.06, AmphibiousDimensions.centerZ),
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
          width: AmphibiousDimensions.buildingWidth + 0.15,
          height: AmphibiousDimensions.platformThickness,
          depth: AmphibiousDimensions.buildingDepth + 0.15,
          center: BimVec3(
            AmphibiousDimensions.centerX,
            AmphibiousDimensions.deckY + AmphibiousDimensions.platformThickness / 2,
            AmphibiousDimensions.centerZ,
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
          center: BimVec3(AmphibiousDimensions.centerX - 3.5, 0.18, AmphibiousDimensions.centerZ),
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

  void _buoyancyDrums(List<BimEntity> e) {
    final positions = [
      (AmphibiousDimensions.siteOffsetX + 0.6, 0.7),
      (AmphibiousDimensions.siteOffsetX + 2.4, 0.7),
      (AmphibiousDimensions.siteOffsetX + 4.2, 0.7),
      (AmphibiousDimensions.siteOffsetX + 0.6, 3.2),
      (AmphibiousDimensions.siteOffsetX + 2.4, 3.2),
      (AmphibiousDimensions.siteOffsetX + 4.2, 3.2),
      (AmphibiousDimensions.siteOffsetX + 1.5, 2.0),
      (AmphibiousDimensions.siteOffsetX + 3.3, 2.0),
    ];
    for (var i = 0; i < positions.length; i++) {
      final p = positions[i];
      e.add(
        BimEntity(
          id: 'buoy_drum_$i',
          label: 'Sealed Buoyancy Drum',
          mesh: BimMesh.cylinder(radius: AmphibiousDimensions.drumRadius, height: AmphibiousDimensions.drumHeight),
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
          position: BimVec3(p.$1, AmphibiousDimensions.deckY - 0.02, p.$2),
          explodeGroup: 5,
          minStage: 5,
          buildProgress: 0,
        ),
      );
    }
  }

  void _frame(List<BimEntity> e) {
    final baseY = AmphibiousDimensions.deckY + AmphibiousDimensions.platformThickness;
    final cols = [
      (AmphibiousDimensions.siteOffsetX + 0.2, 0.2),
      (AmphibiousDimensions.siteOffsetX + AmphibiousDimensions.buildingWidth - 0.35, 0.2),
      (AmphibiousDimensions.siteOffsetX + 0.2, AmphibiousDimensions.buildingDepth - 0.35),
      (AmphibiousDimensions.siteOffsetX + AmphibiousDimensions.buildingWidth - 0.35, AmphibiousDimensions.buildingDepth - 0.35),
    ];
    for (var i = 0; i < cols.length; i++) {
      final p = cols[i];
      e.add(
        BimEntity(
          id: 'frame_col_$i',
          label: 'Frame Column',
          mesh: BimMesh.box(width: 0.1, height: AmphibiousDimensions.frameColumnHeight, depth: 0.1),
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
          width: AmphibiousDimensions.buildingWidth,
          height: 0.09,
          depth: 0.09,
          center: BimVec3(AmphibiousDimensions.centerX, baseY + AmphibiousDimensions.frameColumnHeight - 0.05, 0.15),
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
          width: AmphibiousDimensions.buildingWidth,
          height: 0.09,
          depth: 0.09,
          center: BimVec3(
            AmphibiousDimensions.centerX,
            baseY + AmphibiousDimensions.frameColumnHeight - 0.05,
            AmphibiousDimensions.buildingDepth - 0.15,
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
        position: BimVec3(AmphibiousDimensions.centerX, baseY + 0.6, AmphibiousDimensions.centerZ),
        explodeGroup: 5,
        minStage: 6,
        buildProgress: 0,
      ),
    );
  }

  void _floor(List<BimEntity> e) {
    final y = AmphibiousDimensions.deckY + AmphibiousDimensions.platformThickness + 0.02;
    for (var i = 0; i < 4; i++) {
      e.add(
        BimEntity(
          id: 'deck_panel_$i',
          label: 'Deck Panel',
          mesh: BimMesh.box(width: 2.3, height: 0.04, depth: 1.8),
          color: const Color(0xFFE7E5E4),
          category: BimEntityCategory.timber,
          position: BimVec3(AmphibiousDimensions.siteOffsetX + 0.3 + (i % 2) * 2.3, y, 0.3 + (i ~/ 2) * 1.8),
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
          width: AmphibiousDimensions.buildingWidth - 0.1,
          height: 0.02,
          depth: AmphibiousDimensions.buildingDepth - 0.1,
          center: BimVec3(AmphibiousDimensions.centerX, y + 0.05, AmphibiousDimensions.centerZ),
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

  void _walls(List<BimEntity> e) {
    final baseY = AmphibiousDimensions.deckY + AmphibiousDimensions.platformThickness + 0.08;
    var idx = 0;
    for (var c = 0; c < 6; c++) {
      final y = baseY + c * (AmphibiousDimensions.wallThickness + 0.02);
      for (var s = 0; s < 4; s++) {
        final alongX = s < 2;
        final px = alongX
            ? AmphibiousDimensions.siteOffsetX + (s * 2.4)
            : (s == 2 ? AmphibiousDimensions.siteOffsetX : AmphibiousDimensions.siteOffsetX + AmphibiousDimensions.buildingWidth - AmphibiousDimensions.wallThickness);
        final pz = alongX ? 0 : (s == 2 ? 0 : AmphibiousDimensions.buildingDepth - AmphibiousDimensions.wallThickness);
        final w = alongX ? 2.2 : AmphibiousDimensions.wallThickness;
        final dep = alongX ? AmphibiousDimensions.wallThickness : 1.8;
        e.add(
          BimEntity(
            id: 'wall_panel_$idx',
            label: 'Lightweight Wall Panel',
            mesh: BimMesh.box(
              width: w,
              height: AmphibiousDimensions.wallThickness,
              depth: dep,
              center: BimVec3(px + w / 2, y + AmphibiousDimensions.wallThickness / 2, pz + dep / 2),
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
          height: AmphibiousDimensions.wallHeight,
          depth: AmphibiousDimensions.wallThickness,
          center: BimVec3(AmphibiousDimensions.siteOffsetX - 0.7, baseY + AmphibiousDimensions.wallHeight / 2, AmphibiousDimensions.centerZ),
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

  void _openings(List<BimEntity> e) {
    final y = AmphibiousDimensions.deckY + AmphibiousDimensions.platformThickness + 0.5;
    e.add(
      BimEntity(
        id: 'door_frame',
        label: 'Door Frame',
        mesh: BimMesh.box(width: 0.85, height: 1.95, depth: 0.05),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        position: BimVec3(AmphibiousDimensions.siteOffsetX + 2.0, y, 0),
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
        position: BimVec3(AmphibiousDimensions.siteOffsetX + 0.35, y + 0.4, AmphibiousDimensions.buildingDepth - 0.05),
        explodeGroup: 5,
        minStage: 9,
        buildProgress: 0,
      ),
    );
  }

  void _roofStructure(List<BimEntity> e) {
    final y = AmphibiousDimensions.roofBaseY;
    final spans = [
      (AmphibiousDimensions.siteOffsetX + 0.4, AmphibiousDimensions.centerZ, AmphibiousDimensions.siteOffsetX + 4.6, AmphibiousDimensions.centerZ),
      (AmphibiousDimensions.siteOffsetX + 0.4, 0.4, AmphibiousDimensions.siteOffsetX + 2.5, AmphibiousDimensions.centerZ + 0.8),
      (AmphibiousDimensions.siteOffsetX + 4.6, 0.4, AmphibiousDimensions.siteOffsetX + 2.5, AmphibiousDimensions.centerZ + 0.8),
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

  void _roofCover(List<BimEntity> e) {
    final y = AmphibiousDimensions.roofBaseY + 0.2;
    for (var i = 0; i < 6; i++) {
      e.add(
        BimEntity(
          id: 'cgi_$i',
          label: 'CGI Sheet',
          mesh: BimMesh.box(width: 1.55, height: 0.02, depth: 2.0),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.finishing,
          position: BimVec3(
            AmphibiousDimensions.siteOffsetX + 0.25 + (i % 3) * 1.55,
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

  void _utilities(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'flex_water',
        label: 'Flexible Water Connection',
        mesh: BimMesh.box(width: 0.08, height: 1.8, depth: 0.08),
        color: const Color(0xFF0EA5E9),
        category: BimEntityCategory.drainage,
        position: BimVec3(AmphibiousDimensions.siteOffsetX - 0.5, 0.4, AmphibiousDimensions.centerZ),
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
        position: BimVec3(AmphibiousDimensions.siteOffsetX + AmphibiousDimensions.buildingWidth + 0.4, 0.5, 1.0),
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
        position: BimVec3(AmphibiousDimensions.centerX, 0.35, AmphibiousDimensions.buildingDepth + 0.5),
        explodeGroup: 5,
        minStage: 12,
        componentId: 'flexible_utilities',
        buildProgress: 0,
      ),
    );
  }

  void _anchorage(List<BimEntity> e) {
    final guides = _guidePostPositions();
    for (var i = 0; i < guides.length; i++) {
      final p = guides[i];
      e.add(
        BimEntity(
          id: 'guide_collar_$i',
          label: 'Guide Collar',
          mesh: BimMesh.box(
            width: AmphibiousDimensions.guidePostSize + 0.08,
            height: 0.12,
            depth: AmphibiousDimensions.guidePostSize + 0.08,
          ),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.equipment,
          position: BimVec3(p.$1 - 0.04, AmphibiousDimensions.deckY + 0.15, p.$2 - 0.04),
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
        mesh: BimMesh.box(width: 0.04, height: AmphibiousDimensions.maxFloatRise, depth: 0.04),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.annotation,
        position: BimVec3(AmphibiousDimensions.centerX + 3.0, AmphibiousDimensions.deckY, AmphibiousDimensions.centerZ),
        explodeGroup: 0,
        minStage: 13,
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
          mesh: BimMesh.cylinder(radius: 0.1, height: 0.7),
          color: const Color(0xFF166534),
          category: BimEntityCategory.terrain,
          position: BimVec3(9.0 + i, 0.35, 2 + i * 1.5),
          explodeGroup: 0,
          minStage: 14,
          buildProgress: 0,
        ),
      );
    }
  }

  void _comparisons(List<BimEntity> e) {
    e.add(
      BimEntity(
        id: 'grounded_label',
        label: 'Normal Grounded Condition',
        mesh: BimMesh.box(width: 0.5, height: 0.02, depth: 0.5),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.annotation,
        position: BimVec3(AmphibiousDimensions.centerX, AmphibiousDimensions.deckY + 0.5, AmphibiousDimensions.buildingDepth + 1.2),
        explodeGroup: 5,
        minStage: 14,
        buildProgress: 1,
      ),
    );
  }

  List<(double, double)> _padPositions() {
    final ox = AmphibiousDimensions.siteOffsetX;
    return [
      (ox, 0),
      (ox + AmphibiousDimensions.buildingWidth - AmphibiousDimensions.padSize, 0),
      (ox, AmphibiousDimensions.buildingDepth - AmphibiousDimensions.padSize),
      (ox + AmphibiousDimensions.buildingWidth - AmphibiousDimensions.padSize, AmphibiousDimensions.buildingDepth - AmphibiousDimensions.padSize),
      (ox + AmphibiousDimensions.buildingWidth / 2 - AmphibiousDimensions.padSize / 2, AmphibiousDimensions.buildingDepth / 2 - AmphibiousDimensions.padSize / 2),
    ];
  }

  List<(double, double)> _guidePostPositions() {
    final ox = AmphibiousDimensions.siteOffsetX - 0.35;
    final oz = -0.35;
    final bx = ox + AmphibiousDimensions.buildingWidth + 0.35;
    final bz = oz + AmphibiousDimensions.buildingDepth + 0.35;
    return [
      (ox, oz),
      (bx, oz),
      (ox, bz),
      (bx, bz),
    ];
  }
}
