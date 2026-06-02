import 'dart:math' as math;
import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'house_dimensions.dart';
import '../math/bim_vec3.dart';

/// Engineering-grade procedural BIM — interlocking brick masonry digital twin.
///
/// Coordinates: origin at SW corner of building footprint, Y up, meters.
class InterlockingBrickSceneBuilder {
  List<BimEntity> build() {
    final entities = <BimEntity>[];
    _addSiteAndGrid(entities);
    _addExcavation(entities);
    _addFoundationSystem(entities);
    _addPlinthBeamSystem(entities);
    _addDpcLayer(entities);
    _addVerticalReinforcement(entities);
    _addInterlockingWalls(entities);
    _addLintelBandSystem(entities);
    _addRoofBandSystem(entities);
    _addRoofStructure(entities);
    _addOpenings(entities);
    _addLoadPathAnnotations(entities);
    _addEquipment(entities);
    return entities;
  }

  // ── Site & structural grid ──────────────────────────────────────────────

  void _addSiteAndGrid(List<BimEntity> entities) {
    entities.add(
      BimEntity(
        id: 'terrain',
        label: 'Terrain',
        mesh: BimMesh.box(
          width: HouseDimensions.plotWidth,
          height: 0.15,
          depth: HouseDimensions.plotDepth,
          center: BimVec3(
            HouseDimensions.plotWidth / 2,
            -0.075,
            HouseDimensions.plotDepth / 2,
          ),
        ),
        color: const Color(0xFF8B7355),
        category: BimEntityCategory.terrain,
        minStage: 0,
      ),
    );

    _addFootprintEdges(entities);

    entities.add(
      BimEntity(
        id: 'north_arrow',
        label: 'North',
        mesh: BimMesh.box(width: 0.15, height: 0.02, depth: 1.2),
        color: const Color(0xFFEF4444),
        category: BimEntityCategory.annotation,
        position: BimVec3(
          HouseDimensions.plotWidth - 1.2,
          0.05,
          HouseDimensions.plotDepth - 1.5,
        ),
        minStage: 0,
      ),
    );

    // Structural grid — 1 m module aligned to building
    final gridX = (HouseDimensions.buildingWidth / HouseDimensions.gridModule).ceil() + 1;
    final gridZ = (HouseDimensions.buildingDepth / HouseDimensions.gridModule).ceil() + 1;
    for (var i = 0; i <= gridX; i++) {
      final x = i * HouseDimensions.gridModule;
      entities.add(
        BimEntity(
          id: 'grid_x_$i',
          label: 'Grid Line X$i',
          mesh: BimMesh.box(
            width: 0.015,
            height: 0.008,
            depth: HouseDimensions.buildingDepth + 1.5,
          ),
          color: const Color(0xFF64748B),
          category: BimEntityCategory.grid,
          position: BimVec3(x, 0.025, -0.75),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    for (var i = 0; i <= gridZ; i++) {
      final z = i * HouseDimensions.gridModule;
      entities.add(
        BimEntity(
          id: 'grid_z_$i',
          label: 'Grid Line Z$i',
          mesh: BimMesh.box(
            width: HouseDimensions.buildingWidth + 1.5,
            height: 0.008,
            depth: 0.015,
          ),
          color: const Color(0xFF64748B),
          category: BimEntityCategory.grid,
          position: BimVec3(-0.75, 0.025, z),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }

    for (final corner in _buildingCorners()) {
      entities.add(
        BimEntity(
          id: 'stake_${corner.$1.toStringAsFixed(1)}_${corner.$2.toStringAsFixed(1)}',
          label: 'Survey Stake',
          mesh: BimMesh.cylinder(radius: 0.025, height: 1.0, segments: 8),
          color: const Color(0xFFF97316),
          category: BimEntityCategory.survey,
          position: BimVec3(corner.$1, 0, corner.$2),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
  }

  void _addFootprintEdges(List<BimEntity> entities) {
    const y = 0.04;
    const h = 0.04;
    final w = HouseDimensions.buildingWidth;
    final d = HouseDimensions.buildingDepth;
    final edges = [
      (0.0, 0.0, w, 0.0),
      (w, 0.0, w, d),
      (w, d, 0.0, d),
      (0.0, d, 0.0, 0.0),
    ];
    for (var i = 0; i < edges.length; i++) {
      final e = edges[i];
      final len = _dist(e.$1, e.$2, e.$3, e.$4);
      entities.add(
        BimEntity(
          id: 'footprint_$i',
          label: 'Building Footprint',
          mesh: BimMesh.box(width: len, height: h, depth: 0.08),
          color: const Color(0xFF0F172A),
          category: BimEntityCategory.annotation,
          position: BimVec3((e.$1 + e.$3) / 2 - len / 2, y, (e.$2 + e.$4) / 2),
          minStage: 0,
        ),
      );
    }
  }

  // ── Excavation ──────────────────────────────────────────────────────────

  void _addExcavation(List<BimEntity> entities) {
    final yBase = HouseDimensions.trenchBottomY + HouseDimensions.trenchDepth / 2;
    final w = HouseDimensions.buildingWidth;
    final d = HouseDimensions.buildingDepth;
    final tw = HouseDimensions.trenchWidth;

    final specs = [
      (HouseDimensions.centerX, yBase, 0.0, w + tw * 2, HouseDimensions.trenchDepth, tw),
      (HouseDimensions.centerX, yBase, d, w + tw * 2, HouseDimensions.trenchDepth, tw),
      (0.0, yBase, HouseDimensions.centerZ, tw, HouseDimensions.trenchDepth, d),
      (w, yBase, HouseDimensions.centerZ, tw, HouseDimensions.trenchDepth, d),
    ];

    for (var i = 0; i < specs.length; i++) {
      final s = specs[i];
      entities.add(
        BimEntity(
          id: 'trench_$i',
          label: 'Excavation Trench',
          mesh: BimMesh.box(width: s.$4, height: s.$5, depth: s.$6),
          color: const Color(0xFFA16207),
          category: BimEntityCategory.excavation,
          position: BimVec3(s.$1 - s.$4 / 2, s.$2, s.$3 - s.$6 / 2),
          explodeGroup: 1,
          minStage: 2,
          pickable: i == 0,
          componentId: 'foundation',
          buildProgress: 0,
        ),
      );
    }

    entities.add(
      BimEntity(
        id: 'bearing_layer',
        label: 'Bearing Stratum',
        mesh: BimMesh.box(
          width: w + 2,
          height: 0.2,
          depth: d + 2,
          center: BimVec3(
            HouseDimensions.centerX,
            HouseDimensions.trenchBottomY + 0.1,
            HouseDimensions.centerZ,
          ),
        ),
        color: const Color(0xFF78716C),
        category: BimEntityCategory.excavation,
        minStage: 2,
        opacity: 0.85,
      ),
    );
  }

  // ── Foundation: PCC, footings, foundation wall ────────────────────────

  void _addFoundationSystem(List<BimEntity> entities) {
    final yPcc = HouseDimensions.trenchBottomY + HouseDimensions.pccThickness / 2;
    final w = HouseDimensions.buildingWidth;
    final d = HouseDimensions.buildingDepth;
    final tw = HouseDimensions.trenchWidth;

    // PCC strips — 4 trench segments
    final pccSpecs = [
      (HouseDimensions.centerX, yPcc, 0.0, w + 0.4, HouseDimensions.pccThickness, tw),
      (HouseDimensions.centerX, yPcc, d, w + 0.4, HouseDimensions.pccThickness, tw),
      (0.0, yPcc, HouseDimensions.centerZ, tw, HouseDimensions.pccThickness, d + 0.2),
      (w, yPcc, HouseDimensions.centerZ, tw, HouseDimensions.pccThickness, d + 0.2),
    ];
    for (var i = 0; i < pccSpecs.length; i++) {
      final s = pccSpecs[i];
      entities.add(
        BimEntity(
          id: 'pcc_$i',
          label: 'PCC Blinding',
          mesh: BimMesh.box(width: s.$4, height: s.$5, depth: s.$6),
          color: const Color(0xFFD1D5DB),
          category: BimEntityCategory.concrete,
          position: BimVec3(s.$1 - s.$4 / 2, s.$2, s.$3 - s.$6 / 2),
          explodeGroup: 1,
          minStage: 3,
          pickable: i == 0,
          componentId: 'foundation',
          buildProgress: 0,
        ),
      );
    }

    // Strip footings — 4 sides
    final yFoot = HouseDimensions.pccTopY + HouseDimensions.footingDepth / 2;
    final fw = HouseDimensions.footingWidth;
    final footSpecs = [
      (HouseDimensions.centerX, yFoot, 0.0, w + fw, HouseDimensions.footingDepth, fw),
      (HouseDimensions.centerX, yFoot, d, w + fw, HouseDimensions.footingDepth, fw),
      (0.0, yFoot, HouseDimensions.centerZ, fw, HouseDimensions.footingDepth, d + fw * 0.5),
      (w, yFoot, HouseDimensions.centerZ, fw, HouseDimensions.footingDepth, d + fw * 0.5),
    ];
    for (var i = 0; i < footSpecs.length; i++) {
      final s = footSpecs[i];
      entities.add(
        BimEntity(
          id: 'footing_$i',
          label: 'Strip Footing',
          mesh: BimMesh.box(width: s.$4, height: s.$5, depth: s.$6),
          color: const Color(0xFF9CA3AF),
          category: BimEntityCategory.concrete,
          position: BimVec3(s.$1 - s.$4 / 2, s.$2, s.$3 - s.$6 / 2),
          explodeGroup: 1,
          minStage: 4,
          pickable: i == 0,
          componentId: 'footing',
          buildProgress: 0,
        ),
      );
    }

    // Foundation wall masonry — course-by-course in trench
    for (var course = 0; course < HouseDimensions.foundationCourses; course++) {
      final y = HouseDimensions.footingTopY + course * HouseDimensions.blockHeight;
      entities.add(
        BimEntity(
          id: 'found_wall_course_$course',
          label: 'Foundation Wall Course ${course + 1}',
          mesh: BimMesh.box(
            width: w + HouseDimensions.wallThickness,
            height: HouseDimensions.blockHeight,
            depth: d + HouseDimensions.wallThickness,
            center: BimVec3(
              HouseDimensions.centerX,
              y + HouseDimensions.blockHeight / 2,
              HouseDimensions.centerZ,
            ),
          ),
          color: Color.lerp(
            const Color(0xFFB45309),
            const Color(0xFF92400E),
            course / HouseDimensions.foundationCourses,
          )!,
          category: BimEntityCategory.masonry,
          explodeGroup: 1,
          minStage: 4,
          componentId: 'foundation',
          buildProgress: 0,
        ),
      );
    }
  }

  // ── Plinth beam: formwork → rebar → concrete ────────────────────────────

  void _addPlinthBeamSystem(List<BimEntity> entities) {
    final baseY = HouseDimensions.foundationWallTopY;
    final w = HouseDimensions.buildingWidth;
    final d = HouseDimensions.buildingDepth;
    final pb = HouseDimensions.plinthBeam;

    entities.add(
      BimEntity(
        id: 'plinth_formwork',
        label: 'Plinth Beam Formwork',
        mesh: BimMesh.box(
          width: w + 0.4,
          height: pb + 0.08,
          depth: d + 0.4,
          center: BimVec3(HouseDimensions.centerX, baseY + pb / 2, HouseDimensions.centerZ),
        ),
        color: const Color(0xFFDEB887),
        category: BimEntityCategory.formwork,
        minStage: 5,
        componentId: 'plinth_beam',
        buildProgress: 0,
      ),
    );

    // Longitudinal bars — 4 corners of beam cage
    final barY = baseY + pb * 0.25;
    final barPositions = [
      (0.15, 0.15),
      (w - 0.15, 0.15),
      (w - 0.15, d - 0.15),
      (0.15, d - 0.15),
    ];
    for (var i = 0; i < barPositions.length; i++) {
      final bp = barPositions[i];
      entities.add(
        BimEntity(
          id: 'plinth_rebar_long_$i',
          label: 'Plinth Longitudinal Bar',
          mesh: BimMesh.cylinder(radius: HouseDimensions.rebarRadius, height: pb * 0.6),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(bp.$1, barY, bp.$2),
          explodeGroup: 2,
          minStage: 5,
          pickable: i == 0,
          componentId: 'plinth_beam',
          buildProgress: 0,
        ),
      );
    }

    // Stirrups at 150 mm c/c
    final stirrupCount = ((w + d) * 2 / 0.15).ceil().clamp(8, 24);
    for (var i = 0; i < stirrupCount; i++) {
      final t = i / (stirrupCount - 1);
      entities.add(
        BimEntity(
          id: 'plinth_rebar_stir_$i',
          label: 'Plinth Stirrup',
          mesh: BimMesh.box(width: 0.18, height: pb * 0.85, depth: 0.04),
          color: const Color(0xFFDC2626),
          category: BimEntityCategory.rebar,
          position: BimVec3(
            0.2 + t * (w - 0.4),
            baseY + pb / 2,
            0.12,
          ),
          explodeGroup: 2,
          minStage: 5,
          buildProgress: 0,
        ),
      );
    }

    entities.add(
      BimEntity(
        id: 'plinth_concrete',
        label: 'Plinth Beam Concrete',
        mesh: BimMesh.box(
          width: w + HouseDimensions.wallThickness * 0.5,
          height: pb,
          depth: d + HouseDimensions.wallThickness * 0.5,
          center: BimVec3(HouseDimensions.centerX, baseY + pb / 2, HouseDimensions.centerZ),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 2,
        minStage: 5,
        pickable: true,
        componentId: 'plinth_beam',
        buildProgress: 0,
      ),
    );
  }

  void _addDpcLayer(List<BimEntity> entities) {
    entities.add(
      BimEntity(
        id: 'dpc_layer',
        label: 'DPC Layer',
        mesh: BimMesh.box(
          width: HouseDimensions.buildingWidth + HouseDimensions.wallThickness,
          height: HouseDimensions.dpcThickness,
          depth: HouseDimensions.buildingDepth + HouseDimensions.wallThickness,
          center: BimVec3(
            HouseDimensions.centerX,
            HouseDimensions.dpcY + HouseDimensions.dpcThickness / 2,
            HouseDimensions.centerZ,
          ),
        ),
        color: const Color(0xFF1E293B),
        category: BimEntityCategory.finishing,
        explodeGroup: 2,
        minStage: 5,
        pickable: true,
        componentId: 'dpc',
        buildProgress: 0,
      ),
    );
  }

  // ── Vertical reinforcement ──────────────────────────────────────────────

  void _addVerticalReinforcement(List<BimEntity> entities) {
    final baseY = HouseDimensions.wallBaseY;
    final barH = HouseDimensions.wallHeight + HouseDimensions.bandHeight * 2;

    // Corner bars — anchored into footing/plinth
    var i = 0;
    for (final c in _buildingCorners(inset: HouseDimensions.wallThickness / 2)) {
      entities.add(
        BimEntity(
          id: 'vbar_corner_$i',
          label: 'Corner Bar Ø12',
          mesh: BimMesh.cylinder(radius: HouseDimensions.rebarRadius, height: barH),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(c.$1, baseY, c.$2),
          explodeGroup: 2,
          minStage: 6,
          pickable: i == 0,
          componentId: 'vertical_reinforcement',
          buildProgress: 0,
        ),
      );
      // Footing anchor L-bar
      entities.add(
        BimEntity(
          id: 'vbar_anchor_$i',
          label: 'Footing Anchor',
          mesh: BimMesh.box(width: 0.12, height: 0.04, depth: 0.12),
          color: const Color(0xFFDC2626),
          category: BimEntityCategory.rebar,
          position: BimVec3(c.$1, HouseDimensions.footingTopY, c.$2),
          minStage: 6,
          buildProgress: 0,
        ),
      );
      i++;
    }

    // Mid-wall bars at 2 m spacing
    final midPositions = <(double, double)>[
      (HouseDimensions.centerX, 0.12),
      (HouseDimensions.centerX, HouseDimensions.buildingDepth - 0.12),
      (0.12, HouseDimensions.centerZ),
      (HouseDimensions.buildingWidth - 0.12, HouseDimensions.centerZ),
    ];
    for (var j = 0; j < midPositions.length; j++) {
      final mp = midPositions[j];
      entities.add(
        BimEntity(
          id: 'vbar_mid_$j',
          label: 'Wall Bar Ø12',
          mesh: BimMesh.cylinder(radius: HouseDimensions.rebarRadius, height: barH * 0.98),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(mp.$1, baseY, mp.$2),
          minStage: 6,
          componentId: 'vertical_reinforcement',
          buildProgress: 0,
        ),
      );
    }

    // Opening reinforcement — door jambs
    final doorX = HouseDimensions.centerX;
    for (final dx in [-0.55, 0.55]) {
      entities.add(
        BimEntity(
          id: 'vbar_opening_${dx > 0 ? 'r' : 'l'}',
          label: 'Opening Bar',
          mesh: BimMesh.cylinder(radius: HouseDimensions.rebarRadius, height: barH * 0.85),
          color: const Color(0xFFDC2626),
          category: BimEntityCategory.rebar,
          position: BimVec3(doorX + dx, baseY, 0.12),
          minStage: 6,
          componentId: 'vertical_reinforcement',
          buildProgress: 0,
        ),
      );
    }
  }

  // ── Interlocking brick walls — course-by-course ─────────────────────────

  void _addInterlockingWalls(List<BimEntity> entities) {
    final courses = (HouseDimensions.wallHeight / HouseDimensions.blockHeight).ceil();
    final baseY = HouseDimensions.wallBaseY;
    var blockIndex = 0;

    for (var course = 0; course < courses; course++) {
      final y = baseY + course * HouseDimensions.blockHeight;
      final stagger = (course % 2) * HouseDimensions.blockLength / 2;

      blockIndex = _addWallRun(
        entities,
        blockIndex,
        course,
        y,
        stagger,
        axis: _WallAxis.front,
      );
      blockIndex = _addWallRun(
        entities,
        blockIndex,
        course,
        y,
        stagger,
        axis: _WallAxis.back,
      );
      blockIndex = _addWallRun(
        entities,
        blockIndex,
        course,
        y,
        stagger,
        axis: _WallAxis.left,
      );
      blockIndex = _addWallRun(
        entities,
        blockIndex,
        course,
        y,
        stagger,
        axis: _WallAxis.right,
      );

      // Corner interlock blocks — alternate course orientation
      blockIndex = _addCornerBlocks(entities, blockIndex, course, y);
    }
  }

  int _addWallRun(
    List<BimEntity> entities,
    int blockIndex,
    int course,
    double y,
    double stagger, {
    required _WallAxis axis,
  }) {
    final w = HouseDimensions.buildingWidth;
    final d = HouseDimensions.buildingDepth;
    final wt = HouseDimensions.wallThickness;
    final bl = HouseDimensions.blockLength;
    final inset = wt + 0.02;

    double runLength;
    double startCoord;
    bool alongX;

    switch (axis) {
      case _WallAxis.front:
        runLength = w - wt * 2;
        startCoord = wt + stagger;
        alongX = true;
      case _WallAxis.back:
        runLength = w - wt * 2;
        startCoord = wt + stagger;
        alongX = true;
      case _WallAxis.left:
        runLength = d - wt * 2;
        startCoord = wt + stagger;
        alongX = false;
      case _WallAxis.right:
        runLength = d - wt * 2;
        startCoord = wt + stagger;
        alongX = false;
    }

    final count = (runLength / bl).floor();
    for (var b = 0; b < count; b++) {
      final coord = startCoord + b * bl;
      if (coord + bl > (alongX ? w : d) - inset) continue;

      late double x, z;
      late double blockW, blockD;

      switch (axis) {
        case _WallAxis.front:
          x = coord;
          z = 0.0;
          blockW = bl;
          blockD = wt;
        case _WallAxis.back:
          x = coord;
          z = d - wt;
          blockW = bl;
          blockD = wt;
        case _WallAxis.left:
          x = 0.0;
          z = coord;
          blockW = wt;
          blockD = bl;
        case _WallAxis.right:
          x = w - wt;
          z = coord;
          blockW = wt;
          blockD = bl;
      }

      entities.add(_makeBlock('blk_$blockIndex', x, y, z, blockW, blockD, course));
      blockIndex++;
    }
    return blockIndex;
  }

  int _addCornerBlocks(
    List<BimEntity> entities,
    int blockIndex,
    int course,
    double y,
  ) {
    final w = HouseDimensions.buildingWidth;
    final d = HouseDimensions.buildingDepth;
    final wt = HouseDimensions.wallThickness;
    final isHeader = course.isOdd;

    final corners = [
      (0.0, 0.0),
      (w - wt, 0.0),
      (w - wt, d - wt),
      (0.0, d - wt),
    ];

    for (final c in corners) {
      if (isHeader) {
        entities.add(_makeBlock(
          'blk_corner_$blockIndex',
          c.$1,
          y,
          c.$2,
          wt,
          wt,
          course,
          isCorner: true,
        ));
      } else {
        entities.add(_makeBlock(
          'blk_corner_$blockIndex',
          c.$1,
          y,
          c.$2,
          wt,
          wt,
          course,
          isCorner: true,
        ));
      }
      blockIndex++;
    }
    return blockIndex;
  }

  BimEntity _makeBlock(
    String id,
    double x,
    double y,
    double z,
    double width,
    double depth,
    int course, {
    bool isCorner = false,
  }) {
    final bh = HouseDimensions.blockHeight;
    // Interlock key nub — simulated with slight size reduction for visual bond
    final shrink = isCorner ? 0.96 : 0.94;

    return BimEntity(
      id: id,
      label: isCorner ? 'Corner Interlock Block' : 'Interlocking Block',
      mesh: BimMesh.box(
        width: width * shrink,
        height: bh,
        depth: depth * shrink,
      ),
      color: Color.lerp(
        const Color(0xFFB45309),
        const Color(0xFF78350F),
        (course % 4) / 4,
      )!,
      category: BimEntityCategory.masonry,
      position: BimVec3(x, y, z),
      explodeGroup: 2,
      minStage: 7,
      pickable: id.endsWith('0') || isCorner,
      componentId: 'wall',
      buildProgress: 0,
    );
  }

  // ── Lintel band: formwork → rebar → pour → complete ─────────────────────

  void _addLintelBandSystem(List<BimEntity> entities) {
    final y = HouseDimensions.lintelBandY;
    final w = HouseDimensions.buildingWidth;
    final d = HouseDimensions.buildingDepth;
    final bh = HouseDimensions.bandHeight;

    entities.add(
      BimEntity(
        id: 'lintel_formwork',
        label: 'Lintel Band Formwork',
        mesh: BimMesh.box(
          width: w + 0.35,
          height: bh + 0.06,
          depth: d + 0.35,
          center: BimVec3(HouseDimensions.centerX, y + bh / 2, HouseDimensions.centerZ),
        ),
        color: const Color(0xFFDEB887),
        category: BimEntityCategory.formwork,
        minStage: 8,
        componentId: 'lintel_band',
        buildProgress: 0,
      ),
    );

    for (var i = 0; i < 16; i++) {
      final t = i / 15;
      entities.add(
        BimEntity(
          id: 'lintel_rebar_$i',
          label: 'Lintel Band Rebar',
          mesh: BimMesh.cylinder(radius: HouseDimensions.rebarRadius, height: bh * 0.7),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(0.2 + t * (w - 0.4), y + bh * 0.3, 0.15),
          explodeGroup: 3,
          minStage: 8,
          pickable: i == 0,
          componentId: 'lintel_band',
          buildProgress: 0,
        ),
      );
    }

    entities.add(
      BimEntity(
        id: 'lintel_concrete_pour',
        label: 'Lintel Concrete Pour',
        mesh: BimMesh.box(
          width: w + HouseDimensions.wallThickness,
          height: bh * 0.85,
          depth: d + HouseDimensions.wallThickness,
          center: BimVec3(HouseDimensions.centerX, y + bh * 0.4, HouseDimensions.centerZ),
        ),
        color: const Color(0xFF94A3B8),
        category: BimEntityCategory.concrete,
        minStage: 8,
        opacity: 0.75,
        componentId: 'lintel_band',
        buildProgress: 0,
      ),
    );

    entities.add(
      BimEntity(
        id: 'lintel_band',
        label: 'Lintel Band (Complete)',
        mesh: BimMesh.box(
          width: w + HouseDimensions.wallThickness,
          height: bh,
          depth: d + HouseDimensions.wallThickness,
          center: BimVec3(HouseDimensions.centerX, y + bh / 2, HouseDimensions.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 3,
        minStage: 8,
        pickable: true,
        componentId: 'lintel_band',
        buildProgress: 0,
      ),
    );
  }

  // ── Roof band: rebar → formwork → concrete ──────────────────────────────

  void _addRoofBandSystem(List<BimEntity> entities) {
    final y = HouseDimensions.roofBandY;
    final w = HouseDimensions.buildingWidth;
    final d = HouseDimensions.buildingDepth;
    final bh = HouseDimensions.bandHeight;

    for (var i = 0; i < 18; i++) {
      final t = i / 17;
      entities.add(
        BimEntity(
          id: 'roof_band_rebar_$i',
          label: 'Roof Band Rebar',
          mesh: BimMesh.cylinder(radius: HouseDimensions.rebarRadius, height: bh * 0.75),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(0.15 + t * (w - 0.3), y + bh * 0.28, 0.12),
          explodeGroup: 3,
          minStage: 9,
          pickable: i == 0,
          componentId: 'roof_band',
          buildProgress: 0,
        ),
      );
    }

    entities.add(
      BimEntity(
        id: 'roof_band_formwork',
        label: 'Roof Band Formwork',
        mesh: BimMesh.box(
          width: w + 0.38,
          height: bh + 0.06,
          depth: d + 0.38,
          center: BimVec3(HouseDimensions.centerX, y + bh / 2, HouseDimensions.centerZ),
        ),
        color: const Color(0xFFDEB887),
        category: BimEntityCategory.formwork,
        minStage: 9,
        componentId: 'roof_band',
        buildProgress: 0,
      ),
    );

    entities.add(
      BimEntity(
        id: 'roof_band_concrete',
        label: 'Roof Band Concrete',
        mesh: BimMesh.box(
          width: w + HouseDimensions.wallThickness * 1.1,
          height: bh,
          depth: d + HouseDimensions.wallThickness * 1.1,
          center: BimVec3(HouseDimensions.centerX, y + bh / 2, HouseDimensions.centerZ),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 3,
        minStage: 9,
        pickable: true,
        componentId: 'roof_band',
        buildProgress: 0,
      ),
    );
  }

  // ── Roof: trusses, purlins, sheets, bracing ─────────────────────────────

  void _addRoofStructure(List<BimEntity> entities) {
    final eaveY = HouseDimensions.eaveY;
    final ridgeY = HouseDimensions.ridgeY;
    final w = HouseDimensions.buildingWidth;
    final d = HouseDimensions.buildingDepth;
    final slope = HouseDimensions.roofSlopeRadians;

    // Wall plate
    entities.add(
      BimEntity(
        id: 'wall_plate',
        label: 'Wall Plate',
        mesh: BimMesh.box(
          width: w + 0.1,
          height: 0.08,
          depth: d + 0.1,
          center: BimVec3(HouseDimensions.centerX, eaveY + 0.04, HouseDimensions.centerZ),
        ),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        minStage: 10,
        componentId: 'roof_structure',
        buildProgress: 0,
      ),
    );

    // Trusses at 2 m spacing along width
    final trussCount = (w / HouseDimensions.trussSpacing).ceil() + 1;
    for (var t = 0; t < trussCount; t++) {
      final x = t * HouseDimensions.trussSpacing;
      if (x > w) break;
      final trussId = 'truss_$t';

      // Bottom chord
      entities.add(
        BimEntity(
          id: '${trussId}_bottom',
          label: 'Truss Bottom Chord',
          mesh: BimMesh.box(width: 0.08, height: 0.06, depth: d + 0.2),
          color: const Color(0xFF92400E),
          category: BimEntityCategory.timber,
          position: BimVec3(x, eaveY + 0.08, -0.1),
          minStage: 10,
          pickable: t == 0,
          componentId: 'roof_truss',
          buildProgress: 0,
        ),
      );

      // Top chord (sloped rafters)
      final rafterLen = (d / 2 + 0.15) / math.cos(slope);
      entities.add(
        BimEntity(
          id: '${trussId}_rafter_l',
          label: 'Truss Rafter',
          mesh: BimMesh.box(width: 0.07, height: rafterLen, depth: 0.07),
          color: const Color(0xFFB45309),
          category: BimEntityCategory.timber,
          position: BimVec3(x, eaveY + (ridgeY - eaveY) / 2, d / 4),
          minStage: 10,
          componentId: 'roof_truss',
          buildProgress: 0,
        ),
      );
      entities.add(
        BimEntity(
          id: '${trussId}_rafter_r',
          label: 'Truss Rafter',
          mesh: BimMesh.box(width: 0.07, height: rafterLen, depth: 0.07),
          color: const Color(0xFFB45309),
          category: BimEntityCategory.timber,
          position: BimVec3(x, eaveY + (ridgeY - eaveY) / 2, d * 3 / 4),
          minStage: 10,
          componentId: 'roof_truss',
          buildProgress: 0,
        ),
      );

      // Web members
      entities.add(
        BimEntity(
          id: '${trussId}_web',
          label: 'Truss Web',
          mesh: BimMesh.box(width: 0.05, height: 0.5, depth: 0.05),
          color: const Color(0xFF78350F),
          category: BimEntityCategory.timber,
          position: BimVec3(x, eaveY + 0.35, HouseDimensions.centerZ),
          minStage: 10,
          componentId: 'roof_truss',
          buildProgress: 0,
        ),
      );
    }

    // Ridge beam
    entities.add(
      BimEntity(
        id: 'ridge_beam',
        label: 'Ridge Beam',
        mesh: BimMesh.box(width: w + 0.15, height: 0.1, depth: 0.1),
        color: const Color(0xFF92400E),
        category: BimEntityCategory.timber,
        position: BimVec3(0, ridgeY, HouseDimensions.centerZ),
        minStage: 10,
        componentId: 'roof_truss',
        buildProgress: 0,
      ),
    );

    // Purlins along slope
    final purlinCount = (d / HouseDimensions.purlinSpacing).ceil();
    for (var p = 0; p <= purlinCount; p++) {
      final z = p * HouseDimensions.purlinSpacing;
      if (z > d) break;
      final t = z / d;
      final py = eaveY + t * (ridgeY - eaveY) * 2 * (t < 0.5 ? t : 1 - t) * 2;
      entities.add(
        BimEntity(
          id: 'purlin_$p',
          label: 'Purlin',
          mesh: BimMesh.box(width: w + 0.2, height: 0.06, depth: 0.08),
          color: const Color(0xFF78350F),
          category: BimEntityCategory.timber,
          position: BimVec3(-0.1, py + 0.03, z),
          minStage: 10,
          componentId: 'roof_structure',
          buildProgress: 0,
        ),
      );
    }

    // Roof bracing
    entities.add(
      BimEntity(
        id: 'roof_bracing',
        label: 'Roof Bracing',
        mesh: BimMesh.box(width: 0.04, height: 0.04, depth: d * 0.8),
        color: const Color(0xFF64748B),
        category: BimEntityCategory.wire,
        position: BimVec3(HouseDimensions.centerX, ridgeY - 0.15, HouseDimensions.centerZ),
        minStage: 10,
        componentId: 'roof_structure',
        buildProgress: 0,
      ),
    );

    // Roof sheets — individual panels
    final sheetRows = purlinCount;
    for (var row = 0; row < sheetRows; row++) {
      for (var col = 0; col < 3; col++) {
        final z = row * HouseDimensions.purlinSpacing + 0.1;
        final x = col * (w / 3);
        final t = z / d;
        final sy = eaveY + t * (ridgeY - eaveY);
        entities.add(
          BimEntity(
            id: 'roof_sheet_${row}_$col',
            label: 'Roof Sheet',
            mesh: BimMesh.box(
              width: w / 3 + 0.05,
              height: HouseDimensions.sheetThickness,
              depth: HouseDimensions.purlinSpacing + 0.05,
            ),
            color: const Color(0xFF475569),
            category: BimEntityCategory.finishing,
            position: BimVec3(x, sy + 0.04, z),
            explodeGroup: 4,
            minStage: 11,
            pickable: row == 0 && col == 0,
            componentId: 'roof_cover',
            buildProgress: 0,
          ),
        );
      }
    }

    // Connection plates at truss bases
    for (var t = 0; t < trussCount; t++) {
      final x = t * HouseDimensions.trussSpacing;
      if (x > w) break;
      entities.add(
        BimEntity(
          id: 'truss_connector_$t',
          label: 'Truss Connection',
          mesh: BimMesh.box(width: 0.1, height: 0.04, depth: 0.1),
          color: const Color(0xFF64748B),
          category: BimEntityCategory.concrete,
          position: BimVec3(x, eaveY, 0.05),
          minStage: 10,
          componentId: 'roof_structure',
          buildProgress: 0,
        ),
      );
    }
  }

  // ── Openings & finishing ────────────────────────────────────────────────

  void _addOpenings(List<BimEntity> entities) {
    entities.add(
      BimEntity(
        id: 'door',
        label: 'Door',
        mesh: BimMesh.box(width: 1.0, height: 2.1, depth: 0.06),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.finishing,
        position: BimVec3(HouseDimensions.centerX - 0.5, HouseDimensions.wallBaseY, 0),
        explodeGroup: 4,
        minStage: 11,
        buildProgress: 0,
      ),
    );
    entities.add(
      BimEntity(
        id: 'window_1',
        label: 'Window',
        mesh: BimMesh.box(width: 1.2, height: 1.0, depth: 0.05),
        color: const Color(0xFF38BDF8),
        category: BimEntityCategory.finishing,
        position: BimVec3(
          HouseDimensions.buildingWidth - 0.08,
          HouseDimensions.wallBaseY + 1.2,
          HouseDimensions.centerZ - 0.6,
        ),
        explodeGroup: 4,
        minStage: 11,
        buildProgress: 0,
      ),
    );
    entities.add(
      BimEntity(
        id: 'landscape',
        label: 'Landscape',
        mesh: BimMesh.box(
          width: HouseDimensions.plotWidth,
          height: 0.06,
          depth: 1.2,
          center: BimVec3(
            HouseDimensions.plotWidth / 2,
            0.03,
            HouseDimensions.plotDepth - 0.6,
          ),
        ),
        color: const Color(0xFF22C55E),
        category: BimEntityCategory.finishing,
        minStage: 11,
        buildProgress: 0,
      ),
    );
  }

  // ── Load path annotations (visible in load-transfer view) ───────────────

  void _addLoadPathAnnotations(List<BimEntity> entities) {
    final cx = HouseDimensions.centerX;
    final cz = HouseDimensions.centerZ;

    const markers = <(String, String, double, double, double, Color)>[
      ('load_roof', 'Roof Load', cx, HouseDimensions.ridgeY, cz, Color(0xFFEF4444)),
      ('load_wall', 'Wall Load', cx, HouseDimensions.wallTopY * 0.65, cz, Color(0xFFF97316)),
      ('load_foundation', 'Foundation Reaction', cx, HouseDimensions.footingTopY / 2, cz, Color(0xFF22C55E)),
      ('load_soil', 'Soil Bearing', cx, HouseDimensions.trenchBottomY, cz, Color(0xFF16A34A)),
    ];

    for (final m in markers) {
      entities.add(
        BimEntity(
          id: m.$1,
          label: m.$2,
          mesh: BimMesh.box(width: 0.12, height: 0.12, depth: 0.12),
          color: m.$6,
          category: BimEntityCategory.annotation,
          position: BimVec3(m.$3, m.$4, m.$5),
          minStage: 0,
          opacity: 0.0,
        ),
      );
    }
  }

  void _addEquipment(List<BimEntity> entities) {
    entities.add(
      BimEntity(
        id: 'excavator',
        label: 'Excavator',
        mesh: BimMesh.box(width: 1.8, height: 1.2, depth: 2.5),
        color: const Color(0xFFFBBF24),
        category: BimEntityCategory.equipment,
        position: BimVec3(-1.5, 0.1, HouseDimensions.buildingDepth + 1.5),
        minStage: 2,
        buildProgress: 0,
      ),
    );
  }

  List<(double, double)> _buildingCorners({double inset = 0.12}) => [
        (inset, inset),
        (HouseDimensions.buildingWidth - inset, inset),
        (HouseDimensions.buildingWidth - inset, HouseDimensions.buildingDepth - inset),
        (inset, HouseDimensions.buildingDepth - inset),
      ];

  double _dist(double x1, double z1, double x2, double z2) {
    final dx = x2 - x1;
    final dz = z2 - z1;
    return math.sqrt(dx * dx + dz * dz);
  }
}

enum _WallAxis { front, back, left, right }
