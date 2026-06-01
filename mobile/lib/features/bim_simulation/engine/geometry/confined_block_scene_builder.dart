import 'dart:ui';

import '../bim_entity.dart';
import 'bim_mesh.dart';
import 'confined_block_dimensions.dart';
import '../math/bim_vec3.dart';

/// Procedural BIM scene — Model 04 Confined Concrete Block Masonry.
class ConfinedBlockSceneBuilder {
  List<BimEntity> build() {
    final e = <BimEntity>[];
    final d = ConfinedBlockDimensions;

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
        mesh: BimMesh.box(width: 1.5, height: 0.02, depth: 1.5),
        color: const Color(0xFFF97316),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.centerX - 0.75, 0.05, d.centerZ - 0.75),
        minStage: 0,
        opacity: 0.6,
        buildProgress: 0,
      ),
    );

    _settingOut(e, d);
    _excavation(e, d);
    _pcc(e, d);
    _footings(e, d);
    _plinthBeam(e, d);
    _tieColumnCages(e, d);
    _blockWalls(e, d);
    _tieColumnConcrete(e, d);
    _openings(e, d);
    _lintelBand(e, d);
    _tieBeams(e, d);
    _roofBand(e, d);
    _roofSlab(e, d);
    _finishing(e, d);
    _landscape(e, d);
    _comparisonGhost(e, d);

    return e;
  }

  void _settingOut(List<BimEntity> e, ConfinedBlockDimensions d) {
    for (var i = 0; i <= 6; i++) {
      e.add(
        BimEntity(
          id: 'grid_x_$i',
          label: 'Grid',
          mesh: BimMesh.box(width: 0.02, height: 0.01, depth: d.buildingDepth + 0.4),
          color: const Color(0xFF94A3B8),
          category: BimEntityCategory.grid,
          position: BimVec3(i * (d.buildingWidth / 6), 0.06, -0.2),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
    final tieColPositions = _tieColumnPositions(d);
    for (var i = 0; i < tieColPositions.length; i++) {
      final p = tieColPositions[i];
      e.add(
        BimEntity(
          id: 'tie_col_marker_$i',
          label: 'Tie-Column Position',
          mesh: BimMesh.box(
            width: d.tieColumnSize,
            height: 0.05,
            depth: d.tieColumnSize,
          ),
          color: const Color(0xFFDC2626),
          category: BimEntityCategory.survey,
          position: BimVec3(p.$1, 0.08, p.$2),
          minStage: 1,
          buildProgress: 0,
        ),
      );
    }
  }

  void _excavation(List<BimEntity> e, ConfinedBlockDimensions d) {
    e.add(
      BimEntity(
        id: 'excavation',
        label: 'Excavation',
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
        label: 'Bearing Soil',
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

  void _pcc(List<BimEntity> e, ConfinedBlockDimensions d) {
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

  void _footings(List<BimEntity> e, ConfinedBlockDimensions d) {
    final baseY = -d.trenchDepth + d.pccThickness;
    final positions = _tieColumnPositions(d);
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
          componentId: 'foundation',
          buildProgress: 0,
        ),
      );
    }
  }

  void _plinthBeam(List<BimEntity> e, ConfinedBlockDimensions d) {
    final y = -d.trenchDepth + d.pccThickness + d.footingDepth;
    e.add(
      BimEntity(
        id: 'plinth_formwork',
        label: 'Plinth Formwork',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.4,
          height: d.plinthBeamHeight + 0.08,
          depth: d.buildingDepth + 0.4,
          center: BimVec3(d.centerX, y + d.plinthBeamHeight / 2, d.centerZ),
        ),
        color: const Color(0xFFDEB887),
        category: BimEntityCategory.formwork,
        minStage: 5,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'plinth_rebar',
        label: 'Plinth Rebar',
        mesh: BimMesh.box(
          width: d.buildingWidth,
          height: d.plinthBeamHeight * 0.6,
          depth: d.buildingDepth,
          center: BimVec3(d.centerX, y + d.plinthBeamHeight * 0.3, d.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 5,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'plinth_beam',
        label: 'Plinth Beam',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.tieColumnSize,
          height: d.plinthBeamHeight,
          depth: d.buildingDepth + d.tieColumnSize,
          center: BimVec3(d.centerX, y + d.plinthBeamHeight / 2, d.centerZ),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 2,
        minStage: 5,
        pickable: true,
        componentId: 'tie_beam',
        buildProgress: 0,
      ),
    );
  }

  void _tieColumnCages(List<BimEntity> e, ConfinedBlockDimensions d) {
    final baseY = -d.trenchDepth + d.pccThickness + d.footingDepth + d.plinthBeamHeight;
    final positions = _tieColumnPositions(d);
    for (var i = 0; i < positions.length; i++) {
      final p = positions[i];
      e.add(
        BimEntity(
          id: 'tie_cage_$i',
          label: 'Tie-Column Cage',
          mesh: BimMesh.box(
            width: d.tieColumnSize * 0.85,
            height: d.wallHeight,
            depth: d.tieColumnSize * 0.85,
          ),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(p.$1, baseY, p.$2),
          explodeGroup: 2,
          minStage: 6,
          pickable: i == 0,
          componentId: 'tie_column',
          buildProgress: 0,
        ),
      );
    }
  }

  void _blockWalls(List<BimEntity> e, ConfinedBlockDimensions d) {
    final baseY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.plinthBeamHeight;
    var blockIdx = 0;
    for (var course = 0; course < d.courses; course++) {
      final y = baseY + course * d.blockHeight;
      for (var bx = 0; bx < (d.buildingWidth / d.blockLength).floor(); bx++) {
        for (var bz = 0; bz < (d.buildingDepth / d.blockDepth).floor(); bz++) {
          final x = bx * d.blockLength;
          final z = bz * d.blockDepth;
          if (_isTieColumnCell(x, z, d)) continue;
          e.add(
            BimEntity(
              id: 'block_$blockIdx',
              label: 'Concrete Block',
              mesh: BimMesh.box(
                width: d.blockLength * 0.96,
                height: d.blockHeight,
                depth: d.blockDepth * 0.96,
              ),
              color: Color.lerp(
                const Color(0xFF9CA3AF),
                const Color(0xFF6B7280),
                (course % 3) / 3,
              )!,
              category: BimEntityCategory.masonry,
              position: BimVec3(x, y, z),
              explodeGroup: 3,
              minStage: 7,
              pickable: blockIdx == 0,
              componentId: 'concrete_block_wall',
              buildProgress: 0,
            ),
          );
          blockIdx++;
        }
      }
    }
  }

  void _tieColumnConcrete(List<BimEntity> e, ConfinedBlockDimensions d) {
    final baseY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.plinthBeamHeight;
    final positions = _tieColumnPositions(d);
    for (var i = 0; i < positions.length; i++) {
      final p = positions[i];
      e.add(
        BimEntity(
          id: 'tie_concrete_$i',
          label: 'Tie-Column Concrete',
          mesh: BimMesh.box(
            width: d.tieColumnSize,
            height: d.wallHeight,
            depth: d.tieColumnSize,
          ),
          color: const Color(0xFF6B7280),
          category: BimEntityCategory.concrete,
          position: BimVec3(p.$1, baseY, p.$2),
          explodeGroup: 2,
          minStage: 8,
          pickable: i == 0,
          componentId: 'tie_column',
          buildProgress: 0,
        ),
      );
      e.add(
        BimEntity(
          id: 'tie_formwork_$i',
          label: 'Column Formwork',
          mesh: BimMesh.box(
            width: d.tieColumnSize + 0.04,
            height: d.wallHeight,
            depth: d.tieColumnSize + 0.04,
          ),
          color: const Color(0xFFDEB887),
          category: BimEntityCategory.formwork,
          position: BimVec3(p.$1 - 0.02, baseY, p.$2 - 0.02),
          minStage: 8,
          buildProgress: 0,
        ),
      );
    }
  }

  void _openings(List<BimEntity> e, ConfinedBlockDimensions d) {
    final baseY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.plinthBeamHeight;
    e.add(
      BimEntity(
        id: 'door_frame',
        label: 'Door Frame',
        mesh: BimMesh.box(width: 1.0, height: 2.1, depth: 0.1),
        color: const Color(0xFF78350F),
        category: BimEntityCategory.finishing,
        position: BimVec3(d.centerX - 0.5, baseY, 0),
        minStage: 9,
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
        position: BimVec3(d.buildingWidth - 0.12, baseY + 1.0, d.centerZ),
        minStage: 9,
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
        position: BimVec3(d.buildingWidth - 0.1, baseY + 2.0, d.centerZ),
        minStage: 9,
        buildProgress: 0,
      ),
    );
  }

  void _lintelBand(List<BimEntity> e, ConfinedBlockDimensions d) {
    final wallTop = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.plinthBeamHeight +
        d.courses * d.blockHeight;
    e.add(
      BimEntity(
        id: 'lintel_rebar',
        label: 'Lintel Rebar',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.3,
          height: d.bandHeight * 0.5,
          depth: d.buildingDepth + 0.3,
          center: BimVec3(d.centerX, wallTop + d.bandHeight * 0.25, d.centerZ),
        ),
        color: const Color(0xFFEA580C),
        category: BimEntityCategory.rebar,
        minStage: 10,
        buildProgress: 0,
      ),
    );
    e.add(
      BimEntity(
        id: 'lintel_band',
        label: 'Lintel Band',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.tieColumnSize,
          height: d.bandHeight,
          depth: d.buildingDepth + d.tieColumnSize,
          center: BimVec3(d.centerX, wallTop + d.bandHeight / 2, d.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 3,
        minStage: 10,
        pickable: true,
        componentId: 'lintel_band',
        buildProgress: 0,
      ),
    );
  }

  void _tieBeams(List<BimEntity> e, ConfinedBlockDimensions d) {
    final y = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.plinthBeamHeight +
        d.courses * d.blockHeight +
        d.bandHeight;
    e.add(
      BimEntity(
        id: 'tie_beam_ring',
        label: 'Tie Beam System',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.tieColumnSize * 1.2,
          height: d.bandHeight,
          depth: d.buildingDepth + d.tieColumnSize * 1.2,
          center: BimVec3(d.centerX, y + d.bandHeight / 2, d.centerZ),
        ),
        color: const Color(0xFF6B7280),
        category: BimEntityCategory.concrete,
        explodeGroup: 3,
        minStage: 11,
        pickable: true,
        componentId: 'tie_beam',
        buildProgress: 0,
      ),
    );
  }

  void _roofBand(List<BimEntity> e, ConfinedBlockDimensions d) {
    final y = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.plinthBeamHeight +
        d.courses * d.blockHeight +
        d.bandHeight * 2;
    e.add(
      BimEntity(
        id: 'roof_band',
        label: 'Roof Band',
        mesh: BimMesh.box(
          width: d.buildingWidth + d.tieColumnSize * 1.3,
          height: d.bandHeight,
          depth: d.buildingDepth + d.tieColumnSize * 1.3,
          center: BimVec3(d.centerX, y + d.bandHeight / 2, d.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 4,
        minStage: 12,
        pickable: true,
        componentId: 'roof_band',
        buildProgress: 0,
      ),
    );
  }

  void _roofSlab(List<BimEntity> e, ConfinedBlockDimensions d) {
    final slabY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.plinthBeamHeight +
        d.courses * d.blockHeight +
        d.bandHeight * 3;
    e.add(
      BimEntity(
        id: 'slab_formwork',
        label: 'Slab Formwork',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.4,
          height: 0.05,
          depth: d.buildingDepth + 0.4,
          center: BimVec3(d.centerX, slabY, d.centerZ),
        ),
        color: const Color(0xFFDEB887),
        category: BimEntityCategory.formwork,
        minStage: 13,
        buildProgress: 0,
      ),
    );
    for (var i = 0; i < 6; i++) {
      e.add(
        BimEntity(
          id: 'slab_rebar_$i',
          label: 'Slab Reinforcement',
          mesh: BimMesh.cylinder(radius: d.rebarRadius, height: d.buildingWidth),
          color: const Color(0xFFEA580C),
          category: BimEntityCategory.rebar,
          position: BimVec3(-0.1, slabY + 0.03, i * (d.buildingDepth / 5)),
          explodeGroup: 4,
          minStage: 13,
          pickable: i == 0,
          componentId: 'roof_slab',
          buildProgress: 0,
        ),
      );
    }
    e.add(
      BimEntity(
        id: 'roof_slab',
        label: 'RCC Roof Slab',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.35,
          height: d.slabThickness,
          depth: d.buildingDepth + 0.35,
          center: BimVec3(d.centerX, slabY + d.slabThickness / 2 + 0.05, d.centerZ),
        ),
        color: const Color(0xFF9CA3AF),
        category: BimEntityCategory.concrete,
        explodeGroup: 4,
        minStage: 13,
        componentId: 'roof_slab',
        buildProgress: 0,
      ),
    );
  }

  void _finishing(List<BimEntity> e, ConfinedBlockDimensions d) {
    final baseY = -d.trenchDepth +
        d.pccThickness +
        d.footingDepth +
        d.plinthBeamHeight;
    e.add(
      BimEntity(
        id: 'plaster',
        label: 'Plaster',
        mesh: BimMesh.box(
          width: d.buildingWidth + 0.1,
          height: d.wallHeight,
          depth: d.buildingDepth + 0.1,
          center: BimVec3(d.centerX, baseY + d.wallHeight / 2, d.centerZ),
        ),
        color: const Color(0xFFE7E5E4),
        category: BimEntityCategory.finishing,
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

  void _landscape(List<BimEntity> e, ConfinedBlockDimensions d) {
    for (var i = 0; i < 3; i++) {
      e.add(
        BimEntity(
          id: 'landscape_$i',
          label: 'Landscape',
          mesh: BimMesh.box(width: 0.8, height: 0.12, depth: 0.8),
          color: const Color(0xFF22C55E),
          category: BimEntityCategory.finishing,
          position: BimVec3(d.plotWidth - 1.5, 0.06, 2 + i * 2),
          minStage: 15,
          buildProgress: 0,
        ),
      );
    }
  }

  void _comparisonGhost(List<BimEntity> e, ConfinedBlockDimensions d) {
    e.add(
      BimEntity(
        id: 'unconfined_ghost',
        label: 'Unconfined Masonry (comparison)',
        mesh: BimMesh.box(width: 1.2, height: d.wallHeight, depth: 0.2),
        color: const Color(0xFFEF4444),
        category: BimEntityCategory.annotation,
        position: BimVec3(d.buildingWidth + 0.8, 0.5, 1),
        minStage: 8,
        opacity: 0.45,
        buildProgress: 0,
      ),
    );
  }

  List<(double, double)> _tieColumnPositions(ConfinedBlockDimensions d) {
    return [
      (0.0, 0.0),
      (d.buildingWidth - d.tieColumnSize, 0.0),
      (d.buildingWidth - d.tieColumnSize, d.buildingDepth - d.tieColumnSize),
      (0.0, d.buildingDepth - d.tieColumnSize),
      (d.centerX - d.tieColumnSize / 2, 0.0),
      (d.centerX - d.tieColumnSize / 2, d.buildingDepth - d.tieColumnSize),
      (0.0, d.centerZ - d.tieColumnSize / 2),
      (d.buildingWidth - d.tieColumnSize, d.centerZ - d.tieColumnSize / 2),
    ];
  }

  bool _isTieColumnCell(double x, double z, ConfinedBlockDimensions d) {
    const tol = 0.35;
    for (final p in _tieColumnPositions(d)) {
      if ((x - p.$1).abs() < tol && (z - p.$2).abs() < tol) return true;
    }
    return false;
  }
}
